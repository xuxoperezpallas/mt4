//+------------------------------------------------------------------+
//| Expert Advisor - Funciones de Máximos y Mínimos                  |
//+------------------------------------------------------------------+

input int NumVelas = 200;          // Número de velas a analizar
input double DiferenciaPips = 500; // Diferencia mínima en pips entre máximos/mínimos
input double PipsEntrada = 10;     // Pips por encima del máximo/mínimo para entrada
input double ObjetivoPips = 100;   // Pips objetivo para take profit

//+------------------------------------------------------------------+
//| Función para obtener máximos de las últimas N velas              |
//+------------------------------------------------------------------+
void ObtenerMaximos(double &arrayMaximos[])
{
    ArrayResize(arrayMaximos, NumVelas);
    for(int i=0; i<NumVelas; i++)
    {
        arrayMaximos[i] = High[iHighest(NULL, 0, MODE_HIGH, NumVelas, i)];
    }
    ArraySetAsSeries(arrayMaximos, true);
}

//+------------------------------------------------------------------+
//| Función para obtener mínimos de las últimas N velas              |
//+------------------------------------------------------------------+
void ObtenerMinimos(double &arrayMinimos[])
{
    ArrayResize(arrayMinimos, NumVelas);
    for(int i=0; i<NumVelas; i++)
    {
        arrayMinimos[i] = Low[iLowest(NULL, 0, MODE_LOW, NumVelas, i)];
    }
    ArraySetAsSeries(arrayMinimos, true);
}

//+------------------------------------------------------------------+
//| Función para filtrar máximos significativos                      |
//+------------------------------------------------------------------+
void FiltrarMaximos(double &arrayMaximos[], double &maximosFiltrados[])
{
    int count = 0;
    double tempArray[];
    ArrayResize(tempArray, ArraySize(arrayMaximos));
    ArrayCopy(tempArray, arrayMaximos);
    ArraySort(tempArray);
    
    // Siempre añadir el máximo más alto
    maximosFiltrados[0] = tempArray[ArraySize(tempArray)-1];
    count = 1;
    
    // Buscar otros máximos que difieran en al menos DiferenciaPips
    for(int i=ArraySize(tempArray)-2; i>=0 && count<3; i--)
    {
        bool esSignificativo = true;
        for(int j=0; j<count; j++)
        {
            if(MathAbs(tempArray[i] - maximosFiltrados[j]) < DiferenciaPips * Point)
            {
                esSignificativo = false;
                break;
            }
        }
        
        if(esSignificativo)
        {
            maximosFiltrados[count] = tempArray[i];
            count++;
        }
    }
    
    ArrayResize(maximosFiltrados, count);
    ArraySort(maximosFiltrados);
    ArrayReverse(maximosFiltrados);
}

//+------------------------------------------------------------------+
//| Función para filtrar mínimos significativos                      |
//+------------------------------------------------------------------+
void FiltrarMinimos(double &arrayMinimos[], double &minimosFiltrados[])
{
    int count = 0;
    double tempArray[];
    ArrayResize(tempArray, ArraySize(arrayMinimos));
    ArrayCopy(tempArray, arrayMinimos);
    ArraySort(tempArray);
    
    // Siempre añadir el mínimo más bajo
    minimosFiltrados[0] = tempArray[0];
    count = 1;
    
    // Buscar otros mínimos que difieran en al menos DiferenciaPips
    for(int i=1; i<ArraySize(tempArray) && count<3; i++)
    {
        bool esSignificativo = true;
        for(int j=0; j<count; j++)
        {
            if(MathAbs(tempArray[i] - minimosFiltrados[j]) < DiferenciaPips * Point)
            {
                esSignificativo = false;
                break;
            }
        }
        
        if(esSignificativo)
        {
            minimosFiltrados[count] = tempArray[i];
            count++;
        }
    }
    
    ArrayResize(minimosFiltrados, count);
    ArraySort(minimosFiltrados);
}

//+------------------------------------------------------------------+
//| Función para verificar rupturas y abrir operaciones              |
//+------------------------------------------------------------------+
void VerificarRupturas(double &maximosFiltrados[], double &minimosFiltrados[])
{
    // Verificar ruptura de máximos (compra)
    for(int i=0; i<ArraySize(maximosFiltrados); i++)
    {
        if(Bid > maximosFiltrados[i] + PipsEntrada * Point && OrdersTotal() == 0)
        {
            double takeProfit = Bid + ObjetivoPips * Point;
            OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, takeProfit, "Ruptura Máximo", 0, 0, clrGreen);
            break;
        }
    }
    
    // Verificar ruptura de mínimos (venta)
    for(int i=0; i<ArraySize(minimosFiltrados); i++)
    {
        if(Ask < minimosFiltrados[i] - PipsEntrada * Point && OrdersTotal() == 0)
        {
            double takeProfit = Ask - ObjetivoPips * Point;
            OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, takeProfit, "Ruptura Mínimo", 0, 0, clrRed);
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
    double arrayMaximos[], arrayMinimos[];
    double maximosFiltrados[3], minimosFiltrados[3];
    
    // Obtener máximos y mínimos
    ObtenerMaximos(arrayMaximos);
    ObtenerMinimos(arrayMinimos);
    
    // Filtrar los más significativos
    FiltrarMaximos(arrayMaximos, maximosFiltrados);
    FiltrarMinimos(arrayMinimos, minimosFiltrados);
    
    // Verificar rupturas para entrar en operaciones
    VerificarRupturas(maximosFiltrados, minimosFiltrados);
    
    // Puedes agregar aquí código para mostrar la información en pantalla si lo deseas
}
