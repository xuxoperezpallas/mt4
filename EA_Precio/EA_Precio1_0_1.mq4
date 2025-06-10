
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
input int    backdistance = 800;
input int    distance     = 1000;
input int    stoploss     = 200;
input int    takeprofit   = 3000;
input double ganancia = 1000.0;
bool cierratodo = false;
double balanc = AccountBalance();

// Variables globales
double buyLevel, sellLevel;

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
void OnDeinit(const int reason)
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
OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, 0,Bid + NormalizeDouble(takeprofit*Point,Digits), "", MagicNumber, 0, clrGreen);
      buyLevel = NormalizeDouble(buyLevel + PipsDistance * _Point, _Digits);
      sellLevel = buyLevel - NormalizeDouble(backdistance * _Point, _Digits);
     }                                                                                                                         
   // Verificar condiciones para venta                                                                                            
if(Ask < NormalizeDouble(sellLevel, _Digits))
     {
      OrderSend(Symbol(), OP_SELL, LotSize, Bid, Slippage, 0, Ask - NormalizeDouble(takeprofit*Point,Digits), "", MagicNumber, 0, clrGreen);
      sellLevel = NormalizeDouble(sellLevel - PipsDistance * _Point, _Digits);                                                       
    buyLevel = sellLevel + NormalizeDouble( backdistance * _Point, _Digits);
     }

   // Gestionar stops de posiciones abiertas
   ManagePositions();
  }                                                                                                                            
//+------------------------------------------------------------------+
//| Función para gestionar posiciones abiertas                       |
//+------------------------------------------------------------------+
void ManagePositions()
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
           {
            if(OrderType() == OP_BUY)
              {
               if(Bid > NormalizeDouble(OrderOpenPrice() + distance * _Point, _Digits))
                 {
                  double newSL = NormalizeDouble(OrderOpenPrice() + stoploss * _Point, _Digits);
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen);
                 }
              }
            else if(OrderType() == OP_SELL)
              {
               if(Ask < NormalizeDouble(OrderOpenPrice() - distance * _Point, _Digits))
                 {
                  double newSL = NormalizeDouble(OrderOpenPrice() - stoploss * _Point, _Digits);
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen);
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
