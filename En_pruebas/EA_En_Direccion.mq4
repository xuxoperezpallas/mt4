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

int margen = 400;
int margen_cierre = 100;
int stop_loss = 1000;

bool cierre_venta = false;
bool cierre_compra = false;

double primer_constante = Close[1];

int upper = 150;
int margen_2 = 3000;

double constante_compra = primer_constante - NormalizeDouble(margen_cierre*Point,Digits);
double constante_venta = primer_constante + NormalizeDouble(margen_cierre*Point,Digits);


void OnTick()
  {
      MqlTick last_tick;

      SymbolInfoTick(Symbol(), last_tick);          
       
      if (!IsPositionWithinRange(last_tick.ask)) {   
          if (last_tick.ask >= constante_compra + NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_BUY, lots, Ask, 7,NormalizeDouble(stop_loss*Point,Digits),0, "Orden de compra abierta", 12345,0, Green);
              Print ("+++++++++++++++++++++++++++++++++++++++++++++++++++");
              constante_compra += NormalizeDouble(margen*Point,Digits);
              Print("Constante de compra = " +  constante_compra);
              constante_venta = constante_compra;
          }
      }

      if (!IsPositionWithinRange(last_tick.bid)) {
          if (last_tick.bid <= constante_venta -  NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_SELL, lots, Bid, 7,NormalizeDouble(stop_loss*Point,Digits),0, "Orden de venta abierta", 12345,0, Green);
              Print ("---------------------------------------------------");
              constante_venta -= NormalizeDouble(margen*Point,Digits);
              Print("Constante de venta = " +  constante_venta);
              constante_compra = constante_venta;
          }
      }
      
      for (int i = 0; i < OrdersTotal(); i++)
      {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_BUY)
          {    
              if (last_tick.bid > OrderOpenPrice() + NormalizeDouble(margen*Point,Digits)) {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() + NormalizeDouble(margen_cierre*Point,Digits),0,0, Red);
              }
              if (last_tick.bid > OrderOpenPrice() + NormalizeDouble(margen_2*Point,Digits)) {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() + NormalizeDouble(margen_cierre*Point,Digits),0,0, Red);
              }
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL)
          {
              if (last_tick.bid < OrderOpenPrice() - NormalizeDouble(margen*Point,Digits)) {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - NormalizeDouble(margen_cierre*Point,Digits),0,0, Red);
              }
              if (last_tick.bid < OrderOpenPrice() - NormalizeDouble(margen_2*Point,Digits)) {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - NormalizeDouble(margen_cierre*Point,Digits),0,0, Red);
              }
          }
      }
   
  }

bool IsPositionWithinRange(double price) {
    double upperLimit = price + NormalizeDouble(upper*Point,Digits); // Límite superior del rango
    double lowerLimit = price - NormalizeDouble(upper*Point,Digits); // Límite inferior del rango

    // Iterar sobre todas las posiciones abiertas
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
                double orderOpenPrice = OrderOpenPrice();
                // Verificar si el precio de apertura de la posición está dentro del rango
                if (orderOpenPrice >= lowerLimit && orderOpenPrice <= upperLimit) {
                return true; // Hay una posición dentro del rango
                }
            }
            if (OrderSymbol() = Symbol() && OrderType() == OP_BUY) {
                double orderOpenPrice = OrderOpenPrice();
                // Verificar si el precio de apertura de la posición está dentro del rango
                if (orderOpenPrice >= lowerLimit && orderOpenPrice <= upperLimit) {
                return true; // Hay una posición dentro del rango
                }
            }
        }
    }
    return false; // No hay ninguna posición dentro del rango
}

