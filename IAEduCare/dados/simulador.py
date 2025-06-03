import random

def generate_simulated_data(scenario_type: str = "normal") -> dict:

    data = {}

    #  Simulação de Dados de Sensores 

    if scenario_type == "crise":
        data["frequencia_cardiaca_media"] = random.randint(110, 160) # Freq. C elevada
        data["nivel_agitacao_media"] = random.uniform(0.7, 1.0) # Agitação alta
    elif scenario_type == "normal":
        data["frequencia_cardiaca_media"] = random.randint(70, 100) # Freq. C normal
        data["nivel_agitacao_media"] = random.uniform(0.0, 0.3) # Agitação baixa
    else: # Misto ou aleatório
        data["frequencia_cardiaca_media"] = random.randint(60, 140)
        data["nivel_agitacao_media"] = random.uniform(0, 1)

    #  Questionário do Responsável 
    data["idade_aluno"] = random.randint(12, 18)
    data["sexo_aluno"] = random.choice(["Masculino", "Feminino", "Prefere não informar"])
    data["nivel_tea"] = random.choice(["Leve", "Moderado", "Severo", "Não sei informar"])
    data["comunicacao_verbal_resp"] = random.choice(["Sim, fluentemente", "Sim, com dificuldades", "Não verbal"])
    data["interacao_social_escala"] = random.randint(1, 5) # Escala 1-5
    data["rotina_estruturada"] = random.choice(["Sim", "Não", "Parcialmente"])
    data["sensibilidades"] = random.sample(["Sons altos", "Luzes fortes", "Certas texturas", "Cheiros fortes"], random.randint(0, 2)) # Lista de sensibilidades
    data["frequencia_crises"] = random.choice(["Raramente", "Algumas vezes por semana", "Diariamente"])

    # Questionário do Aluno - Diário
    data["sentimento_hoje"] = random.choice(["Feliz", "Normal", "Triste", "Bravo"])
    data["gostou_dia"] = random.choice(["Sim", "Não"])
    data["comunicou_aluno"] = random.choice(["Sim", "Não"])
    data["incomodado_aluno"] = random.sample(["Barulho alto", "Luz forte", "Pessoas"], random.randint(0, 1))
    data["fez_o_que_queria"] = random.choice(["Sim", "Não", "Um pouco"])

    # Questionário do Aluno - Estado Emocional 
    data["estado_emocional_aluno"] = random.choice(["Bravo", "Triste", "Medo", "Cansado", "Bem"])
    data["dor_fisica"] = random.choice(["Sim", "Não"])
    data["quer_ficar_sozinho"] = random.choice(["Sim", "Não"])
    data["precisa_ajuda"] = random.choice(["Sim", "Não"])

    # Questionário do Educador - Perguntas Diárias
    data["humor_aluno_edu"] = random.choice(["Feliz", "Neutro", "Triste", "Irritado"])
    data["participacao_atividades"] = random.choice(["Sim", "Não", "Parcialmente"])
    data["interacao_colegas"] = random.choice(["Excelente", "Boa", "Regular", "Difícil"])
    data["crise_ocorrida_edu"] = random.choice(["Sim", "Não"])
    data["comunicacao_verbal_edu"] = random.choice(["Com facilidade", "Com alguma dificuldade", "Não verbalizou"])

    # Questionário do Educador - Perguntas Semanais
    data["avaliacao_semanal_edu"] = random.choice(["Muito bom", "Bom", "Regular", "Difícil"])
    data["evolucao_observada"] = random.sample(["Comunicação verbal", "Socialização", "Atenção/concentração", "Autonomia (fazer tarefas sozinho)"], random.randint(0, 2))
    data["retrocesso_edu"] = random.choice(["Sim", "Não"])
    data["lidou_mudanca_rotina"] = random.choice(["Muito bem", "Bem", "Com alguma dificuldade", "Com grande dificuldade"])
    data["adaptacao_necessaria"] = random.choice(["Sim", "Não"])


    # Lógica simples para determinar se é uma crise 
  
    data["is_crisis"] = 0 # Assume normal como padrão

    if scenario_type == "crise":
        data["is_crisis"] = 1
    elif (data["frequencia_cardiaca_media"] > 120 and data["nivel_agitacao_media"] > 0.6) or \
         (data["sentimento_hoje"] == "Bravo" and data["estado_emocional_aluno"] == "Bravo") or \
         (data["crise_ocorrida_edu"] == "Sim"):
        data["is_crisis"] = 1

    return data