//+------------------------------------------------------------------+
//| Script de Exportación para IA (500K velas M15)                   |
//+------------------------------------------------------------------+
#property strict

void OnStart()
{
   int total_velas = 500000; // 5.7 años de datos M15
   string nombre_archivo = "EURUSD_M15_IA.csv";
   
   int handle = FileOpen(nombre_archivo, FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(handle == INVALID_HANDLE) {
      Print("Error al crear archivo: ", GetLastError());
      return;
   }
   
   // Encabezados (matching Python features)
   FileWrite(handle, "Time,Open,High,Low,Close,RSI_14,ATR_14,MA_50,MA_200,Body_Size,Candle_Size");
   
   for(int i = total_velas-1; i >= 0; i--)
   {
      double close = iClose(NULL, PERIOD_M15, i);
      double open = iOpen(NULL, PERIOD_M15, i);
      double body_size = MathAbs(close - open);
      
      FileWrite(handle,
         iTime(NULL, PERIOD_M15, i),
         DoubleToString(open, 5),
         DoubleToString(iHigh(NULL, PERIOD_M15, i), 5),
         DoubleToString(iLow(NULL, PERIOD_M15, i), 5),
         DoubleToString(close, 5),
         DoubleToString(iRSI(NULL, PERIOD_M15, 14, PRICE_CLOSE, i), 2),
         DoubleToString(iATR(NULL, PERIOD_M15, 14, i), 5),
         DoubleToString(iMA(NULL, PERIOD_M15, 50, 0, MODE_SMA, PRICE_CLOSE, i), 5),
         DoubleToString(iMA(NULL, PERIOD_M15, 200, 0, MODE_SMA, PRICE_CLOSE, i), 5),
         DoubleToString(body_size, 5),
         DoubleToString(iHigh(NULL, PERIOD_M15, i) - iLow(NULL, PERIOD_M15, i), 5)
      );
      
      if(i % 50000 == 0) {
         Print("Progreso: ", (total_velas-i), "/", total_velas);
         FileFlush(handle); // Guardar periódicamente
      }
   }
   
   FileClose(handle);
   Print("Exportación completada: ", nombre_archivo);
}
