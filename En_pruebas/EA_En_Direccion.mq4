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
int stop_loss = 500;

int primer_caso = 500;
int segundo = 1000;
int tercero = 3000;
int ultimo = 6000;

bool cierre_venta = false;
bool cierre_compra = false;

double primer_constante = Close[1];

double constante_compra = primer_constante - NormalizeDouble(margen_cierre*Point,Digits);
double constante_venta = primer_constante + NormalizeDouble(margen_cierre*Point,Digits);


void OnTick()
  {
      MqlTick last_tick;

      SymbolInfoTick(Symbol(), last_tick);          
       
 
          if (last_tick.ask >= constante_compra + NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_BUY, lots, Ask, 7,Ask - NormalizeDouble(stop_loss*Point,Digits),0, "Orden de compra abierta", 12345,0, Green);
              Print ("+++++++++++++++++++++++++++++++++++++++++++++++++++");
              constante_compra += NormalizeDouble(margen*Point,Digits);
              Print("Constante de compra = " +  constante_compra);
              constante_venta = constante_compra;
          }

          if (last_tick.bid <= constante_venta -  NormalizeDouble(margen*Point,Digits)){
              OrderSend(NULL, OP_SELL, lots, Bid, 7,Bid + NormalizeDoule(stop_loss*Point,Digits),0, "Orden de venta abierta", 12345,0, Green);
              Print ("---------------------------------------------------");
              constante_venta -= NormalizeDouble(margen*Point,Digits);
              Print("Constante de venta = " +  constante_venta);
              constante_compra = constante_venta;
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
          }
          
          if (OrderSymbol() == Symbol() && OrderType() == OP_SELL)
          {
              if (last_tick.bid < OrderOpenPrice() - NormalizeDouble(margen*Point,Digits)) {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - NormalizeDouble(margen_cierre*Point,Digits),0,0, Red);
              }              
          }   
}

void reajustar_stop_loss(int order_type, double ultimo_tick, int ticket, double open_price,int  margen_cerrar){

    switch (order_type)
        case OP_BUY:
             if (ultimo_tick > open_price + NormalizeDouble((primer_caso+(int)10)*Point,Digits &&) ultimo_tick < open_price + NormalizeDouble(((int)1000)*Point,Digits {
             OrderModify (ticket, open_price, openprice + NormalizeDouble((margen_cierre+(int)7)*Point,Digits),0,0,red);
             primercaso += 10;
             }
             if (ultimo_tick > open_price + NormalizeDouble((segundo +(int)2)*Point,Digits) &&) ultimo_tick < open_price + NormalizeDouble(((int)3000)*Point,Digits {
             OrderModify (ticket, open_price, openprice + NormalizeDouble((segundo -(int)500 +(int)1)*Point,Digits),0,0,red);
             segundo += 2;
             }
             if (ultimo_tick > open_price + NormalizeDouble(tercero+(int)2)*Point,Digits) && ultimo_tick < open_price + NormalizeDouble(((int)6000)*Point,Digits {
             OrderModify (ticket, open_price, openprice + NormalizeDouble((tercero-(int)1500+(int)1)*Point,Digits),0,0,red);
             terceso += 2;
             }
            if (ultimo_tick > open_price + NormalizeDouble((ultimo+(int)1)*Point,Digits))  {
             OrderModify (ticket, open_price, openprice + NormalizeDouble((ultimo-(int)3000+(int)1)*Point,Digits),0,0,red);
             ultimo += 1;
             }
             break;
        case OP_SELL:
            if (ultimo_tick < open_price - NormalizeDouble((primer_caso+(int)10)*Point,Digits &&) ultimo_tick > open_price - NormalizeDouble(((int)1000)*Point,Digits {
             OrderModify (ticket, open_price, openprice - NormalizeDouble((margen_cierre+(int)7)*Point,Digits),0,0,red);
             primercaso += 10;
             }
             if (ultimo_tick < open_price - NormalizeDouble((segundo +(int)4)*Point,Digits) &&) ultimo_tick > open_price - NormalizeDouble(((int)3000)*Point,Digits {
             OrderModify (ticket, open_price, openprice - NormalizeDouble((segundo+(int)1)*Point,Digits),0,0,red);
             segundo += 4;
             }
             if (ultimo_tick < open_price - NormalizeDouble(tercero+(int)2)*Point,Digits) && ultimo_tick > open_price - NormalizeDouble(((int)7000)*Point,Digits {
             OrderModify (ticket, open_price, openprice - NormalizeDouble((tercero+(int)1)*Point,Digits),0,0,red);
             terceso += 2;
             }
            if (ultimo_tick < open_price - NormalizeDouble((ultimo+(int)1)*Point,Digits))  {
             OrderModify (ticket, open_price, openprice - NormalizeDouble((ultimo+(int)1)*Point,Digits),0,0,red);
             ultimo += 1;
             }

             break;
}

