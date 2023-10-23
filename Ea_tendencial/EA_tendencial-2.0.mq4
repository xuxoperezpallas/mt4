//+------------------------------------------------------------------+
//|                                                EA_Tendencial.mq4 |
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
//+------------------------------------------------------------------
input double lots = 0.50;
double lot = lots;

double open_tick = Close[1];

double trade_long = open_tick;
double trade_short = open_tick;

input int distancia = 400;

input int stop_loss = 100;
input int take_profit = 100;

input int stop = 2000;


double buy_buffer[5000];
double sell_buffer[5000];

double stop_loss_buy;
double stop_loss_sell;

bool trade = true;
bool _long = true;
bool _short = true;




void OnTick() {

    MqlTick last_tick;
    SymbolInfoTick(Symbol(), last_tick);
    
    if( trade == true && _long == true && last_tick.ask >= trade_long + NormalizeDouble(distancia*Point,Digits)){
    
        OrderSend(Symbol(),OP_BUY,lot,Ask,5,last_tick.ask - NormalizeDouble(stop_loss*Point,Digits),0,"Posicion larga abierta",12345,0,Blue);
        trade_long += NormalizeDouble(distancia*Point,Digits);
        trade_short = trade_long;
    }
    
    if( trade == true && _short == true && last_tick.bid <= trade_short - NormalizeDouble(distancia*Point,Digits)){
    
        OrderSend(Symbol(),OP_SELL,lot,Bid,5,last_tick.bid + NormalizeDouble(stop_loss*Point,Digits),0,"Posicion corta abierta",12345,0,Blue);
        trade_short -= NormalizeDouble(distancia*Point,Digits);
        trade_long = trade_short;
    }
    if (last_tick.ask >= stop_loss_buy){
        stop_loss_buy = last_tick.ask;
    }
    
    if (last_tick.bid <= stop_loss_sell){
        stop_loss_sell = last_tick.bid;
    }
    
    storage_buy_buffer(buy_buffer);
    storage_sell_buffer(sell_buffer);
    
    _long = stop_open_positions_long();
    _short = stop_open_positions_short();
    
    trade = stop_open_positions(buy_buffer,sell_buffer);
    
    storage_buy_buffer(buy_buffer);
    storage_sell_buffer(sell_buffer);
    
    _take_profit_buy();
    _take_profit_sell();
    
    stop_buy_positions(stop_loss_buy);
    stop_sell_positions(stop_loss_sell);
   
}
//+------------------------------------------------------------------+

bool stop_open_positions(double& storage_1[], double& storage_2[]){
    
    int rango = 50;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i < OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_BUY){
                for (int g = 0; g < OrdersTotal(); g++){
                    for (int h = 0; h <= 1000; h++) {
                        if (last_tic.ask <= storage_1[g] + NormalizeDouble(rango*Point,Digits) &&
                            last_tic.ask >= storage_1[g] - NormalizeDouble(rango*Point,Digits) &&
                            last_tic.ask <= storage_2[h] + NormalizeDouble(rango*Point,Digits) &&
                            last_tic.ask >= storage_2[h] - NormalizeDouble(rango*Point,Digits)){
                            return trade = false;
                            }
                    }
                }
            }
            
            if (OrderType() == OP_SELL){
                for (int  g = 0; g < OrdersTotal(); g++){
                    for ( int h = 0; h <= 1000; h++) {
                        if (last_tic.bid <= storage_1[g] + NormalizeDouble(rango*Point,Digits) &&
                            last_tic.bid >= storage_1[g] - NormalizeDouble(rango*Point,Digits) &&
                            last_tic.bid <= storage_2[h] + NormalizeDouble(rango*Point,Digits) &&
                            last_tic.bid >= storage_2[h] - NormalizeDouble(rango*Point,Digits)){
                            return trade = false;
                            }
                    }
                }
            }
            else{
               return trade = true;
            }
        }
    }
    return trade = true;
}

bool stop_open_positions_long(){
    
    int rango = 80;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i <= OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_BUY){
                if (last_tic.ask <= OrderOpenPrice() +  NormalizeDouble(rango*Point,Digits) &&
                    last_tic.ask >= OrderOpenPrice() -  NormalizeDouble(rango*Point,Digits)){
                        return _long = false;
                }
                else {
                   return _long = true;
                }
                
            }
        }
    }
    return _long = true;
}

bool stop_open_positions_short(){
    
    int rango = 80;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i < OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_SELL){
                if (last_tic.bid <= OrderOpenPrice() +  NormalizeDouble(rango*Point,Digits) &&
                    last_tic.bid >= OrderOpenPrice() -  NormalizeDouble(rango*Point,Digits)){
                        return _short = false;
                }
                else {
                   return _short = true;
                }
                
            }
        }
    }
    return _short = true;
}


void storage_buy_buffer(double& storage[]){
    
    int rango = 80;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i < OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_BUY){
                for (int g = 0; g <= OrdersTotal(); g++){
                    if (last_tic.ask <= OrderOpenPrice() + NormalizeDouble(rango*Point,Digits) &&
                        last_tic.ask >= OrderOpenPrice() - NormalizeDouble(rango*Point,Digits)){
                            storage[g] = OrderOpenPrice();                              
                        
                    }
                 }
             }
        }
    }
}


void  storage_sell_buffer(double& storage[]){

    int rango = 80;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i < OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_SELL){
                for (int g = 0; g <= 1000; g++){
                    if (last_tic.bid <= OrderOpenPrice() + NormalizeDouble(rango*Point,Digits) &&
                        last_tic.bid >= OrderOpenPrice() - NormalizeDouble(rango*Point,Digits)){
                            storage[g] = OrderOpenPrice();                              
                    }
                 }
             }
        }
    }
   
}


void reset_buy_buffer(double& storage[]){
    
    int rango = 80;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i < OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_BUY){
                for (int g = 0; g <= 1000; g++){
                    if (!(last_tic.ask <= OrderOpenPrice() + NormalizeDouble(rango*Point,Digits) &&
                        last_tic.ask >= OrderOpenPrice() - NormalizeDouble(rango*Point,Digits))){
                            storage[g] = 10000;                               
                        
                    }
                 }
             }
        }
    }
}


void reset_sell_buffer(double& storage[]){
    
    int rango = 80;
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for(int i = 0; i < OrdersTotal(); i++){
    
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           continue;
           
       if (OrderSymbol() == Symbol()){
       
            if (OrderType() == OP_SELL){
                for (int g = 0; g <= 1000; g++){
                    if (!(last_tic.bid <= OrderOpenPrice() + NormalizeDouble(rango*Point,Digits) &&
                        last_tic.bid >= OrderOpenPrice() - NormalizeDouble(rango*Point,Digits))){
                            storage[g] = 0;
                        
                    }
                 }
             }
        }
    }
}


void _take_profit_buy(){
    
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for (int i = 0; i < OrdersTotal(); i++){
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
         if (OrderSymbol() == Symbol()){
             if (OrderType() == OP_BUY){
                 if (last_tic.ask >= OrderOpenPrice() + NormalizeDouble( distancia*Point,Digits)){
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() + NormalizeDouble(take_profit*Point,Digits),0,0, Yellow))
                         Print("Error : " + GetLastError());
                 }
             }
         }
    }
}

void _take_profit_sell(){
    
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for (int i = 0; i < OrdersTotal(); i++){
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
         if (OrderSymbol() == Symbol()){
             if (OrderType() == OP_SELL){
                 if (last_tic.bid <= OrderOpenPrice() - NormalizeDouble( distancia*Point,Digits)){
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - NormalizeDouble(take_profit*Point,Digits),0,0, Yellow))
                         Print("Error : " + GetLastError());
                 }
             }
         }
    }
}

void stop_sell_positions(double stop_sell){
    
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for (int i = 0; i < OrdersTotal(); i++){
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
         if (OrderSymbol() == Symbol()){
             if (OrderType() == OP_SELL){
                 if (last_tic.bid >= stop_sell + NormalizeDouble(stop *Point,Digits)){
                     OrderClose(OrderTicket(),OrderLots(), Bid, 5, Red);
                 }
             }
         }
     }
}

void stop_buy_positions(double stop_buy){
    
    MqlTick last_tic;
    SymbolInfoTick(Symbol(), last_tic);
    
    for (int i = 0; i < OrdersTotal(); i++){
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
              continue;
         if (OrderSymbol() == Symbol()){
             if (OrderType() == OP_BUY){
                 if (last_tic.ask <= stop_buy - NormalizeDouble(stop *Point,Digits)){
                     OrderClose(OrderTicket(),OrderLots(), Ask, 5, Red);
                 }
             }
         }
     }
}
