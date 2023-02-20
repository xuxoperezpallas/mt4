//+------------------------------------------------------------------+
//|                                                         macd.mq4 |
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
input double lots = 0.05;
double lot = lots;

double posicion = Close[1];

/*
double posicion = uno - 10*Point*Digits;
double posicion = uno + 10*Point*Digits;
*/
int count = 0;

int trade_profit = 350;

void OnTick()
  {
  
  MqlTick last_tick;
  SymbolInfoTick(Symbol(), last_tick);
  
  double macd_0 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_SMA,0);
  double macd_1 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double macd_2 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  
  if (macd_0 >= 0.00000 && last_tick.ask >= posicion + 100*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
          Print("OrderSend ERROR" + GetLastError());
      posicion += 100*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 >= 0.00000 && last_tick.ask <= posicion - 100*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
          Print("OrderSend ERROR" + GetLastError());
      posicion -= 100*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 <= 0.00000 && last_tick.ask <= posicion - 100*Point*Digits){
      if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
          Print("OrderSend ERROR" + GetLastError());
      posicion -= 100*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 <= 0.00000 && last_tick.ask >= posicion + 100*Point*Digits){
      if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
          Print("OrderSend ERROR" + GetLastError());
      posicion += 100*Point*Digits;
      posicion = posicion;
  }
  
  for (count = 0; count <= OrdersTotal(); count++){
     if (!OrderSelect(count,SELECT_BY_POS, MODE_TRADES))
         continue;

     
     if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
         if(macd_1 <= macd_2){
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),0,NormalizeDouble(OrderOpenPrice()+Point*trade_profit,Digits),
            0, White))
               Print("OrderModify  ERROR OP_BUY final: " + GetLastError()+ " " + OrderTicket());
         }
     }
     
     if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
         if(macd_1 >= macd_2){
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),0,NormalizeDouble(OrderOpenPrice()-Point*trade_profit,Digits),
            0, White))
               Print("OrderModify  ERROR OP_SELL final: " + GetLastError()+ " " + OrderTicket());
         }
     }
     
  }

   
  }
//+------------------------------------------------------------------+
