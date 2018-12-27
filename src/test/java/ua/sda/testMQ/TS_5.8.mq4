//+------------------------------------------------------------------+
//|                                                       TS_5.8.mq4 |
//|                                                    Vasiliy Kulik |
//|                                                       alpari.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Kulik"
#property link      "alpari.com"
#property version   "5.8"
#property strict

extern double TakeProfit=2400;
extern double StopLoss=1600;
extern double Lots=1;
extern double TrailingStop=10000;
int iteration;
double filterForMinusHalfWave= -0.0001000;
double filterForPlusHalfWave = 0.0001000;
double firstMinGlobal=0.00000000,secondMinGlobal=0.00000000,firstMaxGlobal=0.00000000,secondMaxGlobal=0.00000000;
double firstMinGlobalMACD=0.00000000,secondMinGlobalMACD=0.00000000,firstMaxGlobalMACD=0.00000000,secondMaxGlobalMACD=0.00000000;
ENUM_TIMEFRAMES periodGlobal;
int firstPointTick=0,secondPointTick=0;
int localFirstPointTick=0,localSecondPointTick=0;

ENUM_TIMEFRAMES timeFrames[]={PERIOD_M5,PERIOD_M15,PERIOD_H1,PERIOD_H4,PERIOD_D1};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {

   int cnt,ticket,total,buy,sell;

/* End Variables Declaration  The algorithm of the trend criteria definition:*/
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;  // check TakeProfit
     }

   buy=0;
   sell=0;
   bool lowAndHighUpdateViaNonSymmTick=false;
   bool lowAndHighUpdateViaNonSymm = false;
   bool lowAndHighUpdateViaNonSymmForTrailing = false;
   bool isFiboModuleGreenState_M5=false,isFiboModuleGreenState_M15=false,isFiboModuleGreenState_H1=false,isFiboModuleGreenState_H4=false,isFiboModuleGreenState_D1=false;
   bool isFiboModuleRedState_M5=false,isFiboModuleRedState_M15=false,isFiboModuleRedState_H1=false,isFiboModuleRedState_H4=false,isFiboModuleRedState_D1=false;
   bool isFiboModuleGreenLevel_100_IsPassed_M5=false,isFiboModuleGreenLevel_100_IsPassed_M15=false,isFiboModuleGreenLevel_100_IsPassed_H1=false,isFiboModuleGreenLevel_100_IsPassed_H4=false,isFiboModuleGreenLevel_100_IsPassed_D1=false;
   bool isFiboModuleRedLevel_100_IsPassed_M5=false,isFiboModuleRedLevel_100_IsPassed_M15=false,isFiboModuleRedLevel_100_IsPassed_H1=false,isFiboModuleRedLevel_100_IsPassed_H4=false,isFiboModuleRedLevel_100_IsPassed_D1=false;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int buyWeight=0,sellWeight=0;
   total=OrdersTotal();
   if(total<1)
     {
/*      мы убираем
      блок условий по пересечению MACD + MA 83
      блок Считаем Веса
      блок Проставляем Флаги*/
      for(int i=0; i<=ArraySize(timeFrames)-1;i++) // iterate through TimeFrames
        {
         //        Print("i = ", i, " ArraySize(timeFrames) = ", ArraySize(timeFrames));
         //        Print("periodGlobal = ", periodGlobal, " timeFrames[i] = ", timeFrames[i]);
         periodGlobal=timeFrames[i]; // set TimeFrame global value for nonSymmTick()
         lowAndHighUpdateViaNonSymmTick=nonSymmTick(); // set values to firstPointTick and secondPointTick global variables
         if(High[secondPointTick]>Low[firstPointTick]) // if green
           {
            if(timeFrames[i]==PERIOD_M5){isFiboModuleGreenState_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isFiboModuleGreenState_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isFiboModuleGreenState_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isFiboModuleGreenState_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isFiboModuleGreenState_D1 = true;}
            // if price higher than Fibo 100 on current TimeFrame
            // but i need
            // not defined cyclePeriod; cyclePeriod equals timeFrames[i]; ie TimeFrame; for example PERIOD_M5
            if(iClose(NULL,timeFrames[i],0)>High[secondPointTick] && iClose(NULL,timeFrames[i],1)<High[secondPointTick])
              {
               if(timeFrames[i]==PERIOD_M5){isFiboModuleGreenLevel_100_IsPassed_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isFiboModuleGreenLevel_100_IsPassed_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isFiboModuleGreenLevel_100_IsPassed_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isFiboModuleGreenLevel_100_IsPassed_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isFiboModuleGreenLevel_100_IsPassed_D1 = true;}
              }
           }
         if(Low[secondPointTick]<High[firstPointTick]) // red
           {
            if(timeFrames[i]==PERIOD_M5){isFiboModuleRedState_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isFiboModuleRedState_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isFiboModuleRedState_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isFiboModuleRedState_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isFiboModuleRedState_D1 = true;}
            if(iClose(NULL,timeFrames[i],0)<Low[secondPointTick] && iClose(NULL,timeFrames[i],1)>Low[secondPointTick]) // not defined cyclePeriod
              {
               if(timeFrames[i]==PERIOD_M5){isFiboModuleRedLevel_100_IsPassed_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isFiboModuleRedLevel_100_IsPassed_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isFiboModuleRedLevel_100_IsPassed_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isFiboModuleRedLevel_100_IsPassed_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isFiboModuleRedLevel_100_IsPassed_D1 = true;}
              }
           }
        }// end of TimeFrames for loop for FiboModule State and IsPassed flag

      bool isTrendBull_M5 = false, isTrendBull_M15 = false, isTrendBull_H1 = false, isTrendBull_H4 = false, isTrendBull_D1 = false;
      bool isTrendBear_M5 = false, isTrendBear_M15 = false, isTrendBear_H1 = false, isTrendBear_H4 = false, isTrendBear_D1 = false;
      bool isDivergenceUp_M5=false,isDivergenceUp_M15=false,isDivergenceUp_H1=false,isDivergenceUp_H4=false,isDivergenceUp_D1=false;
      bool isDivergenceDown_M5=false,isDivergenceDown_M15=false,isDivergenceDown_H1=false,isDivergenceDown_H4=false,isDivergenceDown_D1=false;

      for(int i=0; i<=ArraySize(timeFrames)-1;i++) // iterate through TimeFrames
        {
         periodGlobal=timeFrames[i]; // set TimeFrame global value for nonSymm()
                                     // set values to firstMinGlobal firstMaxGlobal secondMinGlobal secondMaxGlobal and firstMinGlobalMACD, secondMinGlobalMACD, firstMaxGlobalMACD, secondMaxGlobalMACD;
         lowAndHighUpdateViaNonSymm=nonSymm();
         if(firstMinGlobal>secondMinGlobal) // Trend up
           {
            if(timeFrames[i]==PERIOD_M5) {isTrendBull_M5   = true;}
            if(timeFrames[i]==PERIOD_M15){isTrendBull_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {isTrendBull_H1   = true;}
            if(timeFrames[i]==PERIOD_H4) {isTrendBull_H4   = true;}
            if(timeFrames[i]==PERIOD_D1) {isTrendBull_D1   = true;}
            // if price higher than Fibo 100 on current TimeFrame
            // but i need
            // not defined cyclePeriod; cyclePeriod equals timeFrames[i]; ie TimeFrame; for example PERIOD_M5
            if(firstMinGlobalMACD<secondMinGlobalMACD) // Divergence ! сontrary
              {
               if(timeFrames[i]==PERIOD_M5) {isDivergenceUp_M5  = true;}
               if(timeFrames[i]==PERIOD_M15){isDivergenceUp_M15 = true;}
               if(timeFrames[i]==PERIOD_H1) {isDivergenceUp_H1  = true;}
               if(timeFrames[i]==PERIOD_H4) {isDivergenceUp_H4  = true;}
               if(timeFrames[i]==PERIOD_D1) {isDivergenceUp_D1  = true;}
              }
           }
         if(firstMaxGlobal<secondMaxGlobal) // Trend down
           {
            if(timeFrames[i]==PERIOD_M5){isTrendBear_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isTrendBear_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isTrendBear_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isTrendBear_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isTrendBear_D1 = true;}
            if(firstMaxGlobalMACD>secondMaxGlobalMACD) // Divergence ! сontrary
              {
               if(timeFrames[i]==PERIOD_M5){isDivergenceDown_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isDivergenceDown_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isDivergenceDown_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isDivergenceDown_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isDivergenceDown_D1 = true;}
              }
           }
        }// end of TimeFrames for loop for Trend and Divergence flag

      // the trading strategy itself v1
      // Color:       All the Same
      // Trend:       All the Same
      // IsPassed :   M5 || M15
      // Divergence : M15 || H1 || H4 || D1
 //     Print("isFiboModuleGreenState_M5 && isFiboModuleGreenState_M15 && isFiboModuleGreenState_H1 && isFiboModuleGreenState_H4 && isFiboModuleGreenState_D1",isFiboModuleGreenState_M5 && isFiboModuleGreenState_M15 && isFiboModuleGreenState_H1 && isFiboModuleGreenState_H4 && isFiboModuleGreenState_D1);
 //     Print("isTrendBull_M5 && isTrendBull_M15 && isTrendBull_H1 && isTrendBull_H4 &&  isTrendBull_D1 = ",isTrendBull_M5 && isTrendBull_M15 && isTrendBull_H1 && isTrendBull_H4 && isTrendBull_D1);
 bool isFiboModuleGreenState = isFiboModuleGreenState_M5 && isFiboModuleGreenState_M15 && isFiboModuleGreenState_H1 && isFiboModuleGreenState_H4 && isFiboModuleGreenState_D1;
 bool isTrendBull = isTrendBull_M5 && isTrendBull_M15 && isTrendBull_H1 && isTrendBull_H4 && isTrendBull_D1;
 bool isFiboModuleGreenLevel_100_IsPassed = isFiboModuleGreenLevel_100_IsPassed_M5 || isFiboModuleGreenLevel_100_IsPassed_M15;
 bool isDivergenceUp = isDivergenceUp_M15 || isDivergenceUp_H1 || isDivergenceUp_H4 || isDivergenceUp_D1;

  bool isFiboModuleRedState = isFiboModuleRedState_M5 && isFiboModuleRedState_M15 && isFiboModuleRedState_H1 && isFiboModuleRedState_H4 && isFiboModuleRedState_D1;
  bool isTrendBear = isTrendBear_M5 && isTrendBear_M15 && isTrendBear_H1 && isTrendBear_H4 && isTrendBear_D1;
  bool isFiboModuleRedLevel_100_IsPassed = isFiboModuleRedLevel_100_IsPassed_M5 || isFiboModuleRedLevel_100_IsPassed_M15;
  bool isDivergenceDown = isDivergenceDown_M15 || isDivergenceDown_H1 || isDivergenceDown_H4 || isDivergenceDown_D1;

      if
      (isFiboModuleGreenState && isTrendBull && isFiboModuleGreenLevel_100_IsPassed && isDivergenceUp)
      {buy=1;}

      if
      (isFiboModuleRedState && isTrendBear && isFiboModuleRedLevel_100_IsPassed && isDivergenceDown)
      {sell=1;}

      if(AccountFreeMargin()<(1*Lots))
        {
         //Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }

      // check for long position (BUY) possibility
      // Block 3 Открытие позиций
      // Print("isDoubleSymmetricH4BuyReady || isDoubleSymmetricH1BuyReady || isDoubleSymmetricM15BuyReady || isDoubleSymmetricM5BuyReady) ", isDoubleSymmetricH4BuyReady, isDoubleSymmetricH1BuyReady, isDoubleSymmetricM15BuyReady, isDoubleSymmetricM5BuyReady);
      if(buy==1)
        {
         double stopLossForBuyMin;
         if(firstMinGlobal>secondMinGlobal) {stopLossForBuyMin=secondMinGlobal;}
         else {stopLossForBuyMin=firstMinGlobal;}
         double currentStopLoss=Bid-StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForBuyMin<currentStopLoss) {stopLossForBuyMin=currentStopLoss;}

         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,stopLossForBuyMin,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         //Print(" Buy Position was opened on TimeFrame ","periodGlobal = ",periodGlobal);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice()," with buyWeight = ",buyWeight,"periodGlobal = ",periodGlobal);
           }
         else Print("Error opening BUY order : ",GetLastError());
         return;
        }
      // check for short position (SELL) possibility
      // Проверим что выход из ПолуВолны выше входа, так сказать критерий на трендовость

      //Print("isDoubleSymmetricH4SellReady || isDoubleSymmetricH1SellReady || isDoubleSymmetricM15SellReady || isDoubleSymmetricM5SellReady) ", isDoubleSymmetricH4SellReady ,isDoubleSymmetricH1SellReady ,isDoubleSymmetricM15SellReady ,isDoubleSymmetricM5SellReady);
      if(sell==1)
        {
         double stopLossForSellMax;
         if(firstMaxGlobal>secondMaxGlobal) {stopLossForSellMax=firstMaxGlobal;}
         else {stopLossForSellMax=secondMaxGlobal;}
         double currentStopLoss=Ask+StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForSellMax>currentStopLoss) {stopLossForSellMax=currentStopLoss;}

         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,currentStopLoss,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         //Print("Sell Position was opened on TimeFrame ","periodGlobal = ",periodGlobal);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice(),"with sellWeight = ",sellWeight);
           }
         else Print("Error opening SELL order : ",GetLastError());
        }
      return;
     }
// it is important to enter the market correctly,
// but it is more important to exit it correctly...

// Block 4 Ведение позиций
/*Вызывая метод nonSymm
   для periodGlobal мы будем update-ить цену*/

   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position
         OrderSymbol()==Symbol())  // check for symbol
        {
         if(OrderType()==OP_BUY) // long position is opened
           {
            // should it be closed?
/*if(MacdPrevious>0 && MacdCurrent<0)
                {
                 OrderClose(OrderTicket(),OrderLots(),Bid,30,Violet); // close position
                 return(0); // exit
                }*/
            // check for trailing stop

            double stopLossForBuyMin;
            if(TrailingStop>0)
              {
               lowAndHighUpdateViaNonSymmForTrailing = nonSymm();
               //Print("Блок ведения, ","firstMinGlobal = ",firstMinGlobal," secondMinGlobal = ",secondMinGlobal);
               //               //Print ("Блок ведения, ", "firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal);
               if(firstMinGlobal>secondMinGlobal) {stopLossForBuyMin=secondMinGlobal;}
               else {stopLossForBuyMin=firstMinGlobal;}
              }

            //Print("Блок ведения, "," Bid = ",Bid,"stopLossForBuyMin = ",stopLossForBuyMin," OrderStopLoss() = ",OrderStopLoss());
            //               if(Bid>Low[1] && Low[1]>OrderOpenPrice()) // посвечный обвес
            //                 { // посвечный обвес
            //                  if(Low[1]>OrderStopLoss()) // посвечный обвес
            double spread=Ask-Bid;
            double stopShift=stopLossForBuyMin-OrderStopLoss();
            if(stopShift>spread && Bid>stopLossForBuyMin && stopLossForBuyMin>OrderStopLoss())
              {
               //Print("Buy Position was stoplossed on TimeFrame ","periodGlobal = ",periodGlobal);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossForBuyMin,OrderTakeProfit(),0,Green);
               return;
              }

            //                 } // посвечный обвес
            //              } // посвечный обвес
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
            double stopLossForSellMax;
            if(TrailingStop>0)
              {
               lowAndHighUpdateViaNonSymmForTrailing = nonSymm();
               //Print("Блок ведения, ","firstMaxGlobal = ",firstMaxGlobal," secondMaxGlobal = ",secondMaxGlobal);
               if(firstMaxGlobal>secondMaxGlobal) {stopLossForSellMax=firstMaxGlobal;}
               else {stopLossForSellMax=secondMaxGlobal;}
               //               if(Ask<(High[1]+(Ask-Bid)*2) && (High[1]+(Ask-Bid)*2)<OrderOpenPrice())
               //                 {
               //                  if(((High[1]+(Ask-Bid)*2)<OrderStopLoss()) || (OrderStopLoss()==0))

               //               //Print("Блок ведения, stopLossForSellMax = ", stopLossForSellMax);
              }
            OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); // trying to fix disappearing (more precisely - OrderTakeProfit() = 0.00000 in this section)  tp for sell position and moving backward manual stopLoss
            double spread=Ask-Bid;
            double stopShift=OrderStopLoss()-stopLossForSellMax;
            if((stopShift>spread || stopShift<=0) && Ask<stopLossForSellMax && (stopLossForSellMax<OrderStopLoss() || OrderStopLoss()==0))
              {
               //Print("Sell Position was stoplossed on TimeFrame ","periodGlobal = ",periodGlobal);
               OrderModify(OrderTicket(),OrderOpenPrice(),(stopLossForSellMax+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
               return;
              }
            //                 }

           }
        }
     }
  }
// Проверка уровня MACD на две ПолуВолны, проверка симметрии, поиск максимума, и больше ли хотя бы один тик MACD 0.0001 что бы отфильтровать шум
// Метод взят с блока Н4 - потому имена переменных остануться пока такими
// isSymmetric для каждой ПВ

bool isThereTwoSymmetricFilteredHalfWaves(ENUM_TIMEFRAMES period)
  {
   int countHalfWaves=0;
   int begin=0;
   double Macd_1H4=0,Macd_2H4=0;// нулевой тик, пока 0 while работает
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double macdForFilter,priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int i,zz,z,y,x,j,k,m,p,
   resize0H4,resize1H4,resize2H4,resize3H4;
   double firstMinLocalSymmetric=0.00000000,secondMinLocalSymmetric=0.00000000,firstMaxLocalSymmetric=0.00000000,secondMaxLocalSymmetric=0.00000000;
   bool isFirstMin=false,isSecondMin=false,isFirstMax=false,isSecondMax=false;
   bool isFilterFirstHalfWaveOK=false,isFilterSecondHalfWaveOK=false,isFilterThirdHalfWaveOK=false,isFilterFourthHalfWaveOK=false;
   bool isSymmetricFirst=false,isSymmetricThird=false;
   bool resultCheck=false;
// то есть пока значения не проставлены
/*   while(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))
     {
       Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
       Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,begin) = ", Macd_1H4);
       Print("Macd_2H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,begin) = ", Macd_2H4);
       Print("(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0)) = ", (!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0)));
*/
   Macd_1H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,begin);
   Macd_2H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,begin+1);
// Block 5 Определение первой ПолуВолны в меотде bool isThereTwoSymmetricFilteredHalfWaves()
   if(Macd_2H4<0 && Macd_1H4>0)
     {what0HalfWaveMACDH4=1;} // 0 это пересечение снизу вверх
   else if(Macd_2H4>0 && Macd_1H4<0)
     {what0HalfWaveMACDH4=0;} // 1 это пересечение сверху вниз
// Проверка происходит в вызвавшем месте, отсюда мы возвращаем результаты проверки
/*}*/
//
   for(i=begin;countHalfWaves<=3;i++)
     {
      //     Print(" i = ", i, " стартовое значение должен быть 0 ");
      MacdIplus3H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i+1); //то есть это будет второй тик
      MacdIplus4H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i+2); // а это третий
                                                                        // Print("i= ",i, " countHalfWaves = ",countHalfWaves," what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4," MacdIplus3H4= ", MacdIplus3H4, " MacdIplus4H4= ", MacdIplus4H4 );

      // Print("(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) = ", (countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0));
      // И Полуволны складываем в массивы
      // First Wave
      if(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) // Проверим, для перехода снизу вверх, что второй и третий тик ниже 0, основной фильтр на шум
        {
         countHalfWaves++;
         what_1HalfWaveMACDH4=1;
         j=begin+1; // begin 0+1  j=1, а инкремент на begin идет вконце, а не вначале (стоп, обнуление и смещение?) убираем begin ++
         resize0H4=(i+2)-j; // i = begin ie 0, тоесть будет 1й элемент
                            // то есть у нас смещение не на 2, а на 1 - потому вношу ищменения
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         priceForMinMax=iOpen(NULL,period,j);
         firstMaxLocalSymmetric=priceForMinMax;
         int jStart=j;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            // Block 6 Filter
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,j);
            //            //Print(" 0 0 macdForFilter = ", macdForFilter, " filterForPlusHalfWave = ", filterForPlusHalfWave, " macdForFilter>filterForPlusHalfWave ", macdForFilter>filterForPlusHalfWave);
            if(macdForFilter>filterForPlusHalfWave) {isFilterFirstHalfWaveOK=true;}
            // Block 7 firstMinGlobal = 0.00000000, secondMinGlobal = 0.00000000, firstMaxGlobal = 0.00000000, secondMaxGlobal = 0.00000000;
            // строка priceForMinMax=iOpen(NULL,period,j); вынесена до for
            // строка firstMaxLocalSymmetric = priceForMinMax; вынесена до for
            priceForMinMax=iOpen(NULL,period,j);
            // Print("Symmetric, j, zz = ",j," ", zz, " firstMaxLocalSymmetric = ", firstMaxLocalSymmetric, " iTime(NULL,period,0) = ",iTime(NULL,period,0), " iTime(NULL,period,j) = ",iTime(NULL,period,j));
            if(priceForMinMax>firstMaxLocalSymmetric)
              {
               firstMaxLocalSymmetric=priceForMinMax;
               isFirstMax=true;
              }
            zz++;
           }

         // Block 8 Symmetric
         isSymmetricFirst=checkIfSymmetricForSell(jStart,jStart+zz+1,period);
         //         //Print("halfWave0H4 0 ", "jStart = ", jStart, " zz = ", zz , " jStart+zz+1 ", jStart+zz+1, "isSymmetricFirst = ", isSymmetricFirst);
        }
      if(countHalfWaves==0 && what0HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0) // Проверим, для перехода сверзу вниз, что второй и третий тик выше 0 , основной фильтр на шум
        {
         countHalfWaves++;
         what_1HalfWaveMACDH4=0;
         j=begin+1;
         resize0H4=(i+2)-j;
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         priceForMinMax=iOpen(NULL,period,j);
         firstMinLocalSymmetric=priceForMinMax;
         int jStart=j;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,j);
            // Print(" 0 1 macdForFilter = ", macdForFilter, " filterForMinusHalfWave = ", filterForMinusHalfWave, " macdForFilter<filterForMinusHalfWave ", macdForFilter<filterForMinusHalfWave);
            if(macdForFilter<filterForMinusHalfWave) {isFilterFirstHalfWaveOK=true;}
            priceForMinMax=iOpen(NULL,period,j);
            // Print("Symmetric, j, zz = ",j," ", zz, " firstMinLocalSymmetric = ", firstMinLocalSymmetric);
            if(priceForMinMax<firstMinLocalSymmetric)
              {
               firstMinLocalSymmetric=priceForMinMax;
               isFirstMin=true;
              }
            zz++;
           }
         isSymmetricFirst=checkIfSymmetricForBuy(jStart,jStart+zz+1,period);
         //         //Print("halfWave0H4 0 ", "jStart = ", jStart, " zz = ", zz , " jStart+zz+1 ", jStart+zz+1, "isSymmetricFirst = ", isSymmetricFirst);
        }
      // Second Wave
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_2HalfWaveMACDH4=0;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         int kStart=k;
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,k);
            if(macdForFilter<filterForMinusHalfWave) { isFilterSecondHalfWaveOK=true; }
            z++;
           }
        }
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_2HalfWaveMACDH4=1;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         int kStart=k;
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,k);
            if(macdForFilter>filterForPlusHalfWave) { isFilterSecondHalfWaveOK=true; }
            z++;
           }
        }
      // Third Wave
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_3HalfWaveMACDH4=1;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iOpen(NULL,period,m);
         secondMaxLocalSymmetric=priceForMinMax;
         int mStart=m;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,m);
            if(macdForFilter>filterForPlusHalfWave) {isFilterThirdHalfWaveOK=true;}
            priceForMinMax=iOpen(NULL,period,m);
            // Print("Symmetric, m, y = ",m," ", y, " secondMaxLocalSymmetric = ", secondMaxLocalSymmetric);
            if(priceForMinMax>secondMaxLocalSymmetric)
              {
               secondMaxLocalSymmetric=priceForMinMax;
               isSecondMax=true;
              }
            y++;
           }
         isSymmetricThird=checkIfSymmetricForSell(mStart,mStart+y+1,period);
         //          //Print("halfWave2H4 0 ", "mStart = ", mStart, "y = ", y, " mStart+y+1 =  ", mStart+y+1);
        }
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_3HalfWaveMACDH4=0;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iOpen(NULL,period,m);
         secondMinLocalSymmetric=priceForMinMax;
         int mStart=m;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,m);
            if(macdForFilter<filterForMinusHalfWave) {isFilterThirdHalfWaveOK=true;}
            priceForMinMax=iOpen(NULL,period,m);
            // Print("Symmetric, m, y = ",m," ", y, " secondMinLocalSymmetric = ", secondMinLocalSymmetric);
            if(priceForMinMax<secondMinLocalSymmetric)
              {
               secondMinLocalSymmetric=priceForMinMax;
               isSecondMin=true;
              }
            y++;
           }
         isSymmetricThird=checkIfSymmetricForBuy(mStart,mStart+y+1,period);
         //          //Print("halfWave2H4 0 ", "mStart = ", mStart, "y = ", y, " mStart+y+1 =  ", mStart+y+1);
        }
      // Fourth Wave
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_4HalfWaveMACDH4=0;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         int pStart=p;
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,p);
            if(macdForFilter<filterForMinusHalfWave){isFilterFourthHalfWaveOK=true;}
            x++;
           }
        }
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_4HalfWaveMACDH4=1;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         int pStart=p;
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,p);
            if(macdForFilter>filterForPlusHalfWave){isFilterFourthHalfWaveOK=true;}
            x++;
           }
        }
      // begin++;
     }
/*    Получаем четыре массива и проверяем что бы в каждоq ПВ по MACD был тик более 0,000100 isFilterOK
      для каждого тайм фрейма, в начале метода флаг сбрасываем в false
      */
/*
Проставляем
firstMinGlobal, secondMinGlobal, - первая ПВ, countHalfWaves 0
 firstMaxGlobal, secondMaxGlobal, - третья ПВ, countHalfWaves 2
isFirstMin, isSecondMin, isFirstMax, isSecondMax
min для buy
max для sell
приоритет от Н4 до M5
в начале метода флаг сбрасываем в false
значения в 0,00000000
*/

// Block 9 Возвращаем значение
//Print(firstMinGlobal, " = firstMinGlobal ", firstMaxGlobal, " = firstMaxGlobal ", secondMinGlobal, " = secondMinGlobal ", secondMaxGlobal," = secondMaxGlobal ");
//Print(firstMinLocalSymmetric, " = firstMinLocalSymmetric ", firstMaxLocalSymmetric, " = firstMaxLocalSymmetric ", secondMinLocalSymmetric, " = secondMinLocalSymmetric ", secondMaxLocalSymmetric," = secondMaxLocalSymmetric ");
   if(isFilterFirstHalfWaveOK && isFilterSecondHalfWaveOK && isFilterThirdHalfWaveOK && isFilterFourthHalfWaveOK)
     {
      // По сути здесь только проверка на filter, следующий if,
      // где проставляются цены будет всегда true или будет повторять вышеиспользованные флаги
      // тогда заменим isFirstMin && isSecondMin && isFirstMax && isSecondMax на Symmetric
      if(isSymmetricFirst && isSymmetricThird)
        {
         firstMinGlobal = firstMinLocalSymmetric;
         firstMaxGlobal = firstMaxLocalSymmetric;
         secondMinGlobal = secondMinLocalSymmetric;
         secondMaxGlobal = secondMaxLocalSymmetric;
         resultCheck=true;
        }
     }
//   Print("isThereTwoSymmetricFilteredHalfWaves "," period = ",period);
//   Print("isFilterFirstHalfWaveOK = ",isFilterFirstHalfWaveOK," isFilterSecondHalfWaveOK = ",isFilterSecondHalfWaveOK," isFilterThirdHalfWaveOK = ",isFilterThirdHalfWaveOK," isFilterFourthHalfWaveOK = ",isFilterFourthHalfWaveOK);
//   Print("isSymmetricFirst = ",isSymmetricFirst, " isSymmetricThird = ",isSymmetricThird);
//   Print("resultCheck = ",resultCheck);
   return resultCheck;
  }
// проставляем цены для ведения позиции
bool nonSymm()
  {
   int countHalfWaves=0;
   int begin=0;
   double Macd_1H4=0;// нулевой тик
   double Macd_2H4=0;// следующий тик
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int zz,i,z,y,x,j,k,m,p,
   resize0H4,resize1H4,resize2H4,resize3H4;
   double firstMinLocalNonSymmetric=0.00000000,secondMinLocalNonSymmetric=0.00000000,firstMaxLocalNonSymmetric=0.00000000,secondMaxLocalNonSymmetric=0.00000000;
   bool isFirstMin=false,isSecondMin=false,isFirstMax=false,isSecondMax=false;
   bool pricesUpdate=false;
   double firstMinLocalNonSymmetricMACD=0.00000000,secondMinLocalNonSymmetricMACD=0.00000000,firstMaxLocalNonSymmetricMACD=0.00000000,secondMaxLocalNonSymmetricMACD=0.00000000;
   double macdForMinMax;

   int halfWave_4H4[];
   int q,w,resize4H4;
   bool what_5HalfWaveMACDH4;
// то есть пока значения не проставлены
  bool isMACD1BiggerThanZero = Macd_1H4>0;
   bool isMACD2BiggerThanZero = Macd_2H4>0;
   bool isMACD1SmallerThanZero = Macd_1H4<0;
   bool isMACD2SmallerThanZero = Macd_2H4<0;
   bool isMACD1EqualZero = Macd_1H4==0;
   bool isMACD2EqualZero = Macd_2H4==0;
   bool isSmaller= isMACD1SmallerThanZero && isMACD2SmallerThanZero;
   bool isBigger = isMACD1BiggerThanZero && isMACD2BiggerThanZero;
   bool isEqualToZero=isMACD1EqualZero && isMACD2EqualZero;
//  Print("isSmaller = ", isSmaller,"isBigger = ", isBigger,"isEqualToZero = ", isEqualToZero);
   bool isMACDReady=isSmaller || isBigger || isEqualToZero;
   for(begin=0;isMACDReady; begin++)
     {
      // Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
      // Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,begin)");
      // Print(Macd_1H4);

      Macd_1H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,begin);
      Macd_2H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,begin+1);

      if(Macd_2H4<0 && Macd_1H4>0)
        {what0HalfWaveMACDH4=0;} // 0 это пересечение снизу вверх
      else if(Macd_2H4>0 && Macd_1H4<0)
        {what0HalfWaveMACDH4=1;} // 1 это пересечение сверху вниз
      // Проверка происходит в вызвавшем месте, отсюда мы возвращаем результаты проверки
            isMACD1BiggerThanZero = Macd_1H4>0;
            isMACD2BiggerThanZero = Macd_2H4>0;
            isMACD1SmallerThanZero = Macd_1H4<0;
            isMACD2SmallerThanZero = Macd_2H4<0;
            isMACD1EqualZero = Macd_1H4==0;
            isMACD2EqualZero = Macd_2H4==0;
            isSmaller= isMACD1SmallerThanZero && isMACD2SmallerThanZero;
            isBigger = isMACD1BiggerThanZero && isMACD2BiggerThanZero;
            isEqualToZero=isMACD1EqualZero && isMACD2EqualZero;
            isMACDReady=isSmaller || isBigger || isEqualToZero;
     }
//
   for(i=begin;countHalfWaves<=4;i++)
     {
      MacdIplus3H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,i+1); //то есть это будет два первых тика росле перехода нулевой линии
      MacdIplus4H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,i+2); // то есть один из них участвовал в предыдущем сравнении под видом begin+1
                                                                              // Print("i= ",i, " countHalfWaves = ",countHalfWaves," what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4," MacdIplus3H4= ", MacdIplus3H4, " MacdIplus4H4= ", MacdIplus4H4 );

      // Print("(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) = ", (countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0));
      // И Полуволны складываем в массивы
      // First Wave
      if(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) // Проверим, для перехода снизу вверх, что первый и второй тик ниже 0, основной фильтр на шум
        {
         //Print("C0W0");
         countHalfWaves++;
         what_1HalfWaveMACDH4=1;
         j=begin+1; // begin 0+1  j=1, а инкремент на begin идет вконце, а не вначале (стоп, обнуление и смещение?) убираем begin ++
         resize0H4=(i+2)-j; // i = begin ie 0, тоесть будет 1й элемент
                            // то есть у нас смещение не на 2, а на 1 - потому вношу ищменения
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            zz++;
           }
         // // Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWaves==0 && what0HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0) // Проверим, для перехода сверзу вниз, что второй и третий тик выше 0 , основной фильтр на шум
        {
         //Print("C0W1");
         countHalfWaves++;
         what_1HalfWaveMACDH4=0;
         j=begin+1;
         resize0H4=(i+2)-j;
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            zz++;
           }
         // // Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
      // Second Wave
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //Print("C1W1, wait for firstMinLocalNonSymmetric");
         countHalfWaves++;
         what_2HalfWaveMACDH4=0;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         priceForMinMax=iOpen(NULL,periodGlobal,k);
         firstMinLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,k);
         firstMinLocalNonSymmetricMACD=macdForMinMax;

         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            priceForMinMax=iOpen(NULL,periodGlobal,k);
            if(priceForMinMax<firstMinLocalNonSymmetric)
              {
               firstMinLocalNonSymmetric=priceForMinMax;
               isFirstMin=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,k);
            if(macdForMinMax<firstMinLocalNonSymmetricMACD)
              {
               firstMinLocalNonSymmetricMACD=macdForMinMax;
              }

            z++;
           }
         //Print("firstMinLocalNonSymmetric = ", firstMinLocalNonSymmetric);
         // // Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         //Print("C1W0, wait for firstMaxLocalNonSymmetric");
         countHalfWaves++;
         what_2HalfWaveMACDH4=1;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         priceForMinMax=iOpen(NULL,periodGlobal,k);
         firstMaxLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,k);
         firstMaxLocalNonSymmetricMACD=macdForMinMax;

         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            priceForMinMax=iOpen(NULL,periodGlobal,k);
            // Print("NonSymmetric, k, z = ",k," ", z, " firstMaxLocalNonSymmetric = ", firstMaxLocalNonSymmetric);
            if(priceForMinMax>firstMaxLocalNonSymmetric)
              {
               firstMaxLocalNonSymmetric=priceForMinMax;
               isFirstMax=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,k);
            if(macdForMinMax>firstMaxLocalNonSymmetricMACD)
              {
               firstMaxLocalNonSymmetricMACD=macdForMinMax;
              }

            z++;
           }
         //Print("firstMaxLocalNonSymmetric = ", firstMaxLocalNonSymmetric);
         // // Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      // Third Wave
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         //Print("C2W0, wait for firstMaxLocalNonSymmetric");
         countHalfWaves++;
         what_3HalfWaveMACDH4=1;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iOpen(NULL,periodGlobal,m);
         firstMaxLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,m);
         firstMaxLocalNonSymmetricMACD=macdForMinMax;

         for(m; m<i+2; m++)
           {
            priceForMinMax=iOpen(NULL,periodGlobal,m);
            halfWave_2H4[y]=m;
            if(priceForMinMax>firstMaxLocalNonSymmetric)
              {
               firstMaxLocalNonSymmetric=priceForMinMax;
               isFirstMax=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,m);
            if(macdForMinMax>firstMaxLocalNonSymmetricMACD)
              {
               firstMaxLocalNonSymmetricMACD=macdForMinMax;
              }

            y++;
           }
         //Print("firstMaxLocalNonSymmetric = ", firstMaxLocalNonSymmetric);
         // // Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m); ", (i-2)-j);
        }
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //Print("C2W1, wait for firstMinLocalNonSymmetric");
         countHalfWaves++;
         what_3HalfWaveMACDH4=0;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iOpen(NULL,periodGlobal,m);
         firstMinLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,m);
         firstMinLocalNonSymmetricMACD=macdForMinMax;

         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax=iOpen(NULL,periodGlobal,m);
            // Print("NonSymmetric, k, z = ",k," ", z, " firstMinLocalNonSymmetric = ", firstMinLocalNonSymmetric);
            if(priceForMinMax<firstMinLocalNonSymmetric)
              {
               firstMinLocalNonSymmetric=priceForMinMax;
               isFirstMin=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,m);
            if(macdForMinMax<firstMinLocalNonSymmetricMACD)
              {
               firstMinLocalNonSymmetricMACD=macdForMinMax;
              }

            y++;
           }
         //Print("firstMinLocalNonSymmetric = ", firstMinLocalNonSymmetric);
         // // Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m) ", (i-2)-m);
        }
      // Fourth Wave
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //Print("C3W1, wait for secondMinLocalNonSymmetric");
         countHalfWaves++;
         what_4HalfWaveMACDH4=0;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         priceForMinMax=iOpen(NULL,periodGlobal,p);
         secondMinLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,p);
         secondMinLocalNonSymmetricMACD=macdForMinMax;

         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            priceForMinMax = iOpen(NULL,periodGlobal,p);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
            if(priceForMinMax<secondMinLocalNonSymmetric)
              {
               secondMinLocalNonSymmetric=priceForMinMax;
               isSecondMin=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,p);
            if(macdForMinMax<secondMinLocalNonSymmetricMACD)
              {
               secondMinLocalNonSymmetricMACD=macdForMinMax;
              }

            x++;
           }
         //Print("secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         //Print("C3W0, wait for secondMaxLocalNonSymmetric");
         countHalfWaves++;
         what_4HalfWaveMACDH4=1;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         priceForMinMax=iOpen(NULL,periodGlobal,p);
         secondMaxLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,p);
         secondMaxLocalNonSymmetricMACD=macdForMinMax;

         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            priceForMinMax=iOpen(NULL,periodGlobal,p);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
            if(priceForMinMax>secondMaxLocalNonSymmetric)
              {
               secondMaxLocalNonSymmetric=priceForMinMax;
               isSecondMax=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,p);
            if(macdForMinMax<secondMaxLocalNonSymmetricMACD)
              {
               secondMaxLocalNonSymmetricMACD=macdForMinMax;
              }

            x++;
           }
         //Print("secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWaves==4 && what_4HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         //Print("C4W0, wait for secondMaxLocalNonSymmetric");
         countHalfWaves++;
         what_5HalfWaveMACDH4=1;
         q=p+1;
         resize4H4=(i+2)-q;
         ArrayResize(halfWave_4H4,resize4H4);
         w=0;
         priceForMinMax=iOpen(NULL,periodGlobal,q);
         secondMaxLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,q);
         secondMaxLocalNonSymmetricMACD=macdForMinMax;

         for(q; q<i+2; q++)
           {
            halfWave_4H4[w]=q;
            priceForMinMax = iOpen(NULL,periodGlobal,q);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
            if(priceForMinMax>secondMaxLocalNonSymmetric)
              {
               secondMaxLocalNonSymmetric=priceForMinMax;
               isSecondMax=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,q);
            if(macdForMinMax<secondMaxLocalNonSymmetricMACD)
              {
               secondMaxLocalNonSymmetricMACD=macdForMinMax;
              }

            w++;
           }
         //Print("secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
        }
      if(countHalfWaves==4 && what_4HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //Print("C4W1, wait for secondMinLocalNonSymmetric");
         countHalfWaves++;
         what_5HalfWaveMACDH4=1;
         q=p+1;
         resize4H4=(i+2)-q;
         ArrayResize(halfWave_4H4,resize4H4);
         w=0;
         priceForMinMax=iOpen(NULL,periodGlobal,q);
         secondMinLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,q);
         secondMinLocalNonSymmetricMACD=macdForMinMax;

         for(q; q<i+2; q++)
           {
            halfWave_4H4[w]=q;
            priceForMinMax = iOpen(NULL,periodGlobal,q);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
            if(priceForMinMax<secondMinLocalNonSymmetric)
              {
               secondMinLocalNonSymmetric=priceForMinMax;
               isSecondMin=true;
              }

            macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,q);
            if(macdForMinMax<secondMinLocalNonSymmetricMACD)
              {
               secondMinLocalNonSymmetricMACD=macdForMinMax;
              }

            w++;
           }
         //Print("secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
        }
      // begin++;
     }
/*    Получаем четыре массива и проверяем что бы в каждоq ПВ по MACD был тик более 0,000100 isFilterOK
      для каждого тайм фрейма, в начале метода флаг сбрасываем в false
      */
/*
Проставляем
firstMinGlobal, secondMinGlobal, - первая ПВ, countHalfWaves 0
 firstMaxGlobal, secondMaxGlobal, - третья ПВ, countHalfWaves 2
isFirstMin, isSecondMin, isFirstMax, isSecondMax
min для buy
max для sell
приоритет от Н4 до M5
в начале метода флаг сбрасываем в false
значения в 0,00000000
*/

// return section
// По сути здесь только проверка на filter, следующий if будет всегда true
//Print(" isFirstMin = ", isFirstMin, " isSecondMin = ", isSecondMin, " isFirstMax = ", isFirstMax, " isSecondMax = ", isSecondMax);

   firstMinGlobal = firstMinLocalNonSymmetric;
   firstMaxGlobal = firstMaxLocalNonSymmetric;
   secondMinGlobal = secondMinLocalNonSymmetric;
   secondMaxGlobal = secondMaxLocalNonSymmetric;
   firstMinGlobalMACD  = firstMinLocalNonSymmetricMACD;
   secondMinGlobalMACD = secondMinLocalNonSymmetricMACD;
   firstMaxGlobalMACD  = firstMaxLocalNonSymmetricMACD;
   secondMaxGlobalMACD = secondMaxLocalNonSymmetricMACD;
   pricesUpdate=true;
   Sleep(3333);
   return pricesUpdate;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkIfSymmetricForBuy(int start,int end,ENUM_TIMEFRAMES period)
  {
//  Print("checkIfSymmetricForBuy ", " start = ", start, " end = ", end, " period = ", period);
   bool isSymmetricForBuy=true;
   for(int i=start+1;i<end;i++)
     {
      double macdStart= iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i);
      double macdPrev = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i-1);
      double macdNext = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i+1);
      //      Print("checkIfSymmetricForBuy ", " (i=start+1) i = ", i, " end = ", end, " period = ", period);
      if(macdStart>macdPrev && macdStart>macdNext)
        {
         isSymmetricForBuy=false;
         break;
        }
     }
   return isSymmetricForBuy;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkIfSymmetricForSell(int start,int end,ENUM_TIMEFRAMES period)
  {
//  Print("checkIfSymmetricForSell ", " start = ", start, " end = ", end, " period = ", period);
   bool isSymmetricForSell=true;
   for(int i=start+1;i<end;i++)
     {
      double macdStart= iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i);
      double macdPrev = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i-1);
      double macdNext = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i+1);
      //    Print("checkIfSymmetricForSell ", " (i=start+1) i = ", i, " end = ", end, " period = ", period);
      if(macdStart<macdPrev && macdStart<macdNext)
        {
         isSymmetricForSell=false;
         break;
        }
     }
   return isSymmetricForSell;
  }
// the end.

bool nonSymmTick()
  {
   int countHalfWaves=0;
   int begin=0;
   double Macd_1H4=0;// нулевой тик
   double Macd_2H4=0;// следующий тик
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int zz,i,z,y,j,k,m,resize0H4,resize1H4,resize2H4;
   double firstMinLocalNonSymmetric=0.00000000,secondMinLocalNonSymmetric=0.00000000,firstMaxLocalNonSymmetric=0.00000000,secondMaxLocalNonSymmetric=0.00000000;
   int localLowTimeCurrent=0,localHighTimeCurrent=0;
   bool isFirstMin=false,isSecondMin=false,isFirstMax=false,isSecondMax=false;
   bool lowAndHighUpdate=false;

   double open_Array[];
   ArraySetAsSeries(open_Array,true);
   int open=CopyOpen(NULL,0,0,400,open_Array);

   double high_Array[];
   ArraySetAsSeries(high_Array,true);
   int high=CopyHigh(NULL,0,0,400,high_Array);

   double low_Array[];
   ArraySetAsSeries(low_Array,true);
   int low=CopyLow(NULL,0,0,400,low_Array);

   datetime time_Array[];
   ArraySetAsSeries(time_Array,true);
   int time=CopyTime(NULL,0,0,400,time_Array);

/*   for(int count = ArraySize(open_Array); count>=0; count--   ){
   Print("open_Array[count]", open_Array[count], "count", count);
   }*/ // Ok

/*   for(int count = ArraySize(open_Array); count>=0; count--   ){
   Print("Macd_1H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,count) ;",
   Macd_1H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,count)
   , "count ", count);
   }*/

   double macd_Array[399];

   double testMacd=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,1); //то есть это будет два первых тика росле перехода нулевой линии
                                                                            //   Print("nonSymm(), testMacd",testMacd);
//   Print("ArraySize(open_Array) = ",open_Array[0]);
//   Print("ArraySize(high_Array) = ",high_Array[0]);
//   Print("ArraySize(low_Array) = ",low_Array[0]);
//   Print("ArraySize(time_Array) = ",time_Array[0]);

//   Print("time_Array[0] = ",time_Array[0]);
// то есть пока значения не проставлены
// возможно для индикатора вопрос заключается в игнорировании while в коде индикатора
// При while (true) - в индикаторе выполниться while один раз
// При while (false) - в индикаторе выполниться ни разу, если переписать в for?
// for (true) - в индикаторе будет выполнятся бесконечно
//   Print("while757(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))", (!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0)));
   bool isMACD1BiggerThanZero = Macd_1H4>0;
   bool isMACD2BiggerThanZero = Macd_2H4>0;
   bool isMACD1SmallerThanZero = Macd_1H4<0;
   bool isMACD2SmallerThanZero = Macd_2H4<0;
   bool isMACD1EqualZero = Macd_1H4==0;
   bool isMACD2EqualZero = Macd_2H4==0;
   bool isSmaller= isMACD1SmallerThanZero && isMACD2SmallerThanZero;
   bool isBigger = isMACD1BiggerThanZero && isMACD2BiggerThanZero;
   bool isEqualToZero=isMACD1EqualZero && isMACD2EqualZero;
//  Print("isSmaller = ", isSmaller,"isBigger = ", isBigger,"isEqualToZero = ", isEqualToZero);
   bool isMACDReady=isSmaller || isBigger || isEqualToZero;
//   Print("isMACDReady");

//   Print("657, isMACDReady = ", isMACDReady);
   for(begin=0;isMACDReady; begin++)
     {
      //   Print("while758(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))", (!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0)));
      //      begin++;
      testMacd=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,1); //то есть это будет два первых тика росле перехода нулевой линии
                                                                        //   Print("nonSymm() while, testMacd",testMacd);
      // Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
      // Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,begin)");
      // Print(Macd_1H4);

      Macd_1H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,begin);
      Macd_2H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,begin+1);

      //      Print("begin ", begin, "Macd_1H4 = ", Macd_1H4, "Macd_2H4 = ", Macd_2H4);

      if(Macd_2H4<0 && Macd_1H4>0)
        {what0HalfWaveMACDH4=0;} // 0 это пересечение снизу вверх
      else if(Macd_2H4>0 && Macd_1H4<0)
        {what0HalfWaveMACDH4=1;} // 1 это пересечение сверху вниз
      // Проверка происходит в вызвавшем месте, отсюда мы возвращаем результаты проверки

      isMACD1BiggerThanZero = Macd_1H4>0;
      isMACD2BiggerThanZero = Macd_2H4>0;
      isMACD1SmallerThanZero = Macd_1H4<0;
      isMACD2SmallerThanZero = Macd_2H4<0;
      isMACD1EqualZero = Macd_1H4==0;
      isMACD2EqualZero = Macd_2H4==0;
      isSmaller= isMACD1SmallerThanZero && isMACD2SmallerThanZero;
      isBigger = isMACD1BiggerThanZero && isMACD2BiggerThanZero;
      isEqualToZero=isMACD1EqualZero && isMACD2EqualZero;
      isMACDReady=isSmaller || isBigger || isEqualToZero;
      //    Print("658, isMACDReady = ", isMACDReady);
     }
//
   for(i=begin;countHalfWaves<=2;i++)
     {
      MacdIplus3H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,i+1); //то есть это будет два первых тика росле перехода нулевой линии
      MacdIplus4H4=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,i+2); // то есть один из них участвовал в предыдущем сравнении под видом begin+1
                                                                              // Print("i= ",i, " countHalfWaves = ",countHalfWaves," what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4," MacdIplus3H4= ", MacdIplus3H4, " MacdIplus4H4= ", MacdIplus4H4 );

      // Print("(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) = ", (countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0));
      // И Полуволны складываем в массивы
      // First Wave
      if(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) // Проверим, для перехода снизу вверх, что первый и второй тик ниже 0, основной фильтр на шум
        {
         //   Print("C0W0");
         //   Print("begin = ",begin,"j = ",j);
         countHalfWaves++;
         what_1HalfWaveMACDH4=1;
         j=begin+1; // begin 0+1  j=1, а инкремент на begin идет вконце, а не вначале (стоп, обнуление и смещение?) убираем begin ++
         resize0H4=(i+2)-j; // i = begin ie 0, тоесть будет 1й элемент
                            // то есть у нас смещение не на 2, а на 1 - потому вношу ищменения
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            zz++;
           }
         // //// Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWaves==0 && what0HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0) // Проверим, для перехода сверзу вниз, что второй и третий тик выше 0 , основной фильтр на шум
        {
         //   Print("C0W1");
         //   Print("begin = ",begin,"j = ",j);
         countHalfWaves++;
         what_1HalfWaveMACDH4=0;
         j=begin+1;
         resize0H4=(i+2)-j;
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            zz++;
           }
         // //// Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
      // Second Wave
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //   Print("C1W1");
         countHalfWaves++;
         what_2HalfWaveMACDH4=0;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         priceForMinMax=iLow(NULL,periodGlobal,k);;
         firstMinLocalNonSymmetric=priceForMinMax;
         localLowTimeCurrent=k;
         //   Print("C1W1 Before for k = ",k);
         //   Print("C1W1 Before for localLowTimeCurrent = ",localLowTimeCurrent);
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            priceForMinMax=iLow(NULL,periodGlobal,k);;
            if(priceForMinMax<firstMinLocalNonSymmetric)
              {
               localLowTimeCurrent=k;
               firstMinLocalNonSymmetric=priceForMinMax;
               isFirstMin=true;
              }
            z++;
           }
         //   Print("C1W1 After for k = ",k);
         //   Print("C1W1 After for localLowTimeCurrent = ",localLowTimeCurrent);
         // //// Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         //   Print("C1W0");
         countHalfWaves++;
         what_2HalfWaveMACDH4=1;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         priceForMinMax=iHigh(NULL,periodGlobal,k);
         firstMaxLocalNonSymmetric=priceForMinMax;
         localLowTimeCurrent=k;
         //   Print("C1W0 Before for k = ",k);
         //   Print("C1W0 Before for localLowTimeCurrent = ",localLowTimeCurrent);
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            priceForMinMax=iHigh(NULL,periodGlobal,k);
            //// Print("NonSymmetric, k, z = ",k," ", z, " firstMaxLocalNonSymmetric = ", firstMaxLocalNonSymmetric);
            if(priceForMinMax>firstMaxLocalNonSymmetric)
              {
               localLowTimeCurrent=k;
               firstMaxLocalNonSymmetric=priceForMinMax;
               isFirstMax=true;
              }
            z++;
           }
         //   Print("C1W0 After for k = ",k);
         //   Print("C1W0 After for localLowTimeCurrent = ",localLowTimeCurrent);
         // //// Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      // Third Wave
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         //   Print("C2W0");
         countHalfWaves++;
         what_3HalfWaveMACDH4=1;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iHigh(NULL,periodGlobal,m);
         firstMaxLocalNonSymmetric=priceForMinMax;
         localHighTimeCurrent=m;
         //   Print("C2W0 Before for m = ",m);
         //   Print("C2W0 Before for localHighTimeCurrent = ",localHighTimeCurrent);
         for(m; m<i+2; m++)
           {
            priceForMinMax=iHigh(NULL,periodGlobal,m);
            halfWave_2H4[y]=m;
            if(priceForMinMax>firstMaxLocalNonSymmetric)
              {
               localHighTimeCurrent=m;
               firstMaxLocalNonSymmetric=priceForMinMax;
               isFirstMax=true;
              }
            y++;
           }
         // //// Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m); ", (i-2)-j);
        }
      //   Print("C2W0 After for m = ",m);
      //   Print("C2W0 After for localHighTimeCurrent = ",localHighTimeCurrent);
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //   Print("C2W1");
         countHalfWaves++;
         what_3HalfWaveMACDH4=0;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iLow(NULL,periodGlobal,m);
         firstMinLocalNonSymmetric=priceForMinMax;
         localHighTimeCurrent=m;
         //   Print("C2W1 Before for m = ",m);
         //   Print("C2W1 Before for localHighTimeCurrent = ",localHighTimeCurrent);
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax=iLow(NULL,periodGlobal,m);
            //// Print("NonSymmetric, k, z = ",k," ", z, " firstMinLocalNonSymmetric = ", firstMinLocalNonSymmetric);
            if(priceForMinMax<firstMinLocalNonSymmetric)
              {
               localHighTimeCurrent=m;
               firstMinLocalNonSymmetric=priceForMinMax;
               isFirstMin=true;
              }
            y++;
           }
         //   Print("C2W1 After for m = ",m);
         //   Print("C2W1 After for localHighTimeCurrent = ",localHighTimeCurrent);
         // //// Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m) ", (i-2)-m);
        }
     }

//   Print("return nonSymm localHighTimeCurrent = ",localHighTimeCurrent,"localLowTimeCurrent",localLowTimeCurrent);
   firstPointTick=localLowTimeCurrent;
   secondPointTick=localHighTimeCurrent;
//   Print("return nonSymm secondPointTick = ",secondPointTick,"firstPointTick",firstPointTick);
   lowAndHighUpdate=true;
   Sleep(3333);
   return lowAndHighUpdate;
  }
//+------------------------------------------------------------------+