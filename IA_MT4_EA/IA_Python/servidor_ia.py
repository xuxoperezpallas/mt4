import joblib
import pandas as pd

model = joblib.load('modelo_ia.pkl')

while True:
    try:
        # 1. Leer datos nuevos de MT4 (ej: último registro)
        datos_mt4 = pd.read_csv('datos_realtime.csv').tail(1)
        
        # 2. Predecir
        prediccion = model.predict(datos_mt4[['RSI', 'ATR', 'MA']])
        probabilidad = model.predict_proba(datos_mt4[['RSI', 'ATR', 'MA']])[0][1]

        # 3. Guardar predicción para MT4
        with open('prediccion_ia.txt', 'w') as f:
            f.write(f"{prediccion[0]},{probabilidad}")
            
    except Exception as e:
        print(f"Error: {e}")
