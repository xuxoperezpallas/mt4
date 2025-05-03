# Smart Hedge EA for MetaTrader 4/5

![EA Logo](https://via.placeholder.com/150) (Optional: Add actual logo if available)

## 📌 Descripción

Este Expert Advisor (EA) implementa una estrategia avanzada de cobertura dinámica con:

- **Equilibrio estricto** entre posiciones de compra/venta (margen ≈ 0)
- **Gestión inteligente de Stop Loss** para asegurar beneficios
- **Cierre selectivo** de posiciones en extremos
- **Reapertura automática** para mantener exposición constante

## 🔥 Características Clave

✅ **Cobertura perfecta 1:1**  
✅ Stop Loss dinámico con toma de beneficios automática  
✅ Protección contra acumulación en extremos  
✅ Sin Take Profit fijo (cierre por movimiento de precio)  
✅ Normalización precisa de precios  

## ⚙️ Parámetros

| Parámetro           | Descripción                         | Valor por Defecto |
|---------------------|-----------------------------------|------------------|
| `LotSize`           | Tamaño del lote                   | 0.1              |
| `GridStep`          | Distancia entre niveles (pips)    | 200              |
| `ProfitDistance`    | Beneficio objetivo (pips)         | 100              |
| `MaxAccumulation`   | Máximo posiciones en extremos     | 3                |

## 📊 Lógica de Trading

1. **Apertura Inicial**:
   - Abre 1 compra + 1 venta al inicio
2. **Movimiento Alcista**:
   - Si precio sube +200 pips en compra → SL = +100 pips
   - Al retroceder 100 pips → Cierra con ganancia
3. **Movimiento Bajista**:
   - Si precio baja -200 pips en venta → SL = -100 pips
   - Al retroceder 100 pips → Cierra con ganancia
4. **Acumulación en Extremos**:
   - Cierra 3 posiciones superiores + 3 inferiores si hay desbalance

## 📥 Instalación

1. Descargar archivo `.mq4`/`.mq5`
2. Copiar a `MQL4/Experts` o `MQL5/Experts`
3. Reiniciar MetaTrader
4. Arrastrar EA al gráfico

## ⚠️ Requisitos

- MetaTrader 4 o 5
- Broker con spreads bajos (< 2 pips)
- Cuenta con cobertura permitida

## 📈 Rendimiento Esperado

| Mercado          | Rentabilidad* |
|------------------|-------------|
| Lateral          | Alta        |
| Volátil         | Media-Alta  |
| Tendencia fuerte | Baja        |

*Depende de configuración y condiciones de mercado

## 📜 Licencia

Código abierto (MIT License) - Libre uso y modificación

---

**📌 Nota**: Este EA funciona mejor en pares con alta volatilidad como GBP/JPY o EUR/JPY. Se recomienda testing previo en cuenta demo.
