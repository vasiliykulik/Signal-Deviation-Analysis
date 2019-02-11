//+------------------------------------------------------------------+
//|                                                   FiboModule.mq4 |
//|                                                    Vasiliy Kulik |
//|                                                       alpari.com |
//+------------------------------------------------------------------+
#property copyright "2019, Vasiliy Kulik"
#property link      "http://www.mql5.com"
#property version     "1.00"
#property description "This Indicator is help for Fibonacci Retracement."
#property description "And Trend Lines"
#property icon          "\\Images\\words-0040_60_x_60.ico";
#property strict

#property indicator_chart_window
ENUM_TIMEFRAMES periodGlobal=PERIOD_CURRENT;
double firstMinGlobal=0.00000000,secondMinGlobal=0.00000000,firstMaxGlobal=0.00000000,secondMaxGlobal=0.00000000;
extern int History=400;
extern double FiboLevel1=0.000;
extern double FiboLevel2=0.236;
extern double FiboLevel3=0.382;
extern double FiboLevel4=0.500;
extern double FiboLevel5=0.618;
extern double FiboLevel6=1.000;
extern double FiboLevel7=1.618;
extern double FiboLevel8=2.618;
extern double FiboLevel9=4.236;
extern double FiboLevel10=0.764;
int firstPointTick=0,secondPointTick=0;
int localFirstPointTick = 0, localSecondPointTick = 0;
bool lowAndHighUpdate=false;
double globalHigh,globalLow;
int thirdPointTick=0, fourthPointTick=0;
color levelColor;


string Copyright="Vasiliy Kulik";
string MPrefix="VK";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   ClearObjects();
   Comment("");
//----


   DL("001",Copyright,5,20,Gold,"Arial",10,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ClearObjects();
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   localFirstPointTick = firstPointTick;
   localSecondPointTick = secondPointTick;

   lowAndHighUpdate=nonSymm();

 //  bool isGlobalTicksChanged = localFirstPointTick == firstPointTick && localSecondPointTick == secondPointTick;
 //  if(!isGlobalTicksChanged){}

   datetime highTime = Time[secondPointTick];
   datetime lowTime  = Time[firstPointTick];
   datetime thirdTime = Time[thirdPointTick];
   datetime fourthTime  = Time[fourthPointTick];

//    Print("datetime buffer_Time[secondPointTick] = ", buffer_Time_Int[secondPointTick], "buffer_Time[firstPointTick]", buffer_Time_Int[firstPointTick]);
ClearObjects(); //
    if(High[secondPointTick]>Low[firstPointTick])// Было  High и Low соответственно. 10.12.2018 combining two clauses - no. 12.10.2018  Case  when need High and Low
    // 14.12.2018 Back to High and Low accordingly, purpose: to use this artefact after proper check
     {
      WindowRedraw();
      ObjectCreate(MPrefix+"FIBO_MOD",OBJ_FIBO,0,highTime,High[secondPointTick],lowTime,Low[firstPointTick]);
      ObjectCreate(MPrefix+"TREND_LINE",OBJ_TREND,0,fourthTime,High[fourthPointTick],highTime,High[secondPointTick]);
      ObjectCreate(MPrefix+"TREND_LINE1",OBJ_TREND,0,thirdTime,Low[thirdPointTick],lowTime,Low[firstPointTick]);
      levelColor=Green;
/*      if(){PERIOD_H4 {levelColor = MediumOrchid;}}
      if(){PERIOD_H1 {levelColor = Blue;}}
      if(){PERIOD_M15 {levelColor = ForestGreen;}}
      if(){PERIOD_M5 {levelColor = Goldenrod;}}*/
     }
     // else
     // if(Low[secondPointTick]<High[firstPointTick])
   if(Low[secondPointTick]<High[firstPointTick])
     {
      WindowRedraw();
      ClearObjects();
      //
      ObjectCreate(MPrefix+"FIBO_MOD",OBJ_FIBO,0,highTime,Low[secondPointTick],lowTime,High[firstPointTick]);
      ObjectCreate(MPrefix+"TREND_LINE",OBJ_TREND,0,fourthTime,Low[fourthPointTick],highTime,Low[secondPointTick]);
      ObjectCreate(MPrefix+"TREND_LINE1",OBJ_TREND,0,thirdTime,High[thirdPointTick],lowTime,High[firstPointTick]);
      levelColor=Red;
     }

   double fiboPrice1=ObjectGet(MPrefix+"FIBO_MOD",OBJPROP_PRICE1);
   double fiboPrice2=ObjectGet(MPrefix+"FIBO_MOD",OBJPROP_PRICE2);

   double fiboPriceDiff=fiboPrice2-fiboPrice1;
   string fiboValue0=DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel1,Digits);
   string fiboValue23 = DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel2,Digits);
   string fiboValue38 = DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel3,Digits);
   string fiboValue50 = DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel4,Digits);
   string fiboValue61 = DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel5,Digits);
   string fiboValue100= DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel6,Digits);
   string fiboValue161= DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel7,Digits);
   string fiboValue261= DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel8,Digits);
   string fiboValue423= DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel9,Digits);
   string fiboValue76=DoubleToStr(fiboPrice2-fiboPriceDiff*FiboLevel10,Digits);

   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIBOLEVELS,10);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+0,FiboLevel1);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+1,FiboLevel2);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+2,FiboLevel3);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+3,FiboLevel4);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+4,FiboLevel5);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+5,FiboLevel6);

   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+6,FiboLevel7);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+7,FiboLevel8);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+8,FiboLevel9);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_FIRSTLEVEL+9,FiboLevel10);

   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_LEVELCOLOR,levelColor);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_LEVELWIDTH,2);
   ObjectSet(MPrefix+"FIBO_MOD",OBJPROP_LEVELSTYLE,STYLE_SOLID);

   // TrendLine
   ObjectSet(MPrefix+"TREND_LINE",OBJPROP_COLOR,levelColor);
   ObjectSet(MPrefix+"TREND_LINE",OBJPROP_STYLE,0);
   ObjectSet(MPrefix+"TREND_LINE",OBJPROP_WIDTH,2);
   ObjectSet(MPrefix+"TREND_LINE1",OBJPROP_COLOR,levelColor);
   ObjectSet(MPrefix+"TREND_LINE1",OBJPROP_STYLE,0);
   ObjectSet(MPrefix+"TREND_LINE1",OBJPROP_WIDTH,2);


   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",0,fiboValue0+" --> "+DoubleToStr(FiboLevel1*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",1,fiboValue23+" --> "+DoubleToStr(FiboLevel2*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",2,fiboValue38+" --> "+DoubleToStr(FiboLevel3*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",3,fiboValue50+" --> "+DoubleToStr(FiboLevel4*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",4,fiboValue61+" --> "+DoubleToStr(FiboLevel5*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",5,fiboValue100+" --> "+DoubleToStr(FiboLevel6*100,1)+"%");

   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",6,fiboValue161+" --> "+DoubleToStr(FiboLevel7*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",7,fiboValue261+" --> "+DoubleToStr(FiboLevel8*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",8,fiboValue423+" --> "+DoubleToStr(FiboLevel9*100,1)+"%");
   ObjectSetFiboDescription(MPrefix+"FIBO_MOD",9,fiboValue76+" --> "+DoubleToStr(FiboLevel10*100,1)+"%");

//   ObjectSetText(MPrefix+"FIBO_MOD","Hello world!",18,"Arial",levelColor);
//   ObjectSetFiboDescription("MyFiboObject",2,"Second line");
   WindowRedraw();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| DL function                                                      |
//+------------------------------------------------------------------+
void DL(string label,string text,int x,int y,color clr,string FontName="Arial",int FontSize=12,int typeCorner=1)
  {
   string labelIndicator=MPrefix+label;
   if(ObjectFind(labelIndicator)==-1)
     {
      ObjectCreate(labelIndicator,OBJ_LABEL,0,0,0);
     }

   ObjectSet(labelIndicator,OBJPROP_CORNER,typeCorner);
   ObjectSet(labelIndicator,OBJPROP_XDISTANCE,x);
   ObjectSet(labelIndicator,OBJPROP_YDISTANCE,y);
   ObjectSetText(labelIndicator,text,FontSize,FontName,clr);

  }
//+------------------------------------------------------------------+
//| ClearObjects function                                            |
//+------------------------------------------------------------------+
void ClearObjects()
  {
   for(int i=0;i<ObjectsTotal();i++)
             if(StringFind(ObjectName(i),MPrefix)==0) { ObjectDelete(ObjectName(i)); i--; }
  }
//+------------------------------------------------------------------+

// ---------------------------------------------------------------------------------------------------------------------
bool nonSymm()
  {
   int countHalfWaves=0;
   int begin=0;
   double Macd_1H4=0;// нулевой тик
   double Macd_2H4=0;// следующий тик
   double MacdIplus3H4,MacdIplus4H4;// следующий тик, пока 0 while работает
   double priceForMinMax;
   bool what0HalfWaveMACDH4,what_1HalfWaveMACDH4,what_2HalfWaveMACDH4,what_3HalfWaveMACDH4,what_4HalfWaveMACDH4,what_5HalfWaveMACDH4;
   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];  int halfWave_4H4[];
   int zz,i,z,y,j,k,m,p,x,q,w,resize0H4,resize1H4,resize2H4,resize3H4,resize4H4;
   double firstMinLocalNonSymmetric=0.00000000,secondMinLocalNonSymmetric=0.00000000,firstMaxLocalNonSymmetric=0.00000000,secondMaxLocalNonSymmetric=0.00000000;
   int localLowTimeCurrent=0,localHighTimeCurrent=0;
   bool isFirstMin=false,isSecondMin=false,isFirstMax=false,isSecondMax=false;
   lowAndHighUpdate=false;
   int local3TimeCurrent=0,local4TimeCurrent=0;

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
   bool isSmaller = isMACD1SmallerThanZero && isMACD2SmallerThanZero;
   bool isBigger = isMACD1BiggerThanZero && isMACD2BiggerThanZero ;
   bool isEqualToZero = isMACD1EqualZero && isMACD2EqualZero;
 //  Print("isSmaller = ", isSmaller,"isBigger = ", isBigger,"isEqualToZero = ", isEqualToZero);
   bool isMACDReady = isSmaller || isBigger || isEqualToZero;
//   Print("isMACDReady");

//   Print("657, isMACDReady = ", isMACDReady);
   for(begin = 0;isMACDReady; begin++)
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
    isSmaller = isMACD1SmallerThanZero && isMACD2SmallerThanZero;
    isBigger = isMACD1BiggerThanZero && isMACD2BiggerThanZero ;
    isEqualToZero = isMACD1EqualZero && isMACD2EqualZero;
    isMACDReady = isSmaller || isBigger || isEqualToZero;
//    Print("658, isMACDReady = ", isMACDReady);
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

      if(countHalfWaves==3 && what_3HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
         //Print("C3W1, wait for secondMinLocalNonSymmetric");
         countHalfWaves++;
         what_4HalfWaveMACDH4=0;
         p=m+1;
         resize3H4=(i+2)-p;
         ArrayResize(halfWave_3H4,resize3H4);
         x=0;
         priceForMinMax=iLow(NULL,periodGlobal,p);
         secondMinLocalNonSymmetric=priceForMinMax;
         local3TimeCurrent = p;

         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            priceForMinMax = iLow(NULL,periodGlobal,p);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
            if(priceForMinMax<secondMinLocalNonSymmetric)
              {
               local3TimeCurrent = p;
               secondMinLocalNonSymmetric=priceForMinMax;
               isSecondMin=true;
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
         priceForMinMax=iHigh(NULL,periodGlobal,p);
         secondMaxLocalNonSymmetric=priceForMinMax;
         local3TimeCurrent = p;
         for(p; p<i+2; p++)
           {
            halfWave_3H4[x]=p;
            priceForMinMax=iHigh(NULL,periodGlobal,p);
            // Print("NonSymmetric, p, x = ",p," ", x, " secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
            if(priceForMinMax>secondMaxLocalNonSymmetric)
              {
               local3TimeCurrent = p;
               secondMaxLocalNonSymmetric=priceForMinMax;
               isSecondMax=true;
              }

            x++;
           }
         //Print("secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
         // // Print("halfWave_3H4", "ArrayResize(halfWave_3H4,(i-2)-p) ", (i-2)-p);
        }
      if(countHalfWaves==4 && what_4HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0)
        {
//         Print("C4W0, wait for secondMaxLocalNonSymmetric");
         countHalfWaves++;
         what_5HalfWaveMACDH4=1;
         q=p+1;
         resize4H4=(i+2)-q;
         ArrayResize(halfWave_4H4,resize4H4);
         w=0;
         priceForMinMax=iHigh(NULL,periodGlobal,q);
         secondMaxLocalNonSymmetric=priceForMinMax;
         local4TimeCurrent = q;
         for(q; q<i+2; q++)
           {
            halfWave_4H4[w]=q;
            priceForMinMax = iHigh(NULL,periodGlobal,q);
//             Print("NonSymmetric, p, x = ",p," ", x, " secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
            if(priceForMinMax>secondMaxLocalNonSymmetric)
              {
               local4TimeCurrent = q;
               secondMaxLocalNonSymmetric=priceForMinMax;
               isSecondMax=true;
              }

            w++;
           }
//         Print("secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
        }
      if(countHalfWaves==4 && what_4HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0)
        {
//         Print("C4W1, wait for secondMinLocalNonSymmetric");
         countHalfWaves++;
         what_5HalfWaveMACDH4=0;
         q=p+1;
         resize4H4=(i+2)-q;
         ArrayResize(halfWave_4H4,resize4H4);
         w=0;
         priceForMinMax=iLow(NULL,periodGlobal,q);
         secondMinLocalNonSymmetric=priceForMinMax;
         local4TimeCurrent = q;

         for(q; q<i+2; q++)
           {
            halfWave_4H4[w]=q;
            priceForMinMax = iLow(NULL,periodGlobal,q);
 //            Print("NonSymmetric, p, x = ",p," ", x, " secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
            if(priceForMinMax<secondMinLocalNonSymmetric)
              {
               local4TimeCurrent = q;
               secondMinLocalNonSymmetric=priceForMinMax;
               isSecondMin=true;
              }

            w++;
           }
//         Print("secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
        }

     }

//   Print("return nonSymm localHighTimeCurrent = ",localHighTimeCurrent,"localLowTimeCurrent",localLowTimeCurrent);
   firstPointTick=localLowTimeCurrent;
   secondPointTick=localHighTimeCurrent;
   thirdPointTick = local3TimeCurrent;
   fourthPointTick = local4TimeCurrent;
//   Print("return nonSymm secondPointTick = ",secondPointTick,"firstPointTick",firstPointTick);
   lowAndHighUpdate=true;
   Sleep(3333);
   return lowAndHighUpdate;
  }
//+------------------------------------------------------------------+
