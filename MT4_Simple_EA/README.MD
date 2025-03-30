
```markdown
# WaveNewsEA for MT4

Forex EA that trades using price waves + economic news.

## 🚀 How to Use

1. **Download Files**:
   - `EA_NEWS.mq4` (main EA file)
   - `https://github.com/dingmaotu/mql4-lib` (library for news API)

2. **Install in MT4**:
   - Copy `EA_NEWS.mq4` to `MQL4/Experts/`
   - Copy `mql4-lib` folder to `MQL4/Include/`

3. **Set Up API** (optional):
   ```mql4
   input string apiKey = "YOUR_KEY"; // Replace if using Investing.com
   ```

4. **Attach to Chart**:
   - Drag EA onto any Forex chart (EURUSD/M15 recommended)
   - Enable "Allow WebRequests" in MT4 settings

5. **Basic Settings**:
   ```mql4
   riskPercent = 1.0; // Risk per trade (1%)
   newsThreshold = 0.5; // Medium news impact
   ```

## ⚙️ Default Configuration
- Checks news every **5 minutes**
- Requires **ADX > 25** (strong trend)
- Avoids trading during **high spread**

## 📈 Recommended Pairs
| Pair | Timeframe | 
|------|-----------|
| EURUSD | M15/H1 |
| USDJPY | H1 |
| GBPUSD | H4 |

> 💡 **Tip**: Test in demo account first!
```

### Key Differences:
1. **Removed**:
   - Performance metrics
   - License info
   - Contribution notes
   - Complex tables

2. **Added**:
   - Minimal install steps
   - Quickstart settings
   - Pair/timeframe table
   - Single emoji per section

This version is optimized for users who just want to **install and run** without extra details.
