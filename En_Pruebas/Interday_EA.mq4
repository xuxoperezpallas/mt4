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

int margen_open = 90;

input int margen_close = 100;
input int take_prifit = 100;
input int stop_loss = 100;

void OnTick()
  {
      MqlTick last_tick;
      SymbolInfoTick(NULL,last_tick);
      int day = DayOfWeek();
      
      int h = TimeHour(TimeCurrent());
      
      if ( day == 0 && h > 23 && day == 1 && h < 2) 
          trade = false;
      
      else {
          trade = true;
      }
            
      double atr_indicator = iATR(NULL, PERIOD_H1, 1, 0);
      
      if (last_tick.ask >= top)
          top = last_tick.ask;
      
      if (last_tick.bid <= down)
          down = last_tick.bid;

      Print ("top: " + top);
      Print("down: " + down);
          
          
      if (trade == true && atr_indicator >= 0.0013 && OrdersTotal() == 0 && last_tick.ask >= down + NormalizeDouble(margen_open*Point, Digits)){
          OrderSend(NULL, OP_BUY, lots, Ask, 7,last_tick.ask - NormalizeDouble(stop_loss*Point,Digits),last_tick.ask + NormalizeDouble(take_prifit*Point,Digits), "Orden de compra abierta", 12345,0, Green);
          Print("down: " + down);
          top = 0;
          down = 10000;
      }
      
      if (trade == true && atr_indicator >= 0.0013 && OrdersTotal() == 0 && last_tick.bid <= top - NormalizeDouble(margen_open*Point, Digits)){
          OrderSend(NULL, OP_SELL, lots, Bid, 7,last_tick.bid + NormalizeDouble(stop_loss*Point,Digits),last_tick.bid - NormalizeDouble(take_prifit*Point,Digits), "Orden de venta abierta", 12345,0, Green);
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
               if (last_tick.ask <= top - NormalizeDouble(margen_close*Point, Digits))
                   OrderClose(OrderTicket(), OrderLots(), Bid, Red);
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL)
          {
               if (last_tick.bid >= down + NormalizeDouble(margen_close*Point, Digits))
                   OrderClose(OrderTicket(), OrderLots(), Ask, Red);
          }
      }
   
  }
//+------------------------------------------------------------------+
