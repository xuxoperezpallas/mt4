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

int modify_1 = 10;
int modify = 50;

int md_buy = 1;
int md_sell = 1;
int estatico_buy = 1;
int estatico_sell = 1;

int open_position = 250;
int stop_lost = 50;
int take_profit = 300;

bool trade = false;

void OnTick()

{

    MqlTick last_tick;
    SymbolInfoTick(Symbol(), last_tick);

    double long_position = Low[0];
    double short_position = High[0];
    
    if (TimeHour(TimeCurrent()) <= 9 && (last_tick.bid <= NormalizeDouble(short_position - open_position*Point,Digits) || last_tick.ask >= NormalizeDouble(long_position + open_position*Point,Digits)))
       trade = false;

    if( trade == true && last_tick.ask >= NormalizeDouble(long_position + open_position*Point,Digits && OrdersTotal() == 0)) {
        OrderSend(Symbol(),OP_BUY,lot,Ask,5,NormalizeDouble(last_tick.bid - stop_lost*Point, Digits),NormalizeDouble(last_tick.bid + take_profit*Point, Digits),"Posicion larga abierta", 12345,0, Green);
        trade = false;
    }

    if( trade == true && last_tick.bid <= NormalizeDouble(short_position - open_position*Point,Digits) && OrdersTotal() == 0) {
        OrderSend(Symbol(),OP_SELL,lot,Bid,5,NormalizeDouble(last_tick.ask + stop_lost*Point, Digits),NormalizeDouble(last_tick.ask - take_profit*Point, Digits),"Posicion corta abierta", 12345,0, Blue);
        trade = false;
    }
    static datetime today;

    if (OrdersTotal() == 0 &&today != iTime (Symbol(), PERIOD_D1, 0)) {

        today = iTime (Symbol(), PERIOD_D1, 0);
        trade = true;
        md_sell = 1;
        md_buy = 1;
        estatico_buy = 1;
        estatico_sell = 1;
    } 
     estatico_buy = 1;
     estatico_sell = 1;
    
    
    int count;
    
    for (count = 0; count <= OrdersTotal(); count++){
    
        if (!OrderSelect(count, SELECT_BY_POS, MODE_TRADES))
            continue;
        if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
            if (last_tick.bid >= NormalizeDouble(OrderOpenPrice() + md_buy*modify_1*Point,Digits)) {
                if (md_buy >= estatico_buy){
                    OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble(last_tick.bid - modify*Point,Digits),0,0, Red);
                    md_buy +=1;
                    Print ("md_buy = " + md_buy);
                }
                estatico_buy += 1;
                Print("estatico_buy = " + estatico_buy);
            }
        }
    
        if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
        
            if (last_tick.ask <= NormalizeDouble(OrderOpenPrice() - md_sell*modify_1*Point,Digits)) {
                OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble(last_tick.ask + modify*Point,Digits),0,0, Orange);
                if (md_sell >= estatico_sell){
                    md_sell += 1;
                    Print("md_sell= " + md_sell);
                }
                estatico_sell += 1;
                Print("estatico_sell = " + estatico_sell);
            }
        }
    
     }  

}

//+------------------------------------------------------------------+