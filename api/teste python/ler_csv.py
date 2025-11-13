# analisador_dados.py
import pandas as pd
import matplotlib.pyplot as plt
import os
import glob

# CONFIGURAÇÃO
DATA_DIR = "data"
NOME_ARQUIVO_GRAFICO = "analise_fisiologica.png"

def encontrar_ultimo_csv():
    """Encontra o arquivo CSV mais recente na pasta DATA_DIR."""
    # Garante que o diretório de dados exista
    if not os.path.isdir(DATA_DIR):
        print(f"⚠️ Diretório '{DATA_DIR}' não encontrado. Execute a API primeiro.")
        return None
    
    # Busca todos os arquivos CSV
    caminhos_csv = glob.glob(os.path.join(DATA_DIR, "*.csv"))
    
    if not caminhos_csv:
        print(f"⚠️ Nenhum arquivo CSV encontrado em '{DATA_DIR}'.")
        return None
    
    # Ordena os arquivos pela data de modificação (o mais novo é o último)
    caminhos_csv.sort(key=os.path.getmtime)
    
    return caminhos_csv[-1]

def analisar_e_visualizar(caminho_csv: str):
    """Carrega, analisa e visualiza os dados do CSV."""
    print(f"✅ Analisando arquivo: {os.path.basename(caminho_csv)}")
    
    # Carregar Dados
    # O seu CSV não tem cabeçalhos muito descritivos na primeira linha do arquivo
    # Vou usar read_csv com um pouco mais de cautela
    try:
        df = pd.read_csv(caminho_csv)
    except pd.errors.EmptyDataError:
        print("❌ O arquivo CSV está vazio.")
        return
    except Exception as e:
        print(f"❌ Erro ao ler o CSV: {e}")
        return

    # Pré-processamento e Estatísticas
    
    # Converte 'timestamp' para datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    
    # Calcula estatísticas
    stats = {
        "BPM Médio": df['bpm'].mean(),
        "BPM Máximo": df['bpm'].max(),
        "Movimento Médio (Accel X)": df['accel_x'].mean(),
        "Total de Registros": len(df)
    }

    print("\n=== Estatísticas Rápidas ===")
    for k, v in stats.items():
        print(f"{k}: {v:.2f}")

    # Visualização (Gráfico)
    try:
        # Cria a figura e os eixos
        fig, ax1 = plt.subplots(figsize=(12, 6))

        # Eixo 1: BPM
        cor_bpm = 'tab:red'
        ax1.set_xlabel('Tempo (Índice de Amostra)')
        ax1.set_ylabel('BPM', color=cor_bpm)
        ax1.plot(df.index, df['bpm'], color=cor_bpm, label='BPM')
        ax1.tick_params(axis='y', labelcolor=cor_bpm)

        # Eixo 2: Aceleração(movimento na direção X como proxy)
        ax2 = ax1.twinx()  # Cria um segundo eixo que compartilha o eixo X
        cor_accel = 'tab:blue'
        ax2.set_ylabel('Accel X (Movimento)', color=cor_accel)
        ax2.plot(df.index, df['accel_x'], color=cor_accel, linestyle='--', label='Accel X')
        ax2.tick_params(axis='y', labelcolor=cor_accel)
        
        # Título e Layout
        aluno_id = os.path.basename(caminho_csv).replace(".csv", "")
        plt.title(f'Análise Fisiológica (BPM e Movimento) para {aluno_id}')
        fig.tight_layout()
        
        # Salva o gráfico
        plt.savefig(os.path.join(DATA_DIR, NOME_ARQUIVO_GRAFICO))
        print(f"\n✅ Gráfico salvo em: {os.path.join(DATA_DIR, NOME_ARQUIVO_GRAFICO)}")

    except Exception as e:
        print(f"\n❌ Erro ao gerar o gráfico: {e}")


if __name__ == "__main__":
    csv_file = encontrar_ultimo_csv()
    if csv_file:
        analisar_e_visualizar(csv_file)
    else:
        print("\nProcesso de análise encerrado. Nenhum dado encontrado para analisar.")