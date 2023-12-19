//+------------------------------------------------------------------+
//|                                                   Scalper_EA.mq4 |
//|                                               Jesus Perez Pallas |
//|                                        xuxoperezpallas@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Jesus Perez Pallas"
#property link      "xuxoperezpallas@gmail.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

input double lots = 0.01;

double top = 0; 
double down = 10000;

bool trade = false;

input int margen = 125;

void OnTick()
  {
      MqlTick last_tick;
      SymbolInfoTick(NULL,last_tick);
      
      if (last_tick.ask >= top)
          top = last_tick.ask;
      
      if (last_tick.bid <= down)
          down = last_tick.bid;
          
      
      double atr_indicator = iATR(NULL, PERIOD_H1, 1, 0);
      
      if (atr_indicator <= 0.0012)
      {
          down = 10000;
          top = 0;
      }
          
      if (atr_indicator >= 0.0014 && OrdersTotal() == 0 && last_tick.ask >= down + NormalizeDouble(margen*Point, Digits)){
          OrderSend(NULL, OP_BUY, lots, Ask, 7,0,0, "Orden de compra abierta", 12345,0, Green);
          Print("down: " + down);
          top = 0;
          down = 10000;
      }
      
      if (atr_indicator >= 0.0014 && OrdersTotal() == 0 && last_tick.bid <= top - NormalizeDouble(margen*Point, Digits)){
          OrderSend(NULL, OP_SELL, lots, Bid, 7,0,0, "Orden de venta abierta", 12345,0, Green);
          Print ("top: " + top);
          top = 0;
          down = 10000;
      }
      
      for (int i = 0; i < OrdersTotal(); i++)
      {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY)
          {
               if (last_tick.ask >= down + NormalizeDouble(margen*Point, Digits))
                   OrderClose(OrderTicket(), OrderLots(), Bid, Red);
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL)
          {
               if (last_tick.bid <= top - NormalizeDouble(margen*Point, Digits))
                   OrderClose(OrderTicket(), OrderLots(), Ask, Red);
          }
      }
   
  }
//+------------------------------------------------------------------+
