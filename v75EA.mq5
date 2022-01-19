//+------------------------------------------------------------------+
//|                                                        newEa.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit(){
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
}
#include<Trade\Trade.mqh>
CTrade trade;

datetime globalbartime;

int Ema20Def = iMA(_Symbol, PERIOD_M30, 20, 0, MODE_EMA, PRICE_CLOSE);
int Ema50Def = iMA(_Symbol, PERIOD_M30, 50, 0, MODE_EMA, PRICE_CLOSE);
int Ema200Def = iMA(_Symbol, PERIOD_M30, 200, 0, MODE_EMA, PRICE_CLOSE);

void OnTick(){
   datetime rightbartime = iTime(_Symbol,PERIOD_M30, 0);
   if(rightbartime != globalbartime){
      takeBuy();
      globalbartime = rightbartime;
   }
}

void takeBuy(){
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   double Ema20Arr[]; double Ema50Arr[]; double Ema200Arr[];
   
   ArraySetAsSeries(Ema20Arr, true);
   ArraySetAsSeries(Ema50Arr, true);
   ArraySetAsSeries(Ema200Arr, true);
   
   CopyBuffer(Ema20Def, 0, 0, 3, Ema20Arr);
   CopyBuffer(Ema50Def, 0, 0, 3, Ema50Arr);
   CopyBuffer(Ema200Def, 0, 0, 3, Ema200Arr);
   
   int numBuy = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--){
      string symBuy = PositionGetSymbol(i);
      if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) ){
         numBuy += 1;
      }
   }
   
   int numSell = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--){
      string symSell = PositionGetSymbol(i);
      if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL) ){
         numSell += 1;
      }
   }
   
   for(int i=0; i<2; i++){
   
      if((Ema20Arr[i] > Ema50Arr[i]) && (Ema50Arr[i] > Ema200Arr[i]) && (Ema20Arr[i] > Ema200Arr[i])){
         if(numBuy == 0){
            trade.Buy(0.01, NULL, Ask, NULL, NULL, NULL);
         }
      }
      
      if((Ema20Arr[i] < Ema50Arr[i]) && (Ema20Arr[i+1] > Ema50Arr[i+1])){
         for(int x=PositionsTotal()-1; x>=0; x--){  
            string symbols = PositionGetSymbol(x);
            if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) ){
               ulong posTicket = PositionGetInteger(POSITION_TICKET);
               trade.PositionClose(posTicket);
            }
           
         }
      }
      
      /*
      if((Ema20Arr[i] < Ema50Arr[i]) && (Ema50Arr[i] < Ema200Arr[i]) && (Ema20Arr[i] < Ema200Arr[i])){
         if(numSell == 0){
            trade.Sell(0.001, NULL, Bid, NULL, NULL, NULL);
         }
      }
      
      if((Ema20Arr[i] > Ema50Arr[i]) && (Ema20Arr[i+1] < Ema50Arr[i+1])){
         for(int x=PositionsTotal()-1; x>=0; x--){  
            string symbols = PositionGetSymbol(x);
            if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL)){
               ulong posTicket = PositionGetInteger(POSITION_TICKET);
               trade.PositionClose(posTicket);
            }
           
         }
      }
      **/
      
   }
   
   
}
