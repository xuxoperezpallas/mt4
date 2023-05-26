//+------------------------------------------------------------------+

//|                                                     interday.mq4 |

//|                                               Jesus Perez Pallas |

//|                                        xuxoperezpallas@gmail.com |

//+------------------------------------------------------------------+

#property copyright "Jesus Perez Pallas"

#property link      "xuxoperezpallas@gmail.com"

#property version   "1.00"

#property strict

//+------------------------------------------------------------------+

//| Expert initialization function                                   |

//+------------------------------------------------------------------+

int OnInit()

  {

//---

   

//---

   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+

//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+

void OnDeinit(const int reason)

  {

//---

   

  }

//+------------------------------------------------------------------+

//| Expert tick function                                             |

//+------------------------------------------------------------------+

input double lots = 0.01;

double lot = lots;

int open_position = 400;
int stop_lost = 700;
int take_profit = 250;

bool trade = false;

void OnTick()

{

    MqlTick last_tick;
    SymbolInfoTick(Symbol(), last_tick);

    double long_position = Low[0];
    double short_position = High[0];
    
    

    if( trade == true && last_tick.ask >= NormalizeDouble(long_position + open_position*Point,Digits)) {
        OrderSend(Symbol(),OP_BUY,lot,Ask,5,NormalizeDouble(last_tick.bid - stop_lost*Point, Digits),NormalizeDouble(last_tick.bid + take_profit*Point, Digits),"Posicion larga abierta", 12345,0, Green);
        trade = false;
    }

    if(trade == true && last_tick.bid <= NormalizeDouble(short_position - open_position*Point,Digits)) {
        OrderSend(Symbol(),OP_SELL,lot,Bid,5,NormalizeDouble(last_tick.ask + stop_lost*Point, Digits),NormalizeDouble(last_tick.ask - take_profit*Point, Digits),"Posicion corta abierta", 12345,0, Blue);
        trade = false;
    }
    static datetime today;

    if (OrdersTotal() == 0 &&today != iTime (Symbol(), PERIOD_D1, 0)) {

        today = iTime (Symbol(), PERIOD_D1, 0);
        trade = true;
    } else if (OrdersTotal() >= 1 && today != iTime (Symbol(), PERIOD_D1, 0)) {
        today = iTime (Symbol(), PERIOD_D1, 0);   

        int count;
        for (count = 0; count <= OrdersTotal(); count++){
        if (!OrderSelect(count, SELECT_BY_POS, MODE_TRADES))
            continue;
        if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
            OrderClose(OrderTicket(),OrderLots(),Bid, 5 , Orange);
        }
        if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
            OrderClose(OrderTicket(),OrderLots(),Ask, 5 , Red);
        }
        trade = true;
    }
   }  

}

//+------------------------------------------------------------------+
