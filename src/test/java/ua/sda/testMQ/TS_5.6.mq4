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
double filterForSell= 0.0001000;
double filterForBuy = -0.0001000;
double firstMin,secondMin,firstMax,secondMax;
string periodGlobal,additionalPeriodGlobal;
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

   int halfWave0H1[];  int halfWave_1H1[];  int halfWave_2H1[];  int halfWave_3H1[];
   int halfWave0M15[]; int halfWave_1M15[]; int halfWave_2M15[]; int halfWave_3M15[];
   int halfWave0M5[];  int halfWave_1M5[];  int halfWave_2M5[];  int halfWave_3M5[];
   int halfWave0M1[];  int halfWave_1M1[];  int halfWave_2M1[];  int halfWave_3M1[];

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



   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];

   int buyWeight,sellWeight;

// Block 11 Logics End The algorithm of the trend criteria definition
   buy=1;
   sell=1;
   buyWeight=0;
   sellWeight=0;
   total=OrdersTotal();
   if(total<1)
      Sleep(8888);
// Block 13  TS 5.6 Listener
//  for buy если M5 пересекает и MA 83 Н1
// Event detection block for opening position
// Здесь надо обработать additionalPeriodGlobal
// Сначала посчитаем вес
   if(iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_D1,0)>iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      isDoubleSymmetricH4BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H4");
     }
   if(iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_H4,0)>iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      isDoubleSymmetricH1BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H1");
     }
   if(iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      isDoubleSymmetricM15BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M15");
     }
   if(iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0
      && iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
      isDoubleSymmetricM5BuyReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M5");
     }

   if(isDoubleSymmetricH4BuyReady){buyWeight++;}
   if(isDoubleSymmetricH1BuyReady){buyWeight++;}
   if(isDoubleSymmetricM15BuyReady){buyWeight++;}
   if(isDoubleSymmetricM5BuyReady){buyWeight++;}

//  for sell
   if(iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_D1,0)<iMA(NULL,PERIOD_D1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      isDoubleSymmetricH4SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H4");
     }
   if(iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_H4,0)<iMA(NULL,PERIOD_H4,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      isDoubleSymmetricH1SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_H1");
     }
   if(iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      isDoubleSymmetricM15SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M15");
     }
   if(iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 && iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0
      && iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_H1,83,0,MODE_SMA,PRICE_OPEN,0))
     {
      // проверяем симметричность двух предыдущих; doubleSymmetricM5Buy, передавая параметром период в метод
      isDoubleSymmetricM5SellReady=isThereTwoSymmetricFilteredHalfWaves("PERIOD_M5");
     }

   if(isDoubleSymmetricH4SellReady){sellWeight++;}
   if(isDoubleSymmetricH1SellReady){sellWeight++;}
   if(isDoubleSymmetricM15SellReady){sellWeight++;}
   if(isDoubleSymmetricM5SellReady){sellWeight++;}

   Print("sellWeight = ",sellWeight," " "buyWeight = ",buyWeight);

// а теперь укажем periodGlobal и пока повторный вызов анализатора что бы проставить firstMin, secondMin, firstMax, secondMax
   if(sellWeight==0 && buyWeight>1)
     {
      if(isDoubleSymmetricM5BuyReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_M5");
         periodGlobal="PERIOD_M5";
        }
      if(isDoubleSymmetricM15BuyReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_M15");
         periodGlobal="PERIOD_M15";
        }
      if(isDoubleSymmetricH1BuyReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_H1");
         periodGlobal="PERIOD_H1";
        }
      if(isDoubleSymmetricH4BuyReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_H4");
         periodGlobal="PERIOD_H1";
        }
     }
   if(sellWeight==buyWeight)
     {
      buy=0;
      sell=0;
     }
   if(buyWeight==0 && sellWeight>1)
     {
      if(isDoubleSymmetricM5SellReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_M5");
         periodGlobal="PERIOD_M5";
        }
      if(isDoubleSymmetricM15SellReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_M15");
         periodGlobal="PERIOD_M15";
        }
      if(isDoubleSymmetricH1SellReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_H1");
         periodGlobal="PERIOD_H1";
        }
      if(isDoubleSymmetricH4SellReady)
        {
         isThereTwoSymmetricFilteredHalfWaves("PERIOD_H4");
         periodGlobal="PERIOD_H1";
        }
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
      //bool isBuy=shouldIBuy();
      // что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних
      //bool isBuySymetric=shouldIBuySymetric();
      if(
         //iClose(NULL,PERIOD_M15,0)<iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0)
         buy==1 &&
         (isDoubleSymmetricH4BuyReady ||
         isDoubleSymmetricH1BuyReady ||
         isDoubleSymmetricM15BuyReady ||
         isDoubleSymmetricM5BuyReady)

         // Критерий Замаха OsMA на Н1
         //iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0)<0 &&
         // Критерий ПВ М15
         //iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 &&
         //iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0 &&

         // цена выхода из ПолуВолны выше цены входа для М15
         //isBuy==true &&
         // при покупке OsMA М15 был выше 0
         //iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0)>0 &&
         // что бы ни один тик предыдущей его отрицательной волны, не был больше чем два соседних
         //isBuySymetric==true
         // Criterion for buy position according to the TS
         // doubleCriterionTrendH1 == 0 && doubleCriterionEntryPointM15 == 0 && doubleCriterionTheTimeOfEntryM5 == 0 && criterionDirectionH1==1 && criterionDirectionH1Check==1&&   /*doubleCriterionM1==0 && allOsMA==0 && allStochastic == 0 && checkOsMA ==1 && checkStochastic == 1 &&*/ 0>Macd_1_M1 && Macd_0_M1>0
         )
        {
         double stopLossForBuyMin;
         if(firstMin>secondMin){stopLossForBuyMin=secondMin;}
         else{stopLossForBuyMin=firstMin;}
         double currentStopLoss= Bid-StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForBuyMin<currentStopLoss){stopLossForBuyMin=currentStopLoss;}

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
      bool isSell=shouldISell();
      // что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних

      bool isSellSymetric=shouldISellSymetric();
      if(

         sell==1 &&
         (isDoubleSymmetricH4SellReady ||
         isDoubleSymmetricH1SellReady ||
         isDoubleSymmetricM15SellReady ||
         isDoubleSymmetricM5SellReady)

         // Критерий Замаха OsMA на Н1
         //iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0)>0 &&
         // Критерий ПВ М15
         //iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 &&
         //iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0 &&

         // цена выхода из ПолуВолны выше цены входа для М15
         //isSell==true &&
         // при продаже OsMA М15 был ниже 0
         //iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0)<0 &&
         // что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних
         //isSellSymetric==true
         // Criterion for sell position according to the TS
         // doubleCriterionTrendH1 == 1 && doubleCriterionEntryPointM15 == 1 && doubleCriterionTheTimeOfEntryM5 == 1 && criterionDirectionH1==1 && criterionDirectionH1Check==1&&  /*doubleCriterionM1==1 && allOsMA==1 && allStochastic == 1 && checkOsMA ==1 && checkStochastic == 1 &&*/ 0<Macd_1_M1 && Macd_0_M1<0
         )
        {

         double stopLossForSellMax;
         if(firstMax>secondMax){stopLossForSellMax=firstMax;}
         else{stopLossForSellMax=secondMax;}
         double currentStopLoss = Ask+StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForSellMax>currentStopLoss){stopLossForSellMax=currentStopLoss;}

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

/* Block 12  Алгоритм закрытия Позиции:
   критерий закрытия (предварительно двойной M15)

   Алгоритм ведения Позиции:
   критерий БезУбытка (взять из Безубытка - реализован в Трейлинг условии реализацией "Посвечный Безубыток")
   критерий ведения (двойной M5)*/
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

               if(firstMin>secondMin){stopLossForBuyMin=secondMin;}
               else{stopLossForBuyMin=firstMin;}
              }
            //               if(Bid>Low[1] && Low[1]>OrderOpenPrice()) // посвечный обвес
            //                 { // посвечный обвес
            //                  if(Low[1]>OrderStopLoss()) // посвечный обвес
            if(Bid>stopLossForBuyMin && stopLossForBuyMin>OrderStopLoss())
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
               if(firstMax>secondMax){stopLossForSellMax=firstMax;}
               else{stopLossForSellMax=secondMax;}
               //               if(Ask<(High[1]+(Ask-Bid)*2) && (High[1]+(Ask-Bid)*2)<OrderOpenPrice())
               //                 {
               //                  if(((High[1]+(Ask-Bid)*2)<OrderStopLoss()) || (OrderStopLoss()==0))
               if(Ask<stopLossForSellMax && stopLossForSellMax<OrderStopLoss())
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

      for(i=1;k==0;i++)
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
      for(i=1;k==0;i++)
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
bool shouldIBuySymetric(void)
  {
   bool isBuySymmetric=false;
   double osma0= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0);
   double osma1= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,1);
// Проверим завершилась ли волна OsMA
   if(osma0>0)
     {
      // firstTransition - start, firstTransition to secondTransition - first HalfWawe, thirdTransition to fourthTransition - secondHalfWave
      bool firstTransition=false;
      bool secondTransition=false;
      // идем назад, пока не пересечем нулевую линию, проверяем что бы ни один тик предыдущей его отрицательной волны,
      // не был больше чем два соседних, и останавливаемся когда полуволна опять выходит в положительную зону
      for(int i=0;secondTransition==false;i++)
        {
         double osmaStart= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i);
         double osmaPrev = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i-1);
         double osmaNext = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i+1);
         // Перешли к отрицательной Полуволне
         if(osmaStart<0)
           {
            firstTransition=true;
            if(firstTransition==true && secondTransition==false)
              {
               if(osmaStart>osmaPrev && osmaStart>osmaNext)
                 {
                  isBuySymmetric=false;
                  break;
                 }
              }

           }
         //значит перешли ко второй полуволне которая положительная
         if(firstTransition==true && osmaStart>0)
           {
            secondTransition=true;
            isBuySymmetric=true;
            break;
           }
        }
     }
   return isBuySymmetric;
  }
// что бы ни один тик предыдущей его положительной волны, не был меньше чем два соседних
bool shouldISellSymetric(void)
  {
   bool isSellSymmetric=false;
   double osma0= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0);
   double osma1= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,1);
// Проверим завершилась ли волна OsMA
   if(osma0<0)
     {
      // firstTransition - start, firstTransition to secondTransition - first HalfWawe, thirdTransition to fourthTransition - secondHalfWave
      bool firstTransition=false;
      bool secondTransition=false;
      // идем назад, пока не пересечем нулевую линию, проверяем что бы ни один тик предыдущей его положительной волны,
      // не был меньше чем два соседних, и останавливаемся когда полуволна опять выходит в отрицательную зону
      for(int i=0;secondTransition==false;i++)
        {
         double osmaStart= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i);
         double osmaPrev = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i-1);
         double osmaNext = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i+1);
         // Перешли к отрицательной Полуволне
         if(osmaStart>0)
           {
            firstTransition=true;
            if(firstTransition==true && secondTransition==false)
              {
               if(osmaStart<osmaPrev && osmaStart<osmaNext)
                 {
                  isSellSymmetric=false;
                  break;
                 }
              }

           }
         //значит перешли ко второй полуволне которая положительная
         if(firstTransition==true && osmaStart<0)
           {
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
// isSymmetric для каждой ПВ

bool isThereTwoSymmetricFilteredHalfWaves(string period)
  {
   int countHalfWaves=0;
   int begin=0;
   int zz;
   double Macd_1H4=0;// нулевой тик, пока 0 while работает
   double Macd_2H4=0;
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double macdForFilter,priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4;
   bool isFilterFirstHalfWaveOK,isFilterSecondHalfWaveOK,isFilterThirdHalfWaveOK,isFilterFourthHalfWaveOK;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int i,z,y,x,j,k,m,p,
   resize0H4,resize1H4,resize2H4,resize3H4;
   isFilterFirstHalfWaveOK=false;
   isFilterSecondHalfWaveOK=false;
   isFilterThirdHalfWaveOK=false;
   isFilterFourthHalfWaveOK=false;
   firstMin=0.00000000;
   secondMin= 0.00000000;
   firstMax = 0.00000000;
   secondMax= 0.00000000;
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
      // И Полуволны складываем в массивы
      // First Wave
      if(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) // Проверим, для перехода снизу вверх, что второй и третий тик ниже 0, основной фильтр на шум
        {
         countHalfWaves++;
         what_1HalfWaveMACDH4=1;
         j=begin+1; // begin 0+1  j=1, а инкремент на begin идет вконце, а не вначале (стоп, обнуление и смещение?) убираем begin ++
         resize0H4=(i+1)-j; // i = begin ie 0, тоесть будет 1й элемент
                            // то есть у нас смещение не на 2, а на 1 - потому вношу ищменения
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+1; j++)
           {
            halfWave0H4[zz]=j;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,j);
            if(isFilterFirstHalfWaveOK==false && macdForFilter<filterForBuy)
              {
               isFilterFirstHalfWaveOK=true;
              }
            priceForMinMax=iOpen(NULL,period,j);
            if(firstMin>priceForMinMax)
              {
               firstMin=priceForMinMax;
               isFirstMin=true;
              }
            zz++;
           }
         isSymmetricFirst=checkIfSymmetricForBuy(j,j+zz-1);
         // // Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWaves==0 && what0HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0) // Проверим, для перехода сверзу вниз, что второй и третий тик выше 0 , основной фильтр на шум
        {
         countHalfWaves++;
         what_1HalfWaveMACDH4=0;
         j=begin+1;
         resize0H4=(i+1)-j;
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+1; j++)
           {
            halfWave0H4[zz]=j;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,j);
            if(isFilterFirstHalfWaveOK==false && macdForFilter>filterForSell)
              {
               isFilterFirstHalfWaveOK=true;
              }
            priceForMinMax=iOpen(NULL,period,j);
            if(firstMax<priceForMinMax)
              {
               firstMax=priceForMinMax;
               isFirstMax=true;
              }
            zz++;
           }
         isSymmetricFirst=checkIfSymmetricForSell(j,j+zz-1);
         // // Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
      // Second Wave
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_2HalfWaveMACDH4=0;
         k=j+1;
         resize1H4=(i+1)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         for(k; k<i+1; k++)
           {
            halfWave_1H4[z]=k;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,k);
            if(isFilterSecondHalfWaveOK==false && macdForFilter>filterForSell)
              {
               isFilterSecondHalfWaveOK=true;
              }
            z++;
           }
         isSymmetricSecond=checkIfSymmetricForSell(k,k+z-1);
         // // Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWaves==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_2HalfWaveMACDH4=1;
         k=j+1;
         resize1H4=(i+1)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         for(k; k<i+1; k++)
           {
            halfWave_1H4[z]=k;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,k);
            if(isFilterSecondHalfWaveOK==false && macdForFilter<filterForBuy)
              {
               isFilterSecondHalfWaveOK=true;
              }
            z++;
           }
         isSymmetricSecond=checkIfSymmetricForBuy(k,k+z-1);
         // // Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
      // Third Wave
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_3HalfWaveMACDH4=1;
         m=k+1;
         resize2H4=(i+1)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         for(m; m<i+1; m++)
           {
            halfWave_2H4[y]=m;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,m);
            if(isFilterThirdHalfWaveOK==false && macdForFilter<filterForBuy)
              {
               isFilterThirdHalfWaveOK=true;
              }
            priceForMinMax=iOpen(NULL,period,j);
            if(secondMin>priceForMinMax)
              {
               secondMin=priceForMinMax;
               isSecondMin=true;
              }
            y++;
           }
         isSymmetricThird=checkIfSymmetricForBuy(m,m+y-1);
         // // Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m); ", (i-2)-j);
        }
      if(countHalfWaves==2 && what_2HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_3HalfWaveMACDH4=0;
         m=k+1;
         resize2H4=(i+1)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         for(m; m<i+1; m++)
           {
            halfWave_2H4[y]=m;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,m);
            if(isFilterThirdHalfWaveOK==false && macdForFilter>filterForSell)
              {
               isFilterThirdHalfWaveOK=true;
              }
            priceForMinMax=iOpen(NULL,period,j);
            if(secondMax<priceForMinMax)
              {
               secondMax=priceForMinMax;
               isSecondMax=true;
              }
            y++;
           }
         isSymmetricThird=checkIfSymmetricForSell(m,m+y-1);
         // // Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m) ", (i-2)-m);
        }
      // Fourth Wave
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWaves++;
         what_4HalfWaveMACDH4=0;
         p=m+1;
         resize3H4=(i+1)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         for(p; p<i+1; p++)
           {
            halfWave_3H4[x]=p;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,p);
            if(isFilterFourthHalfWaveOK==false && macdForFilter>filterForSell)
              {
               isFilterFourthHalfWaveOK=true;
              }
            x++;
           }
         isSymmetricFourth=checkIfSymmetricForSell(p,p+x-1);
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWaves==3 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWaves++;
         what_4HalfWaveMACDH4=1;
         p=m+1;
         resize3H4=(i+1)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         for(p; p<i+1; p++)
           {
            halfWave_3H4[x]=p;
            macdForFilter=iMACD(NULL,period,12,26,9,PRICE_CLOSE,MODE_MAIN,p);
            if(isFilterFourthHalfWaveOK==false && macdForFilter<filterForBuy)
              {
               isFilterFourthHalfWaveOK=true;
              }
            x++;
           }
         isSymmetricFourth=checkIfSymmetricForBuy(p,p+x-1);
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      // begin++;
     }
/*    Получаем четыре массива и проверяем что бы в каждоq ПВ по MACD был тик более 0,000100 isFilterOK
      для каждого тайм фрейма, в начале метода флаг сбрасываем в false
      */
/*
Проставляем
firstMin, secondMin, - первая ПВ, countHalfWaves 0
 firstMax, secondMax, - третья ПВ, countHalfWaves 2
isFirstMin, isSecondMin, isFirstMax, isSecondMax
min для buy
max для sell
приоритет от Н4 до M5
в начале метода флаг сбрасываем в false
значения в 0,00000000
*/

// return section
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
   int zz;
   double Macd_1H4=0;// нулевой тик
   double Macd_2H4=0;// следующий тик
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4;
   bool isFilterFirstHalfWaveOK,isFilterSecondHalfWaveOK,isFilterThirdHalfWaveOK,isFilterFourthHalfWaveOK;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int i,z,y,x,j,k,m,p,
   resize0H4,resize1H4,resize2H4,resize3H4;
   isFilterFirstHalfWaveOK=false;
   isFilterSecondHalfWaveOK=false;
   isFilterThirdHalfWaveOK=false;
   isFilterFourthHalfWaveOK=false;
   firstMin=0.00000000;
   secondMin= 0.00000000;
   firstMax = 0.00000000;
   secondMax= 0.00000000;
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
      // И Полуволны складываем в массивы
      // First Wave
      if(countHalfWaves==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) // Проверим, для перехода снизу вверх, что второй и третий тик ниже 0, основной фильтр на шум
        {
         countHalfWaves++;
         what_1HalfWaveMACDH4=1;
         j=begin+1; // begin 0+1  j=1, а инкремент на begin идет вконце, а не вначале (стоп, обнуление и смещение?) убираем begin ++
         resize0H4=(i+1)-j; // i = begin ie 0, тоесть будет 1й элемент
                            // то есть у нас смещение не на 2, а на 1 - потому вношу ищменения
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+1; j++)
           {
            halfWave0H4[zz]=j;
            priceForMinMax = iOpen(NULL,period,j);
            if(firstMin>priceForMinMax)
              {
               firstMin=priceForMinMax;
               isFirstMin=true;
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
         resize0H4=(i+1)-j;
         ArrayResize(halfWave0H4,resize0H4);
         zz=0;
         for(j; j<i+1; j++)
           {
            halfWave0H4[zz]=j;
            priceForMinMax = iOpen(NULL,period,j);
            if(firstMax<priceForMinMax)
              {
               firstMax=priceForMinMax;
               isFirstMax=true;
              }
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
         resize1H4=(i+1)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         for(k; k<i+1; k++)
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
         resize1H4=(i+1)-k;
         ArrayResize(halfWave_1H4,resize1H4);
         z=0;
         for(k; k<i+1; k++)
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
         resize2H4=(i+1)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         for(m; m<i+1; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax = iOpen(NULL,period,j);
            if(secondMin>priceForMinMax)
              {
               secondMin=priceForMinMax;
               isSecondMin=true;
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
         resize2H4=(i+1)-m;
         ArrayResize(halfWave_2H4,resize2H4);
         y=0;
         for(m; m<i+1; m++)
           {
            halfWave_2H4[y]=m;
            priceForMinMax = iOpen(NULL,period,j);
            if(secondMax<priceForMinMax)
              {
               secondMax=priceForMinMax;
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
         resize3H4=(i+1)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         for(p; p<i+1; p++)
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
         resize3H4=(i+1)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         for(p; p<i+1; p++)
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
firstMin, secondMin, - первая ПВ, countHalfWaves 0
 firstMax, secondMax, - третья ПВ, countHalfWaves 2
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
bool checkIfSymmetricForBuy(int start,int end)
  {
   bool isSymmetricForBuy=true;
   for(int i=start+1;start<end;i++)
     {
      double osmaStart= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i);
      double osmaPrev = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i-1);
      double osmaNext = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i+1);
      if(osmaStart>osmaPrev && osmaStart>osmaNext)
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
bool checkIfSymmetricForSell(int start,int end)
  {
   bool isSymmetricForSell=true;
   for(int i=start+1;start<end;i++)
     {
      double osmaStart= iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i);
      double osmaPrev = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i-1);
      double osmaNext = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,i+1);
      if(osmaStart<osmaPrev && osmaStart<osmaNext)
        {
         isSymmetricForSell=false;
         break;
        }
     }
   return isSymmetricForSell;
  }
// the end.
