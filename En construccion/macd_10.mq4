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
input double lots = 0.10;
input double take_profit = 150.00;

double lot = lots;

/*
double posicion = uno - 10*Point*Digits;
double posicion = uno + 10*Point*Digits;
*/
int count = 0;
int count1 = 0;
int count2 = 0;
int count3 = 0;

bool close_trades = false;
bool open_price = true;
int trade_profit = 350;
double posicion = 0.00;
void OnTick()
  {
  
  MqlTick last_tick;
  SymbolInfoTick(Symbol(), last_tick);
  
  if (OrdersTotal() == 0 && open_price == true){
  posicion = last_tick.ask; 
  open_price = false;
  }
  
  double macd_0 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_SMA,0);
  double macd_1 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double macd_2 = iMACD(Symbol(),PERIOD_W1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  
  if (macd_0 >= 0.00000 && last_tick.ask >= posicion + 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
          Print("OrderSend ERROR" + GetLastError());
      posicion += 50*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 >= 0.00000 && last_tick.ask <= posicion - 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
          Print("OrderSend ERROR" + GetLastError());
      posicion -= 50*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 <= 0.00000 && last_tick.ask <= posicion - 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
          Print("OrderSend ERROR" + GetLastError());
      posicion -= 50*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 <= 0.00000 && last_tick.ask >= posicion + 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
          Print("OrderSend ERROR" + GetLastError());
      posicion += 50*Point*Digits;
      posicion = posicion;
  }
  
  /****************************************
  CALCIULAMOS BENEFICIOS
  ****************************************/
  double close_profit = 0.00;
  for (count1 = 0; count1 <= OrdersTotal(); count1++){
     if (!OrderSelect(count1,SELECT_BY_POS, MODE_TRADES))
         continue;
     close_profit += OrderProfit();
     
     if (close_profit >= take_profit)
         close_trades = true;
     
  }
  while (close_trades == true){
  
  for (count2 = 0; count2 <= OrdersTotal(); count2++){
     if (!OrderSelect(count2,SELECT_BY_POS, MODE_TRADES))
         continue;
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
             OrderClose(OrderTicket(), OrderLots(),Bid,5, Yellow);
         }
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
             OrderClose(OrderTicket(), OrderLots(),Ask,5, Yellow);
         }
        
     }
     close_trades = false;
  
  }  
  
  for (count3 = 0; count3 <= OrdersTotal(); count3++){
     if (!OrderSelect(count3,SELECT_BY_POS, MODE_TRADES))
         continue;
         if (macd_1 <= macd_2){
             if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
                 OrderClose(OrderTicket(), OrderLots(),Bid,5, Yellow);
             }
         }
         if (macd_1 >= macd2) {
             if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
                 OrderClose(OrderTicket(), OrderLots(),Ask,5, Yellow);
             }
         }
        
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
