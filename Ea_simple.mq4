//+------------------------------------------------------------------+
//|                     Trend Reinforcement EA.mq4                   |
//|                        (C) 2023, YourNameHere                   |
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
double next_buy_price = 0;
double next_sell_price = 0;
bool   first_tick = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   // Inicializar precios de referencia
   next_buy_price = Ask - NormalizeDouble(pips_distance * Point, Digits);
   next_sell_price = Bid + NormalizeDouble(pips_distance * Point, Digits);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Reiniciar en cada tick para evitar errores
   if (first_tick)
   {
      next_buy_price = Ask - NormalizeDouble(pips_distance * Point, Digits);
      next_sell_price = Bid + NormalizeDouble(pips_distance * Point, Digits);
      first_tick = false;
   }

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

   //--- Lógica de compra (precio sube)
   if (Bid >= next_buy_price)
   {
      //--- Abrir órdenes adicionales si hay ventas
      if (sell_orders > 0)
      {
         int orders_to_open = sell_orders - buy_orders + 1; // Asegura una más que las ventas
         for (int i = 0; i < orders_to_open; i++)
         {
            OrderSend(
               Symbol(), OP_BUY, lot_size, Ask, 3,
               Ask - stop_loss_pips * Point,
               Ask + stop_loss_pips * Point,
               "", 0, 0, clrBlue
            );
         }
      }
      //--- Si no hay ventas, abrir solo 1 compra
      else if (buy_orders == 0)
      {
         OrderSend(
            Symbol(), OP_BUY, lot_size, Ask, 3,
            Ask - stop_loss_pips * Point,
            Ask + stop_loss_pips * Point,
            "", 0, 0, clrBlue
         );
      }
      
      //--- Actualizar siguiente precio de compra
      next_buy_price += NormalizeDouble(pips_distance * Point, Digits);
      next_sell_price = next_buy_price;
   }

   //--- Lógica de venta (precio baja)
   if (Ask <= next_sell_price)
   {
      //--- Abrir órdenes adicionales si hay compras
      if (buy_orders > 0)
      {
         int orders_to_open = buy_orders - sell_orders + 1; // Asegura una más que las compras
         for (int i = 0; i < orders_to_open; i++)
         {
            OrderSend(
               Symbol(), OP_SELL, lot_size, Bid, 3,
               Bid + stop_loss_pips * Point,
               Bid - stop_loss_pips * Point,
               "", 0, 0, clrRed
            );
         }
      }
      //--- Si no hay compras, abrir solo 1 venta
      else if (sell_orders == 0)
      {
         OrderSend(
            Symbol(), OP_SELL, lot_size, Bid, 3,
            Bid + stop_loss_pips * Point,
            Bid - stop_loss_pips * Point,
            "", 0, 0, clrRed
         );
      }
      
      //--- Actualizar siguiente precio de venta
      next_sell_price -= NormalizeDouble(pips_distance * Point, Digits);
      next_buy_price = next_sell_price;
   }
}
//+------------------------------------------------------------------+
