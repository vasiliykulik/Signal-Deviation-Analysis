//+------------------------------------------------------------------+
//|                                                 TripleShield.mq4 |
//|                                  Copyright © 2018, Vasiliy Kylik |
//|                                           http://www.alpari.org/ |
//+------------------------------------------------------------------+

extern double TakeProfit = 1200;
extern double StopLoss = 10000;
extern double Lots = 0.01;
extern double TrailingStop = 10000;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double

   MacdCurrent,
   MacdPrevious,
   MacdPrevious1,
   MacdPrevious2,
   MacdPrevious3,
   MacdSignal0,
   MacdSignal1,
   MacdSignal2,
   Macd300,
   Macd301,
   Macd302,
   Macd303;

   int
   cnt,
   ticket,
   total,
   buy,
   sell;

/* Variables Declaration  The algorithm of the trend criteria definition:*/

   int []
   halfWave0Н4, halfWave_1Н4, halfWave_2Н4, halfWave_3Н4,
   halfWave0Н1, halfWave_1Н1, halfWave_2Н1, halfWave_3Н1,
   halfWave0М15, halfWave_1М15, halfWave_2М15, halfWave_3М15,
   halfWave0М5, halfWave_1М5, halfWave_2М5, halfWave_3М5,
   halfWave0М1, halfWave_1М1, halfWave_2М1, halfWave_3М1;

   bool
   halfWavesCount,
   what0HalfWaveMACDH4, what_1HalfWaveMACDH4, what_2HalfWaveMACDН4, what_3HalfWaveMACDН4,
   doubleCriterionChannelН4,
   what0HalfWaveMACDН1, what_1HalfWaveMACDН1, what_2HalfWaveMACDН1, what_3HalfWaveMACDН1,
   doubleCriterionTrendН1,
   what0HalfWaveMACDМ15, what_1HalfWaveMACDМ15, what_2HalfWaveMACDМ15, what_3HalfWaveMACDМ15,
   doubleCriterionEntryPointМ15,
   what0HalfWaveMACDМ5, what_1HalfWaveMACDМ5, what_2HalfWaveMACDМ5, what_3halfWaveMACDМ5,
   doubleCriterionTheTimeOfEntryМ5,
   what0HalfWaveMACDМ1, what_1halfWaveMACDМ1, what_2HalfWaveMACDМ1, what_3HalfWaveMACDМ1,
   Stochastic_1H1, Stochastic0H1, Stochastic_1М15, Stochastic0М15, Stochastic_1М5, StochasticМ05, Stochastic_1М1, Stochastic0М1,
   directionStochasticH1, directionStochasticМ15, directionStochasticМ5, directionStochasticМ1,
   allStochastic,
   OsMA0H1, OsMA_1H1, OsMA015, OsMA_1М15, OsMA05, OsMA_1М5, OsMA01, OsMA_1М1,
   directionOsMAH1, directionOsMAМ15, directionOsMAМ5, directionOsMAМ1,
   allOsMA;


/* End Variables Declaration  The algorithm of the trend criteria definition:*/
   if(Bars<100)
     {
      Print("bars less than 100");
      return(0);
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return(0);  // check TakeProfit
     }

   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_MAIN,1);
   MacdPrevious1=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_MAIN,2);
   MacdPrevious2=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_MAIN,3);
   MacdPrevious3=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_MAIN,4);
   MacdSignal0=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_SIGNAL,0);
   MacdSignal1=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_SIGNAL,1);
   MacdSignal2=iMACD(NULL,0,12,26,9,PRICE_OPEN,MODE_SIGNAL,2);
   Macd300=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
   Macd301=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
   Macd302=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,2);
   Macd303=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,3);

/*   The algorithm of the trend criteria definition:

   Идём по истории H4
   1) what0HalfWaveMACDH4 (0 это положительная 1 это отрицательная)
   а) складываем тики в массив halfWave0Н4
   2) если произошло пересечение
   а) what_1HalfWaveMACDH4
   б) складываем тики в массив halfWave_1Н4
   3) если произошло пересечение
   а) what_2HalfWaveMACDН4
   б) складываем тики в массив halfWave_2Н4
   4) если произошло пересечение
   а) what_3HalfWaveMACDН4
   б) складываем тики в массив halfWave_3Н4

   if (what_1HalfWaveMACDH4 ==0 && what_3HalfWaveMACDН4==0) doubleCriterionChannelН4 = 0
   if (what_1HalfWaveMACDH4 ==1 && what_3HalfWaveMACDН4==1) doubleCriterionChannelН4 = 1

   Идём по истории H1
   1) what0HalfWaveMACDН1 (0 это положительная 1 это отрицательная)
   а) складываем тики в массив halfWave0Н1
   2) если произошло пересечение
   а) what_1HalfWaveMACDН1
   б) складываем тики в массив halfWave_1Н1
   3) если произошло пересечение
   а) what_2HalfWaveMACDН1
   б) складываем тики в массив halfWave_2Н1
   4) если произошло пересечение
   а) what_3HalfWaveMACDН1
   б) складываем тики в массив halfWave_3Н1

   if (what_1HalfWaveMACDН1 ==0 && what_3HalfWaveMACDН1==0) doubleCriterionTrendН1 = 0
   if (what_1HalfWaveMACDН1 ==1 && what_3HalfWaveMACDН1==1) doubleCriterionTrendН1 = 1

   Идём по истории М15
   1) what0HalfWaveMACDМ15
   а) складываем тики в массив halfWave0М15
   2) если произошло пересечение
   а) what_1HalfWaveMACDМ15
   б) складываем тики в массив halfWave_1М15
   3) если произошло пересечение
   а) what_2HalfWaveMACDМ15
   б) складываем тики в массив halfWave_2М15
   4) если произошло пересечение
   а) what_3HalfWaveMACDМ15
   б) складываем тики в массив halfWave_3М15

   if (what_1HalfWaveMACDМ15==0 && what_3HalfWaveMACDМ15==0) doubleCriterionEntryPointМ15 = 0
   if (what_1HalfWaveMACDМ15==1 && what_3HalfWaveMACDМ15==1) doubleCriterionEntryPointМ15 = 1

   Идём по истории М5
   1) what0HalfWaveMACDМ5
   а) складываем тики в массив halfWave0М5
   2) если произошло пересечение
   а) what_1HalfWaveMACDМ5
   б) складываем тики в массив halfWave_1М5
   3) если произошло пересечение
   а) what_2HalfWaveMACDМ5
   б) складываем тики в массив halfWave_2М5
   4) если произошло пересечение
   а) what_3halfWaveMACDМ5
   б) складываем тики в массив halfWave_3М5

   if (what_1HalfWaveMACDМ5 ==0 && what_3halfWaveMACDМ5==0) {doubleCriterionTheTimeOfEntryМ5 = 0;}
   if (what_1HalfWaveMACDМ5 ==1 && what_3halfWaveMACDМ5==1) {doubleCriterionTheTimeOfEntryМ5 = 1;}

   Идём по истории М1
   1) what0HalfWaveMACDМ1
   а) складываем тики в массив halfWave0М1
   2) если произошло пересечение
   а) what_1halfWaveMACDМ1
   б) складываем тики в массив halfWave_1М1
   3) если произошло пересечение
   а) what_2HalfWaveMACDМ1
   б) складываем тики в массив halfWave_2М1
   4) если произошло пересечение
   а) what_3HalfWaveMACDМ1
   б) складываем тики в массив halfWave_3М1

   if (what_1halfWaveMACDМ1 ==0 && what_3HalfWaveMACDМ1==0) {doubleCriterionМ1 = 0;}
   if (what_1halfWaveMACDМ1 ==1 && what_3HalfWaveMACDМ1==1) {doubleCriterionМ1 = 1;}

   if (Stochastic_1H1 <Stochastic0H1)  {directionStochasticH1== 0;}
   if (Stochastic_1М15<Stochastic0М15) {directionStochasticМ15==0;}
   if (Stochastic_1М5 <StochasticМ05)  {directionStochasticМ5== 0;}
   if (Stochastic_1М1 <Stochastic0М1)  {directionStochasticМ1== 0;}
   if (Stochastic_1H1 >Stochastic0H1)  {directionStochasticH1== 1;}
   if (Stochastic_1М15>Stochastic0М15) {directionStochasticМ15==1;}
   if (Stochastic_1М5 >StochasticМ05)  {directionStochasticМ5== 1;}
   if (Stochastic_1М1 >Stochastic0М1)  {directionStochasticМ1== 1;}

   if(directionStochasticH1 == 0 И directionStochasticМ15== 0 И directionStochasticМ5 == 0 И directionStochasticМ1 == 0) то allStochastic ==0
   if(directionStochasticH1 == 1 И directionStochasticМ15== 1 И directionStochasticМ5 == 1 И directionStochasticМ1 == 1) то allStochastic ==1

   if (OsMA_1H1>OsMA0H1)  {directionOsMAH1== 0;}
   if (OsMA_1М15>OsMA015) {directionOsMAМ15==0;}
   if (OsMA_1М5>OsMA05)   {directionOsMAМ5== 0;}
   if (OsMA_1М1>OsMA01)   {directionOsMAМ1== 0;}

   if (OsMA_1H1<OsMA0H1)  {directionOsMAH1== 1;}
   if (OsMA_1М15<OsMA015) {directionOsMAМ15==1;}
   if (OsMA_1М5<OsMA05)   {directionOsMAМ5== 1;}
   if (OsMA_1М1<OsMA01)   {directionOsMAМ1== 1;}

   if(directionOsMAH1 == 0 && directionOsMAM15== 0 && directionOsMAM5 == 0 && directionOsMAM1 == 0) {llOsMA ==0;}
   if(directionOsMAH1 == 1 && directionOsMAM15== 1 && directionOsMAM5 == 1 && directionOsMAM1 == 1) {llOsMA ==1;}
   End The algorithm of the trend criteria definition
   */

/*Logics Start The algorithm of the trend criteria definition*/


if (what_1HalfWaveMACDH4 ==0 && what_3HalfWaveMACDН4==0) {doubleCriterionChannelН4 = 0;}
if (what_1HalfWaveMACDH4 ==1 && what_3HalfWaveMACDН4==1) {doubleCriterionChannelН4 = 1;}
if (what_1HalfWaveMACDН1 ==0 && what_3HalfWaveMACDН1==0) {doubleCriterionTrendН1 = 0;}
if (what_1HalfWaveMACDН1 ==1 && what_3HalfWaveMACDН1==1) {doubleCriterionTrendН1 = 1;}
if (what_1HalfWaveMACDМ15==0 && what_3HalfWaveMACDМ15==0) {doubleCriterionEntryPointМ15 = 0;}
if (what_1HalfWaveMACDМ15==1 && what_3HalfWaveMACDМ15==1) {doubleCriterionEntryPointМ15 = 1;}
if (what_1HalfWaveMACDМ5 ==0 && what_3halfWaveMACDМ5==0) {doubleCriterionTheTimeOfEntryМ5 = 0;}
if (what_1HalfWaveMACDМ5 ==1 && what_3halfWaveMACDМ5==1) {doubleCriterionTheTimeOfEntryМ5 = 1;}
if (what_1halfWaveMACDМ1 ==0 && what_3HalfWaveMACDМ1==0) {doubleCriterionМ1 = 0;}
if (what_1halfWaveMACDМ1 ==1 && what_3HalfWaveMACDМ1==1) {doubleCriterionМ1 = 1;}

   if (Stochastic_1H1 <Stochastic0H1)  {directionStochasticH1== 0;}
   if (Stochastic_1М15<Stochastic0М15) {directionStochasticМ15==0;}
   if (Stochastic_1М5 <StochasticМ05)  {directionStochasticМ5== 0;}
   if (Stochastic_1М1 <Stochastic0М1)  {directionStochasticМ1== 0;}
   if (Stochastic_1H1 >Stochastic0H1)  {directionStochasticH1== 1;}
   if (Stochastic_1М15>Stochastic0М15) {directionStochasticМ15==1;}
   if (Stochastic_1М5 >StochasticМ05)  {directionStochasticМ5== 1;}
   if (Stochastic_1М1 >Stochastic0М1)  {directionStochasticМ1== 1;}

if(directionStochasticH1 == 0 && directionStochasticМ15== 0 && directionStochasticМ5 == 0 && directionStochasticМ1 == 0) {allStochastic ==0;}
if(directionStochasticH1 == 1 && directionStochasticМ15== 1 && directionStochasticМ5 == 1 && directionStochasticМ1 == 1) {allStochastic ==1;}

   if (OsMA_1H1>OsMA0H1)  {directionOsMAH1== 0;}
   if (OsMA_1М15>OsMA015) {directionOsMAМ15==0;}
   if (OsMA_1М5>OsMA05)   {directionOsMAМ5== 0;}
   if (OsMA_1М1>OsMA01)   {directionOsMAМ1== 0;}
   if (OsMA_1H1<OsMA0H1)  {directionOsMAH1== 1;}
   if (OsMA_1М15<OsMA015) {directionOsMAМ15==1;}
   if (OsMA_1М5<OsMA05)   {directionOsMAМ5== 1;}
   if (OsMA_1М1<OsMA01)   {directionOsMAМ1== 1;}

if(directionOsMAH1 == 0 && directionOsMAM15== 0 && directionOsMAM5 == 0 && directionOsMAM1 == 0) {allOsMA ==0;}
if(directionOsMAH1 == 1 && directionOsMAM15== 1 && directionOsMAM5 == 1 && directionOsMAM1 == 1) {allOsMA ==1;}


/*Logics End The algorithm of the trend criteria definition*/


   buy=1;
   sell=1;
   total=OrdersTotal();
   if(total<1)
     {
      // no opened orders identified
      if(AccountFreeMargin()<(1*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);
        }


      // check for long position (BUY) possibility
      if(
            /*
            Алгоритм открытия Позиции:
            для покупки если (doubleCriterionTrendН1 == 0 И doubleCriterionEntryPointМ15 == 0 И doubleCriterionTheTimeOfEntryМ5 == 0 И doubleCriterionМ1==0 И allOsMA==0 И allStochastic == 0) открыть покупку
            */
            buy ==1 &&
            // Criterion for buy position according to the TS
            doubleCriterionTrendН1 == 0 && doubleCriterionEntryPointМ15 == 0 && doubleCriterionTheTimeOfEntryМ5 == 0 && doubleCriterionМ1==0 && allOsMA==0 && allStochastic == 0;
        )
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-StopLoss*Point,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError());
         return(0);
        }
      // check for short position (SELL) possibility
      if(

           /*
           Алгоритм открытия Позиции:
           для продажи если (doubleCriterionTrendН1 == 1 И doubleCriterionEntryPointМ15 == 1 И doubleCriterionTheTimeOfEntryМ5 == 1 И doubleCriterionМ1==1 И allOsMA==1 И allStochastic == 1) открыть продажу
           */
           sell ==1 &&
           // Criterion for sell position according to the TS
           doubleCriterionTrendН1 == 1 && doubleCriterionEntryPointМ15 == 1 && doubleCriterionTheTimeOfEntryМ5 == 1 && doubleCriterionМ1==1 && allOsMA==1 && allStochastic == 1;
      )
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+StopLoss*Point,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError());
         return(0);
        }
      return(0);
     }
   // it is important to enter the market correctly,
   // but it is more important to exit it correctly...

/*   Алгоритм закрытия Позиции:
   критерий закрытия (предварительно двойной М15)

   Алгоритм ведения Позиции:
   критерий БезУбытка (взять из Безубытка - реализован в Трейлинг условии реализацией "Посвечный Безубыток")
   критерий ведения (двойной М5)*/

   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position
         OrderSymbol()==Symbol())  // check for symbol
        {
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
            /*if(MacdPrevious>0 && MacdCurrent<0)
                {
                 OrderClose(OrderTicket(),OrderLots(),Bid,30,Violet); // close position
                 return(0); // exit
                }*/
            // check for trailing stop
            if(TrailingStop>0&&!(OrderStopLoss()>OrderOpenPrice()))
              {
               if(Bid>Low[1]&&Low[1]>OrderOpenPrice())
                 {
                  if(Low[1]>OrderStopLoss())
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Low[1],OrderTakeProfit(),0,Green);
                     return(0);
                    }
                 }
              }
           }
         else // go to short position
           {
            // should it be closed?
            /*if(MacdPrevious<0 && MacdCurrent>0)
                {
                 OrderClose(OrderTicket(),OrderLots(),Bid,30,Violet); // close position
                 return(0); // exit
                }*/
            // check for trailing stop
            if(TrailingStop>0 && (OrderStopLoss()>OrderOpenPrice()||OrderStopLoss()==0))  // работает
              {
               if(Ask<(High[1]+(Ask-Bid)*2)&&(High[1]+(Ask-Bid)*2)<OrderOpenPrice())
                 {
                  if(((High[1]+(Ask-Bid)*2)<OrderStopLoss()) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),(High[1]+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
     }
   return(0);
  }
// the end.
