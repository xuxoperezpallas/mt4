//+------------------------------------------------------------------+
//|                      Hedge Grid EA                               |
//|                Copyright 2023, Forex Robot Factory               |
//|                        forexrobotfactory.com                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Forex Robot Factory"
#property link      "forexrobotfactory.com"
#property version   "1.10"
#property strict

//+------------------------------------------------------------------+
//| Input Parameters                                                |
//+------------------------------------------------------------------+
input double LotSize = 0.1;               // Tamaño del lote para cada operación
input int InitialStopLoss = 100;          // Stop Loss inicial en pips
input int TakeProfit = 300;               // Take Profit objetivo en pips
input int GridDistance = 200;             // Distancia entre pares en pips
input int MaxPairs = 5;                   // Máximo número de pares de operaciones
input int TrailingStop = 50;              // Trailing stop en pips
input int MinDistance = 50;               // Distancia mínima del precio para nueva apertura

//+------------------------------------------------------------------+
//| Global Variables                                                |
//+------------------------------------------------------------------+
int magicNumber = 202310;
double lastBuyPrice = 0;
double lastSellPrice = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Verificar si los parámetros son válidos
   if(InitialStopLoss <= 0 || TakeProfit <= 0 || GridDistance <= 0)
   {
      Alert("Parámetros incorrectos! StopLoss, TakeProfit y GridDistance deben ser > 0");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   // Asegurarse que la distancia de la grid es mayor que el stop loss inicial
   if(GridDistance <= InitialStopLoss)
   {
      Alert("GridDistance debe ser mayor que InitialStopLoss!");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Limpiar al desinicializar
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 1. Gestionar las posiciones abiertas
   ManageOpenPositions();
   
   // 2. Verificar si necesitamos abrir nuevos pares
   CheckForNewPairs();
   
   // 3. Verificar si hemos alcanzado el take profit global
   CheckGlobalTakeProfit();
}

//+------------------------------------------------------------------+
//| Gestiona posiciones abiertas con trailing stop                   |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            // Aplicar trailing stop
            if(OrderType() == OP_BUY)
            {
               double newStop = Bid - TrailingStop * Point;
               if(newStop > OrderStopLoss() || OrderStopLoss() == 0)
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrBlue);
               }
            }
            else if(OrderType() == OP_SELL)
            {
               double newStop = Ask + TrailingStop * Point;
               if(newStop < OrderStopLoss() || OrderStopLoss() == 0)
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrRed);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Verifica si necesita abrir nuevos pares de operaciones           |
//+------------------------------------------------------------------+
void CheckForNewPairs()
{
   // Obtener el precio actual
   double currentAsk = Ask;
   double currentBid = Bid;
   
   // Contar pares actuales
   int currentPairs = CountOpenPairs();
   
   // Verificar si podemos abrir más pares
   if(currentPairs >= MaxPairs) return;
   
   // Verificar distancia para nueva apertura (compra)
   if(lastBuyPrice == 0 || (currentAsk <= (lastBuyPrice - GridDistance * Point)))
   {
      if(MathAbs(currentAsk - lastBuyPrice) >= MinDistance * Point || lastBuyPrice == 0)
      {
         OpenBuyOrder(currentAsk);
         OpenSellOrder(currentBid);
         lastBuyPrice = currentAsk;
         lastSellPrice = currentBid;
      }
   }
   
   // Verificar distancia para nueva apertura (venta)
   if(lastSellPrice == 0 || (currentBid >= (lastSellPrice + GridDistance * Point)))
   {
      if(MathAbs(currentBid - lastSellPrice) >= MinDistance * Point || lastSellPrice == 0)
      {
         OpenBuyOrder(currentAsk);
         OpenSellOrder(currentBid);
         lastBuyPrice = currentAsk;
         lastSellPrice = currentBid;
      }
   }
}

//+------------------------------------------------------------------+
//| Abre una orden de compra                                         |
//+------------------------------------------------------------------+
void OpenBuyOrder(double price)
{
   double stopLoss = price - InitialStopLoss * Point;
   double takeProfit = price + TakeProfit * Point;
   
   OrderSend(Symbol(), OP_BUY, LotSize, price, 3, stopLoss, takeProfit, "Buy Hedge", magicNumber, 0, clrBlue);
}

//+------------------------------------------------------------------+
//| Abre una orden de venta                                          |
//+------------------------------------------------------------------+
void OpenSellOrder(double price)
{
   double stopLoss = price + InitialStopLoss * Point;
   double takeProfit = price - TakeProfit * Point;
   
   OrderSend(Symbol(), OP_SELL, LotSize, price, 3, stopLoss, takeProfit, "Sell Hedge", magicNumber, 0, clrRed);
}

//+------------------------------------------------------------------+
//| Cuenta el número de pares abiertos                               |
//+------------------------------------------------------------------+
int CountOpenPairs()
{
   int buyCount = 0;
   int sellCount = 0;
   
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            if(OrderType() == OP_BUY) buyCount++;
            else if(OrderType() == OP_SELL) sellCount++;
         }
      }
   }
   
   return (int)MathMin(buyCount, sellCount);
}

//+------------------------------------------------------------------+
//| Verifica si se alcanzó el take profit global                     |
//+------------------------------------------------------------------+
void CheckGlobalTakeProfit()
{
   double totalProfit = 0;
   
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            totalProfit += OrderProfit();
         }
      }
   }
   
   // Si el beneficio total alcanza el objetivo, cerrar todas las posiciones
   if(totalProfit >= TakeProfit * Point * LotSize * 10 * CountOpenPairs())
   {
      CloseAllPositions();
   }
}

//+------------------------------------------------------------------+
//| Cierra todas las posiciones                                      |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            if(OrderType() == OP_BUY)
               OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
            else if(OrderType() == OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE);
         }
      }
   }
   
   // Resetear precios de referencia
   lastBuyPrice = 0;
   lastSellPrice = 0;
}

//+------------------------------------------------------------------+
