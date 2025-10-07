import random

def generate_simulated_data(scenario_type: str = "normal") -> dict:

    data = {}

    # Lógica para cenários de treinamento bem definidos 
    if scenario_type == "normal":
        data["frequencia_cardiaca_media"] = random.randint(60, 90)
        data["nivel_agitacao_media"] = random.uniform(0.0, 0.2)
        data["sentimento_hoje"] = random.choice(["Feliz", "Normal"])
        data["gostou_dia"] = "Sim"
        data["comunicou_aluno"] = random.choice(["Sim", "Não"])
        data["incomodado_aluno"] = []
        data["fez_o_que_queria"] = "Sim"
        
        # --- AJUSTES NO ESTADO EMOCIONAL PARA O NOVO VETOR (FLUTTER) ---
        data["sentimento"] = random.choice(["feliz", "neutro"]) # Chave 'sentimento' e valores minúsculos
        data["motivo"] = None # Sem motivo de incômodo em cenário normal
        # -----------------------------------------------------------------
        
        data["dor_fisica"] = "Não"
        data["quer_ficar_sozinho"] = "Não"
        data["precisa_ajuda"] = "Não"
        data["humor_aluno_edu"] = random.choice(["Feliz", "Neutro"])
        data["participacao_atividades"] = "Sim"
        data["interacao_colegas"] = random.choice(["Excelente", "Boa"])
        data["crise_ocorrida_edu"] = "Não"
        data["comunicacao_verbal_edu"] = "Com facilidade"
        data["avaliacao_semanal_edu"] = random.choice(["Muito bom", "Bom"])
        data["evolucao_observada"] = random.sample(["Comunicação verbal", "Socialização", "Atenção/concentração", "Autonomia (fazer tarefas sozinho)"], random.randint(1, 2))
        data["retrocesso_edu"] = "Não"
        data["lidou_mudanca_rotina"] = random.choice(["Muito bem", "Bem"])
        data["adaptacao_necessaria"] = "Não"
        data["is_crisis"] = 0
        
    elif scenario_type == "crise":
        data["frequencia_cardiaca_media"] = random.randint(130, 170)
        data["nivel_agitacao_media"] = random.uniform(0.7, 1.0)
        data["sentimento_hoje"] = random.choice(["Bravo", "Triste"])
        data["gostou_dia"] = "Não"
        data["comunicou_aluno"] = random.choice(["Sim", "Não"])
        data["incomodado_aluno"] = random.sample(["Barulho alto", "Pessoas", "Luz forte"], random.randint(1, 3))
        data["fez_o_que_queria"] = "Não"
        
        # --- AJUSTES NO ESTADO EMOCIONAL PARA O NOVO VETOR (FLUTTER) ---
        data["sentimento"] = random.choice(["irritado", "ansioso", "triste", "cansado"]) # Novas emoções de stress
        data["motivo"] = random.choice(["Aula", "Pessoas", "Barulho"]) # Incômodo presente
        # -----------------------------------------------------------------
        
        data["dor_fisica"] = random.choice(["Sim", "Não"])
        data["quer_ficar_sozinho"] = "Sim"
        data["precisa_ajuda"] = "Sim"
        data["humor_aluno_edu"] = random.choice(["Triste", "Irritado"])
        data["participacao_atividades"] = "Não"
        data["interacao_colegas"] = random.choice(["Regular", "Difícil"])
        data["crise_ocorrida_edu"] = "Sim"
        data["comunicacao_verbal_edu"] = random.choice(["Não verbalizou", "Com alguma dificuldade"])
        data["avaliacao_semanal_edu"] = "Difícil"
        data["evolucao_observada"] = []
        data["retrocesso_edu"] = "Sim"
        data["lidou_mudanca_rotina"] = random.choice(["Com grande dificuldade", "Com grande dificuldade"])
        data["adaptacao_necessaria"] = "Sim"
        data["is_crisis"] = 1
    
    # Lógica para cenários mistos/limítrofes (casos de borda)
    else: # scenario_type == "misto"
        # Gerar dados completamente aleatórios
        data["frequencia_cardiaca_media"] = random.randint(60, 140)
        data["nivel_agitacao_media"] = random.uniform(0, 1)
        data["sentimento_hoje"] = random.choice(["Feliz", "Normal", "Triste", "Bravo"])
        data["gostou_dia"] = random.choice(["Sim", "Não"])
        data["comunicou_aluno"] = random.choice(["Sim", "Não"])
        data["incomodado_aluno"] = random.sample(["Barulho alto", "Luz forte", "Pessoas"], random.randint(0, 1))
        data["fez_o_que_queria"] = random.choice(["Sim", "Não", "Um pouco"])
        
        # --- AJUSTES NO ESTADO EMOCIONAL PARA O NOVO VETOR (FLUTTER) ---
        data["sentimento"] = random.choice(["feliz", "neutro", "triste", "irritado", "ansioso", "cansado"])
        data["motivo"] = random.choice(["Aula", "Pessoas", "Barulho", None])
        # -----------------------------------------------------------------
        
        data["dor_fisica"] = random.choice(["Sim", "Não"])
        data["quer_ficar_sozinho"] = random.choice(["Sim", "Não"])
        data["precisa_ajuda"] = random.choice(["Sim", "Não"])
        data["humor_aluno_edu"] = random.choice(["Feliz", "Neutro", "Triste", "Irritado"])
        data["participacao_atividades"] = random.choice(["Sim", "Não", "Parcialmente"])
        data["interacao_colegas"] = random.choice(["Excelente", "Boa", "Regular", "Difícil"])
        data["crise_ocorrida_edu"] = random.choice(["Sim", "Não"])
        data["comunicacao_verbal_edu"] = random.choice(["Com facilidade", "Com alguma dificuldade", "Não verbalizou"])
        data["avaliacao_semanal_edu"] = random.choice(["Muito bom", "Bom", "Regular", "Difícil"])
        data["evolucao_observada"] = random.sample(["Comunicação verbal", "Socialização", "Atenção/concentração", "Autonomia (fazer tarefas sozinho)"], random.randint(0, 2))
        data["retrocesso_edu"] = random.choice(["Sim", "Não"])
        data["lidou_mudanca_rotina"] = random.choice(["Muito bem", "Bem", "Com alguma dificuldade", "Com grande dificuldade"])
        data["adaptacao_necessaria"] = random.choice(["Sim", "Não"])

        # Aplicar lógica de pontuação para determinar 'is_crisis' no cenário misto
        crisis_score = 0
        if data["frequencia_cardiaca_media"] > 120: crisis_score += 2
        if data["nivel_agitacao_media"] > 0.5: crisis_score += 2
        if data["sentimento_hoje"] == "Bravo": crisis_score += 2
        # MUDANÇA NA CHAVE AQUI
        if data["sentimento"] in ["irritado", "ansioso"]: crisis_score += 2 
        if data["dor_fisica"] == "Sim": crisis_score += 1
        if "Barulho alto" in data["incomodado_aluno"]: crisis_score += 1
        if data["humor_aluno_edu"] == "Irritado": crisis_score += 2
        if data["interacao_colegas"] == "Difícil": crisis_score += 2
        if data["retrocesso_edu"] == "Sim": crisis_score += 3
        if data["lidou_mudanca_rotina"] == "Com grande dificuldade": crisis_score += 2
        
        if data["crise_ocorrida_edu"] == "Sim":
            data["is_crisis"] = 1
        elif crisis_score >= 5:
            data["is_crisis"] = 1
        else:
            data["is_crisis"] = 0

    # Lógica de preenchimento para campos que não foram definidos nos cenários
    default_values = {
        "idade_aluno": random.randint(12, 18),
        "sexo_aluno": random.choice(["Masculino", "Feminino", "Prefere não informar"]),
        "nivel_tea": random.choice(["Leve", "Moderado", "Severo", "Não sei informar"]),
        "comunicacao_verbal_resp": random.choice(["Sim, fluentemente", "Sim, com dificuldades", "Não verbal"]),
        "interacao_social_escala": random.randint(1, 5),
        "rotina_estruturada": random.choice(["Sim", "Não", "Parcialmente"]),
        "sensibilidades": random.sample(["Sons altos", "Luzes fortes", "Certas texturas", "Cheiros fortes"], random.randint(0, 2)),
        "frequencia_crises": random.choice(["Raramente", "Algumas vezes por semana", "Diariamente"])
    }
    for key, value in default_values.items():
        if key not in data:
            data[key] = value

    # GARANTINDO QUE A CHAVE ANTIGA NÃO CAUSE ERRO no preprocessaDados
    if "estado_emocional_aluno" in data:
        del data["estado_emocional_aluno"] 

    return data