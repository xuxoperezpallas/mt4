//+------------------------------------------------------------------+
//|                     Smart Hedge EA PRO                           |
//|                   Copyright 2024, Forex Algorithm                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Forex Algorithm"
#property link      "https://www.forexalgorithm.com"
#property version   "4.0"
#property strict

input double LotSize = 0.1;            // Tamaño del lote fijo
input int GridStep = 200;              // Distancia entre niveles (pips)
input int ProfitDistance = 100;        // Distancia para beneficio (pips)
input int MaxAccumulation = 3;         // Máximo acumulación en extremos

//+------------------------------------------------------------------+
//| Global Variables                                                |
//+------------------------------------------------------------------+
int magicNumber = 202404;
double upperZone = 0;
double lowerZone = 0;
double midPrice = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   midPrice = (Ask + Bid) / 2;
   upperZone = midPrice + GridStep * Point;
   lowerZone = midPrice - GridStep * Point;
   
   OpenInitialPair();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 1. Gestionar cierres por beneficio
   ManageProfitClosures();
   
   // 2. Mantener equilibrio de posiciones
   MaintainHedgeBalance();
   
   // 3. Gestionar acumulación en extremos
   ManageExtremeAccumulation();
   
   // 4. Verificar apertura de nuevos niveles
   CheckNewLevels();
}

//+------------------------------------------------------------------+
//| Abre par inicial                                                |
//+------------------------------------------------------------------+
void OpenInitialPair()
{
   double price = NormalizeDouble(Ask, Digits);
   OrderSend(Symbol(), OP_BUY, LotSize, price, 3, 0, 0, "Initial Buy", magicNumber, 0, clrBlue);
   
   price = NormalizeDouble(Bid, Digits);
   OrderSend(Symbol(), OP_SELL, LotSize, price, 3, 0, 0, "Initial Sell", magicNumber, 0, clrRed);
   
   midPrice = (Ask + Bid) / 2;
   upperZone = midPrice + GridStep * Point;
   lowerZone = midPrice - GridStep * Point;
}

//+------------------------------------------------------------------+
//| Gestiona cierres por beneficio                                  |
//+------------------------------------------------------------------+
void ManageProfitClosures()
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            // Para posiciones de compra
            if(OrderType() == OP_BUY && Bid >= OrderOpenPrice() + GridStep * Point)
            {
               double newSL = NormalizeDouble(OrderOpenPrice() + ProfitDistance * Point, Digits);
               if(Bid <= newSL && OrderStopLoss() != newSL)
               {
                  OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
                  OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, 0, 0, "Buy Replacement", magicNumber, 0, clrBlue);
               }
               else if(OrderStopLoss() == 0)
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, 0, 0, clrBlue);
               }
            }
            
            // Para posiciones de venta
            if(OrderType() == OP_SELL && Ask <= OrderOpenPrice() - GridStep * Point)
            {
               double newSL = NormalizeDouble(OrderOpenPrice() - ProfitDistance * Point, Digits);
               if(Ask >= newSL && OrderStopLoss() != newSL)
               {
                  OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE);
                  OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, 0, 0, "Sell Replacement", magicNumber, 0, clrRed);
               }
               else if(OrderStopLoss() == 0)
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, 0, 0, clrRed);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Mantiene equilibrio de posiciones                               |
//+------------------------------------------------------------------+
void MaintainHedgeBalance()
{
   int buyCount = CountPositions(OP_BUY);
   int sellCount = CountPositions(OP_SELL);
   
   if(buyCount > sellCount)
   {
      double price = NormalizeDouble(Bid, Digits);
      OrderSend(Symbol(), OP_SELL, LotSize, price, 3, 0, 0, "Hedge Sell", magicNumber, 0, clrRed);
   }
   else if(sellCount > buyCount)
   {
      double price = NormalizeDouble(Ask, Digits);
      OrderSend(Symbol(), OP_BUY, LotSize, price, 3, 0, 0, "Hedge Buy", magicNumber, 0, clrBlue);
   }
}

//+------------------------------------------------------------------+
//| Gestiona acumulación en extremos                                |
//+------------------------------------------------------------------+
void ManageExtremeAccumulation()
{
   int upperBuys = 0;
   int lowerSells = 0;
   double currentUpperZone = midPrice + GridStep * Point;
   double currentLowerZone = midPrice - GridStep * Point;
   
   // Contar posiciones en extremos
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            if(OrderType() == OP_BUY && OrderOpenPrice() >= currentUpperZone)
               upperBuys++;
            else if(OrderType() == OP_SELL && OrderOpenPrice() <= currentLowerZone)
               lowerSells++;
         }
      }
   }
   
   // Cerrar posiciones en extremos si hay acumulación excesiva
   if(upperBuys >= MaxAccumulation || lowerSells >= MaxAccumulation)
   {
      int closedUpper = 0;
      int closedLower = 0;
      
      for(int i = OrdersTotal()-1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
               if(OrderType() == OP_BUY && OrderOpenPrice() >= currentUpperZone && closedUpper < MaxAccumulation)
               {
                  OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
                  closedUpper++;
               }
               else if(OrderType() == OP_SELL && OrderOpenPrice() <= currentLowerZone && closedLower < MaxAccumulation)
               {
                  OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE);
                  closedLower++;
               }
            }
         }
      }
      
      // Rebalancear después de cerrar extremos
      MaintainHedgeBalance();
   }
}

//+------------------------------------------------------------------+
//| Verifica apertura de nuevos niveles                             |
//+------------------------------------------------------------------+
void CheckNewLevels()
{
   double highestBuy = 0;
   double lowestSell = EMPTY_VALUE;
   
   // Encontrar precios más altos/bajos de posiciones abiertas
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
         {
            if(OrderType() == OP_BUY && OrderOpenPrice() > highestBuy)
               highestBuy = OrderOpenPrice();
            
            if(OrderType() == OP_SELL && OrderOpenPrice() < lowestSell)
               lowestSell = OrderOpenPrice();
         }
      }
   }
   
   // Verificar si necesitamos abrir nuevo nivel superior
   if(Ask >= highestBuy + GridStep * Point)
   {
      double newBuyPrice = NormalizeDouble(highestBuy + GridStep * Point, Digits);
      OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, 0, 0, "Upper Buy", magicNumber, 0, clrBlue);
   }
   
   // Verificar si necesitamos abrir nuevo nivel inferior
   if(Bid <= lowestSell - GridStep * Point)
   {
      double newSellPrice = NormalizeDouble(lowestSell - GridStep * Point, Digits);
      OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, 0, 0, "Lower Sell", magicNumber, 0, clrRed);
   }
}

//+------------------------------------------------------------------+
//| Cuenta posiciones por tipo                                      |
//+------------------------------------------------------------------+
int CountPositions(int type)
{
   int count = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == type)
         {
            count++;
         }
      }
   }
   return count;
}
