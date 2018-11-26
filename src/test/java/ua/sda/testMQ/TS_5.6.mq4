//+------------------------------------------------------------------+
//|                                                       TS_5.6.mq4 |
//|                                                    Vasiliy Kulik |
//|                                                       alpari.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Kulik"
#property link      "alpari.com"
#property version   "5.6"
#property strict

extern double TakeProfit=2400;
extern double StopLoss=1600;
extern double Lots=1;
extern double TrailingStop=10000;
int iteration;
double filterForMinusHalfWave= -0.0001000;
double filterForPlusHalfWave = 0.0001000;
double firstMinGlobal=0.00000000,secondMinGlobal=0.00000000,firstMaxGlobal=0.00000000,secondMaxGlobal=0.00000000;
ENUM_TIMEFRAMES periodGlobal;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {

   int cnt,ticket,total,buy,sell;
   bool isDoubleSymmetricM5BuyReady=false, isDoubleSymmetricM15BuyReady=false,
   isDoubleSymmetricH1BuyReady=false, isDoubleSymmetricH4BuyReady=false,
   isDoubleSymmetricM5SellReady=false, isDoubleSymmetricM15SellReady=false,
   isDoubleSymmetricH1SellReady=false, isDoubleSymmetricH4SellReady=false;

   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int buyWeight,sellWeight;

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

   total=OrdersTotal();
   if(total<1)
     {
      // no opened orders identified
      // Block 1  TS 5.6 Listener
      //  for buy если M5 пересекает и MA 83 Н1
      // Event detection block for opening position
      // Здесь надо обработать additionalPeriodGlobal
      // Сначала посчитаем вес
      if(iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
         && iClose(NULL,PERIOD_D1,0)>iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         isDoubleSymmetricH4BuyReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_H4);
         if(isDoubleSymmetricH4BuyReady){Print("Сработал PERIOD_H4 Buy");}

        }
      if(iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
         && iClose(NULL,PERIOD_H4,0)>iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         isDoubleSymmetricH1BuyReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_H1);
         if(isDoubleSymmetricH1BuyReady){Print("Сработал PERIOD_H1 Buy");}
        }
      if(iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
         && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         isDoubleSymmetricM15BuyReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_M15);
         if(isDoubleSymmetricM15BuyReady){Print("Сработал PERIOD_M15 Buy");}
        }
      if(iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
         && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
         // ENUM_TIMEFRAMES p = PERIOD_M5;
         // Print (" iTime(NULL,p,0) = ",iTime(NULL,p,0), " iTime(NULL,p,3) = ",iTime(NULL,p,3));
         isDoubleSymmetricM5BuyReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_M5);
         if(isDoubleSymmetricM5BuyReady){Print("Сработал PERIOD_M5 Buy");}
        }

      if(isDoubleSymmetricH4BuyReady){buyWeight++;}
      if(isDoubleSymmetricH1BuyReady){buyWeight++;}
      if(isDoubleSymmetricM15BuyReady){buyWeight++;}
      if(isDoubleSymmetricM5BuyReady){buyWeight++;}

      //   Print( "buyWeight = ",buyWeight, " firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal, " firstMaxGlobal = ", firstMaxGlobal," secondMaxGlobal = " ,secondMaxGlobal);
      //  for sell
      if(iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
         && iClose(NULL,PERIOD_D1,0)<iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         isDoubleSymmetricH4SellReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_H4);
         if(isDoubleSymmetricH4SellReady){Print("Сработал PERIOD_H4 Sell");}
        }
      if(iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
         && iClose(NULL,PERIOD_H4,0)<iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         isDoubleSymmetricH1SellReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_H1);
         if(isDoubleSymmetricH1SellReady){Print("Сработал PERIOD_H1 Sell");}
        }
      if(iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
         && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         isDoubleSymmetricM15SellReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_M15);
         if(isDoubleSymmetricM15SellReady){ Print("Сработал PERIOD_M15 Sell");}
        }
      if(iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
         && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
        {
         // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
         isDoubleSymmetricM5SellReady=isThereTwoSymmetricFilteredHalfWaves(PERIOD_M5);
         if(isDoubleSymmetricM5SellReady){Print("Сработал PERIOD_M5 Sell");}
        }

      if(isDoubleSymmetricH4SellReady){sellWeight++;}
      if(isDoubleSymmetricH1SellReady){sellWeight++;}
      if(isDoubleSymmetricM15SellReady){sellWeight++;}
      if(isDoubleSymmetricM5SellReady){sellWeight++;}

      //   Print("sellWeight = ",sellWeight, " firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal, " firstMaxGlobal = ", firstMaxGlobal," secondMaxGlobal = " ,secondMaxGlobal);

      // Block 2 Анализируем  Weight, проставляем periodGlobal
      // а теперь укажем periodGlobal и пока повторный вызов анализатора что бы проставить firstMinGlobal, secondMinGlobal, firstMaxGlobal, secondMaxGlobal
      if(sellWeight==0 && buyWeight>=1)
         //   Print ("sellWeight==0 && buyWeight>1 ",sellWeight==0 && buyWeight>=1);
        {
         if(isDoubleSymmetricM5BuyReady)
           {
            periodGlobal=PERIOD_M1;
            Print("Analyzed and setted follow TF for Buy ","periodGlobal = ",periodGlobal);
           }
         if(isDoubleSymmetricM15BuyReady)
           {
            periodGlobal=PERIOD_M5;
            Print("Analyzed and setted follow TF for Buy ","periodGlobal = ",periodGlobal);
           }
         if(isDoubleSymmetricH1BuyReady)
           {
            periodGlobal=PERIOD_M15;
            Print("Analyzed and setted follow TF for Buy ","periodGlobal = ",periodGlobal);
           }
         if(isDoubleSymmetricH4BuyReady)
           {
            periodGlobal=PERIOD_M15;
            Print("Analyzed and setted follow TF for Buy ","periodGlobal = ",periodGlobal);
           }
         buy=1;
        }

      if(buyWeight==0 && sellWeight>=1)
        {
         if(isDoubleSymmetricM5SellReady)
           {
            periodGlobal=PERIOD_M1;
            Print("Analyzed and setted follow TF for Sell ","periodGlobal = ",periodGlobal);
           }
         if(isDoubleSymmetricM15SellReady)
           {
            periodGlobal=PERIOD_M5;
            Print("Analyzed and setted follow TF for Sell ","periodGlobal = ",periodGlobal);
           }
         if(isDoubleSymmetricH1SellReady)
           {
            periodGlobal=PERIOD_M15;
            Print("Analyzed and setted follow TF for Sell ","periodGlobal = ",periodGlobal);
           }
         if(isDoubleSymmetricH4SellReady)
           {
            periodGlobal=PERIOD_M15;
            Print("Analyzed and setted follow TF for Sell ","periodGlobal = ",periodGlobal);
           }
         sell=1;
        }

      if(AccountFreeMargin()<(1*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }

      // check for long position (BUY) possibility
      // Block 3 Открытие позиций
      // Print("isDoubleSymmetricH4BuyReady || isDoubleSymmetricH1BuyReady || isDoubleSymmetricM15BuyReady || isDoubleSymmetricM5BuyReady) ", isDoubleSymmetricH4BuyReady, isDoubleSymmetricH1BuyReady, isDoubleSymmetricM15BuyReady, isDoubleSymmetricM5BuyReady);
      if(
         buy==1 &&
         (
         isDoubleSymmetricH4BuyReady ||
         isDoubleSymmetricH1BuyReady ||
         isDoubleSymmetricM15BuyReady ||
         isDoubleSymmetricM5BuyReady)
         )
        {
         double stopLossForBuyMin;
         if(firstMinGlobal>secondMinGlobal) {stopLossForBuyMin=secondMinGlobal;}
         else {stopLossForBuyMin=firstMinGlobal;}
         double currentStopLoss=Bid-StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForBuyMin<currentStopLoss) {stopLossForBuyMin=currentStopLoss;}

         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,stopLossForBuyMin,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         Print(" Buy Position was opened on TimeFrame ","periodGlobal = ",periodGlobal);
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
      if(

         sell==1 &&
         (isDoubleSymmetricH4SellReady ||
         isDoubleSymmetricH1SellReady ||
         isDoubleSymmetricM15SellReady ||
         isDoubleSymmetricM5SellReady)
         )
        {

         double stopLossForSellMax;
         if(firstMaxGlobal>secondMaxGlobal) {stopLossForSellMax=firstMaxGlobal;}
         else {stopLossForSellMax=secondMaxGlobal;}
         double currentStopLoss=Ask+StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForSellMax>currentStopLoss) {stopLossForSellMax=currentStopLoss;}

         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,currentStopLoss,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         Print("Sell Position was opened on TimeFrame ","periodGlobal = ",periodGlobal);
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
/*Вызывая метод isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing
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
               isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing();
               Print("Блок ведения, ","firstMinGlobal = ",firstMinGlobal," secondMinGlobal = ",secondMinGlobal);
               //               Print ("Блок ведения, ", "firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal);
               if(firstMinGlobal>secondMinGlobal) {stopLossForBuyMin=secondMinGlobal;}
               else {stopLossForBuyMin=firstMinGlobal;}
              }

            Print("Блок ведения, "," Bid = ",Bid,"stopLossForBuyMin = ",stopLossForBuyMin," OrderStopLoss() = ",OrderStopLoss());
            //               if(Bid>Low[1] && Low[1]>OrderOpenPrice()) // посвечный обвес
            //                 { // посвечный обвес
            //                  if(Low[1]>OrderStopLoss()) // посвечный обвес
            if(Bid>stopLossForBuyMin && stopLossForBuyMin>OrderStopLoss())
              {
               Print("Buy Position was stoplossed on TimeFrame ","periodGlobal = ",periodGlobal);
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
               isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing();
               Print("Блок ведения, ","firstMaxGlobal = ",firstMaxGlobal," secondMaxGlobal = ",secondMaxGlobal);
               if(firstMaxGlobal>secondMaxGlobal) {stopLossForSellMax=firstMaxGlobal;}
               else {stopLossForSellMax=secondMaxGlobal;}
               //               if(Ask<(High[1]+(Ask-Bid)*2) && (High[1]+(Ask-Bid)*2)<OrderOpenPrice())
               //                 {
               //                  if(((High[1]+(Ask-Bid)*2)<OrderStopLoss()) || (OrderStopLoss()==0))

               //               Print("Блок ведения, stopLossForSellMax = ", stopLossForSellMax);
               if(Ask<stopLossForSellMax && stopLossForSellMax<OrderStopLoss())
                 {
                  Print("Sell Position was stoplossed on TimeFrame ","periodGlobal = ",periodGlobal);
                  OrderModify(OrderTicket(),OrderOpenPrice(),(stopLossForSellMax+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
                  return;
                 }
               //                 }
              }
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
            //            Print(" 0 0 macdForFilter = ", macdForFilter, " filterForPlusHalfWave = ", filterForPlusHalfWave, " macdForFilter>filterForPlusHalfWave ", macdForFilter>filterForPlusHalfWave);
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
         //         Print("halfWave0H4 0 ", "jStart = ", jStart, " zz = ", zz , " jStart+zz+1 ", jStart+zz+1, "isSymmetricFirst = ", isSymmetricFirst);
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
         //         Print("halfWave0H4 0 ", "jStart = ", jStart, " zz = ", zz , " jStart+zz+1 ", jStart+zz+1, "isSymmetricFirst = ", isSymmetricFirst);
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
         //          Print("halfWave2H4 0 ", "mStart = ", mStart, "y = ", y, " mStart+y+1 =  ", mStart+y+1);
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
         //          Print("halfWave2H4 0 ", "mStart = ", mStart, "y = ", y, " mStart+y+1 =  ", mStart+y+1);
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
bool isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing()
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

   int halfWave_4H4[];
   int q,w,resize4H4;
   bool what_5HalfWaveMACDH4;
// то есть пока значения не проставлены
   while(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))
     {
      begin++;
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
         countHalfWaves++;
         what_2HalfWaveMACDH4=0;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         priceForMinMax=iOpen(NULL,periodGlobal,k);
         firstMinLocalNonSymmetric=priceForMinMax;
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            priceForMinMax=iOpen(NULL,periodGlobal,k);
            if(priceForMinMax<firstMinLocalNonSymmetric)
              {
               firstMinLocalNonSymmetric=priceForMinMax;
               isFirstMin=true;
              }
            z++;
           }
         // // Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_2HalfWaveMACDH4=1;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         priceForMinMax=iOpen(NULL,periodGlobal,k);
         firstMaxLocalNonSymmetric=priceForMinMax;
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            priceForMinMax= iOpen(NULL,periodGlobal,k);
            // Print("NonSymmetric, k, z = ",k," ", z, " firstMaxLocalNonSymmetric = ", firstMaxLocalNonSymmetric);
            if(priceForMinMax>firstMaxLocalNonSymmetric)
              {
               firstMaxLocalNonSymmetric=priceForMinMax;
               isFirstMax=true;
              }
            z++;
           }
         // // Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
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
         priceForMinMax=iOpen(NULL,periodGlobal,m);
         firstMaxLocalNonSymmetric=priceForMinMax;

         for(m; m<i+2; m++)
           {
            priceForMinMax=iOpen(NULL,periodGlobal,m);
            halfWave_2H4[y]=m;
            if(priceForMinMax>firstMaxLocalNonSymmetric)
              {
               firstMaxLocalNonSymmetric=priceForMinMax;
               isFirstMax=true;
              }
            y++;
           }
         // // Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m); ", (i-2)-j);
        }
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_3HalfWaveMACDH4=0;
         m=k+1;
         resize2H4=(i+2)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         priceForMinMax=iOpen(NULL,periodGlobal,m);
         firstMinLocalNonSymmetric=priceForMinMax;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax= iOpen(NULL,periodGlobal,m);
            // Print("NonSymmetric, k, z = ",k," ", z, " firstMinLocalNonSymmetric = ", firstMinLocalNonSymmetric);
            if(priceForMinMax<firstMinLocalNonSymmetric)
              {
               firstMinLocalNonSymmetric=priceForMinMax;
               isFirstMin=true;
              }
            y++;
           }
         // // Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m) ", (i-2)-m);
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
         priceForMinMax=iOpen(NULL,periodGlobal,p);
         secondMinLocalNonSymmetric=priceForMinMax;
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
            x++;
           }
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_4HalfWaveMACDH4=1;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         priceForMinMax=iOpen(NULL,periodGlobal,p);
         secondMaxLocalNonSymmetric=priceForMinMax;

         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            priceForMinMax= iOpen(NULL,periodGlobal,p);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
            if(priceForMinMax > secondMaxLocalNonSymmetric)
              {
               secondMaxLocalNonSymmetric=priceForMinMax;
               isSecondMax=true;
              }
            x++;
           }
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWaves==4 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_5HalfWaveMACDH4=1;
         q=p+1;
         resize4H4=(i+2)-q;
         ArrayResize(halfWave_4H4,resize4H4);
         w=0;
         priceForMinMax=iOpen(NULL,periodGlobal,q);
         secondMaxLocalNonSymmetric=priceForMinMax;
         for(q; q<i+2; q++)
           {
            halfWave_4H4[w]=q;
            priceForMinMax = iOpen(NULL,periodGlobal,q);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
            if(priceForMinMax > secondMaxLocalNonSymmetric)
              {
               secondMaxLocalNonSymmetric=priceForMinMax;
               isSecondMax=true;
              }
            w++;
           }
        }
      if(countHalfWaves==4 && what_3HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_5HalfWaveMACDH4=1;
         q=p+1;
         resize4H4=(i+2)-q;
         ArrayResize(halfWave_4H4,resize4H4);
         w=0;
         priceForMinMax=iOpen(NULL,periodGlobal,q);
         secondMinLocalNonSymmetric=priceForMinMax;
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
            w++;
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

// return section
// По сути здесь только проверка на filter, следующий if будет всегда true
//Print(" isFirstMin = ", isFirstMin, " isSecondMin = ", isSecondMin, " isFirstMax = ", isFirstMax, " isSecondMax = ", isSecondMax);

   firstMinGlobal = firstMinLocalNonSymmetric;
   firstMaxGlobal = firstMaxLocalNonSymmetric;
   secondMinGlobal = secondMinLocalNonSymmetric;
   secondMaxGlobal = secondMaxLocalNonSymmetric;
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