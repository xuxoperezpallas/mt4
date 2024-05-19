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

int margen = 300;

double profit = 0.00;
double close_at = 1.00;

double atr_olgura_1 = 0.00005;

double max_atr = 0.00;

bool close_bool = false;
bool not_trade = false;

double constante_compra = Bid;
double constante_venta = Ask;


void OnTick()
  {
      if (profit >= close_at)
          close_bool = true;
          
      if (OrdersTotal() == 0) {
          close_bool = false;
          profit = 0.00;
      }
      
      MqlTick last_tick;

      SymbolInfoTick(Symbol(), last_tick);
      
      double last_atr = iATR(Symbol(),PERIOD_M15,14,0);
      
      if (last_atr >= 0.00043 && last_atr >= max_atr)
          max_atr = last_atr;
          
      if (last_atr < 0.00043){
          last_atr = 0.00000;
          constante_compra = last_tick.bid;
          constante_venta = last_tick.ask;
      }
          
      if (last_atr >= max_atr - atr_olgura_1)
          not_trade = false;
      
      if ( last_atr < max_atr - atr_olgura_1){
          not_trade = true;
          close_bool = true;
      }                 
 
          if (!not_trade && last_tick.ask >= constante_compra + NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_BUY, lots, Ask, 7,0,0, "Orden de compra abierta", 12345,0, Green);
              constante_compra += NormalizeDouble(margen*Point,Digits);
              constante_venta = constante_compra;
          }

          if (!not_trade && last_tick.bid <= constante_venta -  NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_SELL, lots, Bid, 7,0,0, "Orden de venta abierta", 12345,0, Green);
              constante_venta -= NormalizeDouble(margen*Point,Digits);
              constante_compra = constante_venta;
          }
      
      for (int i = 0; i < OrdersTotal(); i++)
      {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
          if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL) && close_bool) {
              if (!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5 , Orange))
                  Print ("Print Error en la orden de cerrar posiciones");
          }        
          if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {
              profit += OrderOpenPrice();
          }  
     }
}


