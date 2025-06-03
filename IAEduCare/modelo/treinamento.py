import joblib
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import numpy as np

# Importa as funções de dados
from dados.preprocessamento import preprocessaDados
from dados.simulador import generate_simulated_data

def treinaModeloESalva(model_filename: str = "model.pkl"):
 
    print("Iniciando o treinamento do modelo")

    # Gerar um conjunto de dados simulados
    print("Gerando dados de treino simulados...")
    X_raw_data = [] # Lista de dicionários de dados 
    y_labels = []   # Lista de rótulos 0 = normal, 1 = crise

    NUM_NORMAL_SAMPLES = 1000
    NUM_CRISIS_SAMPLES = 200 # Crises são geralmente mais raras, mas precisamos de exemplos suficientes

    # Gerar exemplos de cenário "normal"
    for _ in range(NUM_NORMAL_SAMPLES):
        data = generate_simulated_data(scenario_type="normal")
        X_raw_data.append(data)
        y_labels.append(data["is_crisis"]) # Pega o rótulo que o simulador gerou

    # Gerar exemplos de cenário de "crise"
    for _ in range(NUM_CRISIS_SAMPLES):
        data = generate_simulated_data(scenario_type="crise")
        X_raw_data.append(data)
        y_labels.append(data["is_crisis"])

    print(f"Total de amostras geradas: {len(X_raw_data)}")
    print(f"Amostras de crise: {sum(y_labels)}, Amostras normais: {len(y_labels) - sum(y_labels)}")

    # 2. Pré-processar os dados brutos para o formato numérico
    print("Pré-processando os dados...")
    X_processed_features = [preprocessaDados(data) for data in X_raw_data]

    # Converta para arrays NumPy para usar com Scikit-learn
    X = np.array(X_processed_features)
    y = np.array(y_labels)

    # 3. Dividir os dados em conjuntos de treino e teste
    # Usaremos 20% dos dados para teste e 80% para treino.
    # stratify=y garante que a proporção de crises seja mantida nos dois conjuntos.
    print("Dividindo dados em treino e teste...")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    print(f"Tamanho do conjunto de treino: {len(X_train)} amostras")
    print(f"Tamanho do conjunto de teste: {len(X_test)} amostras")

    # 4. Treinar o modelo
    print("Treinando o modelo Decision Tree...")
    # Usando class_weight='balanced' para lidar com o possível desbalanceamento de classes (mais normais que crises)
    model = DecisionTreeClassifier(random_state=42, class_weight='balanced')
    model.fit(X_train, y_train)
    print("Modelo treinado com sucesso!")

    # 5. Avaliar o modelo
    print("Avaliando o modelo no conjunto de teste...")
    y_pred = model.predict(X_test)

    print(f"\nAcurácia: {accuracy_score(y_test, y_pred):.4f}")
    print(f"Precisão (crise): {precision_score(y_test, y_pred, pos_label=1):.4f}")
    print(f"Recall (crise): {recall_score(y_test, y_pred, pos_label=1):.4f}")
    print(f"F1-Score (crise): {f1_score(y_test, y_pred, pos_label=1):.4f}")
    print("\nMatriz de Confusão:")
    print(confusion_matrix(y_test, y_pred))
    # A matriz de confusão mostra:
    # [[Verdadeiro Negativo, Falso Positivo],
    #  [Falso Negativo, Verdadeiro Positivo]]
    # No nosso caso:
    # [[Não-Crise previstos como Não-Crise, Não-Crise previstos como Crise],
    #  [Crise previstos como Não-Crise, Crise previstos como Crise]]


    # 6. Salvar o modelo treinado
    joblib.dump(model, model_filename)
    print(f"\nModelo salvo com sucesso como '{model_filename}'")

if __name__ == "__main__":
    treinaModeloESalva()