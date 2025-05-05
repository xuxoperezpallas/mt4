//+------------------------------------------------------------------+
//|                      GridMasterEA.mq4                           |
//|          EA con panel visual y gestión robusta de riesgos       |
//+------------------------------------------------------------------+
#property strict
#property show_inputs

// --- Parámetros configurables ---
input int    PipsDistancia = 200;      // Distancia entre órdenes (pips)
input double Lote = 0.1;               // Tamaño de lote
input int    MaxOrdenes = 3;           // Máximo de órdenes en misma dirección
input double RatioTP = 0.5;            // % de posición que cierra con TP (0-1)
input int    MinATR = 50;              // Mínimo ATR(14) en pips para operar
input color  ColorFondo = clrWhiteSmoke; // Color fondo panel
input color  ColorTexto = clrBlack;    // Color texto panel

// --- Variables globales ---
double nextBuy, nextSell;
int magicNumber = 999888;

//+------------------------------------------------------------------+
//| Función de inicialización                                       |
//+------------------------------------------------------------------+
int OnInit()
{
   // Inicializar niveles
   nextBuy = Ask + PipsDistancia * _Point;
   nextSell = Bid - PipsDistancia * _Point;
   
   // Crear panel visual
   CrearPanel();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Función de desinicialización                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Eliminar objetos del panel
   ObjectDelete(0, "PanelFondo");
   ObjectDelete(0, "PanelTitulo");
   ObjectDelete(0, "PanelInfo");
}

//+------------------------------------------------------------------+
//| Crear el panel visual                                           |
//+------------------------------------------------------------------+
void CrearPanel()
{
   // Panel fondo
   ObjectCreate(0, "PanelFondo", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "PanelFondo", OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, "PanelFondo", OBJPROP_YDISTANCE, 10);
   ObjectSetInteger(0, "PanelFondo", OBJPROP_XSIZE, 250);
   ObjectSetInteger(0, "PanelFondo", OBJPROP_YSIZE, 150);
   ObjectSetInteger(0, "PanelFondo", OBJPROP_BGCOLOR, ColorFondo);
   ObjectSetInteger(0, "PanelFondo", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   
   // Título
   ObjectCreate(0, "PanelTitulo", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "PanelTitulo", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "PanelTitulo", OBJPROP_YDISTANCE, 20);
   ObjectSetString(0, "PanelTitulo", OBJPROP_TEXT, "Grid Master EA");
   ObjectSetInteger(0, "PanelTitulo", OBJPROP_COLOR, ColorTexto);
   ObjectSetInteger(0, "PanelTitulo", OBJPROP_FONTSIZE, 10);
   
   // Información
   ObjectCreate(0, "PanelInfo", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "PanelInfo", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "PanelInfo", OBJPROP_YDISTANCE, 50);
}

//+------------------------------------------------------------------+
//| Actualizar información del panel                                |
//+------------------------------------------------------------------+
void ActualizarPanel()
{
   string infoText = "";
   
   // Niveles
   infoText += "Próxima compra: " + DoubleToString(nextBuy, _Digits) + "\n";
   infoText += "Próxima venta:  " + DoubleToString(nextSell, _Digits) + "\n\n";
   
   // Órdenes abiertas
   int buys = 0, sells = 0;
   double profit = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == magicNumber)
      {
         if(OrderType() == OP_BUY) buys++;
         if(OrderType() == OP_SELL) sells++;
         profit += OrderProfit();
      }
   }
   
   infoText += "Compras: " + IntegerToString(buys) + " | Ventas: " + IntegerToString(sells) + "\n";
   infoText += "Beneficio: $" + DoubleToString(profit, 2) + "\n";
   infoText += "ATR actual: " + DoubleToString(iATR(NULL,0,14,0)/_Point,0) + " pips";
   
   ObjectSetString(0, "PanelInfo", OBJPROP_TEXT, infoText);
}

//+------------------------------------------------------------------+
//| Verificar condiciones de trading                                |
//+------------------------------------------------------------------+
bool PuedeOperar()
{
   // Verificar volatilidad mínima
   if(iATR(NULL, 0, 14, 0)/_Point < MinATR) 
   {
      Comment("\nVolatilidad insuficiente para operar");
      return false;
   }
   
   // Verificar máximo de órdenes
   int buys = 0, sells = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == magicNumber)
      {
         if(OrderType() == OP_BUY) buys++;
         if(OrderType() == OP_SELL) sells++;
      }
   }
   
   if(buys >= MaxOrdenes || sells >= MaxOrdenes) 
   {
      Comment("\nLímite de órdenes alcanzado");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Gestión de stops móviles                                        |
//+------------------------------------------------------------------+
void GestionarStops()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == magicNumber)
      {
         double newSL = OrderType() == OP_BUY ? 
                       OrderOpenPrice() + (PipsDistancia/2)*_Point : 
                       OrderOpenPrice() - (PipsDistancia/2)*_Point;
         
         if((OrderType() == OP_BUY && Bid > OrderOpenPrice() + PipsDistancia*_Point) ||
            (OrderType() == OP_SELL && Ask < OrderOpenPrice() - PipsDistancia*_Point))
         {
            OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(newSL,_Digits), OrderTakeProfit(), 0);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Función principal                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!PuedeOperar()) 
   {
      ActualizarPanel();
      return;
   }

   // Lógica de compra
   if(Bid > NormalizeDouble(nextBuy, _Digits))
   {
      double tp = NormalizeDouble(Ask + PipsDistancia*RatioTP*_Point, _Digits);
      if(OrderSend(Symbol(), OP_BUY, Lote, Ask, 3, 0, tp, "", magicNumber) > 0)
      {
         nextBuy += PipsDistancia * _Point;
         nextSell += PipsDistancia * _Point;
      }
   }

   // Lógica de venta
   if(Ask < NormalizeDouble(nextSell, _Digits))
   {
      double tp = NormalizeDouble(Bid - PipsDistancia*RatioTP*_Point, _Digits);
      if(OrderSend(Symbol(), OP_SELL, Lote, Bid, 3, 0, tp, "", magicNumber) > 0)
      {
         nextSell -= PipsDistancia * _Point;
         nextBuy -= PipsDistancia * _Point;
      }
   }

   GestionarStops();
   ActualizarPanel();
}
//+------------------------------------------------------------------+
