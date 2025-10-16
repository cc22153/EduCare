import numpy as np
from typing import Dict, Any, List

def preprocessaDados(data_input: Dict[str, Any]) -> List[float]:
    """
    Pré-processa os dados de entrada (Aluno e Responsável) em um vetor de features
    numéricas de 24 dimensões, prontas para o modelo de IA.

    Os dados são limpos e convertidos para minúsculas antes do mapeamento para 
    garantir a robustez do sistema, alinhado com o envio do Flutter.
    """

    # Mapeamentos Categóricos do Responsável/Perfil
    SEX_MAP = {"masculino": 0, "feminino": 1, "prefere não informar": 2}
    SPECTRUM_LEVEL_MAP = {"leve": 0, "moderado": 1, "severo": 2, "não sei informar": 3}
    ROUTINE_MAP = {"sim": 0, "parcialmente": 1, "não": 2}
    CRISIS_FREQ_MAP = {"raramente": 0, "algumas vezes por semana": 1, "diariamente": 2}
    COMMUNICATION_RESP_MAP = {"com facilidade": 0, "com alguma dificuldade": 1, "não verbalizou": 2}

    # Mapeamentos do Aluno (Diário/Emocional) - Todos os valores de input devem ser minúsculos
    FEELING_MAP = {"feliz": 0, "neutro": 1, "triste": 2, "irritado": 3, "ansioso": 4, "cansado": 5}
    LIKED_DAY_MAP = {"sim": 1, "não": 0}
    COMMUNICATED_MAP = {"sim": 1, "não": 0}
    DID_WHAT_WANTED_MAP = {"sim": 1, "não": 0, "um pouco": 0.5} 
    EMOTIONAL_STATE_MAP = {"feliz": 0, "neutro": 1, "triste": 2, "irritado": 3, "ansioso": 4, "cansado": 5}
    PHYSICAL_PAIN_MAP = {"sim": 1, "não": 0}
    WANT_TO_BE_ALONE_MAP = {"sim": 1, "não": 0}
    NEED_HELP_MAP = {"sim": 1, "não": 0}
    MOTIVE_MAP = {"aula": 0, "pessoas": 1, "barulho": 2, "nenhum": 3}

    # Listas para One-Hot Encoding (também em minúsculas)
    SENSITIVITIES_LIST = ["sons altos", "luzes fortes", "certas texturas", "cheiros fortes"]
    STRESSORS_LIST = ["barulho alto", "muitas pessoas"]

    feature_vector = []

    # Helper para pegar valor e garantir que é string minúscula, se aplicável
    def get_value(key, default):
        value = data_input.get(key, default)
        if isinstance(value, str):
            # Tenta limpar e converter para minúscula, senão retorna o valor bruto
            return value.strip().lower() 
        return value

    # ----------------------------------------------------
    # 1. Dados Fisiológicos (2 features)
    # ----------------------------------------------------
    feature_vector.append(get_value("frequencia_cardiaca_media", 0)) 
    feature_vector.append(get_value("nivel_agitacao_media", 0.0))    

    # ----------------------------------------------------
    # 2. Questionário do Responsável (Histórico) (11 features)
    # ----------------------------------------------------
    feature_vector.append(get_value("idade_aluno", 0))
    
    # Mapeamentos categóricos (string para número)
    feature_vector.append(SEX_MAP.get(get_value("sexo_aluno", "prefere não informar"), 2))
    feature_vector.append(SPECTRUM_LEVEL_MAP.get(get_value("nivel_tea", "não sei informar"), 3))
    feature_vector.append(COMMUNICATION_RESP_MAP.get(get_value("comunicacao_verbal_resp", "não verbalizou"), 2)) 
    
    # Escala de interação social (valor numérico)
    feature_vector.append(get_value("interacao_social_escala", 3)) 
    
    feature_vector.append(ROUTINE_MAP.get(get_value("rotina_estruturada", "parcialmente"), 1))

    # Sensibilidades Sensoriais (4 features de 1-hot encoding)
    current_sensitivities = [s.lower() for s in data_input.get("sensibilidades", [])]
    for s in SENSITIVITIES_LIST:
        feature_vector.append(1 if s in current_sensitivities else 0)

    feature_vector.append(CRISIS_FREQ_MAP.get(get_value("frequencia_crises", "raramente"), 0))

    # ----------------------------------------------------
    # 3. Questionário do Aluno (Diário e Emocional) (11 features)
    # ----------------------------------------------------
    feature_vector.append(FEELING_MAP.get(get_value("sentimento_hoje", "neutro"), 1))
    feature_vector.append(LIKED_DAY_MAP.get(get_value("gostou_dia", "sim"), 1))
    feature_vector.append(COMMUNICATED_MAP.get(get_value("comunicou_aluno", "sim"), 1)) 
    
    # Incomodado Aluno (2 features de 1-hot encoding)
    current_stressors = [s.lower() for s in data_input.get("incomodado_aluno", [])]
    for s in STRESSORS_LIST:
        feature_vector.append(1 if s in current_stressors else 0)

    feature_vector.append(DID_WHAT_WANTED_MAP.get(get_value("fez_o_que_queria", "sim"), 1))
    feature_vector.append(EMOTIONAL_STATE_MAP.get(get_value("estado_emocional_aluno", "neutro"), 1)) 
    
    # CAMPO DE MOTIVO 
    feature_vector.append(MOTIVE_MAP.get(get_value("motivo", "nenhum"), 3)) 
    
    feature_vector.append(PHYSICAL_PAIN_MAP.get(get_value("dor_fisica", "não"), 0))
    feature_vector.append(WANT_TO_BE_ALONE_MAP.get(get_value("quer_ficar_sozinho", "não"), 0))
    feature_vector.append(NEED_HELP_MAP.get(get_value("precisa_ajuda", "não"), 0))

    # Total de Features: 2 (Fisio) + 11 (Resp) + 11 (Aluno) = 24 features.

    return feature_vector
