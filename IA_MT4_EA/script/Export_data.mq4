//+------------------------------------------------------------------+
//| Script para exportar datos a CSV                                  |
//+------------------------------------------------------------------+
void OnStart() {
   int handle = FileOpen("datos_entrenamiento.csv", FILE_WRITE|FILE_CSV);
   FileWrite(handle, "Time,Open,High,Low,Close,RSI,ATR,MA,Target"); // Encabezados

   for(int i=1000; i>=0; i--) {
      double rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, i);
      double atr = iATR(NULL, 0, 14, i);
      double ma = iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, i);
      
      // Target: 1 si la siguiente vela es alcista, 0 si es bajista
      int target = (Close[i] > Open[i]) ? 1 : 0; 

      FileWrite(handle, 
         Time[i], Open[i], High[i], Low[i], Close[i],
         rsi, atr, ma, target
      );
   }
   FileClose(handle);
   Print("Datos exportados correctamente.");
}
