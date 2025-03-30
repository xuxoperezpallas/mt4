Here's a clean, minimal `README.md` for your GitHub repository:

```markdown
# MT4 Trading EA with Machine Learning

A MetaTrader 4 Expert Advisor (EA) that combines technical indicators with machine learning for improved trade signals.

## How It Works

1. **Data Collection**  
   - MT4 script exports historical price data + indicators (RSI, ATR, MA) to CSV
   - Labels data based on next candle's direction (1=up, 0=down)

2. **Machine Learning Model**  
   - Python script trains a Random Forest classifier
   - Input features: Technical indicators  
   - Output: Probability of next candle being bullish

3. **Real-Time Trading**  
   - EA checks two conditions before trading:
     1. Traditional signal (e.g. RSI < 30)
     2. ML model confidence > 70%
   - Only executes trades when both agree

## Requirements

- MT4 (Build 600+)
- Python 3.8+ with packages:
  ```bash
  pip install pandas scikit-learn joblib
  ```

## Installation

1. Copy `.mq4` files to MT4's `Experts/` folder
2. Place `modelo_ia.pkl` in MT4's `Files/` folder
3. Run `servidor_ia.py` in background:
   ```bash
   python servidor_ia.py
   ```

## Backtesting

Optimize these parameters in MT4 Strategy Tester:
- `min_probability` (0.6-0.8)
- `stop_loss` (30-50 pips)
- `take_profit` (60-100 pips)

## Key Metrics
- ✅ Profit Factor > 1.5  
- ✅ Win Rate > 60%  
- ❌ Max Drawdown < 20%

## Disclaimer

Use at your own risk. Always test in demo accounts first.
```

### Key Features:
- Uses minimal dependencies
- Clear separation of components
- Focuses on practical implementation
- Includes risk disclaimer
