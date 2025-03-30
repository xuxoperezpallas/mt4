import pandas as pd
import numpy as np
from sklearn.model_selection import TimeSeriesSplit
import lightgbm as lgb
from sklearn.metrics import classification_report
import joblib
from datetime import datetime

# Configuración global
PARES = 'EURUSD'
TIMEFRAME = 'M15'
SEED = 42
np.random.seed(SEED)

# 1. Carga de Datos Optimizada
print("⏳ Cargando y procesando datos...")
start_time = datetime.now()

dtypes = {
    'Open': 'float32', 'High': 'float32', 'Low': 'float32', 
    'Close': 'float32', 'RSI': 'float32', 'ATR': 'float32', 
    'MA': 'float32', 'Target': 'int8'
}

df = pd.read_csv('/content/EURUSD_M15_500K.csv', dtype=dtypes)

# 2. Feature Engineering Avanzado
def create_features(df):
    # Velocidad de tendencia
    df['MA_50_velocity'] = df['MA'].pct_change(periods=5) * 100
    
    # Patrones de velas
    df['Candle_Size'] = df['High'] - df['Low']
    df['Body_Size'] = (df['Close'] - df['Open']).abs()
    df['Is_Hammer'] = np.where(
        ((df['Close'] - df['Low']) > (1.5 * df['Body_Size'])) & 
        (df['Body_Size'] > 0.0005), 1, 0)
    
    # Divergencias RSI
    df['RSI_MA'] = df['RSI'].rolling(14).mean()
    df['RSI_Divergence'] = np.where(
        (df['Close'] > df['Close'].shift(1)) & 
        (df['RSI'] < df['RSI'].shift(1)), 1, 0)
    
    # Clusterización de volatilidad
    df['Volatility_Cluster'] = pd.qcut(df['ATR'], q=5, labels=False)
    
    return df.dropna()

df = create_features(df)

# 3. Balanceo de Clases Mejorado
def advanced_balancing(df):
    from imblearn.over_sampling import SMOTE
    smote = SMOTE(sampling_strategy='minority', random_state=SEED)
    X_res, y_res = smote.fit_resample(df.drop('Target', axis=1), df['Target'])
    return pd.concat([X_res, y_res], axis=1).sample(frac=1, random_state=SEED)

balanced_df = advanced_balancing(df)

# 4. Selección de Features
features = [
    'RSI', 'ATR', 'MA', 'MA_50_velocity', 
    'Candle_Size', 'Body_Size', 'Is_Hammer',
    'RSI_MA', 'RSI_Divergence', 'Volatility_Cluster'
]
X = balanced_df[features]
y = balanced_df['Target']

# 5. Validación Cruzada Temporal
tscv = TimeSeriesSplit(n_splits=5)
best_score = 0
best_model = None

for fold, (train_idx, test_idx) in enumerate(tscv.split(X)):
    print(f"\n=== Fold {fold + 1} ===")
    X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
    y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]
    
    # 6. Modelo LightGBM Hiperoptimizado
    params = {
        'objective': 'binary',
        'metric': 'binary_logloss',
        'boosting_type': 'goss',  # Gradient-based One-Side Sampling
        'device': 'gpu',
        'gpu_platform_id': 0,
        'gpu_device_id': 0,
        'num_leaves': 127,
        'max_depth': -1,  # Sin límite
        'learning_rate': 0.03,
        'feature_fraction': 0.7,
        'bagging_freq': 5,
        'lambda_l1': 0.01,
        'lambda_l2': 0.01,
        'min_data_in_leaf': 100,
        'seed': SEED,
        'verbosity': -1
    }
    
    model = lgb.train(
        params,
        lgb.Dataset(X_train, label=y_train),
        num_boost_round=2000,
        valid_sets=[lgb.Dataset(X_test, label=y_test)],
        callbacks=[
            lgb.early_stopping(stopping_rounds=100, verbose=True),
            lgb.log_evaluation(100)
        ]
    )
    
    # Evaluación
    y_pred = np.round(model.predict(X_test))
    report = classification_report(y_test, y_pred, output_dict=True)
    score = report['accuracy']
    
    if score > best_score:
        best_score = score
        best_model = model
        print(f"🔥 Nuevo mejor modelo (Accuracy: {score:.4f})")

# 7. Guardado del Modelo
joblib.dump(best_model, 'best_lgbm_model.pkl', compress=('zlib', 9))

print(f"\n⏱️ Tiempo Total: {(datetime.now()-start_time).total_seconds()/3600:.2f} horas")
print(f"🎯 Mejor Accuracy: {best_score:.4f}")
