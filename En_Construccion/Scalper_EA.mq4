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

input double lots = 1.00;

double top = 0; 
double down = 10000;

double rsi_top = 0;
double rsi_down = 100;

int margen = 75;

void OnTick()
  {
      MqlTick last_tick;
      SymbolInfoTick(NULL,last_tick);
      
      if (last_tick.ask >= top)
          top = last_tick.ask;
      
      if (last_tick.bid <= down)
          down = last_tick.bid;
          
      double rsi_indicator = iRSI(NULL, PERIOD_M5, 7, PRICE_OPEN, 0);
      
      if (rsi_indicator >= rsi_top)
          rsi_top = rsi_indicator;
       
      if (rsi_indicator <= rsi_down)
          rsi_down = rsi_indicator;
          
      if (rsi_indicator <= 30 && OrdersTotal() == 0 && last_tick.ask >= down + NormalizeDouble(margen*Point, Digits)){
          OrderSend(NULL, OP_BUY, lots, Ask, 7,0,0, "Orden de compra abierta", 12345,0, Green);
          down = 100;
      }
      
      if (rsi_indicator >= 70 && OrdersTotal() == 0 && last_tick.bid >= top - NormalizeDouble(margen*Point, Digits)){
          OrderSend(NULL, OP_SELL, lots, Bid, 7,0,0, "Orden de ventaa abierta", 12345,0, Green);
          top = 0;
      }
      
      for (int i = 0; i < OrdersTotal(); i++)
      {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY)
          {
               if (last_tick.ask <= top - NormalizeDouble(margen*Point, Digits))
                   OrderClose(OrderTicket(), OrderLots(), Bid, Red);
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL)
          {
               if (last_tick.bid >= down + NormalizeDouble(margen*Point, Digits))
                   OrderClose(OrderTicket(), OrderLots(), Ask, Red);
          }
      }
   
  }
//+------------------------------------------------------------------+
