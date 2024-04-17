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
int margen_cierre = 150;
int stop_loss = 1000;

bool cierre_venta = false;
bool cierre_compra = false;

double primer_constante = Close[1];

int margen_2 = 300;

double constante_compra = primer_constante - NormalizeDouble(margen_cierre*Point,Digits);
double constante_venta = primer_constante + NormalizeDouble(margen_cierre*Point,Digits);


void OnTick()
  {
      MqlTick last_tick;

      SymbolInfoTick(Symbol(), last_tick);          
       
 
          if (last_tick.ask >= constante_compra + NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_BUY, lots, Ask, 7,NormalizeDouble(stop_loss*Point,Digits),0, "Orden de compra abierta", 12345,0, Green);
              Print ("+++++++++++++++++++++++++++++++++++++++++++++++++++");
              constante_compra += NormalizeDouble(margen*Point,Digits);
              Print("Constante de compra = " +  constante_compra);
          }
          
          if (last_tick.ask >= constante_venta + NormalizeDouble(margen*Point,Digits)){
              Print ("#######################################################");
              constante_venta += NormalizeDouble(margen*Point,Digits);
              Print("Constante de venta = " +  constante_enta);
          }



          if (last_tick.bid <= constante_venta -  NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_SELL, lots, Bid, 7,NormalizeDoule(stop_loss*Point,Digits),0, "Orden de venta abierta", 12345,0, Green);
              Print ("---------------------------------------------------");
              constante_venta -= NormalizeDouble(margen*Point,Digits);
              Print("Constante de venta = " +  constante_venta);
          }

          if (last_tick.bid <= constante_compra -  NormalizeDouble(margen*Point,Digits)){
              Print ("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
              constante_compra -= NormalizeDouble(margen*Point,Digits);
              Print("Constante de compra = " +  constante_compra);
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



