//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int TakeProfitPips = 100;    // Beneficio objetivo en pips
input int HedgeDistance = 50;      // Distancia en pips para nueva cobertura
input double LotSize = 0.1;        // Tamaño del lote
input int MaxPositions = 10;       // Máximo de posiciones por lado

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Verificar equilibrio de posiciones
    int buyPositions = CountPositions(OP_BUY);
    int sellPositions = CountPositions(OP_SELL);
    
    // Equilibrar posiciones si hay desbalance
    if(buyPositions > sellPositions && (buyPositions - sellPositions) == 1)
    {
        OpenHedgePosition(OP_SELL);
    }
    else if(sellPositions > buyPositions && (sellPositions - buyPositions) == 1)
    {
        OpenHedgePosition(OP_BUY);
    }
    
    // Gestionar stops y toma de beneficios
    ManagePositions();
}

//+------------------------------------------------------------------+
//| Abre posición de cobertura                                        |
//+------------------------------------------------------------------+
void OpenHedgePosition(int type)
{
    double price = (type == OP_BUY) ? Ask : Bid;
    double stopLoss = (type == OP_BUY) ? price - TakeProfitPips * Point : price + TakeProfitPips * Point;
    
    OrderSend(Symbol(), type, LotSize, price, 3, stopLoss, 0, "Hedge", 0, 0, clrNONE);
}

//+------------------------------------------------------------------+
//| Gestiona posiciones abiertas                                      |
//+------------------------------------------------------------------+
void ManagePositions()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Cerrar posiciones que han alcanzado el take profit (stop loss en este caso)
            if((OrderType() == OP_BUY && Bid <= OrderStopLoss()) || 
               (OrderType() == OP_SELL && Ask >= OrderStopLoss()))
            {
                OrderClose(OrderTicket(), OrderLots(), 
                          (OrderType() == OP_BUY) ? Bid : Ask, 3, clrNONE);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Cuenta posiciones por tipo                                        |
//+------------------------------------------------------------------+
int CountPositions(int type)
{
    int count = 0;
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderType() == type)
        {
            count++;
        }
    }
    return count;
}
