//+------------------------------------------------------------------+
//|                                                 TripleShield.mq4 |
//|                                  Copyright © 2018, Vasiliy Kylik |
//|                                           http://www.alpari.org/ |
//+------------------------------------------------------------------+

extern double TakeProfit = 1200;
extern double StopLoss = 10000;
extern double Lots = 0.01;
extern double TrailingStop = 10000;

/*
Обьекты:
Тик
ПолуВолна OsMa (у меня реализовано по простому - direction по двум тикам)
ПолуВолна MACD (у меня реализовано по простому - наличие критерия в ту или иную сторону)
Двойной критерий (у меня реализовано по простому - только сам факт наличия)
и допилен Stochastic по принципу OsMA
*/
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

   int
   i,z,y,x, j,k,m,p;

   int halfWave0H4 [];  int halfWave_1H4 [];  int halfWave_2H4 [];  int halfWave_3H4 [];
   int halfWave0H1 [];  int halfWave_1H1 [];  int halfWave_2H1 [];  int halfWave_3H1 [];
   int halfWave0M15 []; int halfWave_1M15 []; int halfWave_2M15 []; int halfWave_3M15 [];
   int halfWave0M5 [];  int halfWave_1M5 [];  int halfWave_2M5 [];  int halfWave_3M5 [];
   int halfWave0M1 [];  int halfWave_1M1 [];  int halfWave_2M1 [];  int halfWave_3M1 [];

   bool
   halfWavesCount,
   what0HalfWaveMACDH4, what_1HalfWaveMACDH4, what_2HalfWaveMACDH4, what_3HalfWaveMACDH4, what_4HalfWaveMACDH4,
   doubleCriterionChannelH4,
   what0HalfWaveMACDH1, what_1HalfWaveMACDH1, what_2HalfWaveMACDH1, what_3HalfWaveMACDH1, what_4HalfWaveMACDH1,
   doubleCriterionTrendH1,
   what0HalfWaveMACDM15, what_1HalfWaveMACDM15, what_2HalfWaveMACDM15, what_3HalfWaveMACDM15, what_4HalfWaveMACDM15,
   doubleCriterionEntryPointM15,
   what0HalfWaveMACDM5, what_1HalfWaveMACDM5, what_2HalfWaveMACDM5, what_3halfWaveMACDM5, what_4halfWaveMACDM5,
   doubleCriterionTheTimeOfEntryM5,
   what0HalfWaveMACDM1, what_1halfWaveMACDM1, what_2HalfWaveMACDM1, what_3HalfWaveMACDM1, what_4HalfWaveMACDM1,
   doubleCriterionM1,
   Stochastic_1H1, Stochastic0H1, Stochastic_1M15, Stochastic0M15, Stochastic_1M5, StochasticM05, Stochastic_1M1, Stochastic0M1,
   directionStochasticH1, directionStochasticM15, directionStochasticM5, directionStochasticM1,
   allStochastic,
   OsMA0H1, OsMA_1H1, OsMA015, OsMA_1M15, OsMA05, OsMA_1M5, OsMA01, OsMA_1M1,
   directionOsMAH1, directionOsMAM15, directionOsMAM5, directionOsMAM1,
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

   /*   The algorithm of the trend criteria detalization:
Mеханизм распознания первой ПВ:
Какие у меня критерии?
1)
У меня нет механизма распознавания 0-вой полуволны, У меня есть механизм распознавания критериев:
halfWavesCount =0;
1) берем MACD тикa i+1 и i+2, соответствующего таймфрейма
а) если они выше нуля - то what0HalfWaveMACDH4 ==0
б) если они ниже нуля - то what0HalfWaveMACDH4 ==1
в) в случае - если тик i+1 выше 0 и i+2 ниже 0 отдельные случаи ExceptionCases?...
в1) в случае - если тик i+1 ниже 0 и i+2 выше 0 отдельные случаи ExceptionCases?...
в2) в случае - если тик i+1 равен 0 или тик i+2 равен 0 отдельные случаи ExceptionCases?...
г) что делать с тиком 0? отдельные случаи ExceptionCases?... Точность MODE_MAIN - 4 символа после запятой, можно провести тестирование (поиск тиков по истории на всех таймфреймах - но я не видел в реальной жизни то есть в режиме PRICE_CLOSE значений 0.0000, кончечно такое значение абсолютно реально)
Входим в цикл, и с тех же значений (то есть, стартового(1) значения), далее итерируем i, получаем значение (не для 0, начинаем с 11), а для 1,2,3,4,5,6,7,8,9

1) если halfWavesCount ==0 && what0HalfWaveMACDH4==0 И тик i+3<0 И тик i+4<0 то (значит произошел переход) halfWavesCount ++ (будет 1); (значит можно обращаться к what_1HalfWaveMACDH4) И what_1HalfWaveMACDH4==1; И (складываем в массив тики ПолуВолны)
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
2) если halfWavesCount ==1 (итерация, основное условие) && what_1HalfWaveMACDH4==1 (переворротное условие) И тик i+3>0 И тик i+4>0 то (значит произошел переход).
halfWavesCount ++ (будет 2); (значит можно обращаться к what_2HalfWaveMACDH4) what_1HalfWaveMACDH4==2 (! здесь bool) и складываем в массив тики ПВ
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
3) если halfWavesCount ==2 && what_2HalfWaveMACDH4==0 (тк halfWavesCount ==2 то переменной what_2HalfWaveMACDH4 уже присвоено боевое значение) И тик i+3<0 И тик i+4<0 (значит произошел переход)
halfWavesCount ++ (будет 3); what_2HalfWaveMACDH4==1
какие тики нужно сложить? от k+1 до i-2
for(int m=k+1;m>i-2;m++){
int y=0;
ArrayResize(halfWave_2H4,(i-2)-m);
halfWave_2H4[y]=m;
y++;
}
3а)переворачиваем условия для противоположной волны
4) если halfWavesCount ==3 && what_3HalfWaveMACDH4==1 И тик i+3>0 И тик i+4>0
то halfWavesCount ++ (будет 4); what_4HalfWaveMACDH4==0
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
  halfWavesCount =0;
  if (iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,1)>0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,2)>0){
    what0HalfWaveMACDH4 ==0;}
  else if (iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,1)<0 && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,2)<0){
    what0HalfWaveMACDH4 ==1;}
  else Print("   ERROR (Catched 0) Non Double Zero PERIOD_H4 ", halfWavesCount);
  for (i = 1;halfWavesCount>=4;i++){
    if (halfWavesCount==0 && what0HalfWaveMACDH4==0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)<0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)<0)
        {
            halfWavesCount++;
            what_1HalfWaveMACDH4==1;
            j=1;
            ArrayResize(halfWave0H4,(i-2)-j);
            for(j; j>i-2; j++){
                halfWave0H4[j-1]=j;
            }
            Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
    if (halfWavesCount==0 && what0HalfWaveMACDH4==1
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)>0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)>0)
        {
            halfWavesCount++;
            what_1HalfWaveMACDH4==0;
            j=1;
            ArrayResize(halfWave0H4,(i-2)-j);
            for(j; j>i-2; j++){
                halfWave0H4[j-1]=j;
            }
            Print("halfWave0H4", "ArrayResize(halfWave0H4,(i-2)-j); ", (i-2)-j);
        }
    if (halfWavesCount==1 && what_1HalfWaveMACDH4==1
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)>0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)>0)
        {
            halfWavesCount++;
            what_2HalfWaveMACDH4==0;
            k=j+1;
            ArrayResize(halfWave_1H4,(i-2)-k);
            for(k; k>i-2; k++){
                z=0;
                halfWave_1H4[z]=k;
                z++;
            }
            Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
    if (halfWavesCount==1 && what_1HalfWaveMACDH4==0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)<0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)<0)
        {
            halfWavesCount++;
            what_2HalfWaveMACDH4==1;
            k=j+1;
            ArrayResize(halfWave_1H4,(i-2)-k);
            for(k; k>i-2; k++){
                z=0;
                halfWave_1H4[z]=k;
                z++;
            }
            Print("halfWave_1H4", "ArrayResize(halfWave_1H4,(i-2)-k) ", (i-2)-k);
        }
    if (halfWavesCount==2 && what_2HalfWaveMACDH4==0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)<0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)<0)
        {
            halfWavesCount++;
            what_3HalfWaveMACDH4==1;
            m=k+1;
            ArrayResize(halfWave_2H4,(i-2)-m);
            for(m; m>i-2; m++){
                y=0;
                halfWave_2H4[y]=m;
                y++;
            }
            Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m); ", (i-2)-j);
        }
    if (halfWavesCount==2 && what_2HalfWaveMACDH4==1
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)>0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)>0)
        {
            halfWavesCount++;
            what_3HalfWaveMACDH4==0;
            m=k+1;
            ArrayResize(halfWave_2H4,(i-2)-m);
            for(m; m>i-2; m++){
                    y=0;
                    halfWave_2H4[y]=m;
                    y++;
            }
            Print("halfWave_2H4", "ArrayResize(halfWave_2H4,(i-2)-m) ", (i-2)-m);
        }
    if (halfWavesCount==3 && what_3HalfWaveMACDH4==0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)>0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)>0)
        {
            halfWavesCount++;
            what_4HalfWaveMACDH4==0;
            p=m+1;
            ArrayResize(halfWave_1H4,(i-2)-p);
            for(p; p>i-2; p++){
                x=0;
                halfWave_3H4[x]=p;
                x++;
            }
            Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
    if (halfWavesCount==3 && what_3HalfWaveMACDH4==1
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+3)<0
        && iMACD(NULL,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,i+4)<0)
        {
            halfWavesCount++;
            what_4HalfWaveMACDH4==1;
            p=m+1;
            ArrayResize(halfWave_1H4,(i-2)-p);
            for(p; p>i-2; p++){
                x=0;
                halfWave_3H4[x]=p;
                x++;
            }
            Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
  }





/*   The algorithm of the trend criteria definition:
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

   if (Stochastic_1H1 <Stochastic0H1)  {directionStochasticH1== 0;}
   if (Stochastic_1M15<Stochastic0M15) {directionStochasticM15==0;}
   if (Stochastic_1M5 <StochasticM05)  {directionStochasticM5== 0;}
   if (Stochastic_1M1 <Stochastic0M1)  {directionStochasticM1== 0;}
   if (Stochastic_1H1 >Stochastic0H1)  {directionStochasticH1== 1;}
   if (Stochastic_1M15>Stochastic0M15) {directionStochasticM15==1;}
   if (Stochastic_1M5 >StochasticM05)  {directionStochasticM5== 1;}
   if (Stochastic_1M1 >Stochastic0M1)  {directionStochasticM1== 1;}

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
if (what_1HalfWaveMACDH4 ==0 && what_3HalfWaveMACDH4==0) {doubleCriterionChannelH4 = 0;}
if (what_1HalfWaveMACDH4 ==1 && what_3HalfWaveMACDH4==1) {doubleCriterionChannelH4 = 1;}
if (what_1HalfWaveMACDH1 ==0 && what_3HalfWaveMACDH1==0) {doubleCriterionTrendH1 = 0;}
if (what_1HalfWaveMACDH1 ==1 && what_3HalfWaveMACDH1==1) {doubleCriterionTrendH1 = 1;}
if (what_1HalfWaveMACDM15==0 && what_3HalfWaveMACDM15==0) {doubleCriterionEntryPointM15 = 0;}
if (what_1HalfWaveMACDM15==1 && what_3HalfWaveMACDM15==1) {doubleCriterionEntryPointM15 = 1;}
if (what_1HalfWaveMACDM5 ==0 && what_3halfWaveMACDM5==0) {doubleCriterionTheTimeOfEntryM5 = 0;}
if (what_1HalfWaveMACDM5 ==1 && what_3halfWaveMACDM5==1) {doubleCriterionTheTimeOfEntryM5 = 1;}
if (what_1halfWaveMACDM1 ==0 && what_3HalfWaveMACDM1==0) {doubleCriterionM1 = 0;}
if (what_1halfWaveMACDM1 ==1 && what_3HalfWaveMACDM1==1) {doubleCriterionM1 = 1;}

   if (Stochastic_1H1 <Stochastic0H1)  {directionStochasticH1== 0;}
   if (Stochastic_1M15<Stochastic0M15) {directionStochasticM15==0;}
   if (Stochastic_1M5 <StochasticM05)  {directionStochasticM5== 0;}
   if (Stochastic_1M1 <Stochastic0M1)  {directionStochasticM1== 0;}
   if (Stochastic_1H1 >Stochastic0H1)  {directionStochasticH1== 1;}
   if (Stochastic_1M15>Stochastic0M15) {directionStochasticM15==1;}
   if (Stochastic_1M5 >StochasticM05)  {directionStochasticM5== 1;}
   if (Stochastic_1M1 >Stochastic0M1)  {directionStochasticM1== 1;}

if(directionStochasticH1 == 0 && directionStochasticM15== 0 && directionStochasticM5 == 0 && directionStochasticM1 == 0) {allStochastic ==0;}
if(directionStochasticH1 == 1 && directionStochasticM15== 1 && directionStochasticM5 == 1 && directionStochasticM1 == 1) {allStochastic ==1;}

   if (OsMA_1H1>OsMA0H1)  {directionOsMAH1== 0;}
   if (OsMA_1M15>OsMA015) {directionOsMAM15==0;}
   if (OsMA_1M5>OsMA05)   {directionOsMAM5== 0;}
   if (OsMA_1M1>OsMA01)   {directionOsMAM1== 0;}
   if (OsMA_1H1<OsMA0H1)  {directionOsMAH1== 1;}
   if (OsMA_1M15<OsMA015) {directionOsMAM15==1;}
   if (OsMA_1M5<OsMA05)   {directionOsMAM5== 1;}
   if (OsMA_1M1<OsMA01)   {directionOsMAM1== 1;}

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
            для покупки если (doubleCriterionTrendH1 == 0 И doubleCriterionEntryPointM15 == 0 И doubleCriterionTheTimeOfEntryM5 == 0 И doubleCriterionM1==0 И allOsMA==0 И allStochastic == 0) открыть покупку
            */
            buy ==1 &&
            // Criterion for buy position according to the TS
            doubleCriterionTrendH1 == 0 && doubleCriterionEntryPointM15 == 0 && doubleCriterionTheTimeOfEntryM5 == 0 && doubleCriterionM1==0 && allOsMA==0 && allStochastic == 0
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
           для продажи если (doubleCriterionTrendH1 == 1 И doubleCriterionEntryPointM15 == 1 И doubleCriterionTheTimeOfEntryM5 == 1 И doubleCriterionM1==1 И allOsMA==1 И allStochastic == 1) открыть продажу
           */
           sell ==1 &&
           // Criterion for sell position according to the TS
           doubleCriterionTrendH1 == 1 && doubleCriterionEntryPointM15 == 1 && doubleCriterionTheTimeOfEntryM5 == 1 && doubleCriterionM1==1 && allOsMA==1 && allStochastic == 1
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
   критерий закрытия (предварительно двойной M15)

   Алгоритм ведения Позиции:
   критерий БезУбытка (взять из Безубытка - реализован в Трейлинг условии реализацией "Посвечный Безубыток")
   критерий ведения (двойной M5)*/

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
