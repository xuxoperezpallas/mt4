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
input int    distance     = 800;
input int    stopreturn     = 200;
input int    stoploss     = 3000;

// Variables globales
double buyLevel, sellLevel, max = 0.000, min =999999.9;
int restablecer = 5100, olgura = 100;
int top = 5000;
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
   // Verificar condiciones para compra
   if(Bid > NormalizeDouble(buyLevel, _Digits))
     {
      OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, Bid - NormalizeDouble(stoploss*Point,Digits), 0, "", MagicNumber, 0, clrGreen);
      buyLevel = NormalizeDouble(buyLevel + PipsDistance * _Point, _Digits);
      sellLevel = NormalizeDouble(buyLevel - backdistance * _Point, _Digits);
     }

   if (Bid > max)
     {
      max = Bid;
     }

   if (Bid + NormalezeDoube(restablecer*Point,Digits) < max) {max = 0.000;}

   // Verificar condiciones para venta
   if(Ask < NormalizeDouble(sellLevel, _Digits))
     {
      OrderSend(Symbol(), OP_SELL, LotSize, Bid, Slippage, Ask + NormalizeDouble(stoploss*Point,Digits) , 0, "", MagicNumber, 0, clrRed);
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
                if(max - NormalizeDouble((top)*Point,Digits) > OrderOpenPrice())
                  OrderModify(OrderTicket(), OrderOpenPrice(), max - NormaliceDouble(top*Point,Digits), OrderTakeProfit(), 0, clrBlue);
                 }
              }
            else if(OrderType() == OP_SELL)
              {
               if(min + NormalizeDouble(top * _Point, _Digits) < OrderOpenPrice())
                  {
                  OrderModify(OrderTicket(), OrderOpenPrice(), min + NormalizeDouble(top*Point,Digits), OrderTakeProfit(), 0, clrOrange);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
