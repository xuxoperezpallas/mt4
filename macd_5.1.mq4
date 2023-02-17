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
input double lots = 0.02;


double lot = lots;

/*
double posicion = uno - 10*Point*Digits;
double posicion = uno + 10*Point*Digits;
*/

double posicion = Close[1];

double posicion_larga = posicion - 25*Point*Digits;
double posicion_corta = posicion + 25*Point*Digits;

int take_profit = 50;
int stop_lost = 50;

int contador_1 = 0;

void OnTick()
  {
  
  MqlTick last_tick;
  SymbolInfoTick(Symbol(), last_tick);

  
  double macd_0 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_EMA,0);
  double macd_D1_1 = iMACD(Symbol(),PERIOD_D1,6,13,4,PRICE_CLOSE,MODE_SIGNAL,0);
  double macd_D1_2 = iMACD(Symbol(),PERIOD_D1,6,13,4,PRICE_CLOSE,MODE_MAIN,0);
 // double macd_W1_1 = iMACD(Symbol(),PERIOD_W1,6,13,4,PRICE_CLOSE,MODE_SIGNAL,0);
 // double macd_W1_2 = iMACD(Symbol(),PERIOD_W1,6,13,4,PRICE_CLOSE,MODE_MAIN,0); 
  

  if (macd_D1_1 <= macd_D1_2  && last_tick.ask >= posicion_larga + 20*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
          Print("OrderSend ERROR" + GetLastError());
      posicion_larga += 20*Point*Digits;
      posicion_corta = posicion_larga;
  }
  
  if (macd_D1_1 <= macd_D1_2   && last_tick.ask <= posicion_corta - 20*Point*Digits){
     // if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
       //   Print("OrderSend ERROR" + GetLastError());
      posicion_corta -= 20*Point*Digits;
     // posicion_larga = posicion_corta;
  }
  

  
  if (macd_D1_1 >= macd_D1_2   && last_tick.ask <= posicion_corta - 20*Point*Digits){
      if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
          Print("OrderSend ERROR" + GetLastError());
      posicion_corta -= 20*Point*Digits;
      posicion_larga = posicion_corta;
  }
  
  if (macd_D1_1 >= macd_D1_2  && last_tick.ask >= posicion_larga + 20*Point*Digits){
   //   if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
     //     Print("OrderSend ERROR" + GetLastError());
      posicion_larga += 20*Point*Digits;
     // posicion_corta = posicion_larga;
  }
  
  for (contador_1 = 0; contador_1 <= OrdersTotal(); contador_1++){
      
      if (!OrderSelect(contador_1,SELECT_BY_POS, MODE_TRADES))
          continue;
      
      if(OrderSymbol() == Symbol() && OrderType() == OP_BUY){
           if (macd_D1_1 >= macd_D1_2) {
               OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - stop_lost*Point,Digits),NormalizeDouble(OrderOpenPrice() + take_profit*Point,Digits),0, Red);
               Print("Take Profit = " + NormalizeDouble(OrderOpenPrice() + take_profit*Point,Digits));
           }
           else if (macd_D1_1 >= macd_D1_2 && OrderProfit() <= -30.00){
               OrderClose(OrderTicket(), OrderLots(),Bid,5, Yellow);
           }
      }
      
      if(OrderSymbol() == Symbol() && OrderType() == OP_SELL){
           if (macd_D1_1 <= macd_D1_2) {
               OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + stop_lost*Point,Digits),NormalizeDouble(OrderOpenPrice() - take_profit*Point,Digits),0, Red);
               Print("Take Profit = " + NormalizeDouble(OrderOpenPrice() - take_profit*Point,Digits));
           }
           else if (macd_D1_1 <= macd_D1_2 && OrderProfit() <= -30.00){
               OrderClose(OrderTicket(), OrderLots(),Ask,5, Yellow);
           }
      }
         
         
  }
  
   
}
//+------------------------------------------------------------------+
