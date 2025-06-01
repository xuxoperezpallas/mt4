//+------------------------------------------------------------------+
//|                                                      Grid200.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
#property version   "1.00"
#property strict



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
void OnDeinit(const int ason)
  {
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (Bid > max)
     {
      max = Bid;
     }
    else if ( Bid - NormalizeDouble(dif *Point,Digits) < max) {
      Pico[i] = max;
       }

   if (Bid + NormalizeDouble(restablecer*Point,Digits) < max) {max = 0.000;}
   
   if (Ask < min)
      {
        min = Ask;
      }
    if (Ask - NormalizeDouble(restablecer*Point,Digits) > min){min=999999.0;}
  }
//+------------------------------------------------------------------+
