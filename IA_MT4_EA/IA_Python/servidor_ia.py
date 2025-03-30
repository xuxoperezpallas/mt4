import pandas as pd
import numpy as np
import joblib
from flask import Flask, request, jsonify
import threading
import time
from datetime import datetime

# Configuración global
MODEL_PATH = '/content/best_lgbm_model.pkl'
PORT = 5000
UPDATE_INTERVAL = 300  # Actualizar caché cada 5 minutos

app = Flask(__name__)

# Cargar modelo una vez al iniciar
model = joblib.load(MODEL_PATH)

# Caché para datos en tiempo real
data_cache = {
    'last_update': datetime.now(),
    'current_features': None
}

# Función para generar features en tiempo real (igual que en entrenamiento)
def generate_realtime_features(ohlc_data):
    """Convierte datos OHLC en features para el modelo"""
    df = pd.DataFrame([ohlc_data])
    
    # Calcula todas las features usadas en el entrenamiento
    df['Body_Size'] = (df['Close'] - df['Open']).abs()
    df['Candle_Size'] = df['High'] - df['Low']
    df['Is_Hammer'] = np.where(
        ((df['Close'] - df['Low']) > (1.5 * df['Body_Size'])) & 
        (df['Body_Size'] > 0.0005), 1, 0)
    
    # Añadir indicadores técnicos (ejemplo simplificado)
    df['MA_50'] = df['Close'].rolling(50).mean()
    df['RSI_14'] = 100 - (100 / (1 + (df['Close'].diff(1).clip(lower=0).rolling(14).mean() / 
                          df['Close'].diff(1).clip(upper=0).abs().rolling(14).mean()))
    
    # Features adicionales del modelo entrenado
    required_features = [
        'RSI', 'ATR', 'MA', 'MA_50_velocity', 
        'Candle_Size', 'Body_Size', 'Is_Hammer',
        'RSI_MA', 'RSI_Divergence', 'Volatility_Cluster'
    ]
    
    # Rellenar features no disponibles en tiempo real con valores recientes
    for feat in required_features:
        if feat not in df.columns:
            df[feat] = data_cache['current_features'].get(feat, 0) if data_cache['current_features'] else 0
    
    return df[required_features]

# Endpoint para predicciones
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # 1. Obtener datos OHLC del request
        data = request.json
        ohlc = {
            'Open': float(data['open']),
            'High': float(data['high']),
            'Low': float(data['low']),
            'Close': float(data['close'])
        }
        
        # 2. Generar features
        features = generate_realtime_features(ohlc)
        data_cache['current_features'] = features.iloc[-1].to_dict()
        data_cache['last_update'] = datetime.now()
        
        # 3. Predecir
        prediction = model.predict(features)[0]
        probability = model.predict_proba(features)[0][1]
        
        # 4. Formatear respuesta
        return jsonify({
            'prediction': int(prediction),
            'probability': float(probability),
            'timestamp': str(datetime.now())
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Función para mantener el servidor activo
def keep_alive():
    while True:
        time.sleep(60)
        print(f"Server alive at {datetime.now()}")

if __name__ == '__main__':
    # Iniciar thread de mantenimiento
    threading.Thread(target=keep_alive, daemon=True).start()
    
    # Iniciar servidor Flask
    print(f"🚀 Servidor IA iniciado en puerto {PORT}")
    app.run(host='0.0.0.0', port=PORT, threaded=True)
