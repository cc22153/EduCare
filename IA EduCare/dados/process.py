def preprocessar_dados(dados):
    return [
        dados["frequencia_cardiaca"],
        dados["nivel_agitacao"],
        1 if dados["emocao_aluno"] == "triste" else 0,
        1 if dados["estado_fisico"] == "cansado" else 0,
        1 if dados["interacao"] == "nao" else 0,
        1 if dados["humor_educador"] == "irritado" else 0,
        1 if dados["crise_educador"] == "sim" else 0,
        1 if dados["verbalizacao"] == "dificuldade" else 0,
        1 if dados["sensibilidade_som"] else 0,
    ]