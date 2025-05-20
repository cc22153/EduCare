def dados_simulados():
    return {
        "frequencia_cardiaca": random.randint(60, 140),
        "nivel_agitacao": random.uniform(0, 1),

        # Responsável
        "idade_aluno": random.randint(12, 18),
        "sexo_aluno": random.choice([0, 1, 2]),
        "diagnostico_tea": random.choice([0, 1, 2]),
        "tempo_diagnostico": random.randint(1, 120),
        "nivel_tea": random.choice([0, 1, 2, 3]),
        "comorbidades_TDAH": random.choice([0, 1]),
        "comorbidades_ansiedade": random.choice([0, 1]),
        "comunicacao_verbal": random.choice([0, 1, 2]),
        "contato_visual": random.choice([0, 1, 2]),
        "interacao_social_escala": random.randint(1, 5),
        "rotina_estruturada": random.choice([0, 1, 2]),
        "sensibilidade_som": random.choice([0, 1]),
        "sensibilidade_luz": random.choice([0, 1]),
        "sensibilidade_textura": random.choice([0, 1]),
        "sensibilidade_olfativa": random.choice([0, 1]),

        # Aluno
        "emocao_diaria": random.choice([0, 1, 2, 3]),
        "gostou_dia": random.choice([0, 1]),
        "cansaco": random.choice([0, 1, 2]),
        "comunicacao": random.choice([0, 1]),
        "incomodo_som": random.choice([0, 1]),
        "incomodo_luz": random.choice([0, 1]),
        "incomodo_pessoas": random.choice([0, 1]),
        "estado_emocional": random.choice([0, 1, 2, 3]),
        "dor_fisica": random.choice([0, 1]),
        "quer_ficar_sozinho": random.choice([0, 1]),
        "precisa_ajuda": random.choice([0, 1]),

        # Educador
        "humor_aluno": random.choice([0, 1, 2, 3]),
        "participacao_atividades": random.choice([0, 1, 2]),
        "interacao_colegas": random.choice([0, 1, 2, 3]),
        "crise_ocorrida": random.choice([0, 1]),
        "comunicacao_verbal_edu": random.choice([0, 1, 2]),
        "avaliacao_semanal": random.choice([0, 1, 2, 3]),
        "evolucao_comunicacao": random.choice([0, 1]),
        "evolucao_socializacao": random.choice([0, 1]),
        "evolucao_concentracao": random.choice([0, 1]),
        "evolucao_autonomia": random.choice([0, 1]),
        "retrocesso": random.choice([0, 1]),
        "lidou_mudanca_rotina": random.choice([0, 1, 2, 3]),
        "adaptacao_necessaria": random.choice([0, 1])
    }
