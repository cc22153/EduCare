from dados.process import preprocessar_dados
from modelo.preditiva import prever_crise
from questionarios.questionarioResponsavel import coletar_dados_responsavel
from questionarios.questionarioEducador import coletar_dados_professor
from questionarios.diario import coletar_dados_diario

if __name__ == "__main__":
    dados_resp = coletar_dados_responsavel()
    dados_prof = coletar_dados_professor()
    dados_diario = coletar_dados_diario()

    # Combinar todos os dados
    dados_combinados = {**dados_resp, **dados_prof, **dados_diario}

    dados_prontos = preprocessar_dados(dados_combinados)
    resultado = prever_crise(dados_prontos)

    print("Crise detectada" if resultado == 1 else "Sem crise")
