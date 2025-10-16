import random
import pandas as pd
from typing import List, Dict, Any

# Define a quantidade de amostras a serem geradas
NUM_SAMPLES = 5000 
CRISIS_SAMPLES = 500  # Quantidade de amostras forçadas como 'Crise' (10%)

def generate_sample_data(num_samples: int) -> List[Dict[str, Any]]:
    """Gera dados simulados para treinamento, contendo apenas Aluno e Responsável (19 campos)."""
    
    data = []

    # Domínios de Dados (Alinhados com o preprocessamento.py e em minúsculas para robustez)
    SEXO_OPTIONS = ["masculino", "feminino", "prefere não informar"]
    NIVEL_TEA_OPTIONS = ["leve", "moderado", "severo", "não sei informar"]
    COMUN_VERBAL_RESP_OPTIONS = ["com facilidade", "com alguma dificuldade", "não verbalizou"]
    CRISES_FREQ_OPTIONS = ["raramente", "algumas vezes por semana", "diariamente"]
    ROTINA_OPTIONS = ["sim", "parcialmente", "não"]

    SENTIMENTO_OPTIONS = ["feliz", "neutro", "triste", "irritado", "ansioso", "cansado"]
    SIM_NAO_OPTIONS = ["sim", "não"]
    SIM_NAO_POUCO_OPTIONS = ["sim", "não", "um pouco"]
    MOTIVO_OPTIONS = ["aula", "pessoas", "barulho", "nenhum"]
    
    SENSIBILIDADES_LIST = ["sons altos", "luzes fortes", "certas texturas", "cheiros fortes"]
    INCOMODADOS_LIST = ["barulho alto", "muitas pessoas"]


    for i in range(num_samples):
        # ----------------------------------------------------
        # 1. Variável de Saída (Target)
        # ----------------------------------------------------
        # Força uma proporção de crises para garantir o treinamento
        is_crisis = 1 if i < CRISIS_SAMPLES or random.random() < 0.1 else 0

        # ----------------------------------------------------
        # 2. Dados Fisiológicos/Numéricos
        # ----------------------------------------------------
        freq_card = random.randint(70, 100)
        nivel_agit = random.uniform(0.1, 0.4)
        
        # Aumenta os sinais se for crise
        if is_crisis:
            freq_card = random.randint(110, 140)
            nivel_agit = random.uniform(0.7, 1.0)
        
        sample = {
            # Fisiológicos
            "frequencia_cardiaca_media": freq_card,
            "nivel_agitacao_media": nivel_agit,
            
            # ----------------------------------------------------
            # 3. Dados do Responsável (Histórico)
            # ----------------------------------------------------
            "idade_aluno": random.randint(5, 18),
            "sexo_aluno": random.choice(SEXO_OPTIONS),
            "nivel_tea": random.choice(NIVEL_TEA_OPTIONS),
            "comunicacao_verbal_resp": random.choice(COMUN_VERBAL_RESP_OPTIONS),
            "interacao_social_escala": random.randint(1, 5), # 1 a 5
            "frequencia_crises": random.choice(CRISES_FREQ_OPTIONS),
            "rotina_estruturada": random.choice(ROTINA_OPTIONS),

            # Sensibilidades
            "sensibilidades": random.sample(SENSIBILIDADES_LIST, k=random.randint(0, len(SENSIBILIDADES_LIST))),

            # ----------------------------------------------------
            # 4. Dados do Aluno (Diário/Emocional)
            # ----------------------------------------------------
            "sentimento_hoje": random.choice(SENTIMENTO_OPTIONS),
            "gostou_dia": random.choice(SIM_NAO_OPTIONS),
            "comunicou_aluno": random.choice(SIM_NAO_OPTIONS),
            "fez_o_que_queria": random.choice(SIM_NAO_POUCO_OPTIONS),
            "estado_emocional_aluno": random.choice(SENTIMENTO_OPTIONS), # Corrigido para corresponder ao preprocessamento
            "motivo": random.choice(MOTIVO_OPTIONS),
            "dor_fisica": random.choice(SIM_NAO_OPTIONS),
            "quer_ficar_sozinho": random.choice(SIM_NAO_OPTIONS),
            "precisa_ajuda": random.choice(SIM_NAO_OPTIONS),
            "incomodado_aluno": random.sample(INCOMODADOS_LIST, k=random.randint(0, len(INCOMODADOS_LIST))),
            
            # Target
            "target": is_crisis
        }
        
        # Ajusta campos para cenários de crise (Aumenta estressores e piora emoções)
        if is_crisis:
            sample["sentimento_hoje"] = random.choice(["triste", "irritado", "ansioso", "cansado"])
            sample["estado_emocional_aluno"] = random.choice(["triste", "irritado", "ansioso", "cansado"])
            sample["dor_fisica"] = "sim" if random.random() < 0.8 else "não"
            sample["quer_ficar_sozinho"] = "sim" if random.random() < 0.7 else "não"
            if random.random() < 0.6:
                 sample["incomodado_aluno"] = INCOMODADOS_LIST 
                 
        data.append(sample)

    return data

def create_simulated_dataset() -> pd.DataFrame:
    """Cria o DataFrame final simulado."""
    data = generate_sample_data(NUM_SAMPLES)
    df = pd.DataFrame(data)
    
    # Adiciona 500 amostras extras para garantir que o total seja 5500
    extra_data = generate_sample_data(500)
    df_extra = pd.DataFrame(extra_data)
    
    df = pd.concat([df, df_extra], ignore_index=True)

    return df
