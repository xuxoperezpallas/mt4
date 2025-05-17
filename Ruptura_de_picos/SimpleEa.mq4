//+------------------------------------------------------------------+
//|                                                      SimpleEA.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
#property version   "1.00"
#property strict

// Configuración de entrada
input double LotSize = 0.1;          // Tamaño del lote
input int    TakeProfit = 100;       // Take profit en puntos
input int    StopLoss = 50;          // Stop loss en puntos
input int    BarsToCheck = 50;       // Barras a analizar para encontrar picos/valles

// Variables globales
double lastPeak = 0;                 // Último pico alcista identificado
double lastTrough = 0;               // Último valle bajista identificado
bool   uptrend = false;              // Indica si estamos en tendencia alcista
bool   downtrend = false;            // Indica si estamos en tendencia bajista

//+------------------------------------------------------------------+
//| Función de inicialización del experto                            |
//+------------------------------------------------------------------+
int OnInit()
{
   // Verificar que el TakeProfit y StopLoss no sean cero
   if(TakeProfit <= 0 || StopLoss <= 0)
   {
      Print("TakeProfit y StopLoss deben ser mayores que cero");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Función de desinicialización del experto                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Limpiar objetos gráficos si es necesario
}

//+------------------------------------------------------------------+
//| Función tick del experto                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verificar si hay órdenes abiertas para no operar de nuevo
   if(OrdersTotal() > 0) return;
   
   // Identificar tendencia y picos/valles
   IdentifyTrendAndExtremes();
   
   // Operar según las condiciones
   if(uptrend)
   {
      // Si el precio supera el último pico, comprar
      if(Ask > lastPeak)
      {
         OpenOrder(OP_BUY);
      }
      // Si el precio rompe por debajo del último valle, vender
      else if(Bid < lastTrough)
      {
         OpenOrder(OP_SELL);
      }
   }
   else if(downtrend)
   {
      // Si el precio rompe por debajo del último valle, vender
      if(Bid < lastTrough)
      {
         OpenOrder(OP_SELL);
      }
      // Si el precio supera el último pico, comprar
      else if(Ask > lastPeak)
      {
         OpenOrder(OP_BUY);
      }
   }
}

//+------------------------------------------------------------------+
//| Identificar tendencia y extremos                                 |
//+------------------------------------------------------------------+
void IdentifyTrendAndExtremes()
{
   // Reiniciar variables
   uptrend = false;
   downtrend = false;
   lastPeak = 0;
   lastTrough = 0;
   
   // Encontrar picos y valles en el rango de barras especificado
   for(int i = 3; i < BarsToCheck; i++)
   {
      // Verificar si es un pico (high mayor que las dos barras anteriores y posteriores)
      if(High[i] > High[i+1] && High[i] > High[i+2] && 
         High[i] > High[i-1] && High[i] > High[i-2])
      {
         if(lastPeak == 0 || High[i] > lastPeak)
         {
            lastPeak = High[i];
         }
      }
      
      // Verificar si es un valle (low menor que las dos barras anteriores y posteriores)
      if(Low[i] < Low[i+1] && Low[i] < Low[i+2] && 
         Low[i] < Low[i-1] && Low[i] < Low[i-2])
      {
         if(lastTrough == 0 || Low[i] < lastTrough)
         {
            lastTrough = Low[i];
         }
      }
   }
   
   // Determinar la tendencia basada en los extremos
   if(lastPeak != 0 && lastTrough != 0)
   {
      if(lastPeak > lastTrough)
      {
         uptrend = true;
      }
      else
      {
         downtrend = true;
      }
   }
}

//+------------------------------------------------------------------+
//| Abrir una orden                                                  |
//+------------------------------------------------------------------+
void OpenOrder(int cmd)
{
   double price = (cmd == OP_BUY) ? Ask : Bid;
   double sl = (cmd == OP_BUY) ? price - StopLoss * Point : price + StopLoss * Point;
   double tp = (cmd == OP_BUY) ? price + TakeProfit * Point : price - TakeProfit * Point;
   
   int ticket = OrderSend(Symbol(), cmd, LotSize, price, 3, sl, tp, "EA Simple", 0, 0, clrNONE);
   
   if(ticket < 0)
   {
      Print("Error al abrir orden: ", GetLastError());
   }
}
//+------------------------------------------------------------------+
