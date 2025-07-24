//+------------------------------------------------------------------+
//|                                                    Simple_EA.mq4 |
//|                                                 JesusPerezPallas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "JesusPerezPallas"
#property link      "https://www.mql5.com"
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
input int difpips = 200;
input int inv_stoploss = 200;
input double lots = 0.01;
input double ganancia = 100;
input int max_return = 800;
input int stop_loss = 800;

bool max_trade_buy = false;
bool max_trade_sell = false;

double balance = AccountBalance();
double price_buy = Ask - NormalizeDouble(((int)100)*Point,Digits);
double price_sell = Bid + NormalizeDouble(((int)100)*Point,Digits);

void OnTick()
  {
     if(Bid >= price_buy + NormalizeDouble(difpips*Point,Digits)){
         OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
         if (max_trade_buy == true){
             OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
         }
         price_buy += NormalizeDouble(difpips*Point,Digits);
         price_sell = price_buy;
      }

      if(Ask <= price_sell - NormalizeDouble(difpips*Point,Digits)){
         OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
         if (max_trade_sell == true){
             OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
         }
         price_sell -= NormalizeDouble(difpips*Point,Digits);
         price_buy = price_sell;
      }

      for(int i = 1; i <= OrdersTotal(); i++){
          OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
              if (OrderOpenPrice() <= Ask){
                  max_trade_sell = true;
              } else {
                   max_trade_sell = false;
              }
          }

          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
              if (OrderOpenPrice() >= Bid){
                  max_trade_buy = true;
              } else {
                 max_trade_buy = false;
              }
          }
      }



  }
//+------------------------------------------------------------------+
