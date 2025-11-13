# main.py
from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from typing import List, Literal, Optional
from uuid import UUID
import os
import requests
import numpy as np
from datetime import datetime, timedelta
from dotenv import load_dotenv

load_dotenv()

# === Supabase Config ===
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError("Defina SUPABASE_URL e SUPABASE_KEY nas variáveis de ambiente")

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json"
}

app = FastAPI(title="IA de Monitoramento - TCC")

# === MODELOS ===
class DataIn(BaseModel):
    aluno_id: str
    timestamp: str
    bpm: List[int]
    accel: List[List[float]]

class AnalysisOut(BaseModel):
    status: Literal["normal", "alerta"]
    risco_crise: float
    mensagem: str
    detalhes: dict

# === SUPABASE HELPERS ===
def supabase_get(table: str, select="*", params=None):
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    q = {"select": select}
    if params:
        q.update(params)
    r = requests.get(url, headers=HEADERS, params=q)
    if r.status_code >= 400:
        raise RuntimeError(f"GET {table} error: {r.text}")
    return r.json()

def supabase_insert(table: str, payload: dict):
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    r = requests.post(url, headers=HEADERS, json=payload)
    if r.status_code >= 400:
        raise RuntimeError(f"INSERT {table} error: {r.text}")
    return r.json()

# === UTILS ===
def parse_iso(ts: str):
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except Exception:
        return datetime.fromisoformat(ts)

# === CONTEXTO ===
def get_context_for_aluno(aluno_id: str, ts_iso: str):
    ts = parse_iso(ts_iso)

    # rotina aproximada (fallback se não houver data_hora precisa)
    rotina = []
    try:
        day_start = datetime(ts.year, ts.month, ts.day).isoformat()
        rotina = supabase_get("rotina", params={
            "id_aluno": f"eq.{aluno_id}",
            "data_hora": f"gte.{day_start}"
        })
    except:
        rotina = []

    # estado emocional
    estado = []
    try:
        estado = supabase_get("estado_emocional", params={
            "id_aluno": f"eq.{aluno_id}",
            "order": "enviado_em.desc",
            "limit": "1"
        })
    except:
        pass

    # diários
    diarios = []
    try:
        diarios = supabase_get("diario", params={
            "id_aluno": f"eq.{aluno_id}",
            "order": "criado_em.desc",
            "limit": "5"
        })
    except:
        pass

    return {
        "rotina": rotina,
        "estado": estado[0] if estado else None,
        "diarios": diarios
    }

# === ANÁLISE ===
def analyze(payload: DataIn, context: dict):
    bpm = np.array(payload.bpm, dtype=float)
    accel = np.array(payload.accel, dtype=float)

    bpm_mean = float(np.mean(bpm))
    bpm_max = int(np.max(bpm))
    bpm_std = float(np.std(bpm))
    picos = [int(x) for x in bpm if x > bpm_mean + 20][:10]

    mov = np.linalg.norm(accel, axis=1)
    mov_mean = float(np.mean(mov))
    mov_max = float(np.max(mov))

    risco = 0.0
    mensagens = []

    variacao = bpm_max - bpm_mean

    if variacao > 25 and mov_mean > 1.8:
        risco = 0.9
        mensagens.append("BPM alto + movimento extremo")
    elif variacao > 25:
        risco = 0.8
        mensagens.append("BPM alto sem movimento proporcional")
    elif mov_mean > 2.5:
        risco = 0.5
        mensagens.append("Movimento muito elevado")

    if bpm_std > 8:
        risco = max(risco, 0.3)

    negativos = len([d for d in context.get("diarios", []) if d.get("humor_geral") == "ruim"])
    if negativos >= 2:
        risco = max(risco, 0.5)
        mensagens.append("Humor recente negativo")

    mensagem = " ; ".join(mensagens) if mensagens else "Dentro do esperado."

    return {
        "status": "alerta" if risco >= 0.5 else "normal",
        "risco": risco,
        "mensagem": mensagem,
        "detalhes": {
            "bpm_medio": round(bpm_mean, 2),
            "bpm_max": bpm_max,
            "bpm_std": round(bpm_std, 2),
            "bpm_picos": picos,
            "mov_mean": round(mov_mean, 3),
            "mov_max": round(mov_max, 3),
        }
    }

# === ENDPOINT ===
@app.post("/analisar", response_model=AnalysisOut)
def analisar(payload: DataIn):
    # ✅ valida UUID antes de qualquer coisa
    try:
        UUID(payload.aluno_id)
    except:
        raise HTTPException(400, "aluno_id inválido: deve ser UUID")

    context = get_context_for_aluno(payload.aluno_id, payload.timestamp)
    result = analyze(payload, context)

    entry = {
        "aluno_id": payload.aluno_id,
        "timestamp": payload.timestamp,
        "status": result["status"],
        "risco": float(result["risco"]),
        "mensagem": result["mensagem"],
        "detalhes": result["detalhes"]
    }

    # ✅ Save analysis safely
    try:
        supabase_insert("analise", entry)
    except Exception as e:
        print("Erro ao salvar analise:", e)

    # ✅ Create notification only if warning
    if result["risco"] >= 0.5:
        try:
            supabase_insert("notificacoes", {
                "titulo": "Possível crise detectada",
                "tipo": "crise",
                "id_aluno": payload.aluno_id,
                "visualizada": False,
            })
        except Exception as e:
            print("Erro ao salvar notificação:", e)

        import csv
        import os

        # --- 4) Salvar dados em CSV ---
        os.makedirs("data", exist_ok=True)
        csv_path = f"data/{payload.aluno_id}.csv"

        bpm_list = payload.bpm
        acc_list = payload.accel

        # Garante que accel terá mesmo tamanho (se não, preenche com zeros)
        min_len = min(len(bpm_list), len(acc_list))
        bpm_list = bpm_list[:min_len]
        acc_list = acc_list[:min_len]

        file_exists = os.path.isfile(csv_path)

        with open(csv_path, "a", newline="") as csvfile:
            writer = csv.writer(csvfile)

            # Cabeçalho, se arquivo criado na hora
            if not file_exists:
                writer.writerow(["timestamp", "bpm", "accel_x", "accel_y", "accel_z"])

            for i in range(min_len):
                writer.writerow([
                    payload.timestamp,
                    bpm_list[i],
                    acc_list[i][0],
                    acc_list[i][1],
                    acc_list[i][2],
                ])

        print(f"✅ Dados CSV salvos em: {csv_path}")


    return AnalysisOut(
        status=result["status"],
        risco_crise=float(result["risco"]),
        mensagem=result["mensagem"],
        detalhes=result["detalhes"]
    )

@app.get("/")
def root():
    return {"ok": True}
