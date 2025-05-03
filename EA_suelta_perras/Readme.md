# EA de Cobertura Dinámica para MetaTrader 4/5

## 📌 Descripción
Este Expert Advisor (EA) para MetaTrader 4/5 implementa una estrategia de cobertura dinámica que:
✅ Mantiene un equilibrio entre posiciones de compra y venta
✅ Coloca stop-loss como take-profit (ejemplo: 100 pips)
✅ Abre nuevas posiciones de cobertura cuando el mercado se mueve en contra
✅ Cierra posiciones con beneficio y reabre nuevas operaciones

Ideal para mercados con oscilaciones laterales o tendencias con retrocesos frecuentes.

---

## ⚙️ Parámetros Ajustables
| Parámetro           | Descripción                                  | Valor por Defecto |
|---------------------|--------------------------------------------|------------------|
| TakeProfitPips      | Beneficio objetivo en pips                  | 100 pips         |
| HedgeDistance       | Distancia para nueva cobertura              | 50 pips          |
| LotSize             | Volumen de operación (0.1, 0.5, 1.0)       | 0.1              |
| MaxPositions        | Máximo de posiciones por lado              | 10               |

---

## 📊 Lógica del EA
1. **Balance de Posiciones**
   - Si hay más compras, abre venta (y viceversa)
   - Mantiene igual número de operaciones en ambos sentidos

2. **Gestión de Beneficios**
   - Cada posición abre con stop-loss como take-profit
   - Si el precio sube/baja 100 pips, cierra con ganancia

3. **Reapertura Automática**
   - Al cerrar con beneficio, abre nueva operación opuesta

---

## 📈 Escenarios
### 🔹 Mercado Lateral
- Obtiene beneficios en cada oscilación
- Cierra y reabre continuamente

### 🔹 Mercado con Tendencia
- Funciona mejor con retrocesos frecuentes
- Riesgo en tendencias fuertes sin correcciones

---

## ⚠️ Advertencias
❌ No para tendencias fuertes sin retrocesos
❌ Requiere spreads bajos
❌ Usa más margen por posiciones opuestas

🔹 Recomendación:
- Optimizar parámetros para cada activo
- Probar en backtest y forward-test primero

---

## 📥 Instalación
1. Descargar archivo .mq4/.mq5
2. Copiar a MQL4/Experts o MQL5/Experts
3. Reiniciar MT4/MT5 y arrastrar EA al gráfico

---

## 📜 Licencia
🔓 Código abierto - Libre uso y modificación

---
🚀 **¿Listo para probarlo?** ¡Configura, prueba y optimiza!
