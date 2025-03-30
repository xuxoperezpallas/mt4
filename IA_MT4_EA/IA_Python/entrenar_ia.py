import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import joblib

# 1. Cargar datos
data = pd.read_csv('datos_entrenamiento.csv')
X = data[['RSI', 'ATR', 'MA']]  # Features (indicadores)
y = data['Target']               # Target (1 o 0)

# 2. Dividir datos en entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# 3. Entrenar modelo (Random Forest)
model = RandomForestClassifier(n_estimators=100)
model.fit(X_train, y_train)

# 4. Evaluar precisión
accuracy = model.score(X_test, y_test)
print(f"Precisión del modelo: {accuracy*100:.2f}%")

# 5. Guardar modelo
joblib.dump(model, 'modelo_ia.pkl')
