import joblib
import numpy as np

def prever_crise(dados_preprocessados):

    modelo = joblib.load("modelo.pkl")
    dados_np = np.array([dados_preprocessados])
    resultado = modelo.predict(dados_np)
    return resultado[0]
