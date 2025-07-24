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
input double lots = 0.01;
input int stop_loss = 1000;

bool max_trade_buy = false;
bool max_trade_sell = false;

double balance = AccountBalance();
double price_buy = Ask - NormalizeDouble(((int)100)*Point,Digits);
double price_sell = Bid + NormalizeDouble(((int)100)*Point,Digits);

int a = 0, b = 0;

void OnTick()
  {
     if(Bid >= price_buy + NormalizeDouble(difpips*Point,Digits)){
         OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),Ask + NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
         if (b >= 2 && max_trade_buy == true){
             OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),Ask + NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
             max_trade_buy = false;
             a++;
         }
         price_buy += NormalizeDouble(difpips*Point,Digits);
         price_sell = price_buy;
         a++;
      }

      if(Ask <= price_sell - NormalizeDouble(difpips*Point,Digits)){
         OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),Bid - NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
         if (a >= 2 && max_trade_sell == true){
             OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),Bid - NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
             max_trade_sell = false;
             b++;
         }
         price_sell -= NormalizeDouble(difpips*Point,Digits);
         price_buy = price_sell;
      }
 int e = 0, f = 0, c = 0, d = 0;
      for(int i = 1; i <= OrdersTotal(); i++){
          if (OrderSelect(i,SELECT_BY_POS, MODE_TRADES)){
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
              if (!(OrderOpenPrice() <= Ask)){
                  c++;
              }
          d++;
          }
          if (d == 0 || c != d) max_trade_sell = true;

          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
              if (!(OrderOpenPrice() >= Bid)){
                  e++;
              }
          f++;
          }
          if (f == 0 || e != f) max_trade_buy = true;
          }
      }



  }
//+------------------------------------------------------------------+
