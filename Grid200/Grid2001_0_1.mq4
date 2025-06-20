//+------------------------------------------------------------------+
//|                                                      Grid200.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
#property version   "1.00"
#property strict

// Inputs
input int    PipsDistance = 200;    // Distancia en pips entre operaciones
input double LotSize      = 0.01;    // Tamaño del lote
input int    MagicNumber  = 12345;  // Número mágico
input int    Slippage     = 3;      // Deslizamiento permitidoint
input int    backdistance = 600;
input int    distance     = 1000;
input int    stopreturn     = 250;
input int    stoploss     = 3000;

// Variables globales
double buyLevel, sellLevel, max = 0.000, min =999999.9;
input int restablecer = 3100;
input int olgura = 100;
input int top = 3000;
double ganacia = 1000.0;
bool cierratodo = false;
double balanc = AccountBalance();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Inicializar niveles con el precio actual
   buyLevel = NormalizeDouble(Ask + PipsDistance * _Point, _Digits);
   sellLevel = NormalizeDouble(Bid - PipsDistance * _Point, _Digits);
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int ason)
  {
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(OrdersTolal() == 0){
     balanc = AccountBalance();
     cierratodo = false;
  }
  if (AccountEquity() - balance => ganancia){
     cierratodo = true;
  }
   
   // Verificar condiciones para compra
   if(Bid > NormalizeDouble(buyLevel, _Digits))
     {
      OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, 0, 0, "", MagicNumber, 0, clrGreen);
      buyLevel = NormalizeDouble(buyLevel + PipsDistance * _Point, _Digits);
      sellLevel = NormalizeDouble(buyLevel - backdistance * _Point, _Digits);
     }

   if (Bid > max)
     {
      max = Bid;
     }

   if (Bid + NormalizeDouble(restablecer*Point,Digits) < max) {max = 0.000;}

   // Verificar condiciones para venta
   if(Ask < NormalizeDouble(sellLevel, _Digits))
     {
      OrderSend(Symbol(), OP_SELL, LotSize, Bid, Slippage, 0, 0, "", MagicNumber, 0, clrRed);
      sellLevel = NormalizeDouble(sellLevel - PipsDistance * _Point, _Digits);
      buyLevel = NormalizeDouble(sellLevel + backdistance * Point, Digits);
      }

    if (Ask < min)
      {
        min = Ask;
      }
    if (Ask - NormalizeDouble(restablecer*Point,Digits) > min){min=999999.9;}

for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            if(OrderType() == OP_BUY)
              {
                if(OrderOpenPrice() + NormalizeDouble((distance)*Point,Digits) >= Ask){
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - NormalizeDouble(stopreturn*Point,Digits), 0, 0, clrBlue);
                 }
              }
            else if(OrderType() == OP_SELL)
              {
               if(OrderOpenPrice() - NormalizeDouble(distance* _Point, _Digits) <= Bid)
                  {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + NormalizeDouble(stopreturn*Point,Digits), OrderTakeProfit(), 0, clrOrange);
                 }
              }
           }
        }
     }

    if(cierratodo == true) {
for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            double price = (OrderType() == OP_BUY) ? Bid : Ask;
            bool closed = OrderClose(OrderTicket(), OrderLots(), price, 3, clrNONE);

            if(!closed)
               Print("Error al cerrar orden ", OrderTicket(), " - Error: ", GetLastError());
            else
               Print("Orden cerrada: ", OrderTicket());
         }
      }
   }
 }
}
//+------------------------------------------------------------------+
