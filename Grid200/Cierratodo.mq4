//+------------------------------------------------------------------+
//| Expert Advisor - Cerrar Todas las Órdenes                        |
//|                                                       |
//+------------------------------------------------------------------+
int start()
{
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
   return(0);
}
