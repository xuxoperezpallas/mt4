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

int buy_count = 0;
int sell_count = 0;

double balance = AccountBalance();
double price_buy = Ask - NormalizeDouble(((int)100)*Point,Digits);
double price_sell = Bid + NormalizeDouble(((int)100)*Point,Digits);

void OnTick()
  {
     // Contar órdenes abiertas
     buy_count = 0;
     sell_count = 0;
     for(int i = 0; i < OrdersTotal(); i++){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
             if(OrderSymbol() == Symbol()){
                 if(OrderType() == OP_BUY) buy_count++;
                 if(OrderType() == OP_SELL) sell_count++;
             }
         }
     }
     
     // Lógica de trading
     if(Bid >= price_buy + NormalizeDouble(difpips*Point,Digits)){
         // Si hay órdenes de venta, abrir 1 más de compra que de venta
         if(sell_count > 0){
             for(int j = 0; j <= sell_count; j++){
                 OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
             }
         }
         else{
             // Si no hay órdenes de venta, abrir solo 1 de compra
             OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
         }
         price_buy += NormalizeDouble(difpips*Point,Digits);
         price_sell = price_buy;
     }

     if(Ask <= price_sell - NormalizeDouble(difpips*Point,Digits)){
         // Si hay órdenes de compra, abrir 1 más de venta que de compra
         if(buy_count > 0){
             for(int k = 0; k <= buy_count; k++){
                 OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
             }
         }
         else{
             // Si no hay órdenes de compra, abrir solo 1 de venta
             OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),0,"",12345,0,clrGreen);
         }
         price_sell -= NormalizeDouble(difpips*Point,Digits);
         price_buy = price_sell;
     }
  }
//+------------------------------------------------------------------+
