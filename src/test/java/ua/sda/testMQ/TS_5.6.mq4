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
double firstMinGlobal = 0.00000000, secondMinGlobal = 0.00000000, firstMaxGlobal = 0.00000000, secondMaxGlobal = 0.00000000;
string periodGlobal,additionalPeriodGlobal;


void OnTick(void) {

   int cnt, ticket, total, buy, sell;
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

   buy=1;
   sell=1;
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
     Print("Сработал PERIOD_H4 Buy");
      isDoubleSymmetricH4BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H4");

     }
   if(iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_H4,0)>iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_H1 Buy");
      isDoubleSymmetricH1BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H1");

     }
   if(iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_M15 Buy");
      isDoubleSymmetricM15BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M15");

     }
   if(iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_M5 Buy");
      // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
      isDoubleSymmetricM5BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M5");

     }

   if(isDoubleSymmetricH4BuyReady){buyWeight++;}
   if(isDoubleSymmetricH1BuyReady){buyWeight++;}
   if(isDoubleSymmetricM15BuyReady){buyWeight++;}
   if(isDoubleSymmetricM5BuyReady){buyWeight++;}

   Print( "buyWeight = ",buyWeight, " firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal, " firstMaxGlobal = ", firstMaxGlobal," secondMaxGlobal = " ,secondMaxGlobal);
//  for sell
   if(iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_D1,0)<iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_H4 Sell");
      isDoubleSymmetricH4SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H4");

     }
   if(iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_H4,0)<iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_H1 Sell");
      isDoubleSymmetricH1SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H1");
     }
   if(iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_M15 Sell");
      isDoubleSymmetricM15SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M15");
     }
   if(iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
     Print("Сработал PERIOD_M5 Sell");
      // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
      isDoubleSymmetricM5SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M5");
     }

   if(isDoubleSymmetricH4SellReady){sellWeight++;}
   if(isDoubleSymmetricH1SellReady){sellWeight++;}
   if(isDoubleSymmetricM15SellReady){sellWeight++;}
   if(isDoubleSymmetricM5SellReady){sellWeight++;}

   Print("sellWeight = ",sellWeight, " firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal, " firstMaxGlobal = ", firstMaxGlobal," secondMaxGlobal = " ,secondMaxGlobal);

// Block 2 Анализируем  Weight, проставляем periodGlobal
// а теперь укажем periodGlobal и пока повторный вызов анализатора что бы проставить firstMinGlobal, secondMinGlobal, firstMaxGlobal, secondMaxGlobal
   if(sellWeight==0 && buyWeight>1)
   Print ("sellWeight==0 && buyWeight>1 ",sellWeight==0 && buyWeight>=1);
     {
      if(isDoubleSymmetricM5BuyReady) {periodGlobal="PERIOD_M5";}
      if(isDoubleSymmetricM15BuyReady) {periodGlobal="PERIOD_M15";}
      if(isDoubleSymmetricH1BuyReady){periodGlobal="PERIOD_H1";}
      if(isDoubleSymmetricH4BuyReady){periodGlobal="PERIOD_H4";}
     }
   if(sellWeight==buyWeight)
     {
      buy=0;
      sell=0;
     }
   if(buyWeight==0 && sellWeight>=1)
     {
      if(isDoubleSymmetricM5SellReady){periodGlobal="PERIOD_M5";}
      if(isDoubleSymmetricM15SellReady){periodGlobal="PERIOD_M15";}
      if(isDoubleSymmetricH1SellReady){periodGlobal="PERIOD_H1";}
      if(isDoubleSymmetricH4SellReady){periodGlobal="PERIOD_H1";}
     }

      if(AccountFreeMargin()<(1*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }

      // check for long position (BUY) possibility
// Block 3 Открытие позиций
Print("isDoubleSymmetricH4BuyReady || isDoubleSymmetricH1BuyReady || isDoubleSymmetricM15BuyReady || isDoubleSymmetricM5BuyReady) ", isDoubleSymmetricH4BuyReady, isDoubleSymmetricH1BuyReady, isDoubleSymmetricM15BuyReady, isDoubleSymmetricM5BuyReady);
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
         if(firstMinGlobal > secondMinGlobal) {stopLossForBuyMin = secondMinGlobal;}
         else {stopLossForBuyMin = firstMinGlobal;}
         double currentStopLoss= Bid-StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForBuyMin < currentStopLoss) {stopLossForBuyMin=currentStopLoss;}

         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,stopLossForBuyMin,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         Print("Position was opened on TimeFrame ",periodGlobal);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice(),"with buyWeight = ",buyWeight);
           }
         else Print("Error opening BUY order : ",GetLastError());
         return;
        }
      // check for short position (SELL) possibility
      // Проверим что выход из ПолуВолны выше входа, так сказать критерий на трендовость

Print("isDoubleSymmetricH4SellReady || isDoubleSymmetricH1SellReady || isDoubleSymmetricM15SellReady || isDoubleSymmetricM5SellReady) ", isDoubleSymmetricH4SellReady ,isDoubleSymmetricH1SellReady ,isDoubleSymmetricM15SellReady ,isDoubleSymmetricM5SellReady);
      if(

         sell==1 &&
         (isDoubleSymmetricH4SellReady ||
         isDoubleSymmetricH1SellReady ||
         isDoubleSymmetricM15SellReady ||
         isDoubleSymmetricM5SellReady)
         )
        {

         double stopLossForSellMax;
         if(firstMaxGlobal > secondMaxGlobal) {stopLossForSellMax = firstMaxGlobal;}
         else {stopLossForSellMax = secondMaxGlobal;}
         double currentStopLoss = Ask+StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForSellMax > currentStopLoss) {stopLossForSellMax = currentStopLoss;}

         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,currentStopLoss,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         Print("Position was opened on TimeFrame ",periodGlobal);
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
               isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing(periodGlobal);

               if(firstMinGlobal > secondMinGlobal) {stopLossForBuyMin = secondMinGlobal;}
               else {stopLossForBuyMin = firstMinGlobal;}
              }
            //               if(Bid>Low[1] && Low[1]>OrderOpenPrice()) // посвечный обвес
            //                 { // посвечный обвес
            //                  if(Low[1]>OrderStopLoss()) // посвечный обвес
            if(Bid > stopLossForBuyMin && stopLossForBuyMin > OrderStopLoss())
              {
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
            if(TrailingStop>0)
              {
               isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing(periodGlobal);
               double stopLossForSellMax;
               if(firstMaxGlobal > secondMaxGlobal) {stopLossForSellMax = firstMaxGlobal;}
               else {stopLossForSellMax = secondMaxGlobal;}
               //               if(Ask<(High[1]+(Ask-Bid)*2) && (High[1]+(Ask-Bid)*2)<OrderOpenPrice())
               //                 {
               //                  if(((High[1]+(Ask-Bid)*2)<OrderStopLoss()) || (OrderStopLoss()==0))
               if(Ask < stopLossForSellMax && stopLossForSellMax < OrderStopLoss())
                 {
                  OrderModify(OrderTicket(),OrderOpenPrice(),(High[1]+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
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

bool isThereTwoSymmetricFilteredHalfWaves(string period)
  {
   int countHalfWaves=0;
   int begin=0;
   double Macd_1H4=0, Macd_2H4=0;// нулевой тик, пока 0 while работает
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double macdForFilter,priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4,
        isFilterFirstHalfWaveOK,isFilterSecondHalfWaveOK,isFilterThirdHalfWaveOK,isFilterFourthHalfWaveOK;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int i,zz,z,y,x,j,k,m,p,
   resize0H4,resize1H4,resize2H4,resize3H4;
   isFilterFirstHalfWaveOK=false;
   isFilterSecondHalfWaveOK=false;
   isFilterThirdHalfWaveOK=false;
   isFilterFourthHalfWaveOK=false;
   double firstMinLocalSymmetric = 0.00000000, secondMinLocalSymmetric = 0.00000000, firstMaxLocalSymmetric = 0.00000000, secondMaxLocalSymmetric = 0.00000000;
   bool isFirstMin,isSecondMin,isFirstMax,isSecondMax;
   isFirstMin=false;
   isSecondMin= false;
   isFirstMax = false;
   isSecondMax= false;
   bool isSymmetricFirst=false;
   bool isSymmetricSecond= false;
   bool isSymmetricThird = false;
   bool isSymmetricFourth= false;
   bool resultCheck=false;
// то есть пока значения не проставлены
   while(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))
     {
      // Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
      // Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,begin)");
      // Print(Macd_1H4);

      Macd_1H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,begin);
      Macd_2H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,begin+1);
// Block 5 Определение первой ПолуВолны в меотде bool isThereTwoSymmetricFilteredHalfWaves()
      if(Macd_1H4>0 && Macd_2H4<0)
        {what0HalfWaveMACDH4=0;} // 0 это пересечение снизу вверх
      else if(Macd_1H4<0 && Macd_2H4>0)
        {what0HalfWaveMACDH4=1;} // 1 это пересечение сверху вниз
      // Проверка происходит в вызвавшем месте, отсюда мы возвращаем результаты проверки
     }
//
   for(i=begin;countHalfWaves<=3;i++)
     {
     Print(" i = ", i, " стартовое значение должен быть 0 ");
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
         firstMaxLocalSymmetric = priceForMinMax;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
// Block 6 Filter
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,j);
            Print(" 0 0 macdForFilter = ", macdForFilter, " filterForPlusHalfWave = ", filterForPlusHalfWave, " macdForFilter>filterForPlusHalfWave ", macdForFilter>filterForPlusHalfWave);
            if(macdForFilter > filterForPlusHalfWave) {isFilterFirstHalfWaveOK = true;}
// Block 7 firstMinGlobal = 0.00000000, secondMinGlobal = 0.00000000, firstMaxGlobal = 0.00000000, secondMaxGlobal = 0.00000000;
            // строка priceForMinMax=iOpen(NULL,period,j); вынесена до for
            // строка firstMaxLocalSymmetric = priceForMinMax; вынесена до for
            priceForMinMax=iOpen(NULL,period,j);
            if(priceForMinMax > firstMaxLocalSymmetric)
              {
               firstMaxLocalSymmetric = priceForMinMax;
               isFirstMax=true;
              }
            zz++;
           }

// Block 8 Symmetric
         isSymmetricFirst=checkIfSymmetricForBuy(j,j+zz-1,period);
          Print("halfWave0H4 0 ", "j = ", j, " zz = ", zz , " j+zz-1 = ", j+zz-1);
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
         firstMinLocalSymmetric  = priceForMinMax;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,j);
            // Print(" 0 1 macdForFilter = ", macdForFilter, " filterForMinusHalfWave = ", filterForMinusHalfWave, " macdForFilter<filterForMinusHalfWave ", macdForFilter<filterForMinusHalfWave);
            if(macdForFilter < filterForMinusHalfWave) {isFilterFirstHalfWaveOK = true;}
            priceForMinMax=iOpen(NULL,period,j);
            if(priceForMinMax < firstMinLocalSymmetric )
              {
               firstMinLocalSymmetric  =priceForMinMax;
               isFirstMin=true;
              }
            zz++;
           }
         isSymmetricFirst=checkIfSymmetricForSell(j,j+zz-1,period);
          Print("halfWave0H4 1 ", "j = ", j, "zz = ", zz, " j+zz-1 = ", j+zz-1);
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
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,k);
            if(macdForFilter<filterForMinusHalfWave) { isFilterSecondHalfWaveOK=true; }
            z++;
           }
         isSymmetricSecond=checkIfSymmetricForSell(k,k+z-1,period);
          Print("halfWave1H4 1 ", "k = ", k, "z = ", z, " k+z-1 = ", k+z-1);
        }
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_2HalfWaveMACDH4=1;
         k=j+1;
         resize1H4=(i+2)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,k);
            if(macdForFilter>filterForPlusHalfWave) { isFilterSecondHalfWaveOK=true; }
            z++;
           }
         isSymmetricSecond=checkIfSymmetricForBuy(k,k+z-1,period);
          Print("halfWave1H4 0 ", "k = ", k, "z = ", z, " k+z-1 = ", k+z-1);
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
         secondMaxLocalSymmetric = priceForMinMax;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,m);
            if(macdForFilter>filterForPlusHalfWave) {isFilterThirdHalfWaveOK=true;}
            priceForMinMax=iOpen(NULL,period,m);
            if(secondMaxLocalSymmetric >priceForMinMax)
              {
               secondMaxLocalSymmetric =priceForMinMax;
               isSecondMax=true;
              }
            y++;
           }
         isSymmetricThird=checkIfSymmetricForBuy(m,m+y-1,period);
          Print("halfWave2H4 0 ", "m = ", m, "y = ", y, " m+y-1 = ", m+y-1);
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
         secondMinLocalSymmetric  = priceForMinMax;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,m);
            if(macdForFilter<filterForMinusHalfWave) {isFilterThirdHalfWaveOK=true;}
            priceForMinMax=iOpen(NULL,period,m);
            if(priceForMinMax < secondMinLocalSymmetric)
              {
               secondMinLocalSymmetric =priceForMinMax;
               isSecondMax=true;
              }
            y++;
           }
         isSymmetricThird=checkIfSymmetricForSell(m,m+y-1,period);
          Print("halfWave2H4 1 ", "m = ", m, "y = ", y, " m+y-1 = ", m+y-1);
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
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,p);
            if(macdForFilter<filterForMinusHalfWave){isFilterFourthHalfWaveOK=true;}
            x++;
           }
         isSymmetricFourth=checkIfSymmetricForSell(p,p+x-1,period);
          Print("halfWave3H4 1 ", "p = ", p, "x = ", x, " p+x-1 = ", p+x-1);
        }
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_4HalfWaveMACDH4=1;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,p);
            if(macdForFilter>filterForPlusHalfWave){isFilterFourthHalfWaveOK=true;}
            x++;
           }
         isSymmetricFourth=checkIfSymmetricForBuy(p,p+x-1,period);
          Print("halfWave3H4 0 ", "p = ", p, "x = ", x, " p+x-1 = ", p+x-1);
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
   if(isFilterFirstHalfWaveOK && isFilterSecondHalfWaveOK && isFilterThirdHalfWaveOK && isFilterFourthHalfWaveOK)
     {
      // По сути здесь только проверка на filter, следующий if,
      // где проставляются цены будет всегда true или будет повторять вышеиспользованные флаги
      // тогда заменим isFirstMin && isSecondMin && isFirstMax && isSecondMax на Symmetric
      if(isSymmetricFirst && isSymmetricSecond && isSymmetricThird && isSymmetricFourth)
        {
         resultCheck=true;
        }
     }
   Print("isThereTwoSymmetricFilteredHalfWaves "," period = ",period);
   Print("isFilterFirstHalfWaveOK = ",isFilterFirstHalfWaveOK," isFilterSecondHalfWaveOK = ",isFilterSecondHalfWaveOK," isFilterThirdHalfWaveOK = ",isFilterThirdHalfWaveOK," isFilterFourthHalfWaveOK = ",isFilterFourthHalfWaveOK);
   Print("isSymmetricFirst = ",isSymmetricFirst," isSymmetricSecond = ",isSymmetricSecond," isSymmetricThird = ",isSymmetricThird," isSymmetricFourth = ",isSymmetricFourth);
   Print("resultCheck = ",resultCheck);
   return resultCheck;
  }
// проставляем цены для ведения позиции
bool isThereTwoNonSymmetricNonFilteredHalfWavesForTrailing(string period)
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
   double firstMinLocalNonSymmetric = 0.00000000, secondMinLocalNonSymmetric = 0.00000000, firstMaxLocalNonSymmetric = 0.00000000, secondMaxLocalNonSymmetric = 0.00000000;
   bool isFirstMin,isSecondMin,isFirstMax,isSecondMax;
   isFirstMin=false;
   isSecondMin= false;
   isFirstMax = false;
   isSecondMax= false;
   bool pricesUpdate=false;
// то есть пока значения не проставлены
   while(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))
     {
      // Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
      // Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,begin)");
      // Print(Macd_1H4);

      Macd_1H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,begin);
      Macd_2H4=iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,begin+1);

      if(Macd_1H4>0 && Macd_2H4<0)
        {what0HalfWaveMACDH4=0;} // 0 это пересечение снизу вверх
      else if(Macd_1H4<0 && Macd_2H4>0)
        {what0HalfWaveMACDH4=1;} // 1 это пересечение сверху вниз
      // Проверка происходит в вызвавшем месте, отсюда мы возвращаем результаты проверки
     }
//
   for(i=begin;countHalfWaves<=3;i++)
     {
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
         firstMaxLocalNonSymmetric = priceForMinMax;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            priceForMinMax = iOpen(NULL,period,j);
         if(priceForMinMax > firstMaxLocalNonSymmetric)
              {
               firstMaxLocalNonSymmetric = priceForMinMax;
               isFirstMax=true;
              }
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
         priceForMinMax=iOpen(NULL,period,j);
         firstMinLocalNonSymmetric  = priceForMinMax;
         for(j; j<i+2; j++)
           {
            halfWave0H4[zz]=j;
            priceForMinMax = iOpen(NULL,period,j);
            if(priceForMinMax < firstMinLocalNonSymmetric )
              {
               firstMinLocalNonSymmetric  =priceForMinMax;
               isFirstMin=true;
              }
            zz++;
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
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
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
         for(k; k<i+2; k++)
           {
            halfWave_1H4[z]=k;
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
         priceForMinMax=iOpen(NULL,period,m);
         secondMaxLocalNonSymmetric = priceForMinMax;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax = iOpen(NULL,period,m);
            if(secondMaxLocalNonSymmetric >priceForMinMax)
              {
                secondMaxLocalNonSymmetric =priceForMinMax;
                isSecondMax=true;
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
         priceForMinMax=iOpen(NULL,period,m);
         secondMinLocalNonSymmetric  = priceForMinMax;
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax = iOpen(NULL,period,m);
            if(priceForMinMax < secondMinLocalNonSymmetric)
              {
               secondMinLocalNonSymmetric =priceForMinMax;
               isSecondMax=true;
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
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
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
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            x++;
           }
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
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
   if(isFirstMin<0 && isSecondMin<0 && isFirstMax>0 && isSecondMax>0)
     {
      pricesUpdate=true;
     }

   return pricesUpdate;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkIfSymmetricForBuy(int start,int end,string period)
  {
  Print("checkIfSymmetricForBuy ", " start = ", start, " end = ", end, " period = ", period);
   bool isSymmetricForBuy=true;
   for(int i=start+1;i<end;i++)
     {
      double macdStart= iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i);
      double macdPrev = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i-1);
      double macdNext = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i+1);
      Print("checkIfSymmetricForBuy ", " (i=start+1) i = ", i, " end = ", end, " period = ", period);
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
bool checkIfSymmetricForSell(int start,int end, string period)
  {
  Print("checkIfSymmetricForSell ", " start = ", start, " end = ", end, " period = ", period);
   bool isSymmetricForSell=true;
   for(int i=start+1;i<end;i++)
     {
      double macdStart= iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i);
      double macdPrev = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i-1);
      double macdNext = iMACD(NULL,period,12,26,9,PRICE_OPEN,MODE_MAIN,i+1);
      Print("checkIfSymmetricForBuy ", " (i=start+1) i = ", i, " end = ", end, " period = ", period);
      if(macdStart<macdPrev && macdStart<macdNext)
        {
         isSymmetricForSell=false;
         break;
        }
     }
   return isSymmetricForSell;
  }
// the end.
