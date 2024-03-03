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

double primer_constante = Close[1];

double constante_compra = primer_constante - 150;
double constante_venta = primer_constante + 150;


void OnTick()
  {
      MqlTick last_tick;

      SymbolInfoTick(Symbol(), last_tick);          
          
      if (last_tick.ask >= constante_compra + NormalizeDouble(300*Point,Digits)){
          OrderSend(NULL, OP_BUY, lots, Ask, 7,0,0, "Orden de compra abierta", 12345,0, Green);
          Print ("+++++++++++++++++++++++++++++++++++++++++++++++++++");
          constante_compra += 300;
          constante_venta = constante_compra;
      }
      
      if (last_tick.bid <= constante_venta - NormalizeDouble(300*Point,Digits)){
          OrderSend(NULL, OP_SELL, lots, Bid, 7,0,0, "Orden de venta abierta", 12345,0, Green);
          Print ("---------------------------------------------------");
          constante_venta -= 300;
          constante_compra = constante_compra;
      }
      
      for (int i = 0; i < OrdersTotal(); i++)
      {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY)
          {
               if (last_tick.bid < OrderOpenPrice() + NormalizeDouble(150*Point,Digits)){
                   Print("ccccccccccccccccccccccccccccccccccccccccccc");
                   OrderClose(OrderTicket(), OrderLots(), Bid, Red);
               }
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL)
          {
               if (last_tick.ask > OrderOpenPrice() - NormalizeDouble(150*Point,Digits)) {
                   Print("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv");
                   OrderClose(OrderTicket(), OrderLots(), Ask, Red);
               }
          }
      }
   
  }
//+------------------------------------------------------------------+
