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
int count4 = 0;
int count5 = 0;
int count6 = 0;

bool close_trades = false;
bool open_price = true;

double posicion = 0.00;

double equiedad_inicial = AccountEquity();
double equiedad_variable = AccountEquity();
double perdida_maxima = 8000.00;

double valores_de_margen[25];
double margen_mas_mas = 0.00;

double progreso = 0.00;
int progreso_1 = 0;

double margen_perdida = 0.00;

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
  
  progreso = AccountEquity() - equiedad_inicial;
  
  progreso_1 = (int) progreso/1000;
  
  // El divisor varia en funcion de la cuenta normal o micro
  
  //lot = lots + (double)progreso_1/100;
  if (macd_0 >= 0.00000  && last_tick.ask >= posicion + 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
          Print("OrderSend ERROR" + GetLastError());
      posicion += 50*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 >= 0.00000   && last_tick.ask <= posicion - 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"Posicion larga abierta", 12205,0,Green))
         Print("OrderSend ERROR" + GetLastError());
      posicion -= 50*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 <= 0.00000   && last_tick.ask <= posicion - 50*Point*Digits){
      if(!OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"Posicion corta abierta", 12205,0,Blue))
          Print("OrderSend ERROR" + GetLastError());
      posicion -= 50*Point*Digits;
      posicion = posicion;
  }
  
  if (macd_0 <= 0.00000   && last_tick.ask >= posicion + 50*Point*Digits){
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
  
  for (count4 = 0; count4 <= 21; count4++){
      valores_de_margen[count4] = margen_mas_mas;
      margen_mas_mas += (double) 100000.00;
  }
  
  for (count5 = 1; count5 <= 21; count5++){
       if(AccountEquity() >= valores_de_margen[count5-1]) {
          if (AccountEquity() <= valores_de_margen[count5]){
             perdida_maxima = valores_de_margen[count5]*2/25;
          }
       }
   }
  
  if (AccountEquity() >= equiedad_variable)
      equiedad_variable = AccountEquity();
      
  if (AccountEquity() <= equiedad_variable - perdida_maxima){
      for(count6 = 0; count6 <= OrdersTotal(); count6++){
          if(!OrderSelect(count6,SELECT_BY_POS, MODE_TRADES))
               continue;
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
              OrderClose(OrderTicket(), OrderLots(), Bid,3, White);
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
              OrderClose(OrderTicket(), OrderLots(), Ask,3, White);
          }
      }
  }
   
}
//+------------------------------------------------------------------+
