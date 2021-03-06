//+------------------------------------------------------------------+
//|                                                       TS_5.5.mq4 |
//|                                                    Vasiliy Kulik |
//|                                                       alpari.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Kulik"
#property link      "alpari.com"
#property version   "5.5"
#property strict

extern double TakeProfit=2400;
extern double StopLoss=1600;
extern double Lots=1;
extern double TrailingStop=10000;
int iteration;
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

*/
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
   countHalfWavesH4,
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

// Block 11 Logics End The algorithm of the trend criteria definition

   buy=1;
   sell=1;
   total=OrdersTotal();
   if(total<1)
     {
      // no opened orders identified
      if(AccountFreeMargin()<(1*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }

      // check for long position (BUY) possibility
      bool isBuy=shouldIBuy();
      bool isBuySymetric=shouldIBuySymetric();
      if(
         /*
            Цена над МА 133, 333, MACD M15 вверх, Н1 OsMA в отрицательной зоне. Покупаем. Проверка М15 на симметричностьпо цене
            */
         buy==1 &&

/*         iClose(NULL,PERIOD_M15,0)>iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_M15,0)>iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&*/


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
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError());
         return;
        }
      // check for short position (SELL) possibility
      bool isSell=shouldISell();
      bool isSellSymetric=shouldISellSymetric();
      if(

         /*
           Цена под МА 133, 333, MACD M15 вниз, Н1 OsMA в положительной зоне. Продаем. Проверка М15 на симметричность по цене.*/
         sell==1 &&

/*         iClose(NULL,PERIOD_M15,0)<iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_M15,0)<iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&*/


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
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
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
    if(osma0>0){
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
    if(osma0<0){
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
// the end.
