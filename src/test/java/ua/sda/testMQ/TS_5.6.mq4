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
double filter = 0,0001000;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
Обьекты:
Тик
ПолуВолна OsMa (у меня реализовано по простому - direction по двум тикам)
ПолуВолна MACD (у меня реализовано по простому - наличие критерия в ту или иную сторону)
Двойной критерий (у меня реализовано по простому - только сам факт наличия)
и допилен Stochastic по принципу OsMA.

Навигация по комментам Block
// Block 1 Попробуем определить пару драйвер
/* Block 2 The algorithm of the trend criteria detalization: Mеханизм распознания первой ПВ: Какие у меня критерии?
/* Block 3 Algorithm, part for H4 Half Waves*/
/* Block 8 The algorithm of the trend criteria definition:
// Block 9 Criterion Direction H4
// Block 10 Не реализован, пока не нужєн? Рисуем критерии
// Block 11 Logics End The algorithm of the trend criteria definition
// Block 12  Алгоритм закрытия Позиции:
// Block 13  TS 5.6 Listener
/* Block 14  Блок Закрытия, в закрытии проверяем, по наступлению новой ПВ уровень цен предыдущих двух ПолуВолн
и по max  уровню цены max ПВ модифицируем тейк*/


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {

   int
   cnt,
   ticket,
   total,
   buy,
   sell;

/* Variables Declaration  The algorithm of the trend criteria definition:*/

   string myPairs[]={"USDJPY","USDCAD","GBPUSD","GBPJPY","EURUSD"};
   int myPairsCount,beginPairDriver,countHalfWavesPairDriver,what_1HalfWavePirDriver,what0HalfWavePairDriver,
   resizeForPairDriver,pd,iPD,jPD,minMaxCount;
   int pairDriver[];
   int printResultDifference[5];
   string myCurrentPair;
   double Macd_1H4PairDriver,Macd_2H4PairDriver,MacdIplus3H4PairDriver,MacdIplus4H4PairDriver,
   tempMin,tempMax,resultLow,resultHigh,resultDifference;

   int
   begin,zz,
   countHalfWavesH1,
   countHalfWavesM15,
   countHalfWavesM5,
   countHalfWavesM1,
   i,z,y,x,j,k,m,p,
   resize0H4,resize1H4,resize2H4,resize3H4,
   resize0H1,resize1H1,resize2H1,resize3H1,
   resize0M15,resize1M15,resize2M15,resize3M15,
   resize0M5,resize1M5,resize2M5,resize3M5,
   resize0M1,resize1M1,resize2M1,resize3M1,
   criterionDirectionH4count,criterionDirectionH1count,criterionDirectionM15count,criterionDirectionM5count,criterionDirectionM1count;
   double
   Macd_1H4,Macd_2H4,MacdIplus3H4,MacdIplus4H4,
   Macd_1H1,Macd_2H1,MacdIplus3H1,MacdIplus4H1,
   Macd_1M15,Macd_2M15,MacdIplus3M15,MacdIplus4M15,
   Macd_1M5,Macd_2M5,MacdIplus3M5,MacdIplus4M5,
   Macd_1M1,Macd_2M1,MacdIplus3M1,MacdIplus4M1,
   Stochastic_1H1,Stochastic_0H1,Stochastic_1M15,Stochastic_0M15,
   Stochastic_1M5,Stochastic_0M5,Stochastic_1M1,Stochastic_0M1,
   OsMA0H1,OsMA_1H1,OsMA015,OsMA_1M15,OsMA05,OsMA_1M5,OsMA01,OsMA_1M1,
   Macd_0_M1,Macd_1_M1,
   temp,result1,result3;

   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int halfWave0H1[];  int halfWave_1H1[];  int halfWave_2H1[];  int halfWave_3H1[];
   int halfWave0M15[]; int halfWave_1M15[]; int halfWave_2M15[]; int halfWave_3M15[];
   int halfWave0M5[];  int halfWave_1M5[];  int halfWave_2M5[];  int halfWave_3M5[];
   int halfWave0M1[];  int halfWave_1M1[];  int halfWave_2M1[];  int halfWave_3M1[];

   bool

   what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4,
   doubleCriterionChannelH4,
   what0HalfWaveMACDH1,what_1HalfWaveMACDH1,what_2HalfWaveMACDH1,what_3HalfWaveMACDH1,what_4HalfWaveMACDH1,
   doubleCriterionTrendH1,
   what0HalfWaveMACDM15,what_1HalfWaveMACDM15,what_2HalfWaveMACDM15,what_3HalfWaveMACDM15,what_4HalfWaveMACDM15,
   doubleCriterionEntryPointM15,
   what0HalfWaveMACDM5,what_1HalfWaveMACDM5,what_2HalfWaveMACDM5,what_3HalfWaveMACDM5,what_4HalfWaveMACDM5,
   doubleCriterionTheTimeOfEntryM5,
   what0HalfWaveMACDM1,what_1HalfWaveMACDM1,what_2HalfWaveMACDM1,what_3HalfWaveMACDM1,what_4HalfWaveMACDM1,
   doubleCriterionM1,
   directionStochasticH1,directionStochasticM15,directionStochasticM5,directionStochasticM1,
   allStochastic,
   directionOsMAH1,directionOsMAM15,directionOsMAM5,directionOsMAM1,
   allOsMA,
   checkOsMA,checkStochastic,
   criterionDirectionH4,criterionDirectionH1,criterionDirectionM15,criterionDirectionM5,criterionDirectionM1,
   criterionDirectionH4Check,criterionDirectionH1Check,criterionDirectionM15Check,criterionDirectionM5Check,criterionDirectionM1Check;

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

bool isDoubleSymmetricM5BuyReady=false;
bool isDoubleSymmetricM15BuyReady=false;
bool isDoubleSymmetricH1BuyReady=false;
bool isDoubleSymmetricH4BuyReady=false;
bool isDoubleSymmetricM5SellReady=false;
bool isDoubleSymmetricM15SellReady=false;
bool isDoubleSymmetricH1SellReady=false;
bool isDoubleSymmetricH4SellReady=false;
string period;
double firstMin, secondMin, firstMax, secondMax;
bool isFirstMin, isSecondMin, isFirstMax, isSecondMax;
int countHalfWaves;



// Block 11 Logics End The algorithm of the trend criteria definition
   buy=1;
   sell=1;
   total=OrdersTotal();
   if(total<1)
   // Block 13  TS 5.6 Listener
   //  for buy если M5 пересекает и MA 83 Н1
   // Event detection block for opening position
   if (iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
       && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0)){
       // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
            isDoubleSymmetricM5BuyReady  = isThereTwoSymmetricFilteredHalfWavesMinBuy("PERIOD_M5");
            period = "PERIOD_M5";
       }
       if (iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
       && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0)){
           isDoubleSymmetricM15BuyReady  = isThereTwoSymmetricFilteredHalfWavesMinBuy("PERIOD_M15");
           period = "PERIOD_M15";
       }
       if (iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
       && iClose(NULL,PERIOD_H4,0)>iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0)){
           isDoubleSymmetricH1BuyReady  = isThereTwoSymmetricFilteredHalfWavesMinBuy("PERIOD_H1");
           period = "PERIOD_H1";
       }
       if (iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
       && iClose(NULL,PERIOD_D1,0)>iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0)){
           isDoubleSymmetricH4BuyReady  = isThereTwoSymmetricFilteredHalfWavesMinBuy("PERIOD_H4");
           period = "PERIOD_H4";
       }
       //  for sell
       if (iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
       && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0)){
       // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
           isDoubleSymmetricM5SellReady  = isThereTwoSymmetricFilteredHalfWavesMaxSell("PERIOD_M5");
           period = "PERIOD_M5";
       }
       if (iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
       && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0)){
           isDoubleSymmetricM15SellReady  = isThereTwoSymmetricFilteredHalfWavesMaxSell("PERIOD_M15");
           period = "PERIOD_M15";
       }
       if (iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
       && iClose(NULL,PERIOD_H4,0)<iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0)){
           isDoubleSymmetricH1SellReady  = isThereTwoSymmetricFilteredHalfWavesMaxSell("PERIOD_H1");
           period = "PERIOD_H1";
       }
       if (iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
       && iClose(NULL,PERIOD_D1,0)<iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0)){
           isDoubleSymmetricH4SellReady  = isThereTwoSymmetricFilteredHalfWavesMaxSell("PERIOD_H4");
           period = "PERIOD_H4";
       }
     {
      // no opened orders identified
      if(AccountFreeMargin()<(1*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }

      // check for long position (BUY) possibility
      // Проверим что выход из ПолуВолны выше входа, так сказать критерий на трендовость
      bool isBuy=shouldIBuy();
      // что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних
      bool isBuySymetric=shouldIBuySymetric();
      if(
        //iClose(NULL,PERIOD_M15,0)<iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0)
         buy==1 &&
         // Критерий Замаха OsMA на Н1
         iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0)<0 &&
         // Критерий ПВ М15
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 &&
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0 &&

         // цена выхода из ПолуВолны выше цены входа для М15
         isBuy==true &&
         // при покупке OsMA М15 был выше 0
         iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0)>0 &&
         // что бы ни один тик предыдущей его отрицательной волны, не был больше чем два соседних
         isBuySymetric==true
         // Criterion for buy position according to the TS
         // doubleCriterionTrendH1 == 0 && doubleCriterionEntryPointM15 == 0 && doubleCriterionTheTimeOfEntryM5 == 0 && criterionDirectionH1==1 && criterionDirectionH1Check==1&&   /*doubleCriterionM1==0 && allOsMA==0 && allStochastic == 0 && checkOsMA ==1 && checkStochastic == 1 &&*/ 0>Macd_1_M1 && Macd_0_M1>0
         )
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-StopLoss*Point,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         Print("Position was opened on TimeFrame ", period);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError());
         return;
        }
      // check for short position (SELL) possibility
      // Проверим что выход из ПолуВолны выше входа, так сказать критерий на трендовость
      bool isSell=shouldISell();
      // что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних

      bool isSellSymetric=shouldISellSymetric();
      if(

         sell==1 &&
         // Критерий Замаха OsMA на Н1
         iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0)>0 &&
         // Критерий ПВ М15
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 &&
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0 &&

         // цена выхода из ПолуВолны выше цены входа для М15
         isSell==true &&
         // при продаже OsMA М15 был ниже 0
         iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0)<0 &&
         // что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних
         isSellSymetric==true
         // Criterion for sell position according to the TS
         // doubleCriterionTrendH1 == 1 && doubleCriterionEntryPointM15 == 1 && doubleCriterionTheTimeOfEntryM5 == 1 && criterionDirectionH1==1 && criterionDirectionH1Check==1&&  /*doubleCriterionM1==1 && allOsMA==1 && allStochastic == 1 && checkOsMA ==1 && checkStochastic == 1 &&*/ 0<Macd_1_M1 && Macd_0_M1<0
         )
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+StopLoss*Point,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         Print("Position was opened on TimeFrame ", period);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError());
        }
      return;
     }
// it is important to enter the market correctly,
// but it is more important to exit it correctly...

/* Block 12  Алгоритм закрытия Позиции:
   критерий закрытия (предварительно двойной M15)

   Алгоритм ведения Позиции:
   критерий БезУбытка (взять из Безубытка - реализован в Трейлинг условии реализацией "Посвечный Безубыток")
   критерий ведения (двойной M5)*/

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
            if(TrailingStop>0)
              {
               if(Bid>Low[1] && Low[1]>OrderOpenPrice())
                 {
                  if(Low[1]>OrderStopLoss())
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Low[1],OrderTakeProfit(),0,Green);
                     return;
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
            if(TrailingStop>0)
              {
               if(Ask<(High[1]+(Ask-Bid)*2) && (High[1]+(Ask-Bid)*2)<OrderOpenPrice())
                 {
                  if(((High[1]+(Ask-Bid)*2)<OrderStopLoss()) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),(High[1]+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
                     return;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Проверим что выход из ПолуВолны выше входа, так сказать критерий на трендовость
bool shouldIBuy(void)
  {
   bool isBuy=false;
   double macd0 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0);
   double macd1 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1);

   if(macd0>0 && macd1<0)
     {
      //      Print("macd0>0 && macd1<0 : in Buy Section",macd0>0 && macd1<0);
      double iCloseFinish= iClose(NULL,PERIOD_M15,0);
      double iCloseStart = 0;
      int i=1;
      int k=0;

      for(int i=1;k==0;i++)
        {
         //       Print("i= ",i," in Buy Section");
         double macdStart=iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,i);
         if(macdStart>0)
           {
            iCloseStart=iClose(NULL,PERIOD_M15,i);
            k=1;
            //      Print("Find Start : in Buy Section, iCloseStart<iCloseFinish ",iCloseStart<iCloseFinish, "iCloseStart = ", iCloseStart, "iCloseFinish = ", iCloseFinish);
           }
        }
      //      Print("in Buy Section", "iCloseStart = ", iCloseStart, "iCloseStart!=0 ", iCloseStart!=0);
      if(iCloseStart!=0)
        {
         //         Print("in Buy Section", "iCloseStart = ", iCloseStart, "iCloseFinish = ", iCloseFinish, "iCloseStart>iCloseFinish ",iCloseStart>iCloseFinish );
         if(iCloseStart<iCloseFinish)
           {
            isBuy=true;
           }
        }
     }
//     Print("return isBuy = ", isBuy);
   return isBuy;
  }
//+------------------------------------------------------------------+
// Проверим что выход из ПолуВолны выше входа, так сказать критерий на трендовость
bool  shouldISell(void)
  {
   bool isSell=false;
   double macd0 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0);
   double macd1 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1);
   if(macd0<0 && macd1>0)
     {
      //      Print("macd0>0 && macd1<0 : in Sell Section",macd0<0 && macd1>0);
      double iCloseFinish= iClose(NULL,PERIOD_M15,0);
      double iCloseStart = 0;
      int i=1;
      int k=0;
      for(int i=1;k==0;i++)
        {
         //         Print("i= ",i," in Sell Section");
         double macdStart=iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,i);
         if(macdStart<0)
           {
            iCloseStart=iClose(NULL,PERIOD_M15,i);
            k=1;
            //       Print("Find Start : in Sell Section, iCloseStart>iCloseFinish ",iCloseStart>iCloseFinish, "iCloseStart = ", iCloseStart, "iCloseFinish = ", iCloseFinish);
           }
        }
      //      Print("in Sell Section", "iCloseStart = ", iCloseStart, "iCloseStart!=0 ", iCloseStart!=0);
      if(iCloseStart!=0)
        {
         //         Print("in Sell Section", "iCloseStart = ", iCloseStart, "iCloseFinish = ", iCloseFinish, "iCloseStart>iCloseFinish ",iCloseStart>iCloseFinish );
         if(iCloseStart>iCloseFinish)
           {
            isSell=true;
           }
        }
     }
//   Print("return isSell = ", isSell);
   return isSell;

  }


  // что бы ни один тик предыдущей его отрицательной волны, не был больше чем два соседних
  bool shouldIBuySymetric(void){
    bool isBuySymmetric=false;
    double osma0 = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0);
    double osma1= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,1);
     // Проверим завершилась ли волна OsMA
    if(osma0>0){
        // firstTransition - start, firstTransition to secondTransition - first HalfWawe, thirdTransition to fourthTransition - secondHalfWave
        bool firstTransition=false;
        bool secondTransition=false;
            // идем назад, пока не пересечем нулевую линию, проверяем что бы ни один тик предыдущей его отрицательной волны,
            // не был больше чем два соседних, и останавливаемся когда полуволна опять выходит в положительную зону
            for(int i=0;secondTransition == false;i++){
                double osmaStart = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i);
                double osmaPrev = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i-1);
                double osmaNext = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i+1);
                // Перешли к отрицательной Полуволне
                if (osmaStart < 0){
                    firstTransition = true;
                    if(firstTransition==true && secondTransition==false){
                        if(osmaStart>osmaPrev && osmaStart>osmaNext){
                            isBuySymmetric=false;
                            break;
                        }
                    }

                }
                //значит перешли ко второй полуволне которая положительная
                if(firstTransition==true && osmaStart>0){
                    secondTransition=true;
                    isBuySymmetric=true;
                    break;
                }
            }
    }
    return isBuySymmetric;
  }
// что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних
 bool shouldISellSymetric(void){
 bool isSellSymmetric=false;
    double osma0 = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0);
    double osma1= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,1);
     // Проверим завершилась ли волна OsMA
    if(osma0<0){
        // firstTransition - start, firstTransition to secondTransition - first HalfWawe, thirdTransition to fourthTransition - secondHalfWave
        bool firstTransition=false;
        bool secondTransition=false;
            // идем назад, пока не пересечем нулевую линию, проверяем что бы ни один тик предыдущей его положительной волны,
            // не был меньше чем два соседних, и останавливаемся когда полуволна опять выходит в отрицательную зону
            for(int i=0;secondTransition == false;i++){
                double osmaStart = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i);
                double osmaPrev = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i-1);
                double osmaNext = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i+1);
                // Перешли к отрицательной Полуволне
                if (osmaStart > 0){
                    firstTransition = true;
                    if(firstTransition==true && secondTransition==false){
                        if(osmaStart<osmaPrev && osmaStart<osmaNext){
                            isSellSymmetric=false;
                            break;
                        }
                    }

                }
                //значит перешли ко второй полуволне которая положительная
                if(firstTransition==true && osmaStart<0){
                    secondTransition=true;
                    isSellSymmetric=true;
                    break;
                }
            }
    }
    return isSellSymmetric;

  }
// Проверка уровня MACD на две ПолуВолны, проверка симметрии, поиск максимума, и больше ли хотя бы один тик MACD 0.0001 что бы отфильтровать шум
// Метод взят с блока Н4 - потому имена переменных остануться пока такими

bool isThereTwoSymmetricFilteredHalfWavesMinBuy(string period){
   countHalfWaves=0;
   begin=0;
   Macd_1H4=0;// нулевой тик
   Macd_2H4=0;// следующий тик
   bool resultCheck;
   while(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))
     {
      // Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
      // Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,begin)");
      // Print(Macd_1H4);

      Macd_1H4=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,begin);
      Macd_2H4=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1);

      if(Macd_1H4>0 && Macd_2H4<0)
        {what0HalfWaveMACDH4=0;} // 0 это пересечение снизу вверх
      else if(Macd_1H4<0 && Macd_2H4>0)
        {what0HalfWaveMACDH4=1;} // 1 это пересечение сверху вниз
        // Проверка происходит в вызвавшем месте, отсюда мы возвращаем результаты проверки
     }
//
   for(i=begin;countHalfWaves<=3;i++)
     {
      MacdIplus3H4=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1); //то есть это будет второй тик
      MacdIplus4H4=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2); // а это третий
      // Print("i= ",i, " countHalfWaves = ",countHalfWaves," what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4," MacdIplus3H4= ", MacdIplus3H4, " MacdIplus4H4= ", MacdIplus4H4 );

      // Print("(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) = ", (countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0));
      // First Wave
      if(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) // Проверим, для перехода снизу вверх, что второй и третий тик ниже 0, основной фильтр на шум
        {
         countHalfWaves++;
         what_1HalfWaveMACDH4=1;
         j=begin+1; // 0+1
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
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
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
         for(m; m<i+2; m++)
           {
            halfWave_2H4[y]=m;
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
     begin++;
     }
     // return sectiom
     return resultCheck;
}

bool isThereTwoSymmetricFilteredHalfWavesMaxSell(string period){
}
// the end.

