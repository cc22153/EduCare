import numpy as np

def preprocess_data(data_input: dict) -> list:
    """
    Args:
        data_input (dict): Dicionário contendo dados dos questionários e sensores.

    Returns:
        list: Um vetor numérico das características.
    """

    #  variáveis categóricas - 
    SEX_MAP = {"Masculino": 0, "Feminino": 1, "Prefere não informar": 2}
    SPECTRUM_LEVEL_MAP = {"Leve": 0, "Moderado": 1, "Severo": 2, "Não sei informar": 3}
    ROUTINE_MAP = {"Sim": 0, "Parcialmente": 1, "Não": 2}
    CRISIS_FREQ_MAP = {"Raramente": 0, "Algumas vezes por semana": 1, "Diariamente": 2}

    # Aluno - Diário
    FEELING_MAP = {"Feliz": 0, "Normal": 1, "Triste": 2, "Bravo": 3}
    LIKED_DAY_MAP = {"Sim": 1, "Não": 0}
    COMMUNICATED_MAP = {"Sim": 1, "Não": 0}
    DID_WHAT_WANTED_MAP = {"Sim": 1, "Não": 0, "Um pouco": 0.5} 
    
    # Aluno - Estado Emocional
    EMOTIONAL_STATE_MAP = {"Bravo": 0, "Triste": 1, "Medo": 2, "Cansado": 3, "Bem": 4}
    PHYSICAL_PAIN_MAP = {"Sim": 1, "Não": 0}
    WANT_TO_BE_ALONE_MAP = {"Sim": 1, "Não": 0}
    NEED_HELP_MAP = {"Sim": 1, "Não": 0}

    # Educador - Perguntas Diárias
    EDUCATOR_MOOD_MAP = {"Feliz": 0, "Neutro": 1, "Triste": 2, "Irritado": 3}
    PARTICIPATION_MAP = {"Sim": 1, "👎 Não": 0, "Parcialmente": 0.5} 
    INTERACTION_MAP = {"Excelente": 3, "Boa": 2, "Regular": 1, "Difícil": 0}
    CRISIS_OCCURRED_MAP = {"Sim": 1, "Não": 0}
    COMMUNICATION_EDU_MAP = {"Com facilidade": 0, "Com alguma dificuldade": 1, "Não verbalizou": 2}

    # Educador - Perguntas Semanais
    WEEKLY_BEHAVIOR_MAP = {"Muito bom": 3, "Bom": 2, "Regular": 1, "Difícil": 0}
    RETROGRESSION_MAP = {"Sim": 1, "Não": 0}
    ROUTINE_CHANGE_MAP = {"Muito bem": 3, "Bem": 2, "Com alguma dificuldade": 1, "Com grande dificuldade": 0}
    ADAPTATION_NEEDED_MAP = {"Sim": 1, "Não": 0}

    # Definição do vetor de características a ordem importa
    # Cada posição no vetor corresponde a uma característica específica

    feature_vector = []

    # já são as CARACTERÍSTICAS extraídas (e.g., média, desvio padrão)
    # Para série de dados (listas), precisa de uma função
    # para extrair essas características antes de chamar preprocess_data

    feature_vector.append(data_input.get("frequencia_cardiaca_media", 0)) # Média da FC em um período
    feature_vector.append(data_input.get("nivel_agitacao_media", 0.0))    # Média da agitação em um período

    # Questionário do Responsável
    feature_vector.append(data_input.get("idade_aluno", 0))
    feature_vector.append(SEX_MAP.get(data_input.get("sexo_aluno", "Prefere não informar"), 2))
    feature_vector.append(SPECTRUM_LEVEL_MAP.get(data_input.get("nivel_tea", "Não sei informar"), 3))

    feature_vector.append(COMMUNICATION_EDU_MAP.get(data_input.get("comunicacao_verbal_resp", "Sim, fluentemente"), 0)) 
    feature_vector.append(data_input.get("interacao_social_escala", 3)) 

    feature_vector.append(ROUTINE_MAP.get(data_input.get("rotina_estruturada", "Parcialmente"), 1))

    # Sensibilidades Sensoriais (Multi-seleção: One-Hot Encoding)
    SENSITIVITIES_LIST = ["Sons altos", "Luzes fortes", "Certas texturas", "Cheiros fortes"]
    current_sensitivities = data_input.get("sensibilidades", [])
    for s in SENSITIVITIES_LIST:
        feature_vector.append(1 if s in current_sensitivities else 0)

    feature_vector.append(CRISIS_FREQ_MAP.get(data_input.get("frequencia_crises", "Raramente"), 0))

    # Questionário do Aluno - Diário 
    feature_vector.append(FEELING_MAP.get(data_input.get("sentimento_hoje", "Normal"), 1))
    feature_vector.append(LIKED_DAY_MAP.get(data_input.get("gostou_dia", "Sim"), 1))
    feature_vector.append(COMMUNICATED_MAP.get(data_input.get("comunicou_aluno", "Sim"), 1)) 

    # O que incomodou 
    INCOMFORT_LIST = ["Barulho alto", "Luz forte", "Pessoas"] 
    current_incomforts = data_input.get("incomodado_aluno", [])
    for i in INCOMFORT_LIST:
        feature_vector.append(1 if i in current_incomforts else 0)

    feature_vector.append(DID_WHAT_WANTED_MAP.get(data_input.get("fez_o_que_queria", "Sim"), 1))

    # --- Questionário do Aluno - Estado Emocional ---
    feature_vector.append(EMOTIONAL_STATE_MAP.get(data_input.get("estado_emocional_aluno", "Bem"), 4))
    feature_vector.append(PHYSICAL_PAIN_MAP.get(data_input.get("dor_fisica", "Não"), 0))
    feature_vector.append(WANT_TO_BE_ALONE_MAP.get(data_input.get("quer_ficar_sozinho", "👎 Não"), 0))
    feature_vector.append(NEED_HELP_MAP.get(data_input.get("precisa_ajuda", "Não"), 0))

    # --- Questionário do Educador - Perguntas Diárias ---
    feature_vector.append(EDUCATOR_MOOD_MAP.get(data_input.get("humor_aluno_edu", "Neutro"), 1))
    feature_vector.append(PARTICIPATION_MAP.get(data_input.get("participacao_atividades", "👍 Sim"), 1))
    feature_vector.append(INTERACTION_MAP.get(data_input.get("interacao_colegas", "Boa"), 2))
    feature_vector.append(CRISIS_OCCURRED_MAP.get(data_input.get("crise_ocorrida_edu", "Não"), 0)) # Sufixo para educador
    feature_vector.append(COMMUNICATION_EDU_MAP.get(data_input.get("comunicacao_verbal_edu", "Com facilidade"), 0))

    # --- Questionário do Educador - Perguntas Semanais ---
    feature_vector.append(WEEKLY_BEHAVIOR_MAP.get(data_input.get("avaliacao_semanal_edu", "Bom"), 2))

    # Evoluções 
    EVOLUTIONS_LIST = ["Comunicação verbal", "Socialização", "Atenção/concentração", "Autonomia (fazer tarefas sozinho)"]
    current_evolutions = data_input.get("evolucao_observada", [])
    for e in EVOLUTIONS_LIST:
        feature_vector.append(1 if e in current_evolutions else 0)

    feature_vector.append(RETROGRESSION_MAP.get(data_input.get("retrocesso_edu", "Não"), 0))
    feature_vector.append(ROUTINE_CHANGE_MAP.get(data_input.get("lidou_mudanca_rotina", "Bem"), 2))
    feature_vector.append(ADAPTATION_NEEDED_MAP.get(data_input.get("adaptacao_necessaria", "Não"), 0))

    return feature_vector
