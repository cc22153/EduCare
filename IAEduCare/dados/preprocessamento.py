import numpy as np

def preprocessaDados(data_input: dict) -> list:

    # Mapeamentos Categóricos
    SEX_MAP = {"Masculino": 0, "Feminino": 1, "Prefere não informar": 2}
    SPECTRUM_LEVEL_MAP = {"Leve": 0, "Moderado": 1, "Severo": 2, "Não sei informar": 3}
    ROUTINE_MAP = {"Sim": 0, "Parcialmente": 1, "Não": 2}
    CRISIS_FREQ_MAP = {"Raramente": 0, "Algumas vezes por semana": 1, "Diariamente": 2}

    # Mapeamentos do Aluno (Diário/Emocional) - 6 Emoções em minúsculas
    FEELING_MAP = {"feliz": 0, "neutro": 1, "triste": 2, "irritado": 3, "ansioso": 4, "cansado": 5}
    LIKED_DAY_MAP = {"Sim": 1, "Não": 0}
    COMMUNICATED_MAP = {"Sim": 1, "Não": 0}
    DID_WHAT_WANTED_MAP = {"Sim": 1, "Não": 0, "Um pouco": 0.5} 
    EMOTIONAL_STATE_MAP = {"feliz": 0, "neutro": 1, "triste": 2, "irritado": 3, "ansioso": 4, "cansado": 5}
    PHYSICAL_PAIN_MAP = {"Sim": 1, "Não": 0}
    WANT_TO_BE_ALONE_MAP = {"Sim": 1, "Não": 0}
    NEED_HELP_MAP = {"Sim": 1, "Não": 0}
    MOTIVE_MAP = {"Aula": 0, "Pessoas": 1, "Barulho": 2, None: 3} 

    # Mapeamentos do Educador
    EDUCATOR_MOOD_MAP = {"Feliz": 0, "Neutro": 1, "Triste": 2, "Irritado": 3}
    PARTICIPATION_MAP = {"Sim": 1, "Não": 0, "Parcialmente": 0.5} 
    INTERACTION_MAP = {"Excelente": 3, "Boa": 2, "Regular": 1, "Difícil": 0}
    CRISIS_OCCURRED_MAP = {"Sim": 1, "Não": 0}
    COMMUNICATION_EDU_MAP = {"Com facilidade": 0, "Com alguma dificuldade": 1, "Não verbalizou": 2}
    WEEKLY_BEHAVIOR_MAP = {"Muito bom": 3, "Bom": 2, "Regular": 1, "Difícil": 0}
    RETROGRESSION_MAP = {"Sim": 1, "Não": 0}
    ROUTINE_CHANGE_MAP = {"Muito bem": 3, "Bem": 2, "Com alguma dificuldade": 1, "Com grande dificuldade": 0}
    ADAPTATION_NEEDED_MAP = {"Sim": 1, "Não": 0}

    feature_vector = []

    # ----------------------------------------------------
    # 1. Dados Fisiológicos (2 features)
    # ----------------------------------------------------
    feature_vector.append(data_input.get("frequencia_cardiaca_media", 0)) 
    feature_vector.append(data_input.get("nivel_agitacao_media", 0.0))    

    # ----------------------------------------------------
    # 2. Questionário do Responsável (9 features + 4 sensibilidades)
    # ----------------------------------------------------
    feature_vector.append(data_input.get("idade_aluno", 0))
    feature_vector.append(SEX_MAP.get(data_input.get("sexo_aluno", "Prefere não informar"), 2))
    feature_vector.append(SPECTRUM_LEVEL_MAP.get(data_input.get("nivel_tea", "Não sei informar"), 3))

    feature_vector.append(COMMUNICATION_EDU_MAP.get(data_input.get("comunicacao_verbal_resp", "Sim, fluentemente"), 0)) 
    feature_vector.append(data_input.get("interacao_social_escala", 3)) 

    feature_vector.append(ROUTINE_MAP.get(data_input.get("rotina_estruturada", "Parcialmente"), 1))

    # Sensibilidades Sensoriais (4 features de 1-hot encoding)
    SENSITIVITIES_LIST = ["Sons altos", "Luzes fortes", "Certas texturas", "Cheiros fortes"]
    current_sensitivities = data_input.get("sensibilidades", [])
    for s in SENSITIVITIES_LIST:
        feature_vector.append(1 if s in current_sensitivities else 0)

    feature_vector.append(CRISIS_FREQ_MAP.get(data_input.get("frequencia_crises", "Raramente"), 0))

    # ----------------------------------------------------
    # 3. Questionário do Aluno (Diário e Emocional) 
    # ----------------------------------------------------
    # Diário (4 features)
    feature_vector.append(FEELING_MAP.get(data_input.get("sentimento_hoje", "neutro").lower(), 1))
    feature_vector.append(LIKED_DAY_MAP.get(data_input.get("gostou_dia", "Sim"), 1))
    feature_vector.append(COMMUNICATED_MAP.get(data_input.get("comunicou_aluno", "Sim"), 1)) 
    
    # Incomodado Aluno (NOVA CORREÇÃO: 2 features para chegar a 37)
    # Assumimos que o modelo foi treinado com 2 categorias de estressores comuns (Barulho e Pessoas)
    STRESSORS_LIST = ["Barulho alto", "Muitas pessoas"]
    current_stressors = data_input.get("incomodado_aluno", [])
    for s in STRESSORS_LIST:
        # Verifica se a string de estressor está na lista fornecida.
        # Exemplo: Se ["Barulho alto"] estiver na lista, o primeiro item será 1, o segundo 0.
        feature_vector.append(1 if s in current_stressors else 0)

    feature_vector.append(DID_WHAT_WANTED_MAP.get(data_input.get("fez_o_que_queria", "Sim"), 1))
    
    # Estado Emocional (5 features)
    feature_vector.append(EMOTIONAL_STATE_MAP.get(data_input.get("estado_emocional_aluno", "neutro").lower(), 1)) 
    
    # CAMPO DE MOTIVO ADICIONADO (1 feature)
    feature_vector.append(MOTIVE_MAP.get(data_input.get("motivo", None), 3)) 
    
    feature_vector.append(PHYSICAL_PAIN_MAP.get(data_input.get("dor_fisica", "Não"), 0))
    feature_vector.append(WANT_TO_BE_ALONE_MAP.get(data_input.get("quer_ficar_sozinho", "Não"), 0))
    feature_vector.append(NEED_HELP_MAP.get(data_input.get("precisa_ajuda", "Não"), 0))

    # ----------------------------------------------------
    # 4. Questionário do Educador (Diário e Semanal) 
    # ----------------------------------------------------
    # Diárias (5 features)
    feature_vector.append(EDUCATOR_MOOD_MAP.get(data_input.get("humor_aluno_edu", "Neutro"), 1))
    feature_vector.append(PARTICIPATION_MAP.get(data_input.get("participacao_atividades", "Sim"), 1))
    feature_vector.append(INTERACTION_MAP.get(data_input.get("interacao_colegas", "Boa"), 2))
    feature_vector.append(CRISIS_OCCURRED_MAP.get(data_input.get("crise_ocorrida_edu", "Não"), 0)) 
    feature_vector.append(COMMUNICATION_EDU_MAP.get(data_input.get("comunicacao_verbal_edu", "Com facilidade"), 0))

    # Semanais (4 features + 4 evoluções)
    feature_vector.append(WEEKLY_BEHAVIOR_MAP.get(data_input.get("avaliacao_semanal_edu", "Bom"), 2))

    # Evoluções (4 features de 1-hot encoding)
    EVOLUTIONS_LIST = ["Comunicação verbal", "Socialização", "Atenção/concentração", "Autonomia (fazer tarefas sozinho)"]
    current_evolutions = data_input.get("evolucao_observada", [])
    for e in EVOLUTIONS_LIST:
        feature_vector.append(1 if e in current_evolutions else 0)

    feature_vector.append(RETROGRESSION_MAP.get(data_input.get("retrocesso_edu", "Não"), 0))
    feature_vector.append(ROUTINE_CHANGE_MAP.get(data_input.get("lidou_mudanca_rotina", "Bem"), 2))
    feature_vector.append(ADAPTATION_NEEDED_MAP.get(data_input.get("adaptacao_necessaria", "Não"), 0))
    
    # Recalculando o total de features:
    # 2 (Fisio) + 9 (Resp) + 4 (Sensib) + 4 (Diário) + 2 (Incomodado) + 5 (Emocional) + 5 (Edu Diário) + 4 (Edu Semanal) + 4 (Evolução) = 39 - 2 features = 37 features
    # (Sentimento hoje (1), Liked Day (1), Comunicou Aluno (1), Fez o que queria (1), Estado Emocional (1), Motivo (1), Dor (1), Sozinho (1), Ajuda (1)) = 9 features

    # Recontagem: 2 (Fisio) + 6 (Resp Mapeado) + 4 (Sensib) + 1 (Crisis Freq) + 4 (Aluno Diário Mapeado) + 2 (Incomodado) + 5 (Aluno Emocional Mapeado) + 5 (Edu Diário Mapeado) + 1 (Edu Semanal Mapeado) + 4 (Evolução) + 3 (Semanal Mapeado) 
    # 2+6+4+1 + 4+2 + 5 + 5 + 1+4+3 = 37 features. Confere!

    return feature_vector
