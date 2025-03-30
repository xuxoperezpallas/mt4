//+------------------------------------------------------------------+
//|                      EA con IA - Local                           |
//+------------------------------------------------------------------+
#property strict
#property version   "3.0"

// Inputs
input double Lote = 0.1;
input int StopLoss = 50;       // En pips
input int TakeProfit = 100;    // En pips
input string ServidorLocal = "http://127.0.0.1:5000/predict"; // URL local
input double ConfianzaMinima = 0.72; // Mínimo 72% de confianza
input int TimeoutMS = 800;     // Timeout en milisegundos

// Variables globales
int ultima_señal = -1;
datetime ultima_vela = 0;

//+------------------------------------------------------------------+
//| Función de inicialización                                        |
//+------------------------------------------------------------------+
int OnInit()
{
   // Verificar conexión al servidor local
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) {
      Alert("Error: Sin conexión a Internet");
      return INIT_FAILED;
   }
   
   // Whitelist para conexión local (evitar bloqueos)
   if(!WebRequest("GET", ServidorLocal, "", TimeoutMS, "", "")) {
      Alert("Permite URL en: Herramientas > Opciones > Expert Advisors");
      return INIT_FAILED;
   }
   
   Print("EA Iniciado - Servidor Local: ", ServidorLocal);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Obtener señal de IA (versión optimizada)                         |
//+------------------------------------------------------------------+
int ObtenerSeñalIA()
{
   string encabezados = "Content-Type: application/json\r\n";
   string datos = StringFormat(
      "{\"open\":%.5f,\"high\":%.5f,\"low\":%.5f,\"close\":%.5f}",
      Open[0], High[0], Low[0], Close[0]
   );
   
   uchar respuesta[];
   string resultado;
   
   // Enviar solicitud al servidor local
   int res = WebRequest("POST", ServidorLocal, encabezados, TimeoutMS, datos, respuesta);
   
   if(res == 200) // HTTP OK
   {
      resultado = CharArrayToString(respuesta);
      
      // Parsear respuesta JSON rápida (sin librerías externas)
      int inicio_pred = StringFind(resultado, "\"prediction\":") + 13;
      int prediccion = (int)StringSubstr(resultado, inicio_pred, 1);
      
      int inicio_conf = StringFind(resultado, "\"probability\":") + 14;
      double confianza = StringToDouble(StringSubstr(resultado, inicio_conf, 4));
      
      if(confianza >= ConfianzaMinima)
         return prediccion; // 0=Vender, 1=Comprar
   }
   else Print("Error IA (Código ", res, "): ", ErrorDescription(GetLastError()));
   
   return -1; // Señal inválida
}

//+------------------------------------------------------------------+
//| Función principal (OnTick optimizado)                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Operar solo al inicio de cada vela
   if(Time[0] == ultima_vela) return;
   ultima_vela = Time[0];
   
   // Obtener señal
   int señal = ObtenerSeñalIA();
   
   if(señal == 0 || señal == 1)
   {
      // Cerrar órdenes contrarias
      CerrarÓrdenesOpuestas(señal);
      
      // Calcular SL/TP dinámico
      double sl = NormalizeDouble((señal == 1 ? Bid - StopLoss * _Point : Ask + StopLoss * _Point), Digits);
      double tp = NormalizeDouble((señal == 1 ? Bid + TakeProfit * _Point : Ask - TakeProfit * _Point), Digits);
      
      // Enviar orden
      if(señal == 1 && ultima_señal != 1)
      {
         if(OrderSend(Symbol(), OP_BUY, Lote, Ask, 3, sl, tp, "EA_IA_Local", 0, clrBlue))
            ultima_señal = 1;
      }
      else if(señal == 0 && ultima_señal != 0)
      {
         if(OrderSend(Symbol(), OP_SELL, Lote, Bid, 3, sl, tp, "EA_IA_Local", 0, clrOrange))
            ultima_señal = 0;
      }
   }
}

//+------------------------------------------------------------------+
//| Cerrar órdenes en dirección opuesta (optimizado)                 |
//+------------------------------------------------------------------+
void CerrarÓrdenesOpuestas(int señal_actual)
{
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS) && 
         OrderSymbol() == Symbol() && 
         OrderMagicNumber() == 0)
      {
         bool es_opuesta = (señal_actual == 1 && OrderType() == OP_SELL) || 
                          (señal_actual == 0 && OrderType() == OP_BUY);
         
         if(es_opuesta)
            OrderClose(OrderTicket(), OrderLots(), 
                      OrderType() == OP_BUY ? Bid : Ask, 3, clrGray);
      }
   }
}
