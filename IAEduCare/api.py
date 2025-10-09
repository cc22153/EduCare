import os
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import numpy as np

# Importa as funções de préprocessamento
from dados.preprocessamento import preprocessaDados
# As funções de predição (predicaoCrise, probabilidadeCrise) não são mais importadas,
# pois faremos a chamada diretamente no objeto 'model'.

# Inicializa
app = FastAPI()

# Caminho para o arquivo do modelo
MODEL_FILE = os.path.join("modelo","model.pkl")

# Variável para armazenar o modelo carregado
model = None

# Validação de Dados de Entrada 
# CLASSE DataInput ATUALIZADA com o campo 'motivo'
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
    motivo: str # NOVO CAMPO OBRIGATÓRIO
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
@app.post("/predict")
async def predict_crisis_endpoint(data: DataInput):

    if model is None:
        raise HTTPException(status_code=500, detail="O modelo de IA não está carregado.")

    try:
        # 1. Converte o Pydantic model para um dicionário Python
        raw_data = data.dict()
        
        # 2. Pré-processa os dados. (Retorna uma lista 1D, atribuída a 'processed_data')
        processed_data = preprocessaDados(raw_data)
        
        # 3. TRANSFORMAÇÃO: Força o achatamento (flatten) e depois o reshape 2D (1 linha, N colunas).
        data_to_predict = np.array(processed_data).flatten().reshape(1, -1)
        
        # LOG DE DIAGNÓSTICO: Verificamos o formato antes de passar para o modelo
        print(f"DEBUG: Shape do array de predição antes da chamada: {data_to_predict.shape}")
        
        # 4. CHAMA O MODELO DIRETAMENTE para evitar a dimensão 3D
        
        # Predição (model.predict retorna [[0]] ou [[1]]. O [0] no final pega o valor escalar.)
        prediction_result = model.predict(data_to_predict)[0]
        
        # Probabilidade (model.predict_proba retorna [[prob_classe_0, prob_classe_1]]. O [0][1] pega a probabilidade da classe 1 [crise].)
        probability_result = model.predict_proba(data_to_predict)[0][1] 

        return {
            "prediction": int(prediction_result),
            "probability": float(probability_result),
            "is_crisis": bool(prediction_result)
        }
    except Exception as e:
        # Imprime o erro real no console para debug
        print(f"Erro detalhado no processamento: {e}")
        # Retorna o erro ao cliente
        raise HTTPException(status_code=400, detail=f"Erro no processamento dos dados: {e}")

# uvicorn api:app --reload   para rodar a api -- cntrl + C
# http://127.0.0.1:8000/docs rota para testar no insomia



