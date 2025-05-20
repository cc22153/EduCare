def preprocessar_dados(dados):
    # Conversões de variáveis em numéricas

    sexo_map = {"Masculino": 0, "Feminino": 1, "Prefere não informar": 2}
    diagnostico_map = {"Sim": 1, "Não": 0, "Em processo de avaliação": 2}
    nivel_map = {"Leve": 0, "Moderado": 1, "Severo": 2, "Não sei informar": 3}
    comunicacao_map = {
        "Sim": 0,
        "Com dificuldades": 1,
        "Não verbal": 2,
        "Com alguma dificuldade": 3
    }
    contato_visual_map = {"Sim": 0, "As vezes": 1, "Não": 2}
    rotina_map = {"Sim": 0, "Parcialmente": 1, "Não": 2}
    cansado_map = {"Muito": 2, "Um pouco": 1, "Nada": 0}
    sentimento_map = {"Feliz": 0, "Normal": 1, "Triste": 2, "Bravo": 3}
    emocional_map = {"Bravo": 0, "Triste": 1, "Medo": 2, "Cansado": 3}

    # Listas binárias
    comorbidades_list = ["TDAH", "Epilepsia", "Dislexia", "Ansiedade"]
    sensibilidades_list = ["Sons altos", "Luzes fortes", "Certas texturas", "Cheiros fortes"]
    incomodos_list = ["Barulho alto", "Luz forte", "Pessoas"]

    crise_freq_map = {
        "Raramente": 0,
        "Algumas vezes por semana": 1,
        "Diariamente": 2
    }

    # Início da vetorização
    vetor = [
        dados.get("idade", 0),
        nivel_map.get(dados.get("nivel", "Não sei informar"), 3),
        sexo_map.get(dados.get("sexo", "Prefere não informar"), 2),
        diagnostico_map.get(dados.get("diagnostico", "Não"), 0),
        comunicacao_map.get(dados.get("comunicacao", "Sim"), 0),
        contato_visual_map.get(dados.get("contato_visual", "Sim"), 0),
        dados.get("interacao_social", 3),
        rotina_map.get(dados.get("rotina", "Parcialmente"), 1),
        cansado_map.get(dados.get("cansado", "Um pouco"), 1),
        sentimento_map.get(dados.get("sentimento_hoje", "Normal"), 1),
        emocional_map.get(dados.get("estado_emocional", "Triste"), 1),
    ]

    for c in comorbidades_list:
        vetor.append(1 if c in dados.get("comorbidades", []) else 0)

    for s in sensibilidades_list:
        vetor.append(1 if s in dados.get("sensibilidades", []) else 0)

    for i in incomodos_list:
        vetor.append(1 if i in dados.get("incomodado", []) or i in dados.get("incomodo", []) else 0)

    vetor.append(crise_freq_map.get(dados.get("frequencia_crises", "Raramente"), 0))
    vetor.append(1 if dados.get("comunicou", "Não") == "Sim" else 0)

    return vetor
