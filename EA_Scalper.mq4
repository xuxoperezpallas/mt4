//+------------------------------------------------------------------+
//|                                                   EA_Scalper.mq4 |
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

input double lot = 0.01;
input double profit = 0.10;
input int stop_loss = 40;
input double loss = 10.00;
input int margen = 20;
input bool finalizar = false;

bool trade = true;
bool close = false;

double balance = AccountBalance();

double last_buy = Bid;
double last_sell = Ask;
 
void OnTick()
  {
   MqlTick last_tick;
   
   SymbolInfoTick(Symbol(), last_tick);
   
   if (OrdersTotal() == 0) {
       balance = AccountBalance();
       close = false;
   }
   
   if (OrdersTotal() == 0 && finalizar == true) {
       trade = false;
   }
   
   if (AccountEquity() - balance >= profit) {
       close = true;
   }
   
   if (balance - AccountEquity() >= loss){
       close = true;
   } else {
       close = false;
   }
   
   if (trade && last_tick.bid >= last_buy + NormalizeDouble(margen*Point, Digits)){
       OrderSend(Symbol(), OP_BUY, lot, Bid, 3, Bid - NormalizeDouble(stop_loss*Point,Digits),0, "orden de compra abierta",
       12345, 0, Black);
       last_buy += NormalizeDouble(margen*Point,Digits);
       last_sell = last_buy;
   }
   
      if (trade && last_tick.ask <= last_sell - NormalizeDouble(margen*Point, Digits)){
       OrderSend(Symbol(), OP_SELL, lot, Ask, 3,Ask + NormalizeDouble(stop_loss*Point,Digits),0, "orden de venta abierta",
       12345, 0, Black);
       last_sell -= NormalizeDouble(margen*Point,Digits);
       last_buy = last_sell;
   }
   
   for (int i = 0; i < OrdersTotal(); i++){
       if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           continue;
       
       if (Symbol() == OrderSymbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL) && close) {
           OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, Black);
       }
   }
   
  }
//+------------------------------------------------------------------+
