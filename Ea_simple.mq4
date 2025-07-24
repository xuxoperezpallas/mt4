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

double price_buy = Ask - NormalizeDouble(((int)100)*Point,Digits);
double price_sell = Bid + NormalizeDouble(((int)100)*Point,Digits);

void OnTick()
  {
     int buy_orders = 0;
     int sell_orders = 0;
     
     // Contar órdenes abiertas
     for(int i = 0; i < OrdersTotal(); i++){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
             if(OrderSymbol() == Symbol()){
                 if(OrderType() == OP_BUY) buy_orders++;
                 if(OrderType() == OP_SELL) sell_orders++;
             }
         }
     }
     
     // Lógica para compras
     if(Bid >= price_buy + NormalizeDouble(difpips*Point,Digits)){
         // Si hay órdenes de venta, abrir una compra más que ventas
         if(sell_orders > 0 && buy_orders <= sell_orders){
             OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),Ask + NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
         }
         // Si no hay ventas, abrir solo una compra
         else if(sell_orders == 0 && buy_orders == 0){
             OrderSend(Symbol(),OP_BUY,lots,Ask,7,Ask - NormalizeDouble(stop_loss*Point,Digits),Ask + NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
         }
         price_buy += NormalizeDouble(difpips*Point,Digits);
         price_sell = price_buy;
     }
     
     // Lógica para ventas
     if(Ask <= price_sell - NormalizeDouble(difpips*Point,Digits)){
         // Si hay órdenes de compra, abrir una venta más que compras
         if(buy_orders > 0 && sell_orders <= buy_orders){
             OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),Bid - NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
         }
         // Si no hay compras, abrir solo una venta
         else if(buy_orders == 0 && sell_orders == 0){
             OrderSend(Symbol(),OP_SELL,lots,Bid,7,Bid + NormalizeDouble(stop_loss*Point,Digits),Bid - NormalizeDouble(stop_loss*Point,Digits),"",12345,0,clrGreen);
         }
         price_sell -= NormalizeDouble(difpips*Point,Digits);
         price_buy = price_sell;
     }
  }
//+------------------------------------------------------------------+
