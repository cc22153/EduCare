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
    
    print("-" * 50)
    
    # Simula dados completamente aleatórios (cenário misto)
    print("\nSimulando dados de um aluno com cenário MISTO (ALEATÓRIO):")
    mixed_data_raw = generate_simulated_data(scenario_type="misto")
    processed_mixed_data = preprocessaDados(mixed_data_raw)

    prediction_mixed = predicaoCrise(processed_mixed_data, model)
    probability_mixed = probabilidadeCrise(processed_mixed_data, model)

    print(f"Dados brutos simulados (misto): {mixed_data_raw}")
    print(f"Vetor pré-processado (misto): {processed_mixed_data}")
    print(f"Previsão de crise (0=Normal, 1=Crise): {prediction_mixed}")
    print(f"Probabilidade de crise: {probability_mixed:.2f}")

    if prediction_mixed == 1:
        print("RESULTADO: A IA detectou uma possível crise neste cenário ambíguo.")
    else:
        print("RESULTADO: A IA avalia que o cenário ambíguo não representa uma crise.")


"""
simulando dados de um aluno em estado NORMAL:
Dados brutos simulados (normal): {'frequencia_cardiaca_media': 61, 'nivel_agitacao_media': 0.1619596404485133, 'sentimento_hoje': 'Normal', 'gostou_dia': 'Sim', 'comunicou_aluno': 'Sim', 'incomodado_aluno': [], 'fez_o_que_queria': 'Sim', 'estado_emocional_aluno': 'Bem', 'dor_fisica': 'Não', 'quer_ficar_sozinho': 'Não', 'precisa_ajuda': 'Não', 'humor_aluno_edu': 'Neutro', 'participacao_atividades': 'Sim', 'interacao_colegas': 'Excelente', 'crise_ocorrida_edu': 'Não', 'comunicacao_verbal_edu': 'Com facilidade', 'avaliacao_semanal_edu': 'Bom', 'evolucao_observada': ['Socialização', 'Autonomia (fazer tarefas sozinho)'], 'retrocesso_edu': 'Não', 'lidou_mudanca_rotina': 'Muito bem', 'adaptacao_necessaria': 'Não', 'is_crisis': 0, 'idade_aluno': 12, 'sexo_aluno': 'Masculino', 'nivel_tea': 'Severo', 'comunicacao_verbal_resp': 'Não verbal', 'interacao_social_escala': 2, 'rotina_estruturada': 'Parcialmente', 'sensibilidades': [], 'frequencia_crises': 'Diariamente'}
Vetor pré-processado (normal): [61, 0.1619596404485133, 12, 0, 2, 0, 2, 1, 0, 0, 0, 0, 2, 1, 1, 1, 0, 0, 0, 1, 4, 0, 0, 0, 1, 1, 3, 0, 0, 2, 0, 1, 0, 1, 0, 3, 0]
Previsão de crise (0=Normal, 1=Crise): 0
Probabilidade de crise: 0.00
RESULTADO: O aluno está se sentindo normal.

Simulando dados de um aluno em POTENCIAL CRISE:
Dados brutos simulados (crise): {'frequencia_cardiaca_media': 158, 'nivel_agitacao_media': 0.8307496400502145, 'sentimento_hoje': 'Bravo', 'gostou_dia': 'Não', 'comunicou_aluno': 'Sim', 'incomodado_aluno': ['Barulho alto', 'Pessoas'], 'fez_o_que_queria': 'Não', 'estado_emocional_aluno': 'Bravo', 'dor_fisica': 'Não', 'quer_ficar_sozinho': 'Sim', 'precisa_ajuda': 'Sim', 'humor_aluno_edu': 'Irritado', 'participacao_atividades': 'Não', 'interacao_colegas': 'Regular', 'crise_ocorrida_edu': 'Sim', 'comunicacao_verbal_edu': 'Com alguma dificuldade', 'avaliacao_semanal_edu': 'Difícil', 'evolucao_observada': [], 'retrocesso_edu': 'Sim', 'lidou_mudanca_rotina': 'Com grande dificuldade', 'adaptacao_necessaria': 'Sim', 'is_crisis': 1, 'idade_aluno': 15, 'sexo_aluno': 'Masculino', 'nivel_tea': 'Severo', 'comunicacao_verbal_resp': 'Não verbal', 'interacao_social_escala': 2, 'rotina_estruturada': 'Não', 'sensibilidades': ['Luzes fortes'], 'frequencia_crises': 'Raramente'}
Vetor pré-processado (crise): [158, 0.8307496400502145, 15, 0, 2, 0, 2, 2, 0, 1, 0, 0, 0, 3, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 3, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1]
Previsão de crise (0=Normal, 1=Crise): 1
Probabilidade de crise: 1.00
RESULTADO: ATENÇÃO! Possível crise detectada.
(venv) LAPA10:IAEduCare u22153$ 
"""