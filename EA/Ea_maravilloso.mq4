//+------------------------------------------------------------------+
//|                      UltraMinimalistEA.mq4                       |
//+------------------------------------------------------------------+
#property strict

// Inputs
input double   Lots           = 0.1;       // Tamaño del lote
input double   OpenDistance   = 50.0;      // Distancia entre aperturas (pips)
input double   StopLoss       = 100.0;     // StopLoss inicial (pips)
input double   TriggerDist    = 30.0;      // Distancia para activar SL inverso (pips)
input double   InverseSLDist  = 50.0;      // Distancia del SL inverso (pips)
input double   MaxProfit      = 500.0;     // Ganancia máxima para cierre (USD)

// Variables globales
double lastBuyPrice  = 0;
double lastSellPrice = 0;
bool   closeAll      = false;

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // 1. Lógica de cierre por profit máximo
   if(AccountEquity() - AccountBalance() >= MaxProfit)
      closeAll = true;
   
   if(closeAll && OrdersTotal() == 0)
      closeAll = false;
   
   if(closeAll)
   {
      for(int i = OrdersTotal()-1; i >= 0; i--)
         if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
            OrderClose(OrderTicket(), OrderLots(), OrderType()==OP_BUY ? Bid : Ask, 3);
      return;
   }

   // 2. Lógica de apertura de órdenes
   if(Ask >= NormalizeDouble(lastBuyPrice + OpenDistance*Point, Digits) || lastBuyPrice == 0)
   {
      OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, 
               NormalizeDouble(Ask - StopLoss*Point, Digits), 
               0, "Compra", 0, 0, clrGreen);
      lastBuyPrice = Ask;
      lastSellPrice = lastBuyPrice;
   }
   
   if(Bid <= NormalizeDouble(lastSellPrice - OpenDistance*Point, Digits) || lastSellPrice == 0)
   {
      OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, 
               NormalizeDouble(Bid + StopLoss*Point, Digits), 
               0, "Venta", 0, 0, clrRed);
      lastSellPrice = Bid;
      lastBuyPrice = lastSellPrice;
   }

   // 3. Gestión de SL inverso
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
      {
         if(OrderType() == OP_BUY && 
            Bid >= NormalizeDouble(OrderOpenPrice() + TriggerDist*Point, Digits))
         {
            OrderModify(OrderTicket(), OrderOpenPrice(), 
                       NormalizeDouble(OrderOpenPrice() + InverseSLDist*Point, Digits), 
                       0, 0, clrBlue);
         }
         
         if(OrderType() == OP_SELL && 
            Ask <= NormalizeDouble(OrderOpenPrice() - TriggerDist*Point, Digits))
         {
            OrderModify(OrderTicket(), OrderOpenPrice(), 
                       NormalizeDouble(OrderOpenPrice() - InverseSLDist*Point, Digits), 
                       0, 0, clrRed);
         }
      }
   }
}
