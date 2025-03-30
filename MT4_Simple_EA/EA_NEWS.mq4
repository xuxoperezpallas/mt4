//+------------------------------------------------------------------+
//|                                  WaveNewsEA_InvestingAPI_Final.mq4 |
//|                      Usando JSON.mqh para conexión a Investing.com |
//+------------------------------------------------------------------+
#property strict
#include <JSON.mqh> // Asegúrate de tener esta librería en /Include/

// --- Parámetros Ajustables ---
input string apiKey = "TU_API_KEY"; // Clave de API (opcional)
input int updateNewsInterval = 300; // Intervalo de actualización de noticias (segundos)
input double adxThreshold = 25.0;   // Filtro ADX para tendencias fuertes

// --- Variables globales ---
datetime lastNewsUpdate;
JSONParser parser;
JSONArray events;

//+------------------------------------------------------------------+
//| Función de inicialización                                        |
//+------------------------------------------------------------------+
int OnInit() {
   lastNewsUpdate = TimeCurrent();
   if (!LoadEconomicCalendar()) {
      Alert("Error al cargar noticias. Verifica la conexión o la API key.");
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Función principal (OnTick)                                       |
//+------------------------------------------------------------------+
void OnTick() {
   if (TimeCurrent() - lastNewsUpdate >= updateNewsInterval) {
      LoadEconomicCalendar();
      lastNewsUpdate = TimeCurrent();
   }

   // --- Lógica de trading (similar a versiones anteriores) ---
   double adx = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, 0);
   if (adx >= adxThreshold) {
      double impact = GetNewsImpact(Symbol());
      if (impact >= 0.5) ExecuteTrade(OP_BUY);
      else if (impact <= -0.5) ExecuteTrade(OP_SELL);
   }
}

//+------------------------------------------------------------------+
//| Cargar noticias desde Investing.com                             |
//+------------------------------------------------------------------+
bool LoadEconomicCalendar() {
   string url = "https://api.investing.com/api/financial-calendar/economicCalendar";
   string headers = "Content-Type: application/json";
   char data[], result[];

   // --- Realizar solicitud HTTP ---
   int res = WebRequest("GET", url, headers, 0, data, result, headers);
   if (res == 200) {
      string json = CharArrayToString(result);
      parser = JSONParser(json);
      events = parser.GetArray("data");
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Obtener impacto de noticias para una moneda                      |
//+------------------------------------------------------------------+
double GetNewsImpact(string currency) {
   for (int i = 0; i < events.Size(); i++) {
      JSONObject event = events.GetObject(i);
      if (event.GetString("currency") == currency) {
         string impact = event.GetString("impact");
         double actual = event.GetDouble("actual");
         double forecast = event.GetDouble("forecast");

         if (impact == "High") return (actual > forecast) ? 1.0 : -1.0;
         else if (impact == "Medium") return (actual > forecast) ? 0.5 : -0.5;
      }
   }
   return 0.0;
}

//+------------------------------------------------------------------+
//| Ejecutar órdenes (gestión de riesgo incluida)                   |
//+------------------------------------------------------------------+
void ExecuteTrade(int cmd) {
   double lotSize = 0.1; // Ajustar según gestión de riesgo
   double price = (cmd == OP_BUY) ? Ask : Bid;
   double sl = (cmd == OP_BUY) ? price - 50*Point : price + 50*Point;
   double tp = (cmd == OP_BUY) ? price + 100*Point : price - 100*Point;

   OrderSend(Symbol(), cmd, lotSize, price, 3, sl, tp, "WaveNewsEA", 0);
}
