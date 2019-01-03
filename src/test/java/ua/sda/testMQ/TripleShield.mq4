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

// Block 1 Попробуем определить пару драйвер
   for(myPairsCount=0; myPairsCount<5; myPairsCount++) // iterate instruments
     {
      beginPairDriver=-1;
      myCurrentPair=myPairs[myPairsCount];
      Macd_1H4PairDriver=0;
      Macd_2H4PairDriver=0;
      while(!(Macd_1H4PairDriver>0 && Macd_2H4PairDriver>0) && !(Macd_1H4PairDriver<0 && Macd_2H4PairDriver<0))
        {
         beginPairDriver++;
         Macd_1H4PairDriver=iMACD(myCurrentPair,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,beginPairDriver); // start value is 1
         Macd_2H4PairDriver=iMACD(myCurrentPair,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,beginPairDriver+1);
         if(Macd_1H4PairDriver>0 && Macd_2H4PairDriver>0){what0HalfWavePairDriver=0;}
         else if(Macd_1H4PairDriver<0 && Macd_2H4PairDriver<0){what0HalfWavePairDriver=1;}
         countHalfWavesPairDriver=0;
         what_1HalfWavePirDriver=0;
         for(iPD=beginPairDriver; countHalfWavesPairDriver<1; iPD++)
           {
            MacdIplus3H4PairDriver=iMACD(myCurrentPair,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,iPD+1);
            MacdIplus4H4PairDriver=iMACD(myCurrentPair,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,iPD+2);
            if(countHalfWavesPairDriver==0 && what0HalfWavePairDriver==0 && MacdIplus3H4PairDriver<0 && MacdIplus4H4PairDriver<0)
              {
               countHalfWavesPairDriver++;
               what_1HalfWavePirDriver=1;
               jPD=beginPairDriver+1;
               resizeForPairDriver=(iPD+2)-jPD;
               ArrayResize(pairDriver,resizeForPairDriver);
               pd=0;
               for(jPD; jPD<iPD+2; jPD++)
                 {
                  pairDriver[pd]=jPD;
                  pd++;
                 }
              }
            if(countHalfWavesPairDriver==0 && what0HalfWavePairDriver==1 && MacdIplus3H4PairDriver>0 && MacdIplus4H4PairDriver>0)
              {
               countHalfWavesPairDriver++;
               what_1HalfWavePirDriver=0;
               jPD=beginPairDriver+1;
               resizeForPairDriver=(iPD+2)-jPD;
               ArrayResize(pairDriver,resizeForPairDriver);
               pd=0;
               for(jPD; jPD<iPD+2; jPD++)
                 {
                  pairDriver[pd]=jPD;
                  pd++;
                 }
              }
           }
         // Имеем для определения пары драйвера массив, каждый проход для каждой пары
         resultLow=iLow(myCurrentPair,PERIOD_M15,pairDriver[0]);
         resultHigh=iHigh(myCurrentPair,PERIOD_M15,pairDriver[0]);
         for(minMaxCount=0; minMaxCount<resizeForPairDriver; minMaxCount++)
           {
            tempMin = iLow(myCurrentPair,PERIOD_M15,pairDriver[minMaxCount]);
            tempMax = iHigh(myCurrentPair,PERIOD_M15,pairDriver[minMaxCount]);
            if(resultLow>tempMin){resultLow=tempMin;}
            if(resultHigh<tempMax){resultHigh=tempMax;}
           }
         if(myCurrentPair=="EURUSD" || myCurrentPair=="GBPUSD" || myCurrentPair=="USDCAD")
           {
            resultDifference=(resultHigh-resultLow)/0.00001;
           }
         if(myCurrentPair=="GBPJPY" || myCurrentPair=="USDJPY")
           {
            resultDifference=(resultHigh-resultLow)/0.001;
           }
        }
      printResultDifference[myPairsCount]=resultDifference;
      Print("myCurrentPair = ",myCurrentPair,"; resultDifference = ",resultDifference);
     }
   Print(" "," --- ", ", (",printResultDifference[4],") "," --- ", ", (",printResultDifference[3],") "," --- ", ", (",printResultDifference[2],") "," --- ", ", (",printResultDifference[1],") "," --- ", ", (",printResultDifference[0],")");
   Sleep(3333);
/* Block 2   The algorithm of the trend criteria detalization:
Mеханизм распознания первой ПВ:
Какие у меня критерии?
1)
У меня нет механизма распознавания 0-вой полуволны, У меня есть механизм распознавания критериев:
countHalfWavesH4 =0;
1) берем MACD тикa i+1 и i+2, соответствующего таймфрейма
а) если они выше нуля - то what0HalfWaveMACDH4 ==0
б) если они ниже нуля - то what0HalfWaveMACDH4 ==1
в) в случае - если тик i+1 выше 0 и i+2 ниже 0 отдельные случаи ExceptionCases?...
в1) в случае - если тик i+1 ниже 0 и i+2 выше 0 отдельные случаи ExceptionCases?...
в2) в случае - если тик i+1 равен 0 или тик i+2 равен 0 отдельные случаи ExceptionCases?...
г) что делать с тиком 0? отдельные случаи ExceptionCases?... Точность MODE_MAIN - 4 символа после запятой, можно провести тестирование (поиск тиков по истории на всех таймфреймах - но я не видел в реальной жизни то есть в режиме PRICE_CLOSE значений 0.0000, кончечно такое значение абсолютно реально)
Входим в цикл, и с тех же значений (то есть, стартового(1) значения), далее итерируем i, получаем значение (не для 0, начинаем с 11), а для 1,2,3,4,5,6,7,8,9

1) если countHalfWavesH4 ==0 && what0HalfWaveMACDH4==0 И тик i+3<0 И тик i+4<0 то (значит произошел переход) countHalfWavesH4 ++ (будет 1); (значит можно обращаться к what_1HalfWaveMACDH4) И what_1HalfWaveMACDH4==1; И (складываем в массив тики ПолуВолны)
Какие тики мне нужно сложить в массив 0 - вой ПолуВолны? тики от i = 1 до текущего i-2 и складывать их надо в прямом порядке, тоесть от 1 до i-2.
for (int j=1; j>i-2;j++){ ( и j++ остановится на тике (-2 от текущего)), те будет равна последнему тику сложенному в массив
ArrayResize(halfWave0H4,(i-2)-j);
halfWave0H4[j-1] = j;
Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j));
Print(halfWave0H4);
проверить на валидность элементы массива, по количеству и по значению.
}
случай 1 - например на  i = 10, те 13 и 14 тике
что дальше? следующая волна (те 1ая), тики в массиве
1а) переворачиваем условия для противоположной волны
2) если countHalfWavesH4 ==1 (итерация, основное условие) && what_1HalfWaveMACDH4==1 (переворротное условие) И тик i+3>0 И тик i+4>0 то (значит произошел переход).
countHalfWavesH4 ++ (будет 2); (значит можно обращаться к what_2HalfWaveMACDH4) what_1HalfWaveMACDH4==2 (! здесь bool) и складываем в массив тики ПВ
какие тики нужно сложить? от первого тика
складываем в массив halfWave_1H4
в этот момент мы получаем сигнал о 2ой ПолуВолне (отсчет с 0ой) и складываем тики  -1 ПолуВолны (тоесть до данного момента i-2 от...) и так как j остановился на последнем тике той (предыдущей 0ой ПВ) то мне надо сложить в массив halfWave_1H4 тики от j+1 до i-2
for (int k=j+1; k>i-2; k++){
int z=0;
ArrayResize(halfWave_1H4,(i-2)-k);
halfWave_1H4[z] =k;
z++;
}
2а) переворачиваем условия для противоположной волны
3) если countHalfWavesH4 ==2 && what_2HalfWaveMACDH4==0 (тк countHalfWavesH4 ==2 то переменной what_2HalfWaveMACDH4 уже присвоено боевое значение) И тик i+3<0 И тик i+4<0 (значит произошел переход)
countHalfWavesH4 ++ (будет 3); what_2HalfWaveMACDH4==1
какие тики нужно сложить? от k+1 до i-2
for(int m=k+1;m>i-2;m++){
int y=0;
ArrayResize(halfWave_2H4,(i-2)-m);
halfWave_2H4[y]=m;
y++;
}
3а)переворачиваем условия для противоположной волны
4) если countHalfWavesH4 ==3 && what_3HalfWaveMACDH4==1 И тик i+3>0 И тик i+4>0
то countHalfWavesH4 ++ (будет 4); what_4HalfWaveMACDH4==0
какие тики нужно сложить? от m+1 до i-2
for(int p=m+1;p>i-2;p++){
int x=0;
ArrayResize(halfWave_3H4,(i-2)-p);
halfWave_3H4[x]=p;
x++;
}
4а )переворачиваем условия для противоположной волны

ArrayResize - в цикле не пойдет, так как есть
и до массива не пойдет... Подумать и Сделать Переменную с которой начинается отсчет волны объявляюю и обсчитую инициализируя раньше

   */

/* Block 3 Algorithm, part for H4 Half Waves*/

// Print("Test Vasiliy", !(Macd_1H4>0 && Macd_2H4>0) || !(Macd_1H4<0 && Macd_2H4<0));// будет 1



   countHalfWavesH4=0;
   begin=0;
   Macd_1H4=0;
   Macd_2H4=0;
   // пока не больше 0 И Пока не меньше 0
   while(!(Macd_1H4>0 && Macd_2H4>0) && !(Macd_1H4<0 && Macd_2H4<0))
     {

      begin++;

      // Print("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS), " Time[begin]=",TimeToStr(Time[begin],TIME_SECONDS));
      // Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,begin)");
      // Print(Macd_1H4);

      Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,begin);

/*
      if(iteration==15391){
      Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,1)");
      Print(Macd_1H4);
      }
*/
      Macd_2H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1);
/*
      if(iteration==15391){
      Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1)");
      Print(Macd_2H4);
      }

      Macd_2H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,2);
            if(iteration==15391){
      Print("Macd_1H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,2)");
      Print(Macd_2H4);

      }
*/
      if(Macd_1H4>0 && Macd_2H4>0){what0HalfWaveMACDH4=0;}
      else if(Macd_1H4<0 && Macd_2H4<0){what0HalfWaveMACDH4=1;}
/*     if(iteration==15391){
      Print("Macd_1H4 = ", Macd_1H4, " Macd_2H4 = ", Macd_2H4, "what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4);
      Print("Macd_1H4>0 = ", Macd_1H4>0, " Macd_2H4>0 = ", Macd_2H4>0, "what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4);
      Print("Macd_1H4<0 = ", Macd_1H4<0, " Macd_2H4<0 = ", Macd_2H4<0, "what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4);
      Print(begin);
      }
      */
     }

/*
if(iteration==15391){
Print("start of H4 for bllock");}

*/
// else // Print("   ERROR (Catched 0) MACD equals 0,0000 PERIOD_H4 ", countHalfWavesH4);
   for(i=begin;countHalfWavesH4<=3;i++)
     {
      MacdIplus3H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      MacdIplus4H4=iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2);
      // Print("i= ",i, " countHalfWavesH4 = ",countHalfWavesH4," what0HalfWaveMACDH4 = ", what0HalfWaveMACDH4," MacdIplus3H4= ", MacdIplus3H4, " MacdIplus4H4= ", MacdIplus4H4 );

      // Print("(countHalfWavesH4==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0) = ", (countHalfWavesH4==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0));
      if(countHalfWavesH4==0 && what0HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWavesH4++;
         what_1HalfWaveMACDH4=1;
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
      if(countHalfWavesH4==0 && what0HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWavesH4++;
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
      if(countHalfWavesH4==1 && what_1HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWavesH4++;
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
      if(countHalfWavesH4==1 && what_1HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWavesH4++;
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
      if(countHalfWavesH4==2 && what_2HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWavesH4++;
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
      if(countHalfWavesH4==2 && what_2HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWavesH4++;
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
      if(countHalfWavesH4==3 && what_3HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         countHalfWavesH4++;
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
      if(countHalfWavesH4==3 && what_3HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
         countHalfWavesH4++;
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
     }

/* Block 4 Algorithm, part for H1 Half Waves*/
   countHalfWavesH1=0;
// Print("H1 HalfWave");
   begin=0;
   Macd_1H1=0;
   Macd_2H1=0;
   while(!(Macd_1H1>0 && Macd_2H1>0) && !(Macd_1H1<0 && Macd_2H1<0))
     {

      begin++;

      Macd_1H1=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,begin);
      // Print("Macd_1H1=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,begin)");
      // Print(Macd_1H1);

      Macd_2H1=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1);
      // Print("Macd_2H1=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1)");
      // Print(Macd_2H1);

      if(Macd_1H1>0 && Macd_2H1>0){what0HalfWaveMACDH1=0;}
      else if(Macd_1H1<0 && Macd_2H1<0){what0HalfWaveMACDH1=1;}
     }
// else // Print("   ERROR (Catched 0) MACD equals 0,0000 PERIOD_H1 ", countHalfWavesH1);
   for(i=begin;countHalfWavesH1<=3;i++)
     {
      MacdIplus3H1=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      MacdIplus4H1=iMACD(NULL,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2);
      // Print("i= ",i, " countHalfWavesH1 = ",countHalfWavesH1," what0HalfWaveMACDH1 = ", what0HalfWaveMACDH1," MacdIplus3H1= ", MacdIplus3H1, " MacdIplus4H1= ", MacdIplus4H1 );

      if(countHalfWavesH1==0 && what0HalfWaveMACDH1==0 && MacdIplus3H1<0 && MacdIplus4H1<0)
        {
         countHalfWavesH1++;
         what_1HalfWaveMACDH1=1;
         j=begin+1;
         resize0H1=(i+2)-j;
         ArrayResize(halfWave0H1,resize0H1);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0H1[zz]=j;
            zz++;
           }
         // // Print("halfWave0H1", "ArrayResize(halfWave0H1,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesH1==0 && what0HalfWaveMACDH1==1 && MacdIplus3H1>0 && MacdIplus4H1>0)
        {
         countHalfWavesH1++;
         what_1HalfWaveMACDH1=0;
         j=begin+1;
         resize0H1=(i+2)-j;
         ArrayResize(halfWave0H1,resize0H1);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0H1[zz]=j;
            zz++;
           }
         // // Print("halfWave0H1", "ArrayResize(halfWave0H1,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesH1==1 && what_1HalfWaveMACDH1==1 && MacdIplus3H1>0 && MacdIplus4H1>0)
        {
         countHalfWavesH1++;
         what_2HalfWaveMACDH1=0;
         k=j+1;
         resize1H1=(i+2)-k;
         ArrayResize(halfWave_1H1,resize1H1);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1H1[z]=k;
            z++;
           }
         // // Print("halfWave_1H1", "ArrayResize(halfWave_1H1,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesH1==1 && what_1HalfWaveMACDH1==0 && MacdIplus3H1<0 && MacdIplus4H1<0)
        {
         countHalfWavesH1++;
         what_2HalfWaveMACDH1=1;
         k=j+1;
         resize1H1=(i+2)-k;
         ArrayResize(halfWave_1H1,resize1H1);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1H1[z]=k;
            z++;
           }
         // // Print("halfWave_1H1", "ArrayResize(halfWave_1H1,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesH1==2 && what_2HalfWaveMACDH1==0 && MacdIplus3H1<0 && MacdIplus4H1<0)
        {
         countHalfWavesH1++;
         what_3HalfWaveMACDH1=1;
         m=k+1;
         resize2H1=(i+2)-m;
         ArrayResize(halfWave_2H1,resize2H1);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2H1[y]=m;
            y++;
           }
         // // Print("halfWave_2H1", "ArrayResize(halfWave_2H1,(i-2)-m); ", (i-2)-j);
        }
      // Print("(countHalfWavesH1==2 && what_2HalfWaveMACDH1==1 && MacdIplus3H1>0 && MacdIplus4H1>0) = ", (countHalfWavesH1==2 && what_2HalfWaveMACDH1==1 && MacdIplus3H1>0 && MacdIplus4H1>0));
      // Print("MacdIplus3H1>0 && MacdIplus4H1>0 ", MacdIplus3H1," ", MacdIplus4H1);
      if(countHalfWavesH1==2 && what_2HalfWaveMACDH1==1 && MacdIplus3H1>0 && MacdIplus4H1>0)
        {
         countHalfWavesH1++;
         what_3HalfWaveMACDH1=0;
         m=k+1;
         resize2H1=(i+2)-m;
         ArrayResize(halfWave_2H1,resize2H1);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2H1[y]=m;
            y++;
           }
         // // Print("halfWave_2H1", "ArrayResize(halfWave_2H1,(i-2)-m) ", (i-2)-m);
        }
      if(countHalfWavesH1==3 && what_3HalfWaveMACDH1==1 && MacdIplus3H1>0 && MacdIplus4H1>0)
        {
         countHalfWavesH1++;
         what_4HalfWaveMACDH1=0;
         p=m+1;
         resize3H1=(i+2)-p;
         ArrayResize(halfWave_3H1,resize3H1);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3H1[x]=p;
            x++;
           }
         // // Print("halfWave_3H1", "ArrayResize(halfWave_3H1,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWavesH1==3 && what_3HalfWaveMACDH1==0 && MacdIplus3H1<0 && MacdIplus4H1<0)
        {
         countHalfWavesH1++;
         what_4HalfWaveMACDH1=1;
         p=m+1;
         resize3H1=(i+2)-p;
         ArrayResize(halfWave_3H1,resize3H1);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3H1[x]=p;
            x++;
           }
         // // Print("halfWave_3H1", "ArrayResize(halfWave_3H1,(i-2)-p) ", (i-2)-p);
        }
     }



/* Block 5 Algorithm, part for M15 Half Waves*/
// Print("M15 HalfWave");
   countHalfWavesM15=0;
   begin=0;
   Macd_1M15=0;
   Macd_2M15=0;
   while(!(Macd_1M15>0 && Macd_2M15>0) && !(Macd_1M15<0 && Macd_2M15<0))
     {
      begin++;
      Macd_1M15=iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,begin);
      Macd_2M15=iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1);
      if(Macd_1M15>0 && Macd_2M15>0){what0HalfWaveMACDM15=0;}
      else if(Macd_1M15<0 && Macd_2M15<0){what0HalfWaveMACDM15=1;}
     }
// else // Print("   ERROR (Catched 0) MACD equals 0,0000 PERIOD_M15 ", countHalfWavesM15);
   for(i=begin;countHalfWavesM15<=3;i++)
     {
      MacdIplus3M15=iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      MacdIplus4M15=iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2);

      if(countHalfWavesM15==0 && what0HalfWaveMACDM15==0 && MacdIplus3M15<0 && MacdIplus4M15<0)
        {
         countHalfWavesM15++;
         what_1HalfWaveMACDM15=1;
         j=begin+1;
         resize0M15=(i+2)-j;
         ArrayResize(halfWave0M15,resize0M15);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0M15[zz]=j;
            zz++;
           }
         // // Print("halfWave0M15", "ArrayResize(halfWave0M15,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesM15==0 && what0HalfWaveMACDM15==1 && MacdIplus3M15>0 && MacdIplus4M15>0)
        {
         countHalfWavesM15++;
         what_1HalfWaveMACDM15=0;
         j=begin+1;
         resize0M15=(i+2)-j;
         ArrayResize(halfWave0M15,resize0M15);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0M15[zz]=j;
            zz++;
           }
         // // Print("halfWave0M15", "ArrayResize(halfWave0M15,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesM15==1 && what_1HalfWaveMACDM15==1 && MacdIplus3M15>0 && MacdIplus4M15>0)
        {
         countHalfWavesM15++;
         what_2HalfWaveMACDM15=0;
         k=j+1;
         resize1M15=(i+2)-k;
         ArrayResize(halfWave_1M15,resize1M15);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1M15[z]=k;
            z++;
           }
         // // Print("halfWave_1M15", "ArrayResize(halfWave_1M15,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesM15==1 && what_1HalfWaveMACDM15==0 && MacdIplus3M15<0 && MacdIplus4M15<0)
        {
         countHalfWavesM15++;
         what_2HalfWaveMACDM15=1;
         k=j+1;
         resize1M15=(i+2)-k;
         ArrayResize(halfWave_1M15,resize1M15);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1M15[z]=k;
            z++;
           }
         // // Print("halfWave_1M15", "ArrayResize(halfWave_1M15,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesM15==2 && what_2HalfWaveMACDM15==0 && MacdIplus3M15<0 && MacdIplus4M15<0)
        {
         countHalfWavesM15++;
         what_3HalfWaveMACDM15=1;
         m=k+1;
         resize2M15=(i+2)-m;
         ArrayResize(halfWave_2M15,resize2M15);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2M15[y]=m;
            y++;
           }
         // // Print("halfWave_2M15", "ArrayResize(halfWave_2M15,(i-2)-m); ", (i-2)-j);
        }
      if(countHalfWavesM15==2 && what_2HalfWaveMACDM15==1 && MacdIplus3M15>0 && MacdIplus4M15>0)
        {
         countHalfWavesM15++;
         what_3HalfWaveMACDM15=0;
         m=k+1;
         resize2M15=(i+2)-m;
         ArrayResize(halfWave_2M15,resize2M15);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2M15[y]=m;
            y++;
           }
         // // Print("halfWave_2M15", "ArrayResize(halfWave_2M15,(i-2)-m) ", (i-2)-m);
        }
      if(countHalfWavesM15==3 && what_3HalfWaveMACDM15==1 && MacdIplus3M15>0 && MacdIplus4M15>0)
        {
         countHalfWavesM15++;
         what_4HalfWaveMACDM15=0;
         p=m+1;
         resize3M15=(i+2)-p;
         ArrayResize(halfWave_3M15,resize3M15);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3M15[x]=p;
            x++;
           }
         // // Print("halfWave_3M15", "ArrayResize(halfWave_3M15,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWavesM15==3 && what_3HalfWaveMACDM15==0 && MacdIplus3M15<0 && MacdIplus4M15<0)
        {
         countHalfWavesM15++;
         what_4HalfWaveMACDM15=1;
         p=m+1;
         resize3M15=(i+2)-p;
         ArrayResize(halfWave_3M15,resize3M15);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3M15[x]=p;
            x++;
           }
         // // Print("halfWave_3M15", "ArrayResize(halfWave_3M15,(i-2)-p) ", (i-2)-p);
        }
     }



/* Block 6 Algorithm, part for M5 Half Waves*/
// Print("M5 HalfWave");
   countHalfWavesM5=0;
   begin=0;
   Macd_1M5=0;
   Macd_2M5=0;
   while(!(Macd_1M5>0 && Macd_2M5>0) && !(Macd_1M5<0 && Macd_2M5<0))
     {
      begin++;
      Macd_1M5=iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_MAIN,begin);
      Macd_2M5=iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1);
      if(Macd_1M5>0 && Macd_2M5>0){what0HalfWaveMACDM5=0;}
      else if(Macd_1M5<0 && Macd_2M5<0){what0HalfWaveMACDM5=1;}
     }
// else // Print("   ERROR (Catched 0) MACD equals 0,0000 PERIOD_M5 ", countHalfWavesM5);
   for(i=begin;countHalfWavesM5<=3;i++)
     {
      MacdIplus3M5=iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      MacdIplus4M5=iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2);

      if(countHalfWavesM5==0 && what0HalfWaveMACDM5==0 && MacdIplus3M5<0 && MacdIplus4M5<0)
        {
         countHalfWavesM5++;
         what_1HalfWaveMACDM5=1;
         j=begin+1;
         resize0M5=(i+2)-j;
         ArrayResize(halfWave0M5,resize0M5);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0M5[zz]=j;
            zz++;
           }
         // // Print("halfWave0M5", "ArrayResize(halfWave0M5,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesM5==0 && what0HalfWaveMACDM5==1 && MacdIplus3M5>0 && MacdIplus4M5>0)
        {
         countHalfWavesM5++;
         what_1HalfWaveMACDM5=0;
         j=begin+1;
         resize0M5=(i+2)-j;
         ArrayResize(halfWave0M5,resize0M5);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0M5[zz]=j;
            zz++;
           }
         // // Print("halfWave0M5", "ArrayResize(halfWave0M5,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesM5==1 && what_1HalfWaveMACDM5==1 && MacdIplus3M5>0 && MacdIplus4M5>0)
        {
         countHalfWavesM5++;
         what_2HalfWaveMACDM5=0;
         k=j+1;
         resize1M5=(i+2)-k;
         ArrayResize(halfWave_1M5,resize1M5);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1M5[z]=k;
            z++;
           }
         // // Print("halfWave_1M5", "ArrayResize(halfWave_1M5,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesM5==1 && what_1HalfWaveMACDM5==0 && MacdIplus3M5<0 && MacdIplus4M5<0)
        {
         countHalfWavesM5++;
         what_2HalfWaveMACDM5=1;
         k=j+1;
         resize1M5=(i+2)-k;
         ArrayResize(halfWave_1M5,resize1M5);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1M5[z]=k;
            z++;
           }
         // // Print("halfWave_1M5", "ArrayResize(halfWave_1M5,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesM5==2 && what_2HalfWaveMACDM5==0 && MacdIplus3M5<0 && MacdIplus4M5<0)
        {
         countHalfWavesM5++;
         what_3HalfWaveMACDM5=1;
         m=k+1;
         resize2M5=(i+2)-m;
         ArrayResize(halfWave_2M5,resize2M5);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2M5[y]=m;
            y++;
           }
         // // Print("halfWave_2M5", "ArrayResize(halfWave_2M5,(i-2)-m); ", (i-2)-j);
        }
      if(countHalfWavesM5==2 && what_2HalfWaveMACDM5==1 && MacdIplus3M5>0 && MacdIplus4M5>0)
        {
         countHalfWavesM5++;
         what_3HalfWaveMACDM5=0;
         m=k+1;
         resize2M5=(i+2)-m;
         ArrayResize(halfWave_2M5,resize2M5);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2M5[y]=m;
            y++;
           }
         // // Print("halfWave_2M5", "ArrayResize(halfWave_2M5,(i-2)-m) ", (i-2)-m);
        }
      if(countHalfWavesM5==3 && what_3HalfWaveMACDM5==1 && MacdIplus3M5>0 && MacdIplus4M5>0)
        {
         countHalfWavesM5++;
         what_4HalfWaveMACDM5=0;
         p=m+1;
         resize3M5=(i+2)-p;
         ArrayResize(halfWave_3M5,resize3M5);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3M5[x]=p;
            x++;
           }
         // // Print("halfWave_3M5", "ArrayResize(halfWave_3M5,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWavesM5==3 && what_3HalfWaveMACDM5==0 && MacdIplus3M5<0 && MacdIplus4M5<0)
        {
         countHalfWavesM5++;
         what_4HalfWaveMACDM5=1;
         p=m+1;
         resize3M5=(i+2)-p;
         ArrayResize(halfWave_3M5,resize3M5);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3M5[x]=p;
            x++;
           }
         // // Print("halfWave_3M5", "ArrayResize(halfWave_3M5,(i-2)-p) ", (i-2)-p);
        }
     }



/* Block 7 Algorithm, part for M1 Half Waves*/
// Print("M1 HalfWave");
   countHalfWavesM1=0;
   begin=0;
   Macd_1M1=0;
   Macd_2M1=0;
   while(!(Macd_1M1>0 && Macd_2M1>0) && !(Macd_1M1<0 && Macd_2M1<0))
     {
      begin++;
      Macd_1M1=iMACD(NULL,PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_MAIN,begin);
      Macd_2M1=iMACD(NULL,PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_MAIN,begin+1);
      if(Macd_1M1>0 && Macd_2M1>0){what0HalfWaveMACDM1=0;}
      else if(Macd_1M1<0 && Macd_2M1<0){what0HalfWaveMACDM1=1;}
     }
// else // Print("   ERROR (Catched 0) MACD equals 0,0000 PERIOD_M1 ", countHalfWavesM1);
   for(i=begin;countHalfWavesM1<=3;i++)
     {
      MacdIplus3M1=iMACD(NULL,PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      MacdIplus4M1=iMACD(NULL,PERIOD_M1,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2);

      if(countHalfWavesM1==0 && what0HalfWaveMACDM1==0 && MacdIplus3M1<0 && MacdIplus4M1<0)
        {
         countHalfWavesM1++;
         what_1HalfWaveMACDM1=1;
         j=begin+1;
         resize0M1=(i+2)-j;
         ArrayResize(halfWave0M1,resize0M1);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0M1[zz]=j;
            zz++;
           }
         // // Print("halfWave0M1", "ArrayResize(halfWave0M1,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesM1==0 && what0HalfWaveMACDM1==1 && MacdIplus3M1>0 && MacdIplus4M1>0)
        {
         countHalfWavesM1++;
         what_1HalfWaveMACDM1=0;
         j=begin+1;
         resize0M1=(i+2)-j;
         ArrayResize(halfWave0M1,resize0M1);
         zz=0;
         for(j; j<i+2; j++)
           {
            halfWave0M1[zz]=j;
            zz++;
           }
         // // Print("halfWave0M1", "ArrayResize(halfWave0M1,(i-2)-j); ", (i-2)-j);
        }
      if(countHalfWavesM1==1 && what_1HalfWaveMACDM1==1 && MacdIplus3M1>0 && MacdIplus4M1>0)
        {
         countHalfWavesM1++;
         what_2HalfWaveMACDM1=0;
         k=j+1;
         resize1M1=(i+2)-k;
         ArrayResize(halfWave_1M1,resize1M1);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1M1[z]=k;
            z++;
           }
         // // Print("halfWave_1M1", "ArrayResize(halfWave_1M1,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesM1==1 && what_1HalfWaveMACDM1==0 && MacdIplus3M1<0 && MacdIplus4M1<0)
        {
         countHalfWavesM1++;
         what_2HalfWaveMACDM1=1;
         k=j+1;
         resize1M1=(i+2)-k;
         ArrayResize(halfWave_1M1,resize1M1);
         z=0;
         for(k; k<i+2; k++)
           {
            halfWave_1M1[z]=k;
            z++;
           }
         // // Print("halfWave_1M1", "ArrayResize(halfWave_1M1,(i-2)-k) ", (i-2)-k);
        }
      if(countHalfWavesM1==2 && what_2HalfWaveMACDM1==0 && MacdIplus3M1<0 && MacdIplus4M1<0)
        {
         countHalfWavesM1++;
         what_3HalfWaveMACDM1=1;
         m=k+1;
         resize2M1=(i+2)-m;
         ArrayResize(halfWave_2M1,resize2M1);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2M1[y]=m;
            y++;
           }
         // // Print("halfWave_2M1", "ArrayResize(halfWave_2M1,(i-2)-m); ", (i-2)-j);
        }
      if(countHalfWavesM1==2 && what_2HalfWaveMACDM1==1 && MacdIplus3M1>0 && MacdIplus4M1>0)
        {
         countHalfWavesM1++;
         what_3HalfWaveMACDM1=0;
         m=k+1;
         resize2M1=(i+2)-m;
         ArrayResize(halfWave_2M1,resize2M1);
         y=0;
         for(m; m<i+2; m++)
           {
            halfWave_2M1[y]=m;
            y++;
           }
         // // Print("halfWave_2M1", "ArrayResize(halfWave_2M1,(i-2)-m) ", (i-2)-m);
        }
      if(countHalfWavesM1==3 && what_3HalfWaveMACDM1==1 && MacdIplus3M1>0 && MacdIplus4M1>0)
        {
         countHalfWavesM1++;
         what_4HalfWaveMACDM1=0;
         p=m+1;
         resize3M1=(i+2)-p;
         ArrayResize(halfWave_3M1,resize3M1);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3M1[x]=p;
            x++;
           }
         // // Print("halfWave_3M1", "ArrayResize(halfWave_3M1,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWavesM1==3 && what_3HalfWaveMACDM1==0 && MacdIplus3M1<0 && MacdIplus4M1<0)
        {
         countHalfWavesM1++;
         what_4HalfWaveMACDM1=1;
         p=m+1;
         resize3M1=(i+2)-p;
         ArrayResize(halfWave_3M1,resize3M1);
         x=0;
         for(p; p<i+2; p++)
           {
            halfWave_3M1[x]=p;
            x++;
           }
         // // Print("halfWave_3M1", "ArrayResize(halfWave_3M1,(i-2)-p) ", (i-2)-p);
        }
     }





/* Block 8   The algorithm of the trend criteria definition:
   Идём по истории H4
   1) what0HalfWaveMACDH4 (0 это положительная 1 это отрицательная)
   а) складываем тики в массив halfWave0H4
   2) если произошло пересечение
   а) what_1HalfWaveMACDH4
   б) складываем тики в массив halfWave_1H4
   3) если произошло пересечение
   а) what_2HalfWaveMACDH4
   б) складываем тики в массив halfWave_2H4
   4) если произошло пересечение
   а) what_3HalfWaveMACDH4
   б) складываем тики в массив halfWave_3H4

   if (what_1HalfWaveMACDH4 ==0 && what_3HalfWaveMACDH4==0) doubleCriterionChannelH4 = 0
   if (what_1HalfWaveMACDH4 ==1 && what_3HalfWaveMACDH4==1) doubleCriterionChannelH4 = 1

   Идём по истории H1
   1) what0HalfWaveMACDH1 (0 это положительная 1 это отрицательная)
   а) складываем тики в массив halfWave0H1
   2) если произошло пересечение
   а) what_1HalfWaveMACDH1
   б) складываем тики в массив halfWave_1H1
   3) если произошло пересечение
   а) what_2HalfWaveMACDH1
   б) складываем тики в массив halfWave_2H1
   4) если произошло пересечение
   а) what_3HalfWaveMACDH1
   б) складываем тики в массив halfWave_3H1

   if (what_1HalfWaveMACDH1 ==0 && what_3HalfWaveMACDH1==0) doubleCriterionTrendH1 = 0
   if (what_1HalfWaveMACDH1 ==1 && what_3HalfWaveMACDH1==1) doubleCriterionTrendH1 = 1

   Идём по истории M15
   1) what0HalfWaveMACDM15
   а) складываем тики в массив halfWave0M15
   2) если произошло пересечение
   а) what_1HalfWaveMACDM15
   б) складываем тики в массив halfWave_1M15
   3) если произошло пересечение
   а) what_2HalfWaveMACDM15
   б) складываем тики в массив halfWave_2M15
   4) если произошло пересечение
   а) what_3HalfWaveMACDM15
   б) складываем тики в массив halfWave_3M15

   if (what_1HalfWaveMACDM15==0 && what_3HalfWaveMACDM15==0) doubleCriterionEntryPointM15 = 0
   if (what_1HalfWaveMACDM15==1 && what_3HalfWaveMACDM15==1) doubleCriterionEntryPointM15 = 1

   Идём по истории M5
   1) what0HalfWaveMACDM5
   а) складываем тики в массив halfWave0M5
   2) если произошло пересечение
   а) what_1HalfWaveMACDM5
   б) складываем тики в массив halfWave_1M5
   3) если произошло пересечение
   а) what_2HalfWaveMACDM5
   б) складываем тики в массив halfWave_2M5
   4) если произошло пересечение
   а) what_3halfWaveMACDM5
   б) складываем тики в массив halfWave_3M5

   if (what_1HalfWaveMACDM5 ==0 && what_3halfWaveMACDM5==0) {doubleCriterionTheTimeOfEntryM5 = 0;}
   if (what_1HalfWaveMACDM5 ==1 && what_3halfWaveMACDM5==1) {doubleCriterionTheTimeOfEntryM5 = 1;}

   Идём по истории M1
   1) what0HalfWaveMACDM1
   а) складываем тики в массив halfWave0M1
   2) если произошло пересечение
   а) what_1halfWaveMACDM1
   б) складываем тики в массив halfWave_1M1
   3) если произошло пересечение
   а) what_2HalfWaveMACDM1
   б) складываем тики в массив halfWave_2M1
   4) если произошло пересечение
   а) what_3HalfWaveMACDM1
   б) складываем тики в массив halfWave_3M1

   if (what_1halfWaveMACDM1 ==0 && what_3HalfWaveMACDM1==0) {doubleCriterionM1 = 0;}
   if (what_1halfWaveMACDM1 ==1 && what_3HalfWaveMACDM1==1) {doubleCriterionM1 = 1;}

   if (Stochastic_1H1 <Stochastic_0H1)  {directionStochasticH1== 0;}
   if (Stochastic_1M15<Stochastic_0M15) {directionStochasticM15==0;}
   if (Stochastic_1M5 <Stochastic_0M5)  {directionStochasticM5== 0;}
   if (Stochastic_1M1 <Stochastic_0M1)  {directionStochasticM1== 0;}
   if (Stochastic_1H1 >Stochastic_0H1)  {directionStochasticH1== 1;}
   if (Stochastic_1M15>Stochastic_0M15) {directionStochasticM15==1;}
   if (Stochastic_1M5 >Stochastic_0M5)  {directionStochasticM5== 1;}
   if (Stochastic_1M1 >Stochastic_0M1)  {directionStochasticM1== 1;}

   if(directionStochasticH1 == 0 И directionStochasticM15== 0 И directionStochasticM5 == 0 И directionStochasticM1 == 0) то allStochastic ==0
   if(directionStochasticH1 == 1 И directionStochasticM15== 1 И directionStochasticM5 == 1 И directionStochasticM1 == 1) то allStochastic ==1

   if (OsMA_1H1>OsMA0H1)  {directionOsMAH1== 0;}
   if (OsMA_1M15>OsMA015) {directionOsMAM15==0;}
   if (OsMA_1M5>OsMA05)   {directionOsMAM5== 0;}
   if (OsMA_1M1>OsMA01)   {directionOsMAM1== 0;}

   if (OsMA_1H1<OsMA0H1)  {directionOsMAH1== 1;}
   if (OsMA_1M15<OsMA015) {directionOsMAM15==1;}
   if (OsMA_1M5<OsMA05)   {directionOsMAM5== 1;}
   if (OsMA_1M1<OsMA01)   {directionOsMAM1== 1;}

   if(directionOsMAH1 == 0 && directionOsMAM15== 0 && directionOsMAM5 == 0 && directionOsMAM1 == 0) {llOsMA ==0;}
   if(directionOsMAH1 == 1 && directionOsMAM15== 1 && directionOsMAM5 == 1 && directionOsMAM1 == 1) {llOsMA ==1;}
   End The algorithm of the trend criteria definition
   */

/*Logics Start The algorithm of the trend criteria definition*/

//Print("what_1HalfWaveMACDH4 = ",what_1HalfWaveMACDH4," what_3HalfWaveMACDH4 = ",what_3HalfWaveMACDH4);
//Print("what_1HalfWaveMACDH1 = ",what_1HalfWaveMACDH1," what_3HalfWaveMACDH1 = ",what_3HalfWaveMACDH1);
//Print("what_1HalfWaveMACDM15 = ",what_1HalfWaveMACDM15," what_3HalfWaveMACDM15 = ",what_3HalfWaveMACDM15);
//Print("what_1HalfWaveMACDM5 = ",what_1HalfWaveMACDM5," what_3HalfWaveMACDM5 = ",what_3HalfWaveMACDM5);
//Print("what_1HalfWaveMACDM1 = ",what_1HalfWaveMACDM1," what_3HalfWaveMACDM1 = ",what_3HalfWaveMACDM1);
   if(what_1HalfWaveMACDH4 ==0 && what_3HalfWaveMACDH4==0) {doubleCriterionChannelH4 = 1;}
   if(what_1HalfWaveMACDH4 ==1 && what_3HalfWaveMACDH4==1) {doubleCriterionChannelH4 = 0;}
   if(what_1HalfWaveMACDH1 ==0 && what_3HalfWaveMACDH1==0) {doubleCriterionTrendH1 = 1;}
   if(what_1HalfWaveMACDH1 ==1 && what_3HalfWaveMACDH1==1) {doubleCriterionTrendH1 = 0;}
   if(what_1HalfWaveMACDM15==0 && what_3HalfWaveMACDM15==0) {doubleCriterionEntryPointM15 = 1;}
   if(what_1HalfWaveMACDM15==1 && what_3HalfWaveMACDM15==1) {doubleCriterionEntryPointM15 = 0;}
   if(what_1HalfWaveMACDM5 ==0 && what_3HalfWaveMACDM5==0) {doubleCriterionTheTimeOfEntryM5 = 1;}
   if(what_1HalfWaveMACDM5 ==1 && what_3HalfWaveMACDM5==1) {doubleCriterionTheTimeOfEntryM5 = 0;}
   if(what_1HalfWaveMACDM1 ==0 && what_3HalfWaveMACDM1==0) {doubleCriterionM1 = 1;}
   if(what_1HalfWaveMACDM1 ==1 && what_3HalfWaveMACDM1==1) {doubleCriterionM1 = 0;}


/*Вопрос какие Полуволны брать в расчет 0,1 или 1,2 (там где я брал MACD - я брал 1,2 - потомучто для
критериев мне надо были завершенные волны)*/

/*да и здесь обработка нулевых значений, может если 0 то принять предыдущую тенденцию?*/
   Stochastic_0H1  = iStochastic(NULL,PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   Stochastic_1H1  = iStochastic(NULL,PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,1);
   Stochastic_0M15 = iStochastic(NULL,PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   Stochastic_1M15 = iStochastic(NULL,PERIOD_M15,5,3,3,MODE_SMA,0,MODE_MAIN,1);
   Stochastic_0M5  = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   Stochastic_1M5  = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,0,MODE_MAIN,1);
   Stochastic_0M1  = iStochastic(NULL,PERIOD_M1,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   Stochastic_1M1  = iStochastic(NULL,PERIOD_M1,5,3,3,MODE_SMA,0,MODE_MAIN,1);

   OsMA0H1   = iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0);
   OsMA_1H1  = iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,1);
   OsMA015   = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,0);
   OsMA_1M15 = iOsMA(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,1);
   OsMA05    = iOsMA(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,0);
   OsMA_1M5  = iOsMA(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,1);
   OsMA01    = iOsMA(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,0);
   OsMA_1M1  = iOsMA(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,1);



   if(Stochastic_1H1  < Stochastic_0H1)  {directionStochasticH1=  0;}
   if(Stochastic_1M15 < Stochastic_0M15) {directionStochasticM15= 0;}
   if(Stochastic_1M5  < Stochastic_0M5)  {directionStochasticM5=  0;}
   if(Stochastic_1M1  < Stochastic_0M1)  {directionStochasticM1=  0;}
   if(Stochastic_1H1  > Stochastic_0H1)  {directionStochasticH1=  1;}
   if(Stochastic_1M15 > Stochastic_0M15) {directionStochasticM15= 1;}
   if(Stochastic_1M5  > Stochastic_0M5)  {directionStochasticM5=  1;}
   if(Stochastic_1M1  > Stochastic_0M1)  {directionStochasticM1=  1;}

   if(directionStochasticH1 == 0 && directionStochasticM15== 0 && directionStochasticM5 == 0 && directionStochasticM1 == 0) {allStochastic = 0; checkStochastic = 1;}
   if(directionStochasticH1 == 1 && directionStochasticM15== 1 && directionStochasticM5 == 1 && directionStochasticM1 == 1) {allStochastic = 1; checkStochastic = 1;}

   if(OsMA_1H1  < OsMA0H1)  {directionOsMAH1  =  0;}
   if(OsMA_1M15 < OsMA015)  {directionOsMAM15 =  0;}
   if(OsMA_1M5  < OsMA05)   {directionOsMAM5  =  0;}
   if(OsMA_1M1  < OsMA01)   {directionOsMAM1  =  0;}
   if(OsMA_1H1  > OsMA0H1)  {directionOsMAH1  =  1;}
   if(OsMA_1M15 > OsMA015)  {directionOsMAM15 =  1;}
   if(OsMA_1M5  > OsMA05)   {directionOsMAM5  =  1;}
   if(OsMA_1M1  > OsMA01)   {directionOsMAM1  =  1;}

   if(directionOsMAH1 == 0 && directionOsMAM15== 0 && directionOsMAM5 == 0 && directionOsMAM1 == 0) {allOsMA = 0;checkOsMA = 1;}
   if(directionOsMAH1 == 1 && directionOsMAM15== 1 && directionOsMAM5 == 1 && directionOsMAM1 == 1) {allOsMA = 1;checkOsMA = 1;}
   Print("iteration = ",iteration++);

// Block 9 Criterion Direction H4
   if(what_1HalfWaveMACDH4==0 && what_3HalfWaveMACDH4==0)
     {
      result1 = iHigh(NULL,PERIOD_H4,halfWave_1H4[0]);
      result3 = iHigh(NULL,PERIOD_H4,halfWave_3H4[0]);
      for(criterionDirectionH4count=0; criterionDirectionH4count<resize1H4; criterionDirectionH4count++)
        {
         temp=iHigh(NULL,PERIOD_H4,halfWave_1H4[criterionDirectionH4count]);
         if(result1<temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionH4count=0; criterionDirectionH4count<resize3H4; criterionDirectionH4count++)
        {
         temp=iHigh(NULL,PERIOD_H4,halfWave_3H4[criterionDirectionH4count]);
         if(result3<temp){result3=temp;}
        }
      if(result3>result1){criterionDirectionH4=0;criterionDirectionH4Check=1;}
     }

   if(what_1HalfWaveMACDH4==1 && what_3HalfWaveMACDH4==1)
     {
      result1 = iLow(NULL,PERIOD_H4,halfWave_1H4[0]);
      result3 = iLow(NULL,PERIOD_H4,halfWave_3H4[0]);
      for(criterionDirectionH4count=0; criterionDirectionH4count<resize1H4; criterionDirectionH4count++)
        {
         temp=iLow(NULL,PERIOD_H4,halfWave_1H4[criterionDirectionH4count]);
         if(result1>temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionH4count=0; criterionDirectionH4count<resize3H4; criterionDirectionH4count++)
        {
         temp=iHigh(NULL,PERIOD_H4,halfWave_3H4[criterionDirectionH4count]);
         if(result3>temp){result3=temp;}
        }
      if(result3<result1){criterionDirectionH4=1;criterionDirectionH4Check=1;}
     }

// Criterion Direction H1
   if(what_1HalfWaveMACDH1==0 && what_3HalfWaveMACDH1==0)
     {
      result1 = iHigh(NULL,PERIOD_H1,halfWave_1H1[0]);
      result3 = iHigh(NULL,PERIOD_H1,halfWave_3H1[0]);
      for(criterionDirectionH1count=0; criterionDirectionH1count<resize1H1; criterionDirectionH1count++)
        {
         temp=iHigh(NULL,PERIOD_H1,halfWave_1H1[criterionDirectionH1count]);
         if(result1<temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionH1count=0; criterionDirectionH1count<resize3H1; criterionDirectionH1count++)
        {
         temp=iHigh(NULL,PERIOD_H1,halfWave_3H1[criterionDirectionH1count]);
         if(result3<temp){result3=temp;}
        }
      if(result3>result1){criterionDirectionH1=0;criterionDirectionH1Check=1;}
     }

   if(what_1HalfWaveMACDH1==1 && what_3HalfWaveMACDH1==1)
     {
      result1 = iLow(NULL,PERIOD_H1,halfWave_1H1[0]);
      result3 = iLow(NULL,PERIOD_H1,halfWave_3H1[0]);
      for(criterionDirectionH1count=0; criterionDirectionH1count<resize1H1; criterionDirectionH1count++)
        {
         temp=iLow(NULL,PERIOD_H1,halfWave_1H1[criterionDirectionH1count]);
         if(result1>temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionH1count=0; criterionDirectionH1count<resize3H1; criterionDirectionH1count++)
        {
         temp=iHigh(NULL,PERIOD_H1,halfWave_3H1[criterionDirectionH1count]);
         if(result3>temp){result3=temp;}
        }
      if(result3<result1){criterionDirectionH1=1;criterionDirectionH1Check=1;}
     }

// Criterion Direction M15
   if(what_1HalfWaveMACDM15==0 && what_3HalfWaveMACDM15==0)
     {
      result1 = iHigh(NULL,PERIOD_M15,halfWave_1M15[0]);
      result3 = iHigh(NULL,PERIOD_M15,halfWave_3M15[0]);
      for(criterionDirectionM15count=0; criterionDirectionM15count<resize1M15; criterionDirectionM15count++)
        {
         temp=iHigh(NULL,PERIOD_M15,halfWave_1M15[criterionDirectionM15count]);
         if(result1<temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionM15count=0; criterionDirectionM15count<resize3M15; criterionDirectionM15count++)
        {
         temp=iHigh(NULL,PERIOD_M15,halfWave_3M15[criterionDirectionM15count]);
         if(result3<temp){result3=temp;}
        }
      if(result3>result1){criterionDirectionM15=0;criterionDirectionM15Check=1;}
     }

   if(what_1HalfWaveMACDM15==1 && what_3HalfWaveMACDM15==1)
     {
      result1 = iLow(NULL,PERIOD_M15,halfWave_1M15[0]);
      result3 = iLow(NULL,PERIOD_M15,halfWave_3M15[0]);
      for(criterionDirectionM15count=0; criterionDirectionM15count<resize1M15; criterionDirectionM15count++)
        {
         temp=iLow(NULL,PERIOD_M15,halfWave_1M15[criterionDirectionM15count]);
         if(result1>temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionM15count=0; criterionDirectionM15count<resize3M15; criterionDirectionM15count++)
        {
         temp=iHigh(NULL,PERIOD_M15,halfWave_3M15[criterionDirectionM15count]);
         if(result3>temp){result3=temp;}
        }
      if(result3<result1){criterionDirectionM15=1;criterionDirectionM15Check=1;}
     }

// Criterion Direction M5
   if(what_1HalfWaveMACDM5==0 && what_3HalfWaveMACDM5==0)
     {
      result1 = iHigh(NULL,PERIOD_M5,halfWave_1M5[0]);
      result3 = iHigh(NULL,PERIOD_M5,halfWave_3M5[0]);
      for(criterionDirectionM5count=0; criterionDirectionM5count<resize1M5; criterionDirectionM5count++)
        {
         temp=iHigh(NULL,PERIOD_M5,halfWave_1M5[criterionDirectionM5count]);
         if(result1<temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionM5count=0; criterionDirectionM5count<resize3M5; criterionDirectionM5count++)
        {
         temp=iHigh(NULL,PERIOD_M5,halfWave_3M5[criterionDirectionM5count]);
         if(result3<temp){result3=temp;}
        }
      if(result3>result1){criterionDirectionM5=0;criterionDirectionM5Check=1;}
     }

   if(what_1HalfWaveMACDM5==1 && what_3HalfWaveMACDM5==1)
     {
      result1 = iLow(NULL,PERIOD_M5,halfWave_1M5[0]);
      result3 = iLow(NULL,PERIOD_M5,halfWave_3M5[0]);
      for(criterionDirectionM5count=0; criterionDirectionM5count<resize1M5; criterionDirectionM5count++)
        {
         temp=iLow(NULL,PERIOD_M5,halfWave_1M5[criterionDirectionM5count]);
         if(result1>temp)
           {
            result1=temp;
           }
        }
      for(criterionDirectionM5count=0; criterionDirectionM5count<resize3M5; criterionDirectionM5count++)
        {
         temp=iHigh(NULL,PERIOD_M5,halfWave_3M5[criterionDirectionM5count]);
         if(result3>temp){result3=temp;}
        }
      if(result3<result1){criterionDirectionM5=1;criterionDirectionM5Check=1;}
     }

// Block 10 Не реализован, пока не нужєн? Рисуем критерии
//--- перерисуем график и подождем 1 секунду



   Macd_0_M1=iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
   Macd_1_M1=iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,1);


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

         iClose(NULL,PERIOD_M15,0)>iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_M15,0)>iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)>iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&
         iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0)<0 &&
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)>0 &&
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)<0 &&

         // цена выхода из ПолуВолны выше цены входа
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

         iClose(NULL,PERIOD_M15,0)<iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_M15,0)<iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_M15,133,0,MODE_SMA,PRICE_OPEN,0) &&
         iClose(NULL,PERIOD_H1,0)<iMA(NULL,PERIOD_M15,333,0,MODE_SMA,PRICE_OPEN,0) &&
         iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0)>0 &&
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0)<0 &&
         iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1)>0 &&

         // цена выхода из ПолуВолны выше цены входа
         isSell==true &&
         // при покупке OsMA М15 был ниже 0
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
