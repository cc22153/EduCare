# treinar_modelo.py
import joblib
from sklearn.tree import DecisionTreeClassifier

# Exemplos de dados 
X = [
    [130, 4, 1, 1, 1, 1, 1, 1, 1],  # crise
    [100, 1, 0, 0, 0, 0, 0, 0, 0],  # sem crise
    [140, 5, 1, 1, 1, 1, 1, 1, 1],  # crise
    [90, 1, 0, 0, 0, 0, 0, 0, 0],   # sem crise
]
y = [1, 0, 1, 0]  # 1  crise, 0  não crise

modelo = DecisionTreeClassifier()
modelo.fit(X, y)

# Salva o modelo como modelo.pkl
joblib.dump(modelo, "modelo.pkl")
print("Modelo salvo com sucesso como modelo.pkl")
