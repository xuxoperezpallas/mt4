//+------------------------------------------------------------------+
//|                ReinforceTrend_StrictPipsDistance.mq4             |
//|                        (C) 2023, YourNameHere                    |
//|                       https://www.yourwebsite.com                |
//+------------------------------------------------------------------+
#property copyright "YourNameHere"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

//--- Inputs
input int    pips_distance = 200;     // Distancia entre órdenes (pips)
input int    stop_loss_pips = 200;    // Stop Loss y Take Profit (pips)
input double lot_size = 0.01;         // Volumen por operación

//--- Variables globales
double last_buy_price = 0;    // Último precio donde se abrió una compra
double last_sell_price = 0;   // Último precio donde se abrió una venta
bool   trend_direction = 0;   // 0 = indefinido, 1 = alcista, -1 = bajista

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   // Inicializar precios de referencia
   last_buy_price = Ask;
   last_sell_price = Bid;
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Contar órdenes abiertas
   int buy_orders = 0, sell_orders = 0;
   
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == Symbol())
         {
            if (OrderType() == OP_BUY) buy_orders++;
            if (OrderType() == OP_SELL) sell_orders++;
         }
      }
   }

   //--- Determinar dirección del trend
   if (buy_orders > sell_orders) trend_direction = 1;    // Alcista
   else if (sell_orders > buy_orders) trend_direction = -1; // Bajista
   else trend_direction = 0; // Neutral

   //--- Lógica de compra (precio sube 200 pips desde última compra)
   if (Bid >= last_buy_price + NormalizeDouble(pips_distance * Point, Digits))
   {
      // Solo abre UNA orden más si el trend es alcista o neutral
      if (trend_direction >= 0)
      {
         OrderSend(
            Symbol(), OP_BUY, lot_size, Ask, 3,
            Ask - stop_loss_pips * Point,
            Ask + stop_loss_pips * Point,
            "", 0, 0, clrBlue
         );
         last_buy_price = Ask; // Actualiza último precio de compra
      }
   }

   //--- Lógica de venta (precio baja 200 pips desde última venta)
   if (Ask <= last_sell_price - NormalizeDouble(pips_distance * Point, Digits))
   {
      // Solo abre UNA orden más si el trend es bajista o neutral
      if (trend_direction <= 0)
      {
         OrderSend(
            Symbol(), OP_SELL, lot_size, Bid, 3,
            Bid + stop_loss_pips * Point,
            Bid - stop_loss_pips * Point,
            "", 0, 0, clrRed
         );
         last_sell_price = Bid; // Actualiza último precio de venta
      }
   }
}
//+------------------------------------------------------------------+
