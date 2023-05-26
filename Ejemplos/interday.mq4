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

int modify = 400;
int open_position = 400;
int stop_lost = 400;


int ml = 1, ms = 1;

bool trade_long = false;
bool trade_short = false;

//datetime today = D'01.01.2004';

void OnTick()
{

  
    
    MqlTick last_tick;
    SymbolInfoTick(Symbol(), last_tick);
    
    double long_position = Low[0];
    double short_position = High[0];
    
    if( trade_long == true && last_tick.ask >= NormalizeDouble(long_position + open_position*Point,Digits)) {
        OrderSend(Symbol(),OP_BUY,lot,Ask,5,NormalizeDouble(last_tick.bid - stop_lost*Point, Digits),0,"Posicion larga abierta", 12345,0, Green);
        trade_long = false;
    }
    
    if( trade_short == true && last_tick.bid <= NormalizeDouble(short_position - open_position*Point,Digits)) {
        OrderSend(Symbol(),OP_SELL,lot,Bid,5,NormalizeDouble(last_tick.ask + stop_lost*Point, Digits),0,"Posicion corta abierta", 12345,0, Blue);
        trade_short = false;
    }
    
    static datetime today;
    
    

    
    if (today != iTime (Symbol(), PERIOD_D1, 0)) {
        today = iTime (Symbol(), PERIOD_D1, 0);
        ml = 1; ms = 1;
        trade_long = true;
        ml = 1; ms = 1; 
        trade_short = true;
    }
    
    int count;
    
    for (count = 0; count <= OrdersTotal(); count++){
    
        if (!OrderSelect(count, SELECT_BY_POS, MODE_TRADES))
            continue;
            
        if (OrderSymbol() == Symbol() && OrderType() == OP_BUY){
            if (last_tick.ask >= NormalizeDouble(OrderOpenPrice() + ml*modify*Point, Digits)){
                OrderModify(OrderTicket(), OrderOpenPrice(),NormalizeDouble(last_tick.ask - modify*Point, Digits),0,0, Red);
                ml += 1;
            }
        }
        
        if (OrderSymbol() == Symbol() && OrderType() == OP_SELL){
            if (last_tick.bid <= NormalizeDouble(OrderOpenPrice() - ms*modify*Point, Digits)){
                OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(last_tick.bid + modify*Point, Digits),0,0, Yellow);
                ms += 1;
            }
        }
        
        if (OrderSymbol() == Symbol() && OrderType() == OP_BUY || OrderType() == OP_SELL){
            
        }
        
        
    }
   
}
//+------------------------------------------------------------------+
