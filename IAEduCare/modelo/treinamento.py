import joblib
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import numpy as np
import json # biblioteca JSON para salvar as métricas

# Importa as funções de dados
from dados.preprocessamento import preprocessaDados
from dados.simulador import generate_simulated_data

def treinaModeloESalva(model_filename: str = "model.pkl"):
    print("Iniciando o treinamento do modelo")

    # 1. Gerar um conjunto de dados simulados
    print("Gerando dados de treino simulados...")
    X_raw_data = []
    y_labels = []

    NUM_NORMAL_SAMPLES = 5000
    NUM_CRISIS_SAMPLES = 500 # Aumentei o número de crises para um melhor aprendizado

    # Gerar exemplos de cenário "normal" e "crise"
    for _ in range(NUM_NORMAL_SAMPLES + NUM_CRISIS_SAMPLES):
        scenario_type = "crise" if _ < NUM_CRISIS_SAMPLES else "normal"
        data = generate_simulated_data(scenario_type=scenario_type)
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
    print("Dividindo dados em treino e teste...")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    print(f"Tamanho do conjunto de treino: {len(X_train)} amostras")
    print(f"Tamanho do conjunto de teste: {len(X_test)} amostras")

    # 4. Treinar o modelo
    print("Treinando o modelo Decision Tree...")
    model = DecisionTreeClassifier(random_state=42, class_weight='balanced')
    model.fit(X_train, y_train)
    print("Modelo treinado com sucesso!")

    # 5. Avaliar o modelo e salvar métricas
    print("Avaliando o modelo no conjunto de teste...")
    y_pred = model.predict(X_test)

    # Calcula as métricas
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, pos_label=1)
    recall = recall_score(y_test, y_pred, pos_label=1)
    f1 = f1_score(y_test, y_pred, pos_label=1)
    conf_matrix_list = confusion_matrix(y_test, y_pred).tolist()

    # Exibe as métricas no console
    print(f"\nAcurácia: {accuracy:.4f}")
    print(f"Precisão (crise): {precision:.4f}")
    print(f"Recall (crise): {recall:.4f}")
    print(f"F1-Score (crise): {f1:.4f}")
    print("\nMatriz de Confusão:")
    print(confusion_matrix(y_test, y_pred))

    # Salva as métricas em um arquivo JSON
    metrics_data = {
        "accuracy": accuracy,
        "precision": precision,
        "recall": recall,
        "f1_score": f1,
        "confusion_matrix": conf_matrix_list
    }
    
    metrics_filename = "model_metrics.json"
    with open(metrics_filename, 'w') as f:
        json.dump(metrics_data, f, indent=4)
        
    print(f"\nMétricas do modelo salvas com sucesso em '{metrics_filename}'")

    # 6. Salvar o modelo treinado
    joblib.dump(model, model_filename)
    print(f"\nModelo salvo com sucesso como '{model_filename}'")

if __name__ == "__main__":
    treinaModeloESalva()