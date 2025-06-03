import joblib
import numpy as np

def carregarModelo(model_filename: str = "model.pkl"):
    try:
        model = joblib.load(model_filename)
        return model
    except FileNotFoundError:
        print(f"Erro: O arquivo do modelo '{model_filename}' não foi encontrado. Por favor, treine o modelo primeiro.")
        return None

def predicaoCrise(processed_data: list, model) -> int:

    if model is None:
        return -1 # Indica erro ou modelo não carregado

    # Converte a lista de características para um array NumPy 
    data_np = np.array([processed_data])
    prediction = model.predict(data_np)
    return int(prediction[0])

def probabilidadeCrise(processed_data: list, model) -> float:
  
    if model is None:
        return -1.0 # Indica erro ou modelo não carregado

    data_np = np.array([processed_data])
    #retorna as probabilidades para todas as classes.
    probabilities = model.predict_proba(data_np)
    return float(probabilities[0][1]) # Pega a probabilidade da classe 1 (crise)