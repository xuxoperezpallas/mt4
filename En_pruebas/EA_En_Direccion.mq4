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
int margen_cierre = 1500;
int margen_ciere = 50
int olgura = 20;

double margen_compra = 0.0000;
double margen_venta = 10000.00;
double profit = 0.00;
double close_at = 1.00;

bool close_bool = false;

double constante_compra = Ask;
double constante_venta = Bid;


void OnTick()
  {
      if (OrdersTotal() == 0) {
          close_bool = false;
          profit = 0.00;
      }
      MqlTick last_tick;

      SymbolInfoTick(Symbol(), last_tick);          
       
 
          if (last_tick.ask >= constante_compra + NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_BUY, lots, Ask, 7,Ask - NormalizeDouble(stop_loss*Point,Digits),0, "Orden de compra abierta", 12345,0, Green);
              constante_compra += NormalizeDouble(margen*Point,Digits);
              constante_venta = constante_compra;
          }

          if (last_tick.bid <= constante_venta -  NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_SELL, lots, Bid, 7,Bid + NormalizeDoule(stop_loss*Point,Digits),0, "Orden de venta abierta", 12345,0, Green);
              constante_venta -= NormalizeDouble(margen*Point,Digits);
              constante_compra = constante_venta;
          }
      
      for (int i = 0; i < OrdersTotal(); i++)
      {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
          if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {
              profit += OrderOpenPrice();
          }
          if (prifit >= close_at)
             close_bool = true;
          if (close_bool) {
              if (!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5 , Orange))
                  Print ("Print Error en la orden de cerrar posiciones");
          }  
     }
}


