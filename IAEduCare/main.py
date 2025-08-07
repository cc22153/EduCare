import os
import sys
from dados.simulador import generate_simulated_data
from dados.preprocessamento import preprocessaDados
from modelo.treinamento import treinaModeloESalva
from modelo.preditiva import carregarModelo, predicaoCrise, probabilidadeCrise

# Caminho para o arquivo do modelo
MODEL_FILE = "model.pkl"

def run_prediction_simulation(model):
    """
    Função para simular o processo de predição em tempo real.
    """
    print("\nSimulando predição em tempo real")

    # Simular dados de um aluno em estado normal
    print("\nSimulando dados de um aluno em estado NORMAL:")
    normal_data_raw = generate_simulated_data(scenario_type="normal")
    processed_normal_data = preprocessaDados(normal_data_raw)

    prediction_normal = predicaoCrise(processed_normal_data, model)
    probability_normal = probabilidadeCrise(processed_normal_data, model)

    print(f"Dados brutos simulados (normal): {normal_data_raw}")
    print(f"Vetor pré-processado (normal): {processed_normal_data}")
    print(f"Previsão de crise (0=Normal, 1=Crise): {prediction_normal}")
    print(f"Probabilidade de crise: {probability_normal:.2f}")

    if prediction_normal == 0:
        print("RESULTADO: O aluno está se sentindo normal.")
    else:
        # Nota: Seu simulador pode gerar cenários de crise leves mesmo em "normal",
        # então um Falso Positivo aqui pode ser um sinal de aprendizado do modelo.
        print("RESULTADO: ATENÇÃO! Possível crise detectada (Normal - Falso Positivo)")

    # Simula dados de um aluno em POTENCIAL crise
    print("\nSimulando dados de um aluno em POTENCIAL CRISE:")
    crisis_data_raw = generate_simulated_data(scenario_type="crise")
    processed_crisis_data = preprocessaDados(crisis_data_raw)

    prediction_crisis = predicaoCrise(processed_crisis_data, model)
    probability_crisis = probabilidadeCrise(processed_crisis_data, model)

    print(f"Dados brutos simulados (crise): {crisis_data_raw}")
    print(f"Vetor pré-processado (crise): {processed_crisis_data}")
    print(f"Previsão de crise (0=Normal, 1=Crise): {prediction_crisis}")
    print(f"Probabilidade de crise: {probability_crisis:.2f}")

    if prediction_crisis == 1:
        print("RESULTADO: ATENÇÃO! Possível crise detectada.")
    else:
        print("RESULTADO: O aluno está se sentindo normal (Crise - Falso Negativo).")

if __name__ == "__main__":
    # Verifica argumentos da linha de comando para decidir a ação
    # 'train' força o re-treinamento do modelo
    if len(sys.argv) > 1 and sys.argv[1] == "train":
        print("Argumento 'train' detectado. Iniciando o treinamento do modelo.")
        treinaModeloESalva(MODEL_FILE)
    
    # Se o modelo não existir e o comando 'train' não foi usado, treina
    elif not os.path.exists(MODEL_FILE):
        print(f"Modelo '{MODEL_FILE}' não encontrado. Treinando novo modelo...")
        treinaModeloESalva(MODEL_FILE)
    
    # Em todos os outros casos, apenas carrega o modelo existente
    else:
        print(f"Modelo '{MODEL_FILE}' já existe. Carregando para simulação...")

    # Carrega o modelo treinado (ou o novo)
    model = carregarModelo(MODEL_FILE)
    if model is None:
        print("Não foi possível carregar o modelo. Encerrando.")
        exit()

    # Executa a simulação de predição
    run_prediction_simulation(model)