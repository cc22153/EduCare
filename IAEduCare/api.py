import os
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import numpy as np

# Importa as funções de préprocessamento e predição
from dados.preprocessamento import preprocessaDados
from modelo.preditiva import predicaoCrise, probabilidadeCrise

# Inicializa
app = FastAPI()

# Caminho para o arquivo do modelo
MODEL_FILE = os.path.join("modelo","model.pkl")

# Variável para armazenar o modelo carregado
model = None

# Validação de Dados de Entrada 
# garante que a API receba os dados no formato correto.
# O nome e o tipo das chaves devem corresponder ao  dicionário de dados 
class DataInput(BaseModel):
    frequencia_cardiaca_media: int
    nivel_agitacao_media: float
    idade_aluno: int
    sexo_aluno: str
    nivel_tea: str
    comunicacao_verbal_resp: str
    interacao_social_escala: int
    rotina_estruturada: str
    sensibilidades: list
    frequencia_crises: str
    sentimento_hoje: str
    gostou_dia: str
    comunicou_aluno: str
    incomodado_aluno: list
    fez_o_que_queria: str
    estado_emocional_aluno: str
    dor_fisica: str
    quer_ficar_sozinho: str
    precisa_ajuda: str
    humor_aluno_edu: str
    participacao_atividades: str
    interacao_colegas: str
    crise_ocorrida_edu: str
    comunicacao_verbal_edu: str
    avaliacao_semanal_edu: str
    evolucao_observada: list
    retrocesso_edu: str
    lidou_mudanca_rotina: str
    adaptacao_necessaria: str

# Inicialização da Aplicação 
# Essa função é executada uma única vez quando a API inicia
@app.on_event("startup")
async def load_model():
    global model
    try:
        model = joblib.load(MODEL_FILE)
        print("Modelo de IA carregado com sucesso para a API.")
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Erro: O arquivo do modelo 'model.pkl' não foi encontrado.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao carregar o modelo: {e}")

@app.get("/")
def read_root():
    return {"message": "API de Previsão de Crise do EduCare rodando com sucesso!"}

# Rota da API para Predição 
async def predict_crisis_endpoint(data: DataInput):

    #Recebe os dados brutos de um usuário e retorna a probabilidade de crise

    if model is None:
        raise HTTPException(status_code=500, detail="O modelo de IA não está carregado.")

    try:
        # Converte o Pydantic model para um dicionário Python
        raw_data = data.dict()
        
        # Pré-processa os dados para o formato que a IA entende
        processed_data = preprocessaDados(raw_data)
        processed_data = np.array(processed_data).reshape(1, -1) #Formato necessário para a predição

        # Faz a predição e calcula a probabilidade
        prediction = predicaoCrise(processed_data, model)
        probability = probabilidadeCrise(processed_data, model)

        return {
            "prediction": int(prediction),
            "probability": float(probability),
            "is_crisis": bool(prediction)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Erro no processamento dos dados: {e}")

# uvicorn api:app --reload   para rodar a api -- cntrl + C
# http://127.0.0.1:8000/docs rota para testar no insomia



