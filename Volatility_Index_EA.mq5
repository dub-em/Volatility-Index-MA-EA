//+------------------------------------------------------------------+
//|                                                        newEa.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include<Trade\Trade.mqh>
CTrade trade;

datetime globalbartime;

input int most_sens = 20;
input int med_sens = 50;
input int least_sens = 200; 

int Ema20Def = iMA(_Symbol, PERIOD_CURRENT, most_sens, 0, MODE_EMA, PRICE_CLOSE);
int Ema50Def = iMA(_Symbol, PERIOD_CURRENT, med_sens, 0, MODE_EMA, PRICE_CLOSE);
int Ema200Def = iMA(_Symbol, PERIOD_CURRENT, least_sens, 0, MODE_EMA, PRICE_CLOSE);

input double l_Size = 0.01;
input int lag = 2;
int num_lag_buy = 0;
int num_lag_sell = 0;

void OnTick(){
   datetime rightbartime = iTime(_Symbol,PERIOD_CURRENT, 0);
   if(rightbartime != globalbartime){
      takeBuy();
      takeSell();
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
   
   CopyBuffer(Ema20Def, 0, 0, 2, Ema20Arr);
   CopyBuffer(Ema50Def, 0, 0, 2, Ema50Arr);
   CopyBuffer(Ema200Def, 0, 0, 2, Ema200Arr);
   
   int numBuy = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--){
      string symBuy = PositionGetSymbol(i);
      if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) ){
         numBuy += 1;
      }
   }
   
   if (numBuy == 0){
      num_lag_buy = 0;
      for (int i = lag-1; i >= 0; i--){
         if((Ema20Arr[i] > Ema50Arr[i]) && (Ema50Arr[i] > Ema200Arr[i])  && (Ema20Arr[i] > Ema200Arr[i])){
            num_lag_buy +=1;  
         }
      }
      if (num_lag_buy == 2){
         trade.Buy(l_Size, NULL, Ask, NULL, NULL, NULL);
      }   
   }else{
      int i = 0;
      if((Ema20Arr[i] < Ema50Arr[i]) && (Ema20Arr[i+1] < Ema50Arr[i+1])){
         for(int x=PositionsTotal()-1; x>=0; x--){  
            string symbols = PositionGetSymbol(x);
            if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY)){
               ulong posTicket = PositionGetInteger(POSITION_TICKET);
               trade.PositionClose(posTicket);
            } 
         }
      }
   }  
}

void takeSell(){
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   double Ema20Arr[]; double Ema50Arr[]; double Ema200Arr[];
   
   ArraySetAsSeries(Ema20Arr, true);
   ArraySetAsSeries(Ema50Arr, true);
   ArraySetAsSeries(Ema200Arr, true);
   
   CopyBuffer(Ema20Def, 0, 0, 2, Ema20Arr);
   CopyBuffer(Ema50Def, 0, 0, 2, Ema50Arr);
   CopyBuffer(Ema200Def, 0, 0, 2, Ema200Arr);
   
   int numSell = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--){
      string symSell = PositionGetSymbol(i);
      if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL) ){
         numSell += 1;
      }
   }
   
   if (numSell == 0){
      num_lag_sell = 0;
      //double tp;
      //tp = Bid - ((20*10000)*_Point);
      for (int i = lag-1; i >= 0; i--){
         if((Ema20Arr[i] < Ema50Arr[i]) && (Ema50Arr[i] < Ema200Arr[i])){
            num_lag_sell +=1;  
         }
      }
      if (num_lag_sell == 2){
         trade.Sell(l_Size, NULL, Bid, NULL, NULL, NULL);
      }   
   }else{
      int i = 0;
      if((Ema20Arr[i] > Ema50Arr[i]) && (Ema20Arr[i+1] > Ema50Arr[i+1])){
         for(int x=PositionsTotal()-1; x>=0; x--){  
            string symbols = PositionGetSymbol(x);
            if((PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL) ){
               ulong posTicket = PositionGetInteger(POSITION_TICKET);
               trade.PositionClose(posTicket);
            } 
         }
      }
   }  
}