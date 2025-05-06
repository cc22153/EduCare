from modelo.preditiva import prever_crise
from dados.simulador import dados_simulados
from dados.process import preprocessar_dados

if __name__ == "__main__":
    # carrega os dados simulados
    dados_brutos = dados_simulados()

    # pré-processa os dados
    dados_prontos = preprocessar_dados(dados_brutos)

    # predição
    resultado = prever_crise(dados_prontos)

    print("Crise prevista:", "SIM" if resultado == 1 else "NÃO")