//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input double min_probabilidad = 0.7; // Mínima confianza para operar
input double lote = 0.1;
input int stop_loss = 50;           // SL en pips
input int take_profit = 100;        // TP en pips

//+------------------------------------------------------------------+
//| Función principal (OnTick)                                       |
//+------------------------------------------------------------------+
void OnTick() {
   // 1. Obtener señal de la IA
   double probabilidad = GetIAPrediction();
   
   // 2. Generar señal tradicional (ej: RSI < 30 = compra)
   double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   int señal_tradicional = 0;
   if (rsi < 30) señal_tradicional = 1;  // Compra
   if (rsi > 70) señal_tradicional = -1; // Venta
   
   // 3. Operar solo si IA y señal tradicional coinciden
   if (señal_tradicional != 0 && probabilidad >= min_probabilidad) {
      double sl = (señal_tradicional == 1) ? Bid - stop_loss*Point : Ask + stop_loss*Point;
      double tp = (señal_tradicional == 1) ? Bid + take_profit*Point : Ask - take_profit*Point;
      
      if (señal_tradicional == 1) 
         OrderSend(Symbol(), OP_BUY, lote, Ask, 3, sl, tp, "EA+IA", 0, 0, clrGreen);
      else 
         OrderSend(Symbol(), OP_SELL, lote, Bid, 3, sl, tp, "EA+IA", 0, 0, clrRed);
   }
}
