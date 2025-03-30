import pandas as pd
import numpy as np
import joblib
from flask import Flask, request, jsonify
from datetime import datetime
import logging
from typing import Dict, Any

# Configuración global
CONFIG = {
    'MODEL_PATH': 'best_lgbm_model.pkl',  # Ruta local al modelo
    'HOST': '127.0.0.1',                  # Solo conexiones locales
    'PORT': 5000,
    'LOG_FILE': 'ia_server.log',
    'CACHE_TTL': 300                       # Actualizar caché cada 5 minutos
}

# Configuración de logging
logging.basicConfig(
    filename=CONFIG['LOG_FILE'],
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

app = Flask(__name__)

# Carga del modelo con verificación
try:
    model = joblib.load(CONFIG['MODEL_PATH'])
    logging.info("Modelo cargado correctamente")
except Exception as e:
    logging.critical(f"Error al cargar el modelo: {str(e)}")
    raise

# Caché optimizada
class FeatureCache:
    def __init__(self):
        self.data: Dict[str, Any] = {}
        self.last_update = datetime.now()
    
    def update(self, features: Dict[str, float]) -> None:
        self.data = features
        self.last_update = datetime.now()
    
    def get(self, feature: str) -> float:
        return self.data.get(feature, 0.0)

cache = FeatureCache()

# Feature Engineering Optimizado
def generate_features(ohlc: Dict[str, float]) -> pd.DataFrame:
    """Genera features en tiempo real con numpy vectorizado"""
    close = ohlc['Close']
    open_ = ohlc['Open']
    high = ohlc['High']
    low = ohlc['Low']
    
    # Cálculos vectorizados
    body_size = abs(close - open_)
    candle_size = high - low
    is_hammer = np.where(
        ((close - low) > (1.5 * body_size)) & (body_size > 0.0005), 1, 0)
    
    # Features requeridas por el modelo
    features = {
        'RSI': ohlc.get('RSI', 50.0),          # Valor por defecto neutral
        'ATR': ohlc.get('ATR', 0.001),         # Valor por defecto típico
        'MA': ohlc.get('MA', close),
        'MA_50_velocity': 0.0,                  # Se actualiza con valores reales
        'Candle_Size': candle_size,
        'Body_Size': body_size,
        'Is_Hammer': is_hammer,
        'RSI_MA': ohlc.get('RSI_MA', 50.0),
        'RSI_Divergence': 0,
        'Volatility_Cluster': 0
    }
    
    # Actualizar caché
    cache.update(features)
    
    return pd.DataFrame([features])

@app.route('/predict', methods=['POST'])
def predict():
    """Endpoint optimizado para predicciones en tiempo real"""
    start_time = datetime.now()
    
    try:
        # Validación de entrada
        data = request.json
        required_fields = ['open', 'high', 'low', 'close']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Datos OHLC incompletos'}), 400
        
        ohlc = {
            'Open': float(data['open']),
            'High': float(data['high']),
            'Low': float(data['low']),
            'Close': float(data['close'])
        }
        
        # Generación de features
        features = generate_features(ohlc)
        
        # Predicción
        prediction = int(model.predict(features)[0])
        probability = float(model.predict_proba(features)[0][1])
        
        # Log de rendimiento
        processing_time = (datetime.now() - start_time).total_seconds() * 1000
        logging.info(
            f"Predicción: {prediction} | "
            f"Confianza: {probability:.2f} | "
            f"Tiempo: {processing_time:.2f}ms"
        )
        
        return jsonify({
            'prediction': prediction,
            'probability': probability,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logging.error(f"Error en predicción: {str(e)}")
        return jsonify({'error': 'Error interno del servidor'}), 500

if __name__ == '__main__':
    # Configuración de seguridad para entorno local
    app.run(
        host=CONFIG['HOST'],
        port=CONFIG['PORT'],
        threaded=True,
        debug=False,  # Desactivar en producción
        use_reloader=False
    )
