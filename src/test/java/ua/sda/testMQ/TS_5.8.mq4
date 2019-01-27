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
double thirdMinGlobal=0.00000000,thirdMaxGlobal=0.00000000;
bool isC5Min = false; bool isC5Max = false;
bool isC6Min = false; bool isC6Max = false;

double fourthMinGlobal = 0.00000000, fourthMaxGlobal = 0.00000000;
double fifthMinGlobal  = 0.00000000, fifthMaxGlobal  = 0.00000000;
double sixthMinGlobal  = 0.00000000, sixthMaxGlobal  = 0.00000000;


ENUM_TIMEFRAMES periodGlobal;
int firstPointTick=0,secondPointTick=0;
int localFirstPointTick=0,localSecondPointTick=0;
 string messageGlobalPERIOD_M1 ;
 string messageGlobalPERIOD_M5 ;
 string messageGlobalPERIOD_M15;
 string messageGlobalPERIOD_H1 ;
 string messageGlobalPERIOD_H4 ;
 string messageGlobalPERIOD_D1 ;
 int countFigures;

 ENUM_TIMEFRAMES timeFrames[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_H1,PERIOD_H4,PERIOD_D1};
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
   messageGlobalPERIOD_M1 ="nothing";
   messageGlobalPERIOD_M5 ="nothing";
   messageGlobalPERIOD_M15="nothing";
   messageGlobalPERIOD_H1 ="nothing";
   messageGlobalPERIOD_H4 ="nothing";
   messageGlobalPERIOD_D1 ="nothing" ;
   countFigures = 0;


   bool lowAndHighUpdateViaNonSymmTick=false;
   bool lowAndHighUpdateViaNonSymm = false;
   bool lowAndHighUpdateViaNonSymmForTrailing = false;

   bool isFiboModuleGreenState_M1=false, isFiboModuleGreenState_M5=false,isFiboModuleGreenState_M15=false,isFiboModuleGreenState_H1=false,isFiboModuleGreenState_H4=false,isFiboModuleGreenState_D1=false;
   bool isFiboModuleRedState_M1=false,isFiboModuleRedState_M5=false,isFiboModuleRedState_M15=false,isFiboModuleRedState_H1=false,isFiboModuleRedState_H4=false,isFiboModuleRedState_D1=false;
   bool isFiboModuleGreenLevel_100_IsPassed_M1=false,isFiboModuleGreenLevel_100_IsPassed_M5=false,isFiboModuleGreenLevel_100_IsPassed_M15=false,isFiboModuleGreenLevel_100_IsPassed_H1=false,isFiboModuleGreenLevel_100_IsPassed_H4=false,isFiboModuleGreenLevel_100_IsPassed_D1=false;
   bool isFiboModuleRedLevel_100_IsPassed_M1=false,isFiboModuleRedLevel_100_IsPassed_M5=false,isFiboModuleRedLevel_100_IsPassed_M15=false,isFiboModuleRedLevel_100_IsPassed_H1=false,isFiboModuleRedLevel_100_IsPassed_H4=false,isFiboModuleRedLevel_100_IsPassed_D1=false;

   int halfWave0H4[];  int halfWave_1H4[];  int halfWave_2H4[];  int halfWave_3H4[];
   int buyWeight=0,sellWeight=0;
   total=OrdersTotal();


/*      мы убираем
      блок условий по пересечению MACD + MA 83
      блок Считаем Веса
      блок Проставляем Флаги*/
// FiboMod Analyzing Block
      for(int i=0; i<=ArraySize(timeFrames)-1;i++) // iterate through TimeFrames
        {
         //        Print("i = ", i, " ArraySize(timeFrames) = ", ArraySize(timeFrames));
         //        Print("periodGlobal = ", periodGlobal, " timeFrames[i] = ", timeFrames[i]);
         periodGlobal=timeFrames[i]; // set TimeFrame global value for nonSymmTick()
         lowAndHighUpdateViaNonSymmTick=nonSymmTick(); // set values to firstPointTick and secondPointTick global variables

         // change High[secondPointTick]>Low[firstPointTick]
         // to iHigh(NULL, timeFrames[i], secondPointTick) > iLow(NULL, timeFrames[i], firstPointTick) ie high and low
         double highGreen = iHigh(NULL, timeFrames[i], secondPointTick);
         double lowGreen =  iLow(NULL, timeFrames[i], firstPointTick);
         if(highGreen>lowGreen) // if green
           {
            if(timeFrames[i]==PERIOD_M1){isFiboModuleGreenState_M1=true;}
            if(timeFrames[i]==PERIOD_M5){isFiboModuleGreenState_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isFiboModuleGreenState_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isFiboModuleGreenState_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isFiboModuleGreenState_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isFiboModuleGreenState_D1 = true;}
            // if price higher than Fibo 100 on current TimeFrame
            // but i need
            // not defined cyclePeriod; cyclePeriod equals timeFrames[i]; ie TimeFrame; for example PERIOD_M5
         // change High[secondPointTick]>Low[firstPointTick]
         // to iHigh(NULL, timeFrames[i], secondPointTick) > iLow(NULL, timeFrames[i], firstPointTick) ie high and low

            if(iClose(NULL,timeFrames[i],0)>highGreen && iClose(NULL,timeFrames[i],1)<highGreen)
              {
               if(timeFrames[i]==PERIOD_M1){isFiboModuleGreenLevel_100_IsPassed_M1=true;}
               if(timeFrames[i]==PERIOD_M5){isFiboModuleGreenLevel_100_IsPassed_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isFiboModuleGreenLevel_100_IsPassed_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isFiboModuleGreenLevel_100_IsPassed_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isFiboModuleGreenLevel_100_IsPassed_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isFiboModuleGreenLevel_100_IsPassed_D1 = true;}
              }
           }

         // change Low[secondPointTick]<High[firstPointTick]
         // to iLow(NULL, timeFrames[i], secondPointTick) < iHigh(NULL, timeFrames[i], firstPointTick) >  ie high and low

         double lowRed =  iLow(NULL, timeFrames[i], secondPointTick);
         double highRed = iHigh(NULL, timeFrames[i], firstPointTick);


         if(lowRed<highRed) // red
           {
            if(timeFrames[i]==PERIOD_M1){isFiboModuleRedState_M5=true;}
            if(timeFrames[i]==PERIOD_M5){isFiboModuleRedState_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isFiboModuleRedState_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isFiboModuleRedState_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isFiboModuleRedState_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isFiboModuleRedState_D1 = true;}
            if(iClose(NULL,timeFrames[i],0)<lowRed && iClose(NULL,timeFrames[i],1)>lowRed) // not defined cyclePeriod - now defined
              {
               if(timeFrames[i]==PERIOD_M1){isFiboModuleRedLevel_100_IsPassed_M5=true;}
               if(timeFrames[i]==PERIOD_M5){isFiboModuleRedLevel_100_IsPassed_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isFiboModuleRedLevel_100_IsPassed_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isFiboModuleRedLevel_100_IsPassed_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isFiboModuleRedLevel_100_IsPassed_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isFiboModuleRedLevel_100_IsPassed_D1 = true;}
              }
           }
        }// end of TimeFrames for loop for FiboModule State and IsPassed flag
// First layer Analyzing Block plus Figures Analyzing Block



      bool isTrendBull_M1 = false, isTrendBull_M5 = false, isTrendBull_M15 = false, isTrendBull_H1 = false, isTrendBull_H4 = false, isTrendBull_D1 = false;
      bool isTrendBear_M1 = false, isTrendBear_M5 = false, isTrendBear_M15 = false, isTrendBear_H1 = false, isTrendBear_H4 = false, isTrendBear_D1 = false;

      bool isPriceConvergence_M1=false, isPriceConvergence_M5=false, isPriceConvergence_M15=false,isPriceConvergence_H1=false,isPriceConvergence_H4=false,isPriceConvergence_D1=false;
      bool isPriceDivergence_M1=false,  isPriceDivergence_M5=false,  isPriceDivergence_M15=false,isPriceDivergence_H1=false,isPriceDivergence_H4=false,isPriceDivergence_D1=false;

        bool isDivergenceMACDUp_M1=false,        isDivergenceMACDUp_M5=false,     isDivergenceMACDUp_M15=false,isDivergenceMACDUp_H1=false,isDivergenceMACDUp_H4=false,isDivergenceMACDUp_D1=false;
        bool isDivergenceMACDDown_M1=false,      isDivergenceMACDDown_M5=false,   isDivergenceMACDDown_M15=false,isDivergenceMACDDown_H1=false,isDivergenceMACDDown_H4=false,isDivergenceMACDDown_D1=false;

        bool isDivergenceMACDForPriceConv_M1=false,       isDivergenceMACDForPriceConv_M5=false,   isDivergenceMACDForPriceConv_M15=false,isDivergenceMACDForPriceConv_H1=false,isDivergenceMACDForPriceConv_H4=false,isDivergenceMACDForPriceConv_D1=false;
        bool isDivergenceMACDForPriceDiv_M1=false,        isDivergenceMACDForPriceDiv_M5=false,    isDivergenceMACDForPriceDiv_M15=false,isDivergenceMACDForPriceDiv_H1=false,isDivergenceMACDForPriceDiv_H4=false,isDivergenceMACDForPriceDiv_D1=false;

      bool figure1FlagUpContinueUp_M1  =                false;         bool figure1FlagUpContinueUp_M5  = false;        bool figure1FlagUpContinueUp_M15 = false;         bool figure1FlagUpContinueUp_H1  = false;         bool figure1FlagUpContinueUp_H4  = false;         bool figure1FlagUpContinueUp_D1  = false;
      bool figure2FlagDownContinueDown_M1  =            false;     bool figure2FlagDownContinueDown_M5  = false;      bool figure2FlagDownContinueDown_M15 = false;       bool figure2FlagDownContinueDown_H1  = false;       bool figure2FlagDownContinueDown_H4  = false;       bool figure2FlagDownContinueDown_D1  = false;
      bool figure1_1FlagUpContinueAfterDecliningUp_M1  =                false;         bool figure1_1FlagUpContinueAfterDecliningUp_M5  = false;        bool figure1_1FlagUpContinueAfterDecliningUp_M15 = false;         bool figure1_1FlagUpContinueAfterDecliningUp_H1  = false;         bool figure1_1FlagUpContinueAfterDecliningUp_H4  = false;         bool figure1_1FlagUpContinueAfterDecliningUp_D1  = false;
      bool figure2_1FlagDownContinueAfterDecreaseDown_M1  =            false;     bool figure2_1FlagDownContinueAfterDecreaseDown_M5  = false;      bool figure2_1FlagDownContinueAfterDecreaseDown_M15 = false;       bool figure2_1FlagDownContinueAfterDecreaseDown_H1  = false;       bool figure2_1FlagDownContinueAfterDecreaseDown_H4  = false;       bool figure2_1FlagDownContinueAfterDecreaseDown_D1  = false;
      bool figure3TripleUp_M1  =                        false;                 bool figure3TripleUp_M5  = false;       bool figure3TripleUp_M15 = false;        bool figure3TripleUp_H1  = false;        bool figure3TripleUp_H4  = false;        bool figure3TripleUp_D1  = false;
      bool figure4TripleDown_M1  =                      false;               bool figure4TripleDown_M5  = false;       bool figure4TripleDown_M15 = false;        bool figure4TripleDown_H1  = false;        bool figure4TripleDown_H4  = false;        bool figure4TripleDown_D1  = false;
      bool figure5PennantUp_M1  =                       false;                bool figure5PennantUp_M5  = false;             bool figure5PennantUp_M15 = false;              bool figure5PennantUp_H1  = false;              bool figure5PennantUp_H4  = false;              bool figure5PennantUp_D1  = false;
      bool figure6PennantDown_M1  =                     false;              bool figure6PennantDown_M5  = false;           bool figure6PennantDown_M15 = false;            bool figure6PennantDown_H1  = false;            bool figure6PennantDown_H4  = false;            bool figure6PennantDown_D1  = false;
      bool figure5_1PennantUpConfirmationUp_M1  =                       false;                bool figure5_1PennantUpConfirmationUp_M5  = false;             bool figure5_1PennantUpConfirmationUp_M15 = false;              bool figure5_1PennantUpConfirmationUp_H1  = false;              bool figure5_1PennantUpConfirmationUp_H4  = false;              bool figure5_1PennantUpConfirmationUp_D1  = false;
      bool figure6_1PennantDownConfirmationDown_M1  =                     false;              bool figure6_1PennantDownConfirmationDown_M5  = false;           bool figure6_1PennantDownConfirmationDown_M15 = false;            bool figure6_1PennantDownConfirmationDown_H1  = false;            bool figure6_1PennantDownConfirmationDown_H4  = false;            bool figure6_1PennantDownConfirmationDown_D1  = false;
      bool figure7FlagUpDivergenceUp_M1  =              false;       bool figure7FlagUpDivergenceUp_M5  = false;      bool figure7FlagUpDivergenceUp_M15 = false;       bool figure7FlagUpDivergenceUp_H1  = false;       bool figure7FlagUpDivergenceUp_H4  = false;       bool figure7FlagUpDivergenceUp_D1  = false;
      bool figure8FlagDownDivergenceDown_M1  =          false;   bool figure8FlagDownDivergenceDown_M5  = false;    bool figure8FlagDownDivergenceDown_M15 = false;     bool figure8FlagDownDivergenceDown_H1  = false;     bool figure8FlagDownDivergenceDown_H4  = false;     bool figure8FlagDownDivergenceDown_D1  = false;
      bool figure7_1TurnUpDivergenceUp_M1  =              false;       bool figure7_1TurnUpDivergenceUp_M5  = false;      bool figure7_1TurnUpDivergenceUp_M15 = false;       bool figure7_1TurnUpDivergenceUp_H1  = false;       bool figure7_1TurnUpDivergenceUp_H4  = false;       bool figure7_1TurnUpDivergenceUp_D1  = false;
      bool figure8_1TurnDownDivergenceDown_M1  =          false;   bool figure8_1TurnDownDivergenceDown_M5  = false;    bool figure8_1TurnDownDivergenceDown_M15 = false;     bool figure8_1TurnDownDivergenceDown_H1  = false;     bool figure8_1TurnDownDivergenceDown_H4  = false;     bool figure8_1TurnDownDivergenceDown_D1  = false;
      bool figure7_2TurnDivergenceConfirmationUp_M1  =              false;       bool figure7_2TurnDivergenceConfirmationUp_M5  = false;      bool figure7_2TurnDivergenceConfirmationUp_M15 = false;       bool figure7_2TurnDivergenceConfirmationUp_H1  = false;       bool figure7_2TurnDivergenceConfirmationUp_H4  = false;       bool figure7_2TurnDivergenceConfirmationUp_D1  = false;
      bool figure8_2TurnDivergenceConfirmationDown_M1  =          false;   bool figure8_2TurnDivergenceConfirmationDown_M5  = false;    bool figure8_2TurnDivergenceConfirmationDown_M15 = false;     bool figure8_2TurnDivergenceConfirmationDown_H1  = false;     bool figure8_2TurnDivergenceConfirmationDown_H4  = false;     bool figure8_2TurnDivergenceConfirmationDown_D1  = false;
      bool figure9FlagUpShiftUp_M1  =                   false;            bool figure9FlagUpShiftUp_M5  = false;         bool figure9FlagUpShiftUp_M15 = false;          bool figure9FlagUpShiftUp_H1  = false;          bool figure9FlagUpShiftUp_H4  = false;          bool figure9FlagUpShiftUp_D1  = false;
      bool figure10FlagDownShiftDown_M1  =              false;       bool figure10FlagDownShiftDown_M5  = false;    bool figure10FlagDownShiftDown_M15 = false;     bool figure10FlagDownShiftDown_H1  = false;     bool figure10FlagDownShiftDown_H4  = false;     bool figure10FlagDownShiftDown_D1  = false;
      bool figure11DoubleBottomUp_M1  =                 false;          bool figure11DoubleBottomUp_M5  = false;         bool figure11DoubleBottomUp_M15 = false;          bool figure11DoubleBottomUp_H1  = false;          bool figure11DoubleBottomUp_H4  = false;          bool figure11DoubleBottomUp_D1  = false;
      bool figure12DoubleTopDown_M1  =                  false;           bool figure12DoubleTopDown_M5  = false;            bool figure12DoubleTopDown_M15 = false;             bool figure12DoubleTopDown_H1  = false;             bool figure12DoubleTopDown_H4  = false;             bool figure12DoubleTopDown_D1  = false;
      bool figure13DivergentChannelUp_M1  =             false;      bool figure13DivergentChannelUp_M5  = false;   bool figure13DivergentChannelUp_M15 = false;    bool figure13DivergentChannelUp_H1  = false;    bool figure13DivergentChannelUp_H4  = false;    bool figure13DivergentChannelUp_D1  = false;
      bool figure14DivergentChannelDown_M1  = false;    bool figure14DivergentChannelDown_M5  = false; bool figure14DivergentChannelDown_M15 = false;  bool figure14DivergentChannelDown_H1  = false;  bool figure14DivergentChannelDown_H4  = false;  bool figure14DivergentChannelDown_D1  = false;
      bool figure13_1DivergenceFlagConfirmationUp_M1  =             false;      bool figure13_1DivergenceFlagConfirmationUp_M5  = false;   bool figure13_1DivergenceFlagConfirmationUp_M15 = false;    bool figure13_1DivergenceFlagConfirmationUp_H1  = false;    bool figure13_1DivergenceFlagConfirmationUp_H4  = false;    bool figure13_1DivergenceFlagConfirmationUp_D1  = false;
      bool figure14_1DivergenceFlagConfirmationDown_M1  = false;    bool figure14_1DivergenceFlagConfirmationDown_M5  = false; bool figure14_1DivergenceFlagConfirmationDown_M15 = false;  bool figure14_1DivergenceFlagConfirmationDown_H1  = false;  bool figure14_1DivergenceFlagConfirmationDown_H4  = false;  bool figure14_1DivergenceFlagConfirmationDown_D1  = false;
      bool figure15BalancedTriangleUp_M1  = false;      bool figure15BalancedTriangleUp_M5  = false;   bool figure15BalancedTriangleUp_M15 = false;    bool figure15BalancedTriangleUp_H1  = false;    bool figure15BalancedTriangleUp_H4  = false;    bool figure15BalancedTriangleUp_D1  = false;
      bool figure16BalancedTriangleDown_M1  = false;    bool figure16BalancedTriangleDown_M5  = false; bool figure16BalancedTriangleDown_M15 = false;  bool figure16BalancedTriangleDown_H1  = false;  bool figure16BalancedTriangleDown_H4  = false;  bool figure16BalancedTriangleDown_D1  = false;
      bool figure17FlagConfirmationUp_M1  = false;      bool figure17FlagConfirmationUp_M5  = false; bool figure17FlagConfirmationUp_M15 = false;  bool figure17FlagConfirmationUp_H1  = false;  bool figure17FlagConfirmationUp_H4  = false;  bool figure17FlagConfirmationUp_D1  = false;
      bool figure18FlagConfirmationDown_M1  = false,                            figure18FlagConfirmationDown_M5  = false,           figure18FlagConfirmationDown_M15 = false,  figure18FlagConfirmationDown_H1  = false,  figure18FlagConfirmationDown_H4  = false,  figure18FlagConfirmationDown_D1  = false;
      bool figure19HeadAndShouldersConfirmationUp_M1  = false,                  figure19HeadAndShouldersConfirmationUp_M5  = false,             figure19HeadAndShouldersConfirmationUp_M15 = false,  figure19HeadAndShouldersConfirmationUp_H1  = false,  figure19HeadAndShouldersConfirmationUp_H4  = false,  figure19HeadAndShouldersConfirmationUp_D1  = false;
      bool figure20HeadAndShouldersConfirmationDown_M1  = false,                figure20HeadAndShouldersConfirmationDown_M5  = false,           figure20HeadAndShouldersConfirmationDown_M15 = false,  figure20HeadAndShouldersConfirmationDown_H1  = false,  figure20HeadAndShouldersConfirmationDown_H4  = false,  figure20HeadAndShouldersConfirmationDown_D1  = false;
      bool figure21WedgeUp_M1  = false,                                         figure21WedgeUp_M5  = false,            figure21WedgeUp_M15 = false,            figure21WedgeUp_H1  = false,  figure21WedgeUp_H4  = false,  figure21WedgeUp_D1  = false;
      bool figure22WedgeDown_M1  = false,                                       figure22WedgeDown_M5  = false,        figure22WedgeDown_M15 = false,              figure22WedgeDown_H1  = false,  figure22WedgeDown_H4  = false,  figure22WedgeDown_D1  = false;
      bool figure23DiamondUp_M1  = false,                                       figure23DiamondUp_M5  = false,        figure23DiamondUp_M15 = false,              figure23DiamondUp_H1  = false,  figure23DiamondUp_H4  = false,  figure23DiamondUp_D1  = false;
      bool figure24DiamondDown_M1  = false,                                     figure24DiamondDown_M5  = false,    figure24DiamondDown_M15 = false,            figure24DiamondDown_H1  = false,  figure24DiamondDown_H4  = false,  figure24DiamondDown_D1  = false;
      bool figure25TriangleConfirmationUp_M1  = false,                                      figure25TriangleConfirmationUp_M5  = false,      figure25TriangleConfirmationUp_M15 = false,             figure25TriangleConfirmationUp_H1  = false,  figure25TriangleConfirmationUp_H4  = false,  figure25TriangleConfirmationUp_D1  = false;
      bool figure26TriangleConfirmationDown_M1  = false,                                    figure26TriangleConfirmationDown_M5  = false,  figure26TriangleConfirmationDown_M15 = false,           figure26TriangleConfirmationDown_H1  = false,  figure26TriangleConfirmationDown_H4  = false,  figure26TriangleConfirmationDown_D1  = false;
      bool figure27ModerateDivergentFlagConfirmationUp_M1  = false,             figure27ModerateDivergentFlagConfirmationUp_M5  = false,            figure27ModerateDivergentFlagConfirmationUp_M15 = false,  figure27ModerateDivergentFlagConfirmationUp_H1  = false,  figure27ModerateDivergentFlagConfirmationUp_H4  = false,  figure27ModerateDivergentFlagConfirmationUp_D1  = false;
      bool figure28ModerateDivergentFlagConfirmationDown_M1  = false,           figure28ModerateDivergentFlagConfirmationDown_M5  = false,          figure28ModerateDivergentFlagConfirmationDown_M15 = false,  figure28ModerateDivergentFlagConfirmationDown_H1  = false,  figure28ModerateDivergentFlagConfirmationDown_H4  = false,  figure28ModerateDivergentFlagConfirmationDown_D1  = false;
      bool figure29DoubleBottomConfirmationUp_M1  = false,                      figure29DoubleBottomConfirmationUp_M5  = false,             figure29DoubleBottomConfirmationUp_M15 = false,  figure29DoubleBottomConfirmationUp_H1  = false,  figure29DoubleBottomConfirmationUp_H4  = false,  figure29DoubleBottomConfirmationUp_D1  = false;
      bool figure30DoubleTopConfirmationDown_M1  = false,                       figure30DoubleTopConfirmationDown_M5  = false,          figure30DoubleTopConfirmationDown_M15 = false,  figure30DoubleTopConfirmationDown_H1  = false,  figure30DoubleTopConfirmationDown_H4  = false,  figure30DoubleTopConfirmationDown_D1  = false;
      bool figure31DivergentFlagConfirmationUp_M1  = false,                     figure31DivergentFlagConfirmationUp_M5  = false,            figure31DivergentFlagConfirmationUp_M15 = false,  figure31DivergentFlagConfirmationUp_H1  = false,  figure31DivergentFlagConfirmationUp_H4  = false,  figure31DivergentFlagConfirmationUp_D1  = false;
      bool figure32DivergentFlagConfirmationDown_M1  = false,                   figure32DivergentFlagConfirmationDown_M5  = false,          figure32DivergentFlagConfirmationDown_M15 = false,  figure32DivergentFlagConfirmationDown_H1  = false,  figure32DivergentFlagConfirmationDown_H4  = false,  figure32DivergentFlagConfirmationDown_D1  = false;
      bool figure33FlagWedgeForelockConfirmationUp_M1  = false,                 figure33FlagWedgeForelockConfirmationUp_M5  = false,            figure33FlagWedgeForelockConfirmationUp_M15 = false,  figure33FlagWedgeForelockConfirmationUp_H1  = false,  figure33FlagWedgeForelockConfirmationUp_H4  = false,  figure33FlagWedgeForelockConfirmationUp_D1  = false;
      bool figure34FlagWedgeForelockConfirmationDown_M1  = false,               figure34FlagWedgeForelockConfirmationDown_M5  = false,          figure34FlagWedgeForelockConfirmationDown_M15 = false,  figure34FlagWedgeForelockConfirmationDown_H1  = false,  figure34FlagWedgeForelockConfirmationDown_H4  = false,  figure34FlagWedgeForelockConfirmationDown_D1  = false;
      bool figure35TripleBottomConfirmationUp_M1  = false,                      figure35TripleBottomConfirmationUp_M5  = false,             figure35TripleBottomConfirmationUp_M15 = false,  figure35TripleBottomConfirmationUp_H1  = false,  figure35TripleBottomConfirmationUp_H4  = false,  figure35TripleBottomConfirmationUp_D1  = false;
      bool figure36TripleTopConfirmationDown_M1  = false,                    figure36TripleTopConfirmationDown_M5  = false,           figure36TripleTopConfirmationDown_M15 = false,  figure36TripleTopConfirmationDown_H1  = false,  figure36TripleTopConfirmationDown_H4  = false,  figure36TripleTopConfirmationDown_D1  = false;
      bool figure37PennantWedgeUp_M1  = false,                                  figure37PennantWedgeUp_M5  = false,             figure37PennantWedgeUp_M15 = false,  figure37PennantWedgeUp_H1  = false,  figure37PennantWedgeUp_H4  = false,  figure37PennantWedgeUp_D1  = false;
      bool figure38PennantWedgeDown_M1  = false,                                figure38PennantWedgeDown_M5  = false,           figure38PennantWedgeDown_M15 = false,  figure38PennantWedgeDown_H1  = false,  figure38PennantWedgeDown_H4  = false,  figure38PennantWedgeDown_D1  = false;
      bool figure39RollbackChannelPennantConfirmationUp_M1  = false,              figure39RollbackChannelPennantConfirmationUp_M5  = false,             figure39RollbackChannelPennantConfirmationUp_M15 = false,  figure39RollbackChannelPennantConfirmationUp_H1  = false,  figure39RollbackChannelPennantConfirmationUp_H4  = false,  figure39RollbackChannelPennantConfirmationUp_D1  = false;
      bool figure40RollbackChannelPennantConfirmationDown_M1  = false,            figure40RollbackChannelPennantConfirmationDown_M5  = false,           figure40RollbackChannelPennantConfirmationDown_M15 = false,  figure40RollbackChannelPennantConfirmationDown_H1  = false,  figure40RollbackChannelPennantConfirmationDown_H4  = false,  figure40RollbackChannelPennantConfirmationDown_D1  = false;
      bool figure41MoreDivergentFlagConfirmationUp_M1  = false,                     figure41MoreDivergentFlagConfirmationUp_M5  = false,            figure41MoreDivergentFlagConfirmationUp_M15 = false,  figure41MoreDivergentFlagConfirmationUp_H1  = false,  figure41MoreDivergentFlagConfirmationUp_H4  = false,  figure41MoreDivergentFlagConfirmationUp_D1  = false;
      bool figure42MoreDivergentFlagConfirmationDown_M1  = false,                   figure42MoreDivergentFlagConfirmationDown_M5  = false,          figure42MoreDivergentFlagConfirmationDown_M15 = false,  figure42MoreDivergentFlagConfirmationDown_H1  = false,  figure42MoreDivergentFlagConfirmationDown_H4  = false,  figure42MoreDivergentFlagConfirmationDown_D1  = false;
      bool figure43ChannelFlagUp_M1  = false,                                   figure43ChannelFlagUp_M5  = false,          figure43ChannelFlagUp_M15 = false,  figure43ChannelFlagUp_H1  = false,  figure43ChannelFlagUp_H4  = false,  figure43ChannelFlagUp_D1  = false;
      bool figure44ChannelFlagDown_M1  = false,                                 figure44ChannelFlagDown_M5  = false,            figure44ChannelFlagDown_M15 = false,  figure44ChannelFlagDown_H1  = false,  figure44ChannelFlagDown_H4  = false,  figure44ChannelFlagDown_D1  = false;
      bool figure45PennantAfterWedgeConfirmationUp_M1  = false,                 figure45PennantAfterWedgeConfirmationUp_M5  = false,            figure45PennantAfterWedgeConfirmationUp_M15 = false,  figure45PennantAfterWedgeConfirmationUp_H1  = false,  figure45PennantAfterWedgeConfirmationUp_H4  = false,  figure45PennantAfterWedgeConfirmationUp_D1  = false;
      bool figure46PennantAfterWedgeConfirmationDown_M1  = false,               figure46PennantAfterWedgeConfirmationDown_M5  = false,          figure46PennantAfterWedgeConfirmationDown_M15 = false,  figure46PennantAfterWedgeConfirmationDown_H1  = false,  figure46PennantAfterWedgeConfirmationDown_H4  = false,  figure46PennantAfterWedgeConfirmationDown_D1  = false;
      bool figure47PennantAfterFlagConfirmationUp_M1  = false,                  figure47PennantAfterFlagConfirmationUp_M5  = false,             figure47PennantAfterFlagConfirmationUp_M15 = false,  figure47PennantAfterFlagConfirmationUp_H1  = false,  figure47PennantAfterFlagConfirmationUp_H4  = false,  figure47PennantAfterFlagConfirmationUp_D1  = false;
      bool figure48PennantAfterFlagConfirmationDown_M1  = false,                figure48PennantAfterFlagConfirmationDown_M5  = false,           figure48PennantAfterFlagConfirmationDown_M15 = false,  figure48PennantAfterFlagConfirmationDown_H1  = false,  figure48PennantAfterFlagConfirmationDown_H4  = false,  figure48PennantAfterFlagConfirmationDown_D1  = false;
      bool figure49DoublePennantAfterConfirmationUp_M1  = false,                     figure49DoublePennantAfterConfirmationUp_M5  = false,            figure49DoublePennantAfterConfirmationUp_M15 = false,  figure49DoublePennantAfterConfirmationUp_H1  = false,  figure49DoublePennantAfterConfirmationUp_H4  = false,  figure49DoublePennantAfterConfirmationUp_D1  = false;
      bool figure50DoublePennantAfterConfirmationDown_M1  = false,                   figure50DoublePennantAfterConfirmationDown_M5  = false,          figure50DoublePennantAfterConfirmationDown_M15 = false,  figure50DoublePennantAfterConfirmationDown_H1  = false,  figure50DoublePennantAfterConfirmationDown_H4  = false,  figure50DoublePennantAfterConfirmationDown_D1  = false;
      bool figure51WedgeConfirmationUp_M1  = false,                             figure51WedgeConfirmationUp_M5  = false,            figure51WedgeConfirmationUp_M15 = false,  figure51WedgeConfirmationUp_H1  = false,  figure51WedgeConfirmationUp_H4  = false,  figure51WedgeConfirmationUp_D1  = false;
      bool figure52WedgeConfirmationDown_M1  = false,                           figure52WedgeConfirmationDown_M5  = false,          figure52WedgeConfirmationDown_M15 = false,  figure52WedgeConfirmationDown_H1  = false,  figure52WedgeConfirmationDown_H4  = false,  figure52WedgeConfirmationDown_D1  = false;


      bool isM1FigureUp =  false;   bool isM5FigureUp =  false;   bool isM15FigureUp = false; bool isH1FigureUp = false; bool isH4FigureUp = false; bool isD1FigureUp = false;
      bool isM1FigureDown =  false; bool isM5FigureDown =  false; bool isM15FigureDown = false; bool isH1FigureDown = false; bool isH4FigureDown = false; bool isD1FigureDown = false;

      bool isFigureUp = false; bool isFigureDown = false;


      bool blockingFigure9BlockingFlagUpShiftUp_M1 = false;         bool blockingFigure9BlockingFlagUpShiftUp_M5 = false;       bool blockingFigure9BlockingFlagUpShiftUp_M15 = false;       bool blockingFigure9BlockingFlagUpShiftUp_H1 = false;       bool blockingFigure9BlockingFlagUpShiftUp_H4 = false;       bool blockingFigure9BlockingFlagUpShiftUp_D1 = false;
      bool blockingFigure10BlockingFlagUpShiftDown_M1 = false;      bool blockingFigure10BlockingFlagUpShiftDown_M5 = false;    bool blockingFigure10BlockingFlagUpShiftDown_M15 = false;    bool blockingFigure10BlockingFlagUpShiftDown_H1 = false;    bool blockingFigure10BlockingFlagUpShiftDown_H4 = false;    bool blockingFigure10BlockingFlagUpShiftDown_D1 = false;
      bool blockingFigure15BlockingBalancedTriangleUp_M1 = false;   bool blockingFigure15BlockingBalancedTriangleUp_M5 = false; bool blockingFigure15BlockingBalancedTriangleUp_M15 = false; bool blockingFigure15BlockingBalancedTriangleUp_H1 = false; bool blockingFigure15BlockingBalancedTriangleUp_H4 = false; bool blockingFigure15BlockingBalancedTriangleUp_D1 = false;
      bool blockingFigure16BlockingBalancedTriangleUp_M1 = false;   bool blockingFigure16BlockingBalancedTriangleUp_M5 = false; bool blockingFigure16BlockingBalancedTriangleUp_M15 = false; bool blockingFigure16BlockingBalancedTriangleUp_H1 = false; bool blockingFigure16BlockingBalancedTriangleUp_H4 = false; bool blockingFigure16BlockingBalancedTriangleUp_D1 = false;

      bool isM1FigureUpBlocked = false; bool isM5FigureUpBlocked = false; bool isM15FigureUpBlocked = false; bool isH1FigureUpBlocked = false; bool isH4FigureUpBlocked = false; bool isD1FigureUpBlocked = false;
      bool isM1FigureDownBlocked = false; bool isM5FigureDownBlocked = false; bool isM15FigureDownBlocked = false; bool isH1FigureDownBlocked = false; bool isH4FigureDownBlocked = false; bool isD1FigureDownBlocked = false;

bool is11PositionFigureUp_M15 = false, is10PositionFigureUp_M15 = false, is9PositionFigureUp_M15 = false, is11PositionFigureDown_M15 = false, is10PositionFigureDown_M15 = false, is9PositionFigureDown_M15 = false;

      for(int i=0; i<=ArraySize(timeFrames)-1;i++) // iterate through TimeFrames
        {
         periodGlobal=timeFrames[i]; // set TimeFrame global value for nonSymm()
                                     // set values to firstMinGlobal firstMaxGlobal secondMinGlobal secondMaxGlobal and firstMinGlobalMACD, secondMinGlobalMACD, firstMaxGlobalMACD, secondMaxGlobalMACD;
         lowAndHighUpdateViaNonSymm=nonSymm();
         if(firstMinGlobal>secondMinGlobal && firstMaxGlobal>secondMaxGlobal) // Trend up, new, more comprehensive clause
           {
            if(timeFrames[i]==PERIOD_M1) {isTrendBull_M1   = true;}
            if(timeFrames[i]==PERIOD_M5) {isTrendBull_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){isTrendBull_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {isTrendBull_H1   = true;}
            if(timeFrames[i]==PERIOD_H4) {isTrendBull_H4   = true;}
            if(timeFrames[i]==PERIOD_D1) {isTrendBull_D1   = true;}
            // if price higher than Fibo 100 on current TimeFrame
            // but i need
            // not defined cyclePeriod; cyclePeriod equals timeFrames[i]; ie TimeFrame; for example PERIOD_M5
            if(firstMinGlobalMACD>secondMinGlobalMACD) // Divergence MACD ! сontrary
              {
               if(timeFrames[i]==PERIOD_M1) {isDivergenceMACDUp_M1  = true;}
               if(timeFrames[i]==PERIOD_M5) {isDivergenceMACDUp_M5  = true;}
               if(timeFrames[i]==PERIOD_M15){isDivergenceMACDUp_M15 = true;}
               if(timeFrames[i]==PERIOD_H1) {isDivergenceMACDUp_H1  = true;}
               if(timeFrames[i]==PERIOD_H4) {isDivergenceMACDUp_H4  = true;}
               if(timeFrames[i]==PERIOD_D1) {isDivergenceMACDUp_D1  = true;}
              }
           }
         if(firstMaxGlobal<secondMaxGlobal && firstMinGlobal<secondMinGlobal) // Trend down , new, more comprehensive clause
           {
            if(timeFrames[i]==PERIOD_M1){isTrendBear_M1=true;}
            if(timeFrames[i]==PERIOD_M5){isTrendBear_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isTrendBear_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isTrendBear_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isTrendBear_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isTrendBear_D1 = true;}
            if(firstMaxGlobalMACD<secondMaxGlobalMACD) // Divergence MACD ! сontrary
              {
               if(timeFrames[i]==PERIOD_M1){isDivergenceMACDDown_M1=true;}
               if(timeFrames[i]==PERIOD_M5){isDivergenceMACDDown_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isDivergenceMACDDown_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isDivergenceMACDDown_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isDivergenceMACDDown_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isDivergenceMACDDown_D1 = true;}
              }
           }
         if(firstMaxGlobal<secondMaxGlobal && firstMinGlobal>secondMinGlobal) // Convergence
           {
            if(timeFrames[i]==PERIOD_M1){isPriceConvergence_M1=true;}
            if(timeFrames[i]==PERIOD_M5){isPriceConvergence_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isPriceConvergence_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isPriceConvergence_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isPriceConvergence_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isPriceConvergence_D1 = true;}
            if(firstMinGlobalMACD>secondMinGlobalMACD || firstMaxGlobalMACD<secondMaxGlobalMACD) // Divergence MACD ! сontrary
              {
               if(timeFrames[i]==PERIOD_M1){isDivergenceMACDForPriceConv_M1=true;}
               if(timeFrames[i]==PERIOD_M5){isDivergenceMACDForPriceConv_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isDivergenceMACDForPriceConv_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isDivergenceMACDForPriceConv_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isDivergenceMACDForPriceConv_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isDivergenceMACDForPriceConv_D1 = true;}
              }
           }
         if(firstMaxGlobal>secondMaxGlobal && firstMinGlobal<secondMinGlobal) // Divergence
           {
            if(timeFrames[i]==PERIOD_M1){isPriceDivergence_M1=true;}
            if(timeFrames[i]==PERIOD_M5){isPriceDivergence_M5=true;}
            if(timeFrames[i]==PERIOD_M15){isPriceDivergence_M15=true;}
            if(timeFrames[i]==PERIOD_H1){isPriceDivergence_H1 = true;}
            if(timeFrames[i]==PERIOD_H4){isPriceDivergence_H4 = true;}
            if(timeFrames[i]==PERIOD_D1){isPriceDivergence_D1 = true;}
            if(firstMinGlobalMACD>secondMinGlobalMACD || firstMaxGlobalMACD<secondMaxGlobalMACD) // Divergence MACD ! сontrary
              {
               if(timeFrames[i]==PERIOD_M1){isDivergenceMACDForPriceDiv_M1=true;}
               if(timeFrames[i]==PERIOD_M5){isDivergenceMACDForPriceDiv_M5=true;}
               if(timeFrames[i]==PERIOD_M15){isDivergenceMACDForPriceDiv_M15=true;}
               if(timeFrames[i]==PERIOD_H1){isDivergenceMACDForPriceDiv_H1 = true;}
               if(timeFrames[i]==PERIOD_H4){isDivergenceMACDForPriceDiv_H4 = true;}
               if(timeFrames[i]==PERIOD_D1){isDivergenceMACDForPriceDiv_D1 = true;}
              }
           }
// Figures Analyzing Block
// Print("Figures Analyzing Block" );
// Print("firstMinGlobal = ", firstMinGlobal, " secondMinGlobal = ", secondMinGlobal );
// Print("firstMaxGlobal = ", firstMaxGlobal, " secondMaxGlobal", secondMaxGlobal);
// Print("thirdMinGlobal = ", thirdMinGlobal, " thirdMaxGlobal = ", thirdMaxGlobal);


    // Figure 1 "FlagUpContinueUp" v10.6

    if(
        thirdMinGlobal<firstMinGlobal && thirdMinGlobal<secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
        firstMinGlobal<firstMaxGlobal && firstMinGlobal<secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal<secondMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && isC5Min &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < firstMinGlobal && isC6Max &&
        firstMinGlobal  > channelLimiterForLowerEdgeMaxMinMin(firstMaxGlobal, firstMinGlobal, secondMinGlobal) &&
        secondMinGlobal > channelLimiterForLowerEdgeMaxMinMin(firstMaxGlobal, firstMinGlobal, secondMinGlobal)


        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure1FlagUpContinueUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure1FlagUpContinueUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure1FlagUpContinueUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure1FlagUpContinueUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure1FlagUpContinueUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure1FlagUpContinueUp_D1  = true;}
            print("Figure 1 FlagUpContinueUp ", timeFrames[i]);
    }

    // Figure 2 "FlagDownContinueDown" v10.6

    if(
        thirdMaxGlobal>firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal>firstMaxGlobal && thirdMaxGlobal>secondMaxGlobal &&
        firstMaxGlobal>secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
        secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
        firstMinGlobal>secondMinGlobal && isC5Max &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > firstMaxGlobal && isC6Min &&
        firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax (firstMinGlobal, firstMaxGlobal, secondMaxGlobal) &&
        secondMaxGlobal < channelLimiterForUpperEdgeMinMaxMax (firstMinGlobal, firstMaxGlobal, secondMaxGlobal)

        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure2FlagDownContinueDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure2FlagDownContinueDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure2FlagDownContinueDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure2FlagDownContinueDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure2FlagDownContinueDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure2FlagDownContinueDown_D1  = true;}
            print("Figure 2 FlagDownContinueDown ", timeFrames[i]);
    }

    // Figure 1_1 "FlagUpContinueAfterDecliningUp" v11

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min

        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure1_1FlagUpContinueAfterDecliningUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure1_1FlagUpContinueAfterDecliningUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure1_1FlagUpContinueAfterDecliningUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure1_1FlagUpContinueAfterDecliningUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure1_1FlagUpContinueAfterDecliningUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure1_1FlagUpContinueAfterDecliningUp_D1  = true;}
            print("Figure 1_1 FlagUpContinueAfterDecliningUp ", timeFrames[i]);
    }

    // Figure 2_1 "FlagDownContinueAfterDecreaseDown" v11

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal  && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        && isC5Max

        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure2_1FlagDownContinueAfterDecreaseDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure2_1FlagDownContinueAfterDecreaseDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure2_1FlagDownContinueAfterDecreaseDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure2_1FlagDownContinueAfterDecreaseDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure2_1FlagDownContinueAfterDecreaseDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure2_1FlagDownContinueAfterDecreaseDown_D1  = true;}
            print("Figure 2_1 FlagDownContinueAfterDecreaseDown ", timeFrames[i]);
    }

    // Figure 3 "TripleUp" v10.6

    if(
        thirdMinGlobal<firstMinGlobal && thirdMinGlobal<secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
        firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal>secondMaxGlobal &&
        secondMinGlobal<secondMaxGlobal && isC5Min &&
        thirdMaxGlobal<secondMaxGlobal && thirdMaxGlobal < firstMaxGlobal && thirdMaxGlobal > firstMinGlobal && isC6Max
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure3TripleUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure3TripleUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure3TripleUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure3TripleUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure3TripleUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure3TripleUp_D1  = true;}
            print("Figure 3 TripleUp ", timeFrames[i]);
    }

    // Figure 4 "TripleDown" v10.6

    if(
        thirdMaxGlobal>firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal>firstMaxGlobal && thirdMaxGlobal>secondMaxGlobal &&
        firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
        secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
        firstMinGlobal<secondMinGlobal && isC5Max &&
        thirdMinGlobal < firstMaxGlobal && thirdMinGlobal > firstMinGlobal && isC6Min
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure4TripleDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure4TripleDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure4TripleDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure4TripleDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure4TripleDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure4TripleDown_D1  = true;}
            print("Figure 4 TripleDown ", timeFrames[i]);
    }

    // Figure 5 "PennantUp" v10.6

    if(
        thirdMinGlobal<firstMinGlobal && thirdMinGlobal<secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
        firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal<secondMaxGlobal &&
        secondMinGlobal<secondMaxGlobal && isC5Min &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < secondMinGlobal && isC6Max
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure5PennantUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure5PennantUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure5PennantUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure5PennantUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure5PennantUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure5PennantUp_D1  = true;}
            print("Figure 5 PennantUp Removed", timeFrames[i]);
    }

    // Figure 6 "PennantDown" v10.6

    if(
        thirdMaxGlobal>firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal>firstMaxGlobal && thirdMaxGlobal>secondMaxGlobal &&
        firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
        secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
        firstMinGlobal>secondMinGlobal && isC5Max &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > secondMaxGlobal && isC6Min
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure6PennantDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure6PennantDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure6PennantDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure6PennantDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure6PennantDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure6PennantDown_D1  = true;}
            print("Figure 6 PennantDown Removed", timeFrames[i]);
    }

    // Figure 5_1 "PennantUpConfirmationUp" v11

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fourthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure5_1PennantUpConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure5_1PennantUpConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure5_1PennantUpConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure5_1PennantUpConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure5_1PennantUpConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure5_1PennantUpConfirmationUp_D1  = true;}
            print("Figure 5_1 PennantUpConfirmationUp ", timeFrames[i]);
    }

    // Figure 6_1 "PennantDownConfirmationDown" v11

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal  && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fourthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure6_1PennantDownConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure6_1PennantDownConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure6_1PennantDownConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure6_1PennantDownConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure6_1PennantDownConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure6_1PennantDownConfirmationDown_D1  = true;}
            print("Figure 6_1 PennantDownConfirmationDown ", timeFrames[i]);
    }


    // Figure 7 "FlagUpDivergenceUp" v10.6 v11 rewriting the terms

    if(
        firstMinGlobal<firstMaxGlobal && firstMinGlobal<secondMinGlobal && firstMinGlobal<secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal>secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure7FlagUpDivergenceUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure7FlagUpDivergenceUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure7FlagUpDivergenceUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure7FlagUpDivergenceUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure7FlagUpDivergenceUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure7FlagUpDivergenceUp_D1  = true;}
            print("Figure 7 FlagUpDivergenceUp Removed", timeFrames[i]);
    }

    // Figure 8 "FlagDownDivergenceDown" v10.6 v11 rewriting the terms

    if(
        firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMaxGlobal && firstMaxGlobal>secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal &&
        firstMinGlobal<secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        secondMaxGlobal>secondMinGlobal && secondMaxGlobal<thirdMaxGlobal && secondMaxGlobal < thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        thirdMaxGlobal>thirdMinGlobal &&
        isC5Max
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure8FlagDownDivergenceDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure8FlagDownDivergenceDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure8FlagDownDivergenceDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure8FlagDownDivergenceDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure8FlagDownDivergenceDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure8FlagDownDivergenceDown_D1  = true;}
            print("Figure 8 FlagDownDivergenceDown Removed", timeFrames[i]);
    }


    // Figure 7_1 "TurnDivergenceUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure7_1TurnDivergenceUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure7_1TurnDivergenceUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure7_1TurnDivergenceUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure7_1TurnDivergenceUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure7_1TurnDivergenceUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure7_1TurnDivergenceUp_D1  = true;}
            print("Figure 7_1 TurnDivergenceUp ", timeFrames[i]);
    }

    // Figure 8_1 "TurnDivergenceDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure8_1TurnDivergenceDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure8_1TurnDivergenceDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure8_1TurnDivergenceDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure8_1TurnDivergenceDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure8_1TurnDivergenceDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure8_1TurnDivergenceDown_D1  = true;}
            print("Figure 8_1 TurnDivergenceDown ", timeFrames[i]);
    }



    // Figure 7_2 "TurnDivergenceConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure7_2TurnDivergenceConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure7_2TurnDivergenceConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure7_2TurnDivergenceConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure7_2TurnDivergenceConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure7_2TurnDivergenceConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure7_2TurnDivergenceConfirmationUp_D1  = true;}
            print("Figure 7_2 TurnDivergenceConfirmationUp ", timeFrames[i]);
    }

    // Figure 8_2 "TurnDivergenceConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure8_2TurnDivergenceConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure8_2TurnDivergenceConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure8_2TurnDivergenceConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure8_2TurnDivergenceConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure8_2TurnDivergenceConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure8_2TurnDivergenceConfirmationDown_D1  = true;}
            print("Figure 8_2 TurnDivergenceConfirmationDown ", timeFrames[i]);
    }



    // Figure 9 "FlagUpShiftUp" v10.6

    if(
        thirdMinGlobal<firstMinGlobal && thirdMinGlobal<secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
        firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal>secondMaxGlobal &&
        secondMinGlobal<secondMaxGlobal && isC5Min &&
        thirdMaxGlobal < firstMaxGlobal && thirdMaxGlobal < secondMaxGlobal && thirdMaxGlobal > firstMinGlobal && thirdMaxGlobal > secondMinGlobal && isC6Max
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure9FlagUpShiftUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure9FlagUpShiftUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure9FlagUpShiftUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure9FlagUpShiftUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure9FlagUpShiftUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure9FlagUpShiftUp_D1  = true;}
            print("Figure 9 FlagUpShiftUp ", timeFrames[i]);
//            Print("firstMaxGlobal = ", firstMaxGlobal, "firstMinGlobal = ",firstMinGlobal, "secondMaxGlobal = ", secondMaxGlobal, "secondMinGlobal = ",secondMinGlobal, "thirdMaxGlobal = ",thirdMaxGlobal  );
    }

    // Figure 10 "FlagDownShiftDown" v 10.6

    if(
        thirdMaxGlobal>firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal>firstMaxGlobal && thirdMaxGlobal>secondMaxGlobal &&
        firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
        secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
        firstMinGlobal<secondMinGlobal && isC5Max &&
        thirdMinGlobal > firstMinGlobal && thirdMinGlobal > secondMinGlobal && thirdMinGlobal < firstMaxGlobal && thirdMinGlobal < secondMaxGlobal && isC6Min
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure10FlagDownShiftDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure10FlagDownShiftDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure10FlagDownShiftDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure10FlagDownShiftDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure10FlagDownShiftDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure10FlagDownShiftDown_D1  = true;}
            print("Figure 10 FlagDownShiftDown ", timeFrames[i]);
 //           Print("firstMaxGlobal = ", firstMaxGlobal, "firstMinGlobal = ",firstMinGlobal, "secondMaxGlobal = ", secondMaxGlobal, "secondMinGlobal = ",secondMinGlobal, "thirdMaxGlobal = ",thirdMaxGlobal  );
    }

    // Figure 11 "DoubleBottomUp" from this all was started, v10.6

    if(
        thirdMinGlobal>firstMinGlobal && thirdMinGlobal>secondMinGlobal && thirdMinGlobal>firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
        firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal<secondMaxGlobal &&
        secondMinGlobal<secondMaxGlobal && isC5Min &&
        thirdMaxGlobal > secondMaxGlobal && isC6Max
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure11DoubleBottomUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure11DoubleBottomUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure11DoubleBottomUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure11DoubleBottomUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure11DoubleBottomUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure11DoubleBottomUp_D1  = true;}
            print("Figure 11 DoubleBottomUp Removed", timeFrames[i]);
    }

    // Figure 12 "DoubleTopDown" v10.6

    if(
        thirdMaxGlobal<firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal<firstMaxGlobal && thirdMaxGlobal<secondMaxGlobal &&
        firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
        secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
        firstMinGlobal>secondMinGlobal && isC5Max &&
        thirdMinGlobal < secondMinGlobal && isC6Min
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure12DoubleTopDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure12DoubleTopDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure12DoubleTopDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure12DoubleTopDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure12DoubleTopDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure12DoubleTopDown_D1  = true;}
            print("Figure 12 DoubleTopDown Removed", timeFrames[i]);
    }

    // Figure 13 "DivergentChannelUp" from this all was started, v10.6

    if(
        thirdMinGlobal>firstMinGlobal && thirdMinGlobal>secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
        firstMinGlobal<firstMaxGlobal && firstMinGlobal<secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal>secondMaxGlobal &&
        secondMinGlobal<secondMaxGlobal && isC5Min &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < secondMaxGlobal && isC6Max
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure13DivergentChannelUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure13DivergentChannelUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure13DivergentChannelUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure13DivergentChannelUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure13DivergentChannelUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure13DivergentChannelUp_D1  = true;}
            print("Figure 13 DivergentChannelUp Removed", timeFrames[i]);
    }

    // Figure 14 "DivergentChannelDown" v10.6

    if(
        firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMaxGlobal && firstMaxGlobal>secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal &&
        secondMaxGlobal> secondMinGlobal && secondMaxGlobal>thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&
        isC5Max &&
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure14DivergentChannelDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure14DivergentChannelDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure14DivergentChannelDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure14DivergentChannelDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure14DivergentChannelDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure14DivergentChannelDown_D1  = true;}
            print("Figure 14 DivergentChannelDown Removed", timeFrames[i]);
    }


    // Figure 13_1 "DivergenceFlagConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fifthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > thirdMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fifthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal < fifthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure13_1DivergenceFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure13_1DivergenceFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure13_1DivergenceFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure13_1DivergenceFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure13_1DivergenceFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure13_1DivergenceFlagConfirmationUp_D1  = true;}
            print("Figure 13_1 DivergenceFlagConfirmationUp ", timeFrames[i]);
    }

    // Figure 14_1 "DivergenceFlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure14_1DivergenceFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure14_1DivergenceFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure14_1DivergenceFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure14_1DivergenceFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure14_1DivergenceFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure14_1DivergenceFlagConfirmationDown_D1  = true;}
            print("Figure 14_1 DivergenceFlagConfirmationDown ", timeFrames[i]);
    }



    // Figure 15 "BalancedTriangleUp" from this all was started v11 rewriting terms

    if(
        firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        firstMaxGlobal>secondMinGlobal && firstMaxGlobal<secondMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        secondMinGlobal<secondMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > thirdMinGlobal &&
        thirdMaxGlobal < firstMaxGlobal
        && isC5Min
        /*&& isTrendNoErrorForBuyReverseFilter5(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isTrendNoErrorForBuyFilter4(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isH1ConsistentForBuyFilter3()
        && isSecondHalfWaveCommitedToTrendUpFilter2(secondMinGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure15BalancedTriangleUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure15BalancedTriangleUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure15BalancedTriangleUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure15BalancedTriangleUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure15BalancedTriangleUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure15BalancedTriangleUp_D1  = true;}
            print("Figure 15 BalancedTriangleUp ", timeFrames[i]);
    }

    // Figure 16 "BalancedTriangleDown" v11 rewriting terms

    if(
        firstMaxGlobal>firstMinGlobal && firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>secondMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal>secondMinGlobal && secondMaxGlobal>thirdMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal &&
        thirdMinGlobal > firstMinGlobal &&
        isC5Max &&
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure16BalancedTriangleDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure16BalancedTriangleDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure16BalancedTriangleDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure16BalancedTriangleDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure16BalancedTriangleDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure16BalancedTriangleDown_D1  = true;}
            print("Figure 16 BalancedTriangleDown ", timeFrames[i]);
    }
    // Figure 17 "FlagConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal &&
        // firstMaxGlobal к thirdMinGlobal Вот здесь описание уровня "примерно такой же", а именно отношение firstMaxGlobal к thirdMinGlobal, всередине, то есть мы можем сказать что описание этих двух точек одинаково, тоесть они находятся в одном и том же диапазоне. Напрямую между ними, простых, отношений не будет - будут косвенные отношения с другими, но они будут одинаковыми.
        firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure17FlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure17FlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure17FlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure17FlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure17FlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure17FlagConfirmationUp_D1  = true;}
            print("Figure 17 FlagConfirmationUp ", timeFrames[i]);
    }

    // Figure 18 "FlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal &&  firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        // а здесь firstMinGlobal к thirdMaxGlobal Вот здесь описание уровня "примерно такой же", а именно отношение firstMinGlobal к thirdMaxGlobal, всередине, то есть мы можем сказать что описание этих двух точек одинаково, тоесть они находятся в одном и том же диапазоне. Напрямую между ними, простых, отношений не будет - будут косвенные отношения с другими, но они будут одинаковыми.
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure18FlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure18FlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure18FlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure18FlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure18FlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure18FlagConfirmationDown_D1  = true;}
            print("Figure 18 FlagConfirmationDown ", timeFrames[i]);
    }

    // Figure 19 "HeadAndShouldersConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal &&
        // firstMinGlobal and secondMaxGlobal approximately on one level so this relation leave undefined in simple context, description will be indirect, relative to other points, as we can restrict within some channel
        firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        // secondMinGlobal and fourthMinGlobal have no simple relation, restricted within upper and lower channels
        secondMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure19HeadAndShouldersConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure19HeadAndShouldersConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure19HeadAndShouldersConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure19HeadAndShouldersConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure19HeadAndShouldersConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure19HeadAndShouldersConfirmationUp_D1  = true;}
            print("Figure 19 HeadAndShouldersConfirmationUp ", timeFrames[i]);
    }

    // Figure 20 "HeadAndShouldersConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal &&
        // firstMaxGlobal and secondMinGlobal
        firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal >fourthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        // secondMaxGlobal and fourthMaxGlobal
        secondMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure20HeadAndShouldersConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure20HeadAndShouldersConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure20HeadAndShouldersConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure20HeadAndShouldersConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure20HeadAndShouldersConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure20HeadAndShouldersConfirmationDown_D1  = true;}
            print("Figure 20 HeadAndShouldersConfirmationDown ", timeFrames[i]);
    }

    // Figure 21 "WedgeUp" v11 fully inverted

    if(
        firstMaxGlobal > firstMinGlobal &&
        secondMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(firstMinGlobal, firstMaxGlobal,secondMaxGlobal) &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && /*firstMinGlobal and thirdMaxGlobal*/ firstMinGlobal > thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])

        ){
            if(timeFrames[i]==PERIOD_M1) {figure21WedgeUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure21WedgeUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure21WedgeUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure21WedgeUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure21WedgeUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure21WedgeUp_D1  = true;}
            print("Figure 21 WedgeUp Fully Inverted", timeFrames[i]);
    }

    // Figure 22 "WedgeDown" v11 fully inverted

    if(
        firstMinGlobal < firstMaxGlobal &&
        secondMinGlobal > channelLimiterForLowerEdgeMaxMinMin(firstMaxGlobal,firstMinGlobal,secondMinGlobal) && // firstMinGlobal and secondMinGlobal Here w need to limit the channel, as secondMinGlobal or firstMinGlobal or equals will be the lowest point, but no more than. *min > max -fmm(Buy) *max < min+fmm (Sell). For outer border of channel description
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal<secondMaxGlobal &&
        // firstMaxGlobal and thirdMinGlobal // just do not to descript, relation will be clarify by simple comparisons between another points
        firstMaxGlobal < thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure22WedgeDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure22WedgeDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure22WedgeDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure22WedgeDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure22WedgeDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure22WedgeDown_D1  = true;}
            print("Figure 22 WedgeDown Fully Inverted", timeFrames[i]);
    }

    // Figure 23 "DiamondUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal<secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure23DiamondUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure23DiamondUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure23DiamondUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure23DiamondUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure23DiamondUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure23DiamondUp_D1  = true;}
            print("Figure 23 DiamondUp ", timeFrames[i]);
    }

    // Figure 24 "DiamondDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure24DiamondDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure24DiamondDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure24DiamondDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure24DiamondDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure24DiamondDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure24DiamondDown_D1  = true;}
            print("Figure 24 DiamondDown ", timeFrames[i]);
    }

    // Figure 25 "TriangleConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fifthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal >fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal  && thirdMinGlobal > fifthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure25TriangleConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure25TriangleConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure25TriangleConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure25TriangleConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure25TriangleConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure25TriangleConfirmationUp_D1  = true;}
            print("Figure 25 TriangleConfirmationUp ", timeFrames[i]);
    }

    // Figure 26 "TriangleConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal && firstMaxGlobal < thirdMaxGlobal  && firstMaxGlobal < thirdMinGlobal &&  firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal &&  firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal  && firstMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fifthMaxGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure26TriangleConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure26TriangleConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure26TriangleConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure26TriangleConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure26TriangleConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure26TriangleConfirmationDown_D1  = true;}
            print("Figure 26 TriangleConfirmationDown ", timeFrames[i]);
    }


    // Figure 27 "ModerateDivergentFlagConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && /*secondMinGlobal and thirdMaxGlobal */ secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27ModerateDivergentFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27ModerateDivergentFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27ModerateDivergentFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27ModerateDivergentFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27ModerateDivergentFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27ModerateDivergentFlagConfirmationUp_D1  = true;}
            print("Figure 27 ModerateDivergentFlagConfirmationUp ", timeFrames[i]);
    }

    // Figure 28 "ModerateDivergentFlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && /*secondMaxGlobal and thirdMinGlobal */ secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28ModerateDivergentFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28ModerateDivergentFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28ModerateDivergentFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28ModerateDivergentFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28ModerateDivergentFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28ModerateDivergentFlagConfirmationDown_D1  = true;}
            print("Figure 28 ModerateDivergentFlagConfirmationDown ", timeFrames[i]);
    }



    // Figure 29 "DoubleBottomConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fifthMinGlobal && firstMinGlobal < fifthMaxGlobal && firstMinGlobal < sixthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && /*firstMaxGlobal and fifthMinGlobal && */firstMaxGlobal < fifthMaxGlobal && /*firstMaxGlobal and sixthMinGlobal &&*/
        secondMinGlobal < secondMaxGlobal && /*secondMinGlobal and thirdMinGlobal*/ secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fifthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal < sixthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMinGlobal < fifthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMinGlobal < sixthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fifthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal < sixthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fifthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal < sixthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal < fifthMinGlobal && fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal < sixthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal > fifthMaxGlobal && fourthMaxGlobal > sixthMinGlobal &&
        fifthMinGlobal < fifthMaxGlobal && /*fifthMaxGlobal and sixthMinGlobal*/
        fifthMaxGlobal > sixthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure29DoubleBottomConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure29DoubleBottomConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure29DoubleBottomConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure29DoubleBottomConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure29DoubleBottomConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure29DoubleBottomConfirmationUp_D1  = true;}
            print("Figure 29 DoubleBottomConfirmationUp ", timeFrames[i]);
    }

    // Figure 30 "DoubleTopConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fifthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal > sixthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && /*firstMinGlobal and fifthMaxGlobal*/  firstMinGlobal > fifthMinGlobal && /*firstMinGlobal and sixthMaxGlobal*/
        secondMaxGlobal > secondMinGlobal && /*secondMaxGlobal and thirdMaxGlobal */  secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fifthMaxGlobal && secondMaxGlobal > fifthMinGlobal && secondMaxGlobal > sixthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fifthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal > sixthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fifthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal > sixthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fifthMaxGlobal && thirdMinGlobal >fifthMinGlobal && thirdMinGlobal > sixthMaxGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMaxGlobal && fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal> sixthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal < fifthMinGlobal && fourthMinGlobal < sixthMaxGlobal &&
        fifthMaxGlobal > fifthMinGlobal && /*fifthMaxGlobal and sixthMaxGlobal*/
        fifthMinGlobal < sixthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure30DoubleTopConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure30DoubleTopConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure30DoubleTopConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure30DoubleTopConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure30DoubleTopConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure30DoubleTopConfirmationDown_D1  = true;}
            print("Figure 30 DoubleTopConfirmationDown ", timeFrames[i]);
    }


    // Figure 31 "DivergentFlagConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure31DivergentFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure31DivergentFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure31DivergentFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure31DivergentFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure31DivergentFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure31DivergentFlagConfirmationUp_D1  = true;}
            print("Figure 31 DivergentFlagConfirmationUp ", timeFrames[i]);
    }

    // Figure 32 "DivergentFlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure32DivergentFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure32DivergentFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure32DivergentFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure32DivergentFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure32DivergentFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure32DivergentFlagConfirmationDown_D1  = true;}
            print("Figure 32 DivergentFlagConfirmationDown ", timeFrames[i]);
    }

    // Figure 33 "FlagWedgeForelockConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && /*firstMinGlobal and fourthMaxGlobal */ firstMinGlobal > fifthMinGlobal && /*firstMinGlobal and fifthMaxGlobal*/
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal > fifthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure33FlagWedgeForelockConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure33FlagWedgeForelockConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure33FlagWedgeForelockConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure33FlagWedgeForelockConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure33FlagWedgeForelockConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure33FlagWedgeForelockConfirmationUp_D1  = true;}
            print("Figure 33 FlagWedgeForelockConfirmationUp ", timeFrames[i]);
    }

    // Figure 34 "FlagWedgeForelockConfirmationDown"
    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal && firstMaxGlobal < thirdMaxGlobal  && firstMaxGlobal > thirdMinGlobal &&  firstMaxGlobal < fourthMaxGlobal && /*firstMaxGlobal and fourthMinGlobal &&*/
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal &&  firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal  &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure34FlagWedgeForelockConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure34FlagWedgeForelockConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure34FlagWedgeForelockConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure34FlagWedgeForelockConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure34FlagWedgeForelockConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure34FlagWedgeForelockConfirmationDown_D1  = true;}
            print("Figure 34 FlagWedgeForelockConfirmationDown ", timeFrames[i]);
    }


    // Figure 35 "TripleBottomConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && /*firstMinGlobal and secondMaxGlobal &&*/ firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(fourthMinGlobal, thirdMaxGlobal, fourthMaxGlobal) && firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(secondMinGlobal, firstMaxGlobal, secondMaxGlobal) && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(fourthMinGlobal, thirdMaxGlobal, fourthMaxGlobal) &&
        fourthMinGlobal < fourthMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure35TripleBottomConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure35TripleBottomConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure35TripleBottomConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure35TripleBottomConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure35TripleBottomConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure35TripleBottomConfirmationUp_D1  = true;}
            print("Figure 35 TripleBottomConfirmationUp ", timeFrames[i]);
    }

    // Figure 36 "TripleTopConfirmationDown"
    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > channelLimiterForLowerEdgeMaxMinMin(secondMaxGlobal, firstMinGlobal, secondMinGlobal) && firstMaxGlobal < thirdMaxGlobal  && firstMaxGlobal > thirdMinGlobal &&  firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal &&  firstMinGlobal > channelLimiterForLowerEdgeMaxMinMin(fourthMaxGlobal, thirdMinGlobal, fourthMinGlobal) &&  firstMinGlobal > channelLimiterForLowerEdgeMaxMinMin(secondMaxGlobal, firstMinGlobal, secondMinGlobal) && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > channelLimiterForLowerEdgeMaxMinMin(fourthMaxGlobal, thirdMinGlobal, fourthMinGlobal) &&
        fourthMaxGlobal > fourthMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure36TripleTopConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure36TripleTopConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure36TripleTopConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure36TripleTopConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure36TripleTopConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure36TripleTopConfirmationDown_D1  = true;}
            print("Figure 36 TripleTopConfirmationDown ", timeFrames[i]);
    }


    // Figure 37 "PennantWedgeUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > channelLimiterForLowerEdgeMaxMinMin(secondMinGlobal, firstMinGlobal,thirdMinGlobal) /*thirdMinGlobal*/ && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure37PennantWedgeUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure37PennantWedgeUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure37PennantWedgeUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure37PennantWedgeUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure37PennantWedgeUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure37PennantWedgeUp_D1  = true;}
            print("Figure 37 PennantWedgeUp ", timeFrames[i]);
    }

    // Figure 38 "PennantWedgeDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal &&  firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(secondMaxGlobal,firstMaxGlobal,thirdMaxGlobal)/*thirdMaxGlobal*/ && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure38PennantWedgeDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure38PennantWedgeDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure38PennantWedgeDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure38PennantWedgeDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure38PennantWedgeDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure38PennantWedgeDown_D1  = true;}
            print("Figure 38 PennantWedgeDown ", timeFrames[i]);
    }

    // Figure 39 "RollbackChannelPennantConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fifthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fifthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure39RollbackChannelPennantConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure39RollbackChannelPennantConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure39RollbackChannelPennantConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure39RollbackChannelPennantConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure39RollbackChannelPennantConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure39RollbackChannelPennantConfirmationUp_D1  = true;}
            print("Figure 39 RollbackChannelPennantConfirmationUp ", timeFrames[i]);
    }

    // Figure 40 "RollbackChannelPennantConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure40RollbackChannelPennantConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure40RollbackChannelPennantConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure40RollbackChannelPennantConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure40RollbackChannelPennantConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure40RollbackChannelPennantConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure40RollbackChannelPennantConfirmationDown_D1  = true;}
            print("Figure 40 RollbackChannelPennantConfirmationDown ", timeFrames[i]);
    }


    // Figure 41 "MoreDivergentFlagConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure41MoreDivergentFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure41MoreDivergentFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure41MoreDivergentFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure41MoreDivergentFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure41MoreDivergentFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure41MoreDivergentFlagConfirmationUp_D1  = true;}
            print("Figure 41 MoreDivergentFlagConfirmationUp ", timeFrames[i]);
    }

    // Figure 42 "MoreDivergentFlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure42MoreDivergentFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure42MoreDivergentFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure42MoreDivergentFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure42MoreDivergentFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure42MoreDivergentFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure42MoreDivergentFlagConfirmationDown_D1  = true;}
            print("Figure 42 MoreDivergentFlagConfirmationDown ", timeFrames[i]);
    }

    // Figure 43 "ChannelFlagUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax (secondMinGlobal, fifthMaxGlobal, secondMaxGlobal)/*secondMaxGlobal*/ && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure43ChannelFlagUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure43ChannelFlagUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure43ChannelFlagUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure43ChannelFlagUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure43ChannelFlagUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure43ChannelFlagUp_D1  = true;}
            print("Figure 43 ChannelFlagUp ", timeFrames[i]);
    }

    // Figure 44 "ChannelFlagDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > channelLimiterForLowerEdgeMaxMinMin (secondMaxGlobal, firstMinGlobal, secondMinGlobal) /*&& firstMinGlobal > secondMinGlobal*/ && firstMinGlobal< thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure44ChannelFlagDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure44ChannelFlagDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure44ChannelFlagDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure44ChannelFlagDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure44ChannelFlagDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure44ChannelFlagDown_D1  = true;}
            print("Figure 44 ChannelFlagDown ", timeFrames[i]);
    }

    // Figure 45 "PennantAfterWedgeConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fifthMinGlobal && firstMinGlobal > fifthMaxGlobal && firstMinGlobal > sixthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal > fifthMaxGlobal && firstMaxGlobal > sixthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal > fifthMaxGlobal && secondMinGlobal > sixthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMaxGlobal > fifthMaxGlobal && secondMinGlobal > sixthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fourthMaxGlobal && thirdMinGlobal > fifthMinGlobal && thirdMinGlobal > fifthMaxGlobal && thirdMinGlobal > sixthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal > fifthMaxGlobal && thirdMaxGlobal > sixthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal < fifthMinGlobal && fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal < sixthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal < fifthMaxGlobal && fourthMaxGlobal > sixthMinGlobal &&
        fifthMinGlobal < fifthMaxGlobal && fifthMaxGlobal > sixthMinGlobal &&
        fifthMaxGlobal > sixthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure45PennantAfterWedgeConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure45PennantAfterWedgeConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure45PennantAfterWedgeConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure45PennantAfterWedgeConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure45PennantAfterWedgeConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure45PennantAfterWedgeConfirmationUp_D1  = true;}
            print("Figure 45 PennantAfterWedgeConfirmationUp ", timeFrames[i]);
    }

    // Figure 46 "PennantAfterWedgeConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal && firstMaxGlobal < fifthMinGlobal && firstMaxGlobal < sixthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fifthMaxGlobal  && firstMinGlobal < fifthMinGlobal && firstMinGlobal < sixthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal  && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMaxGlobal < fifthMinGlobal && secondMaxGlobal < sixthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal < fifthMinGlobal && secondMinGlobal < sixthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal < fifthMinGlobal && thirdMaxGlobal < sixthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal <fifthMinGlobal && thirdMinGlobal < sixthMaxGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMaxGlobal && fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal> sixthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal > fifthMinGlobal && fourthMinGlobal < sixthMaxGlobal &&
        fifthMaxGlobal > fifthMinGlobal && fifthMaxGlobal < sixthMaxGlobal &&
        fifthMinGlobal < sixthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure46PennantAfterWedgeConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure46PennantAfterWedgeConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure46PennantAfterWedgeConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure46PennantAfterWedgeConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure46PennantAfterWedgeConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure46PennantAfterWedgeConfirmationDown_D1  = true;}
            print("Figure 46 PennantAfterWedgeConfirmationDown ", timeFrames[i]);
    }

    // Figure 47 "PennantAfterFlagConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fifthMinGlobal && firstMinGlobal > fifthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal > fifthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal > fifthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMaxGlobal > fifthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fourthMaxGlobal && thirdMinGlobal > fifthMinGlobal && thirdMinGlobal > fifthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal > fifthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal && fourthMinGlobal > fifthMaxGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal > fifthMaxGlobal &&
        fifthMinGlobal < fifthMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure47PennantAfterFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure47PennantAfterFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure47PennantAfterFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure47PennantAfterFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure47PennantAfterFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure47PennantAfterFlagConfirmationUp_D1  = true;}
            print("Figure 47 PennantAfterFlagConfirmationUp ", timeFrames[i]);
    }

    // Figure 48 "PennantAfterFlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal && firstMaxGlobal < fifthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fifthMaxGlobal  && firstMinGlobal < fifthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal  && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMaxGlobal < fifthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal < fifthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal < fifthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal <fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal && fourthMaxGlobal < fifthMinGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal < fifthMinGlobal &&
        fifthMaxGlobal > fifthMinGlobal &&

        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure48PennantAfterFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure48PennantAfterFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure48PennantAfterFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure48PennantAfterFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure48PennantAfterFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure48PennantAfterFlagConfirmationDown_D1  = true;}
            print("Figure 48 PennantAfterFlagConfirmationDown ", timeFrames[i]);
    }

    // Figure 49 "DoublePennantAfterConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fifthMinGlobal && firstMinGlobal > fifthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal > fifthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal > fifthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMaxGlobal > fifthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fourthMaxGlobal && thirdMinGlobal > fifthMinGlobal && thirdMinGlobal > fifthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal > fifthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal && fourthMinGlobal < fifthMaxGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fifthMinGlobal < fifthMaxGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure49DoublePennantAfterConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure49DoublePennantAfterConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure49DoublePennantAfterConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure49DoublePennantAfterConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure49DoublePennantAfterConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure49DoublePennantAfterConfirmationUp_D1  = true;}
            print("Figure 49 DoublePennantAfterConfirmationUp ", timeFrames[i]);
    }

    // Figure 50 "DoublePennantAfterConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal && firstMaxGlobal < fifthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fifthMaxGlobal  && firstMinGlobal < fifthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal  && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMaxGlobal < fifthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal < fifthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal < fifthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal <fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal && fourthMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        fifthMaxGlobal > fifthMinGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure50DoublePennantAfterConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure50DoublePennantAfterConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure50DoublePennantAfterConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure50DoublePennantAfterConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure50DoublePennantAfterConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure50DoublePennantAfterConfirmationDown_D1  = true;}
            print("Figure 50 DoublePennantAfterConfirmationDown ", timeFrames[i]);
    }

   // Figure 51 "WedgeConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min &&
        isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure51WedgeConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure51WedgeConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure51WedgeConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure51WedgeConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure51WedgeConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure51WedgeConfirmationUp_D1  = true;}
            print("Figure 51 WedgeConfirmationUp ", timeFrames[i]);
    }

    // Figure 52 "WedgeConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max &&
        isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure52WedgeConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure52WedgeConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure52WedgeConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure52WedgeConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure52WedgeConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure52WedgeConfirmationDown_D1  = true;}
            print("Figure 52 WedgeConfirmationDown ", timeFrames[i]);
    }


/*

// Section for Blocking Figures, using C6Max for FigureUP and C6Min fro FigureDown

    // Blocking Figure 9  "BlockingFlagUpShiftUp"
     if(
            thirdMinGlobal<firstMinGlobal && thirdMinGlobal<secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<firstMaxGlobal &&
            firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
            firstMaxGlobal>secondMinGlobal && firstMaxGlobal>secondMaxGlobal &&
            secondMinGlobal<secondMaxGlobal && isC5Min &&
            thirdMaxGlobal < firstMaxGlobal && isC6Max
            ){
                if(timeFrames[i]==PERIOD_M1) {blockingFigure9BlockingFlagUpShiftUp_M1  = true;}
                if(timeFrames[i]==PERIOD_M5) {blockingFigure9BlockingFlagUpShiftUp_M5  = true;}
                if(timeFrames[i]==PERIOD_M15){blockingFigure9BlockingFlagUpShiftUp_M15 = true;}
                if(timeFrames[i]==PERIOD_H1) {blockingFigure9BlockingFlagUpShiftUp_H1  = true;}
                if(timeFrames[i]==PERIOD_H4) {blockingFigure9BlockingFlagUpShiftUp_H4  = true;}
                if(timeFrames[i]==PERIOD_D1) {blockingFigure9BlockingFlagUpShiftUp_D1  = true;}
                print("Blocking Figure 9 BlockingFlagUpShiftUp ", timeFrames[i]);
    //            Print("firstMaxGlobal = ", firstMaxGlobal, "firstMinGlobal = ",firstMinGlobal, "secondMaxGlobal = ", secondMaxGlobal, "secondMinGlobal = ",secondMinGlobal, "thirdMaxGlobal = ",thirdMaxGlobal  );
        }
    // Blocking Figure 10 "BlockingFlagUpShiftDown"
     if(
            thirdMaxGlobal>firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal>firstMaxGlobal && thirdMaxGlobal>secondMaxGlobal &&
            firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
            secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
            firstMinGlobal<secondMinGlobal && isC5Max &&
            thirdMinGlobal > firstMinGlobal && isC6Min
            ){
                if(timeFrames[i]==PERIOD_M1) {blockingFigure10BlockingFlagUpShiftDown_M1  = true;}
                if(timeFrames[i]==PERIOD_M5) {blockingFigure10BlockingFlagUpShiftDown_M5  = true;}
                if(timeFrames[i]==PERIOD_M15){blockingFigure10BlockingFlagUpShiftDown_M15 = true;}
                if(timeFrames[i]==PERIOD_H1) {blockingFigure10BlockingFlagUpShiftDown_H1  = true;}
                if(timeFrames[i]==PERIOD_H4) {blockingFigure10BlockingFlagUpShiftDown_H4  = true;}
                if(timeFrames[i]==PERIOD_D1) {blockingFigure10BlockingFlagUpShiftDown_D1  = true;}
                print("Blocking Figure 10 BlockingFlagUpShiftDown ", timeFrames[i]);
     //           Print("firstMaxGlobal = ", firstMaxGlobal, "firstMinGlobal = ",firstMinGlobal, "secondMaxGlobal = ", secondMaxGlobal, "secondMinGlobal = ",secondMinGlobal, "thirdMaxGlobal = ",thirdMaxGlobal  );
        }
    // Blocking Figure 15 "BlockingBalancedTriangleUp"
    if(
            thirdMinGlobal>firstMinGlobal && thirdMinGlobal>secondMinGlobal && thirdMinGlobal<firstMaxGlobal && thirdMinGlobal<secondMaxGlobal &&
            firstMinGlobal<firstMaxGlobal && firstMinGlobal>secondMinGlobal && firstMinGlobal<secondMaxGlobal &&
            firstMaxGlobal>secondMinGlobal && firstMaxGlobal<secondMaxGlobal &&
            secondMinGlobal<secondMaxGlobal && isC5Min &&
            thirdMaxGlobal > firstMaxGlobal && isC6Max
            ){
                if(timeFrames[i]==PERIOD_M1) {blockingFigure15BlockingBalancedTriangleUp_M1  = true;}
                if(timeFrames[i]==PERIOD_M5) {blockingFigure15BlockingBalancedTriangleUp_M5  = true;}
                if(timeFrames[i]==PERIOD_M15){blockingFigure15BlockingBalancedTriangleUp_M15 = true;}
                if(timeFrames[i]==PERIOD_H1) {blockingFigure15BlockingBalancedTriangleUp_H1  = true;}
                if(timeFrames[i]==PERIOD_H4) {blockingFigure15BlockingBalancedTriangleUp_H4  = true;}
                if(timeFrames[i]==PERIOD_D1) {blockingFigure15BlockingBalancedTriangleUp_D1  = true;}
                print("Blocking Figure 15 BlockingBalancedTriangleUp ", timeFrames[i]);
        }
    // Blocking Figure 16 "BlockingBalancedTriangleUp"
    if(
            thirdMaxGlobal>firstMinGlobal && thirdMaxGlobal>secondMinGlobal && thirdMaxGlobal<firstMaxGlobal && thirdMaxGlobal<secondMaxGlobal &&
            firstMaxGlobal<secondMaxGlobal && firstMaxGlobal>firstMinGlobal && firstMaxGlobal>secondMinGlobal &&
            secondMaxGlobal>firstMinGlobal && secondMaxGlobal>secondMinGlobal &&
            firstMinGlobal>secondMinGlobal && isC5Max &&
            thirdMinGlobal < firstMinGlobal && isC6Min
            ){
                if(timeFrames[i]==PERIOD_M1) {blockingFigure16BlockingBalancedTriangleUp_M1  = true;}
                if(timeFrames[i]==PERIOD_M5) {blockingFigure16BlockingBalancedTriangleUp_M5  = true;}
                if(timeFrames[i]==PERIOD_M15){blockingFigure16BlockingBalancedTriangleUp_M15 = true;}
                if(timeFrames[i]==PERIOD_H1) {blockingFigure16BlockingBalancedTriangleUp_H1  = true;}
                if(timeFrames[i]==PERIOD_H4) {blockingFigure16BlockingBalancedTriangleUp_H4  = true;}
                if(timeFrames[i]==PERIOD_D1) {blockingFigure16BlockingBalancedTriangleUp_D1  = true;}
                print("Blocking Figure 16 BlockingBalancedTriangleUp ", timeFrames[i]);
        }
*/

}

     print();

   if(total<1)
     {
// Second layer analyzing Block
bool isFiboModuleGreenState = false;
bool isFiboModuleGreenLevel_100_IsPassed = false;
bool isTrendBull = false;
bool isDivergenceMACDUp = false;
bool isFiboModuleRedState = false;
bool isFiboModuleRedLevel_100_IsPassed = false;
bool isTrendBear = false;
bool isDivergenceMACDDown = false;
bool isPriceConvergence = false;
bool isPriceDivergence = false;
bool isDivergenceMACDForPriceConv = false;
bool isDivergenceMACDForPriceDiv = false;

isFiboModuleGreenState                = isFiboModuleGreenState_M5 && isFiboModuleGreenState_M15 && isFiboModuleGreenState_H1 && isFiboModuleGreenState_H4 && isFiboModuleGreenState_D1;
isFiboModuleGreenLevel_100_IsPassed   = isFiboModuleGreenLevel_100_IsPassed_D1 || isFiboModuleGreenLevel_100_IsPassed_H4  || isFiboModuleGreenLevel_100_IsPassed_H1 || isFiboModuleGreenLevel_100_IsPassed_M15 || isFiboModuleGreenLevel_100_IsPassed_M5;
isTrendBull                           = isTrendBull_M15 && isTrendBull_H1 && isTrendBull_H4 && isTrendBull_D1 && isTrendBull_M5;
isDivergenceMACDUp                    = isDivergenceMACDUp_M5 || isDivergenceMACDUp_M15 || isDivergenceMACDUp_H1 || isDivergenceMACDUp_H4 || isDivergenceMACDUp_D1;

isFiboModuleRedState                  = isFiboModuleRedState_M5 && isFiboModuleRedState_M15 && isFiboModuleRedState_H1 && isFiboModuleRedState_H4 && isFiboModuleRedState_D1;
isFiboModuleRedLevel_100_IsPassed     = isFiboModuleRedLevel_100_IsPassed_D1 || isFiboModuleRedLevel_100_IsPassed_H4   || isFiboModuleRedLevel_100_IsPassed_H1 || isFiboModuleRedLevel_100_IsPassed_M15 || isFiboModuleRedLevel_100_IsPassed_M5;
isTrendBear                           = isTrendBear_M15 && isTrendBear_H1 && isTrendBear_H4 && isTrendBear_D1 && isTrendBear_M5;
isDivergenceMACDDown                  = isDivergenceMACDDown_M5 || isDivergenceMACDDown_M15 || isDivergenceMACDDown_H1 || isDivergenceMACDDown_H4 || isDivergenceMACDDown_D1;

isPriceConvergence                    = isPriceConvergence_M15;
isPriceDivergence                     = isPriceDivergence_M15;

isDivergenceMACDForPriceConv          = isDivergenceMACDForPriceConv_M15;
isDivergenceMACDForPriceDiv           = isDivergenceMACDForPriceDiv_M15;

// MACD Filter Block
double macd0_H1  = 0.0; double macd1_H1  = 0.0; double macd2_H1  = 0.0;
double macd0_H4  = 0.0; double macd1_H4  = 0.0; double macd2_H4  = 0.0; double macd0_D1  = 0.0; double macd1_D1  = 0.0; double macd2_D1  = 0.0;
double macd0_MN1 = 0.0; double macd1_MN1 = 0.0; double macd2_MN1 = 0.0;

macd0_H1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_H1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_H1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,2);

macd0_H4 = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_H4 = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_H4 = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,2);


macd0_D1 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_D1 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_D1 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,2);

macd0_MN1 = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_MN1 = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_MN1 = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_OPEN,MODE_MAIN,2);

bool macdUp_H1  = false; bool macdDown_H1  = false;
bool macdUp_H4  = false; bool macdUp_D1  = false; bool macdUp_MN1 = false;
bool macdDown_H4 = false; bool macdDown_D1 = false; bool macdDown_MN1 = false;

macdUp_H1  = macd0_H1  > macd1_H1  && macd1_H1  > macd2_H1;
macdUp_H4  = macd0_H4  > macd1_H4  && macd1_H4  > macd2_H4;
macdUp_D1  = macd0_D1  > macd1_D1  && macd1_D1  > macd2_D1;
macdUp_MN1 = macd0_MN1 > macd1_MN1 && macd1_MN1 > macd2_MN1;

macdDown_H1  = macd0_H1  < macd1_H1  && macd1_H1   < macd2_H1;
macdDown_H4  = macd0_H4  < macd1_H4  && macd1_H4   < macd2_H4;
macdDown_D1  = macd0_D1  < macd1_D1  && macd1_D1   < macd2_D1;
macdDown_MN1 = macd0_MN1 < macd1_MN1 && macd1_MN1  < macd2_MN1;

bool MACDForelockFilterForBuyPosition  = false;
bool MACDForelockFilterForSellPosition = false;

MACDForelockFilterForBuyPosition  = macdUp_H1 && macdUp_H4   && macdUp_D1   && macdUp_MN1;
MACDForelockFilterForSellPosition = macdDown_H1&& macdDown_H4 && macdDown_D1 && macdDown_MN1;


     isD1FigureUp  =  figure1FlagUpContinueUp_D1 || figure1_1FlagUpContinueAfterDecliningUp_D1 || figure3TripleUp_D1    || figure5_1PennantUpConfirmationUp_D1  || figure7_1TurnUpDivergenceUp_D1  || figure7_2TurnDivergenceConfirmationUp_D1 || figure9FlagUpShiftUp_D1   /*|| figure11DoubleBottomUp_D1 */ || figure13_1DivergenceFlagConfirmationUp_D1  || figure15BalancedTriangleUp_D1 || figure17FlagConfirmationUp_D1 || figure19HeadAndShouldersConfirmationUp_D1 || figure21WedgeUp_D1 || figure23DiamondUp_D1 || figure25TriangleConfirmationUp_D1 || figure27ModerateDivergentFlagConfirmationUp_D1 || figure29DoubleBottomConfirmationUp_D1 || figure31DivergentFlagConfirmationUp_D1 || figure33FlagWedgeForelockConfirmationUp_D1 || figure35TripleBottomConfirmationUp_D1 || figure37PennantWedgeUp_D1 || figure39RollbackChannelPennantConfirmationUp_D1 || figure41MoreDivergentFlagConfirmationUp_D1 || figure43ChannelFlagUp_D1 || figure45PennantAfterWedgeConfirmationUp_D1 || figure47PennantAfterFlagConfirmationUp_D1 || figure49DoublePennantAfterConfirmationUp_D1 || figure51WedgeConfirmationUp_D1;
     isH4FigureUp  =  figure1FlagUpContinueUp_H4 || figure1_1FlagUpContinueAfterDecliningUp_H4 || figure3TripleUp_H4    || figure5_1PennantUpConfirmationUp_H4  || figure7_1TurnUpDivergenceUp_H4  || figure7_2TurnDivergenceConfirmationUp_H4 || figure9FlagUpShiftUp_H4   /*|| figure11DoubleBottomUp_H4 */ || figure13_1DivergenceFlagConfirmationUp_H4  || figure15BalancedTriangleUp_H4 || figure17FlagConfirmationUp_H4 || figure19HeadAndShouldersConfirmationUp_H4 || figure21WedgeUp_H4 || figure23DiamondUp_H4 || figure25TriangleConfirmationUp_H4 || figure27ModerateDivergentFlagConfirmationUp_H4 || figure29DoubleBottomConfirmationUp_H4 || figure31DivergentFlagConfirmationUp_H4 || figure33FlagWedgeForelockConfirmationUp_H4 || figure35TripleBottomConfirmationUp_H4 || figure37PennantWedgeUp_H4 || figure39RollbackChannelPennantConfirmationUp_H4 || figure41MoreDivergentFlagConfirmationUp_H4 || figure43ChannelFlagUp_H4 || figure45PennantAfterWedgeConfirmationUp_H4 || figure47PennantAfterFlagConfirmationUp_H4 || figure49DoublePennantAfterConfirmationUp_H4 || figure51WedgeConfirmationUp_H4;
     isH1FigureUp  =  figure1FlagUpContinueUp_H1 || figure1_1FlagUpContinueAfterDecliningUp_H1 || figure3TripleUp_H1    || figure5_1PennantUpConfirmationUp_H1  || figure7_1TurnUpDivergenceUp_H1  || figure7_2TurnDivergenceConfirmationUp_H1 || figure9FlagUpShiftUp_H1   /*|| figure11DoubleBottomUp_H1 */ || figure13_1DivergenceFlagConfirmationUp_H1  || figure15BalancedTriangleUp_H1 || figure17FlagConfirmationUp_H1 || figure19HeadAndShouldersConfirmationUp_H1 || figure21WedgeUp_H1 || figure23DiamondUp_H1 || figure25TriangleConfirmationUp_H1 || figure27ModerateDivergentFlagConfirmationUp_H1 || figure29DoubleBottomConfirmationUp_H1 || figure31DivergentFlagConfirmationUp_H1 || figure33FlagWedgeForelockConfirmationUp_H1 || figure35TripleBottomConfirmationUp_H1 || figure37PennantWedgeUp_H1 || figure39RollbackChannelPennantConfirmationUp_H1 || figure41MoreDivergentFlagConfirmationUp_H1 || figure43ChannelFlagUp_H1 || figure45PennantAfterWedgeConfirmationUp_H1 || figure47PennantAfterFlagConfirmationUp_H1 || figure49DoublePennantAfterConfirmationUp_H1 || figure51WedgeConfirmationUp_H1;
     isM15FigureUp =  figure1FlagUpContinueUp_M15 || figure1_1FlagUpContinueAfterDecliningUp_M15 || figure3TripleUp_M15 || figure5_1PennantUpConfirmationUp_M15 || figure7_1TurnUpDivergenceUp_M15 || figure7_2TurnDivergenceConfirmationUp_M15 || figure9FlagUpShiftUp_M15 /*|| figure11DoubleBottomUp_M15*/ || figure13_1DivergenceFlagConfirmationUp_M15 || figure15BalancedTriangleUp_M15 || figure17FlagConfirmationUp_M15 || figure19HeadAndShouldersConfirmationUp_M15 || figure21WedgeUp_M15 || figure23DiamondUp_M15 || figure25TriangleConfirmationUp_M15 || figure27ModerateDivergentFlagConfirmationUp_M15 || figure29DoubleBottomConfirmationUp_M15 || figure31DivergentFlagConfirmationUp_M15 || figure33FlagWedgeForelockConfirmationUp_M15 || figure35TripleBottomConfirmationUp_M15 || figure37PennantWedgeUp_M15 || figure39RollbackChannelPennantConfirmationUp_M15 || figure41MoreDivergentFlagConfirmationUp_M15 || figure43ChannelFlagUp_M15 || figure45PennantAfterWedgeConfirmationUp_M15 || figure47PennantAfterFlagConfirmationUp_M15 || figure49DoublePennantAfterConfirmationUp_M15 || figure51WedgeConfirmationUp_M15;
     isM5FigureUp  =  figure1FlagUpContinueUp_M5 || figure1_1FlagUpContinueAfterDecliningUp_M5 || figure3TripleUp_M5    || figure5_1PennantUpConfirmationUp_M5  || figure7_1TurnUpDivergenceUp_M5  || figure7_2TurnDivergenceConfirmationUp_M5 || figure9FlagUpShiftUp_M5   /*|| figure11DoubleBottomUp_M5 */ || figure13_1DivergenceFlagConfirmationUp_M5  || figure15BalancedTriangleUp_M5 || figure17FlagConfirmationUp_M5 || figure19HeadAndShouldersConfirmationUp_M5 || figure21WedgeUp_M5 || figure23DiamondUp_M5 || figure25TriangleConfirmationUp_M5 || figure27ModerateDivergentFlagConfirmationUp_M5 || figure29DoubleBottomConfirmationUp_M5 || figure31DivergentFlagConfirmationUp_M5 || figure33FlagWedgeForelockConfirmationUp_M5 || figure35TripleBottomConfirmationUp_M5 || figure37PennantWedgeUp_M5 || figure39RollbackChannelPennantConfirmationUp_M5 || figure41MoreDivergentFlagConfirmationUp_M5 || figure43ChannelFlagUp_M5 || figure45PennantAfterWedgeConfirmationUp_M5 || figure47PennantAfterFlagConfirmationUp_M5 || figure49DoublePennantAfterConfirmationUp_M5 || figure51WedgeConfirmationUp_M5;
     isM1FigureUp  =  figure1FlagUpContinueUp_M1 || figure1_1FlagUpContinueAfterDecliningUp_M1 || figure3TripleUp_M1    || figure5_1PennantUpConfirmationUp_M1  || figure7_1TurnUpDivergenceUp_M1  || figure7_2TurnDivergenceConfirmationUp_M1 || figure9FlagUpShiftUp_M1   /*|| figure11DoubleBottomUp_M1 */ || figure13_1DivergenceFlagConfirmationUp_M1  || figure15BalancedTriangleUp_M1 || figure17FlagConfirmationUp_M1 || figure19HeadAndShouldersConfirmationUp_M1 || figure21WedgeUp_M1 || figure23DiamondUp_M1 || figure25TriangleConfirmationUp_M1 || figure27ModerateDivergentFlagConfirmationUp_M1 || figure29DoubleBottomConfirmationUp_M1 || figure31DivergentFlagConfirmationUp_M1 || figure33FlagWedgeForelockConfirmationUp_M1 || figure35TripleBottomConfirmationUp_M1 || figure37PennantWedgeUp_M1 || figure39RollbackChannelPennantConfirmationUp_M1 || figure41MoreDivergentFlagConfirmationUp_M1 || figure43ChannelFlagUp_M1 || figure45PennantAfterWedgeConfirmationUp_M1 || figure47PennantAfterFlagConfirmationUp_M1 || figure49DoublePennantAfterConfirmationUp_M1 || figure51WedgeConfirmationUp_M1;


     isD1FigureDown  =  figure2FlagDownContinueDown_D1 || figure2_1FlagDownContinueAfterDecreaseDown_D1 ||figure4TripleDown_D1      || figure6_1PennantDownConfirmationDown_D1  || figure8_1TurnDownDivergenceDown_D1  || figure8_2TurnDivergenceConfirmationDown_D1  || figure10FlagDownShiftDown_D1  /*|| figure12DoubleTopDown_D1 */ || figure14_1DivergenceFlagConfirmationDown_D1 || figure16BalancedTriangleDown_D1 || figure18FlagConfirmationDown_D1 || figure20HeadAndShouldersConfirmationDown_D1 || figure22WedgeDown_D1 || figure24DiamondDown_D1 || figure26TriangleConfirmationDown_D1 || figure28ModerateDivergentFlagConfirmationDown_D1 || figure30DoubleTopConfirmationDown_D1 || figure32DivergentFlagConfirmationDown_D1 || figure34FlagWedgeForelockConfirmationDown_D1 || figure36TripleTopConfirmationDown_D1 || figure38PennantWedgeDown_D1 || figure40RollbackChannelPennantConfirmationDown_D1 || figure42MoreDivergentFlagConfirmationDown_D1 || figure44ChannelFlagDown_D1 || figure46PennantAfterWedgeConfirmationDown_D1 || figure48PennantAfterFlagConfirmationDown_D1 || figure50DoublePennantAfterConfirmationDown_D1 || figure52WedgeConfirmationDown_D1;
     isH4FigureDown  =  figure2FlagDownContinueDown_H4 || figure2_1FlagDownContinueAfterDecreaseDown_H4 ||figure4TripleDown_H4      || figure6_1PennantDownConfirmationDown_H4  || figure8_1TurnDownDivergenceDown_H4  || figure8_2TurnDivergenceConfirmationDown_H4  || figure10FlagDownShiftDown_H4  /*|| figure12DoubleTopDown_H4 */ || figure14_1DivergenceFlagConfirmationDown_H4 || figure16BalancedTriangleDown_H4 || figure18FlagConfirmationDown_H4 || figure20HeadAndShouldersConfirmationDown_H4 || figure22WedgeDown_H4 || figure24DiamondDown_H4 || figure26TriangleConfirmationDown_H4 || figure28ModerateDivergentFlagConfirmationDown_H4 || figure30DoubleTopConfirmationDown_H4 || figure32DivergentFlagConfirmationDown_H4 || figure34FlagWedgeForelockConfirmationDown_H4 || figure36TripleTopConfirmationDown_H4 || figure38PennantWedgeDown_H4 || figure40RollbackChannelPennantConfirmationDown_H4 || figure42MoreDivergentFlagConfirmationDown_H4 || figure44ChannelFlagDown_H4 || figure46PennantAfterWedgeConfirmationDown_H4 || figure48PennantAfterFlagConfirmationDown_H4 || figure50DoublePennantAfterConfirmationDown_H4 || figure52WedgeConfirmationDown_H4;
     isH1FigureDown  =  figure2FlagDownContinueDown_H1 || figure2_1FlagDownContinueAfterDecreaseDown_H1 ||figure4TripleDown_H1      || figure6_1PennantDownConfirmationDown_H1  || figure8_1TurnDownDivergenceDown_H1  || figure8_2TurnDivergenceConfirmationDown_H1  || figure10FlagDownShiftDown_H1  /*|| figure12DoubleTopDown_H1 */ || figure14_1DivergenceFlagConfirmationDown_H1 || figure16BalancedTriangleDown_H1 || figure18FlagConfirmationDown_H1 || figure20HeadAndShouldersConfirmationDown_H1 || figure22WedgeDown_H1 || figure24DiamondDown_H1 || figure26TriangleConfirmationDown_H1 || figure28ModerateDivergentFlagConfirmationDown_H1 || figure30DoubleTopConfirmationDown_H1 || figure32DivergentFlagConfirmationDown_H1 || figure34FlagWedgeForelockConfirmationDown_H1 || figure36TripleTopConfirmationDown_H1 || figure38PennantWedgeDown_H1 || figure40RollbackChannelPennantConfirmationDown_H1 || figure42MoreDivergentFlagConfirmationDown_H1 || figure44ChannelFlagDown_H1 || figure46PennantAfterWedgeConfirmationDown_H1 || figure48PennantAfterFlagConfirmationDown_H1 || figure50DoublePennantAfterConfirmationDown_H1 || figure52WedgeConfirmationDown_H1;
     isM15FigureDown =  figure2FlagDownContinueDown_M15 || figure2_1FlagDownContinueAfterDecreaseDown_M15 ||figure4TripleDown_M15   || figure6_1PennantDownConfirmationDown_M15 || figure8_1TurnDownDivergenceDown_M15 || figure8_2TurnDivergenceConfirmationDown_M15 || figure10FlagDownShiftDown_M15 /*|| figure12DoubleTopDown_M15*/ || figure14_1DivergenceFlagConfirmationDown_M15 || figure16BalancedTriangleDown_M15 || figure18FlagConfirmationDown_M15 || figure20HeadAndShouldersConfirmationDown_M15 || figure22WedgeDown_M15 || figure24DiamondDown_M15 || figure26TriangleConfirmationDown_M15 || figure28ModerateDivergentFlagConfirmationDown_M15 || figure30DoubleTopConfirmationDown_M15 || figure32DivergentFlagConfirmationDown_M15 || figure34FlagWedgeForelockConfirmationDown_M15 || figure36TripleTopConfirmationDown_M15 || figure38PennantWedgeDown_M15 || figure40RollbackChannelPennantConfirmationDown_M15 || figure42MoreDivergentFlagConfirmationDown_M15 || figure44ChannelFlagDown_M15 || figure46PennantAfterWedgeConfirmationDown_M15 || figure48PennantAfterFlagConfirmationDown_M15 || figure50DoublePennantAfterConfirmationDown_M15 || figure52WedgeConfirmationDown_M15;
     isM5FigureDown  =  figure2FlagDownContinueDown_M5 || figure2_1FlagDownContinueAfterDecreaseDown_M5 ||figure4TripleDown_M5      || figure6_1PennantDownConfirmationDown_M5  || figure8_1TurnDownDivergenceDown_M5  || figure8_2TurnDivergenceConfirmationDown_M5  || figure10FlagDownShiftDown_M5  /*|| figure12DoubleTopDown_M5 */ || figure14_1DivergenceFlagConfirmationDown_M5 || figure16BalancedTriangleDown_M5 || figure18FlagConfirmationDown_M5 || figure20HeadAndShouldersConfirmationDown_M5 || figure22WedgeDown_M5 || figure24DiamondDown_M5 || figure26TriangleConfirmationDown_M5 || figure28ModerateDivergentFlagConfirmationDown_M5 || figure30DoubleTopConfirmationDown_M5 || figure32DivergentFlagConfirmationDown_M5 || figure34FlagWedgeForelockConfirmationDown_M5 || figure36TripleTopConfirmationDown_M5 || figure38PennantWedgeDown_M5 || figure40RollbackChannelPennantConfirmationDown_M5 || figure42MoreDivergentFlagConfirmationDown_M5 || figure44ChannelFlagDown_M5 || figure46PennantAfterWedgeConfirmationDown_M5 || figure48PennantAfterFlagConfirmationDown_M5 || figure50DoublePennantAfterConfirmationDown_M5 || figure52WedgeConfirmationDown_M5;
     isM1FigureDown  =  figure2FlagDownContinueDown_M1 || figure2_1FlagDownContinueAfterDecreaseDown_M1 ||figure4TripleDown_M1      || figure6_1PennantDownConfirmationDown_M1  || figure8_1TurnDownDivergenceDown_M1  || figure8_2TurnDivergenceConfirmationDown_M1  || figure10FlagDownShiftDown_M1  /*|| figure12DoubleTopDown_M1 */ || figure14_1DivergenceFlagConfirmationDown_M1 || figure16BalancedTriangleDown_M1 || figure18FlagConfirmationDown_M1 || figure20HeadAndShouldersConfirmationDown_M1 || figure22WedgeDown_M1 || figure24DiamondDown_M1 || figure26TriangleConfirmationDown_M1 || figure28ModerateDivergentFlagConfirmationDown_M1 || figure30DoubleTopConfirmationDown_M1 || figure32DivergentFlagConfirmationDown_M1 || figure34FlagWedgeForelockConfirmationDown_M1 || figure36TripleTopConfirmationDown_M1 || figure38PennantWedgeDown_M1 || figure40RollbackChannelPennantConfirmationDown_M1 || figure42MoreDivergentFlagConfirmationDown_M1 || figure44ChannelFlagDown_M1 || figure46PennantAfterWedgeConfirmationDown_M1 || figure48PennantAfterFlagConfirmationDown_M1 || figure50DoublePennantAfterConfirmationDown_M1 || figure52WedgeConfirmationDown_M1;

     isFigureUp     = isD1FigureUp || isH4FigureUp || isH1FigureUp || isM15FigureUp|| isM5FigureUp ;
     isFigureDown   = isD1FigureDown || isH4FigureDown || isH1FigureDown || isM15FigureDown || isM5FigureDown ;


is11PositionFigureUp_M15    = figure29DoubleBottomConfirmationUp_M15 ||figure45PennantAfterWedgeConfirmationUp_M15;
is10PositionFigureUp_M15    = figure47PennantAfterFlagConfirmationUp_M15 || figure49DoublePennantAfterConfirmationUp_M15;
is9PositionFigureUp_M15     = figure25TriangleConfirmationUp_M15 || figure39RollbackChannelPennantConfirmationUp_M15;

is11PositionFigureDown_M15  = figure30DoubleTopConfirmationDown_M15 || figure46PennantAfterWedgeConfirmationDown_M15;
is10PositionFigureDown_M15  = figure48PennantAfterFlagConfirmationDown_M15 || figure50DoublePennantAfterConfirmationDown_M15;
is9PositionFigureDown_M15  = figure26TriangleConfirmationDown_M15 || figure40RollbackChannelPennantConfirmationDown_M15;


      if
      (
isFigureUp
      )

      {
Print("figure1_1FlagUpContinueAfterDecliningUp_M1 =  ",figure1_1FlagUpContinueAfterDecliningUp_M1);
Print("figure5_1PennantUpConfirmationUp_M1 =         ",figure5_1PennantUpConfirmationUp_M1);
Print("figure7_1TurnUpDivergenceUp_M1 =              ",figure7_1TurnUpDivergenceUp_M1);
Print("figure7_2TurnDivergenceConfirmationUp_M1 =    ",figure7_2TurnDivergenceConfirmationUp_M1);
Print("figure1FlagUpContinueUp_M1 =                  ",figure1FlagUpContinueUp_M1,                  " figure3TripleUp_M1 =                              ",figure3TripleUp_M1,               " figure5PennantUp_M1 =         ",figure5PennantUp_M1);
Print("figure7FlagUpDivergenceUp_M1 =                ",figure7FlagUpDivergenceUp_M1,                " figure9FlagUpShiftUp_M1 =                         ",figure9FlagUpShiftUp_M1,          " figure11DoubleBottomUp_M1 =   ",figure11DoubleBottomUp_M1);
Print("figure13DivergentChannelUp_M1 =               ",figure13DivergentChannelUp_M1,               " figure15BalancedTriangleUp_M1 =                   ",figure15BalancedTriangleUp_M1);
Print("figure17FlagConfirmationUp_M1 =               ",figure17FlagConfirmationUp_M1,               " figure19HeadAndShouldersConfirmationUp_M1 =       ",figure19HeadAndShouldersConfirmationUp_M1);
Print("figure21WedgeUp_M1 =                          ",figure21WedgeUp_M1,                          " figure23DiamondUp_M1 =                            ",figure23DiamondUp_M1);
Print("figure25TriangleConfirmationUp_M1 =           ",figure25TriangleConfirmationUp_M1,           " figure27ModerateDivergentFlagConfirmationUp_M1 =  ",figure27ModerateDivergentFlagConfirmationUp_M1);
Print("figure29DoubleBottomConfirmationUp_M1 =       ",figure29DoubleBottomConfirmationUp_M1,       " figure31DivergentFlagConfirmationUp_M1 =          ",figure31DivergentFlagConfirmationUp_M1);
Print("figure33FlagWedgeForelockConfirmationUp_M1 =  ",figure33FlagWedgeForelockConfirmationUp_M1,  " figure35TripleBottomConfirmationUp_M1 =           ",figure35TripleBottomConfirmationUp_M1);
Print("figure37PennantWedgeUp_M1 =                   ",figure37PennantWedgeUp_M1,                   " figure39RollbackChannelPennantConfirmationUp_M1 = ",figure39RollbackChannelPennantConfirmationUp_M1);
Print("figure41MoreDivergentFlagConfirmationUp_M1 =  ",figure41MoreDivergentFlagConfirmationUp_M1,  " figure43ChannelFlagUp_M1 =                        ",figure43ChannelFlagUp_M1);
Print("figure45PennantAfterWedgeConfirmationUp_M1 =  ",figure45PennantAfterWedgeConfirmationUp_M1,  " figure47PennantAfterFlagConfirmationUp_M1 =       ",figure47PennantAfterFlagConfirmationUp_M1);
Print("figure49DoublePennantAfterConfirmationUp_M1 = ",figure49DoublePennantAfterConfirmationUp_M1, " figure51WedgeConfirmationUp_M1 =                  ",figure51WedgeConfirmationUp_M1);
Print("figure13_1DivergenceFlagConfirmationUp_M1 =    ",figure13_1DivergenceFlagConfirmationUp_M1);

Print("figure1_1FlagUpContinueAfterDecliningUp_M5 =  ",figure1_1FlagUpContinueAfterDecliningUp_M5);
Print("figure5_1PennantUpConfirmationUp_M5 =         ",figure5_1PennantUpConfirmationUp_M5);
Print("figure7_1TurnUpDivergenceUp_M5 =              ",figure7_1TurnUpDivergenceUp_M5);
Print("figure7_2TurnDivergenceConfirmationUp_M5 =    ",figure7_2TurnDivergenceConfirmationUp_M5);
Print("figure1FlagUpContinueUp_M5 =                  ",figure1FlagUpContinueUp_M5,                  " figure3TripleUp_M5 =                              ",figure3TripleUp_M5,               " figure5PennantUp_M5 =         ",figure5PennantUp_M5);
Print("figure7FlagUpDivergenceUp_M5 =                ",figure7FlagUpDivergenceUp_M5,                " figure9FlagUpShiftUp_M5 =                         ",figure9FlagUpShiftUp_M5,          " figure11DoubleBottomUp_M5 =   ",figure11DoubleBottomUp_M5);
Print("figure13DivergentChannelUp_M5 =               ",figure13DivergentChannelUp_M5,               " figure15BalancedTriangleUp_M5 =                   ",figure15BalancedTriangleUp_M5);
Print("figure17FlagConfirmationUp_M5 =               ",figure17FlagConfirmationUp_M5,               " figure19HeadAndShouldersConfirmationUp_M5 =       ",figure19HeadAndShouldersConfirmationUp_M5);
Print("figure21WedgeUp_M5 =                          ",figure21WedgeUp_M5,                          " figure23DiamondUp_M5 =                            ",figure23DiamondUp_M5);
Print("figure25TriangleConfirmationUp_M5 =           ",figure25TriangleConfirmationUp_M5,           " figure27ModerateDivergentFlagConfirmationUp_M5 =  ",figure27ModerateDivergentFlagConfirmationUp_M5);
Print("figure29DoubleBottomConfirmationUp_M5 =       ",figure29DoubleBottomConfirmationUp_M5,       " figure31DivergentFlagConfirmationUp_M5 =          ",figure31DivergentFlagConfirmationUp_M5);
Print("figure33FlagWedgeForelockConfirmationUp_M5 =  ",figure33FlagWedgeForelockConfirmationUp_M5,  " figure35TripleBottomConfirmationUp_M5 =           ",figure35TripleBottomConfirmationUp_M5);
Print("figure37PennantWedgeUp_M5 =                   ",figure37PennantWedgeUp_M5,                   " figure39RollbackChannelPennantConfirmationUp_M5 = ",figure39RollbackChannelPennantConfirmationUp_M5);
Print("figure41MoreDivergentFlagConfirmationUp_M5 =  ",figure41MoreDivergentFlagConfirmationUp_M5,  " figure43ChannelFlagUp_M5 =                        ",figure43ChannelFlagUp_M5);
Print("figure45PennantAfterWedgeConfirmationUp_M5 =  ",figure45PennantAfterWedgeConfirmationUp_M5,  " figure47PennantAfterFlagConfirmationUp_M5 =       ",figure47PennantAfterFlagConfirmationUp_M5);
Print("figure49DoublePennantAfterConfirmationUp_M5 = ",figure49DoublePennantAfterConfirmationUp_M5, " figure51WedgeConfirmationUp_M5 =                  ",figure51WedgeConfirmationUp_M5);
Print("figure13_1DivergenceFlagConfirmationUp_M5 =    ",figure13_1DivergenceFlagConfirmationUp_M5);

Print("figure1_1FlagUpContinueAfterDecliningUp_M15 = ",figure1_1FlagUpContinueAfterDecliningUp_M15);
Print("figure5_1PennantUpConfirmationUp_M15 =        ",figure5_1PennantUpConfirmationUp_M15);
Print("figure7_1TurnUpDivergenceUp_M15 =             ",figure7_1TurnUpDivergenceUp_M15);
Print("figure7_2TurnDivergenceConfirmationUp_M15 =   ",figure7_2TurnDivergenceConfirmationUp_M15);
Print("figure1FlagUpContinueUp_M15 =                 ",figure1FlagUpContinueUp_M15,                 " figure3TripleUp_M15 =                             ",figure3TripleUp_M15,               " figure5PennantUp_M15 =         ",figure5PennantUp_M15);
Print("figure7FlagUpDivergenceUp_M15 =               ",figure7FlagUpDivergenceUp_M15,               " figure9FlagUpShiftUp_M15 =                        ",figure9FlagUpShiftUp_M15,          " figure11DoubleBottomUp_M15 =   ",figure11DoubleBottomUp_M15);
Print("figure13DivergentChannelUp_M15 =              ",figure13DivergentChannelUp_M15,              " figure15BalancedTriangleUp_M15 =                  ",figure15BalancedTriangleUp_M15);
Print("figure17FlagConfirmationUp_M15 =              ",figure17FlagConfirmationUp_M15,              " figure19HeadAndShouldersConfirmationUp_M15 =      ",figure19HeadAndShouldersConfirmationUp_M15);
Print("figure21WedgeUp_M15 =                         ",figure21WedgeUp_M15,                         " figure23DiamondUp_M15 =                           ",figure23DiamondUp_M15);
Print("figure25TriangleConfirmationUp_M15 =          ",figure25TriangleConfirmationUp_M15,          " figure27ModerateDivergentFlagConfirmationUp_M15 = ",figure27ModerateDivergentFlagConfirmationUp_M15);
Print("figure29DoubleBottomConfirmationUp_M15 =      ",figure29DoubleBottomConfirmationUp_M15,      " figure31DivergentFlagConfirmationUp_M15 =         ",figure31DivergentFlagConfirmationUp_M15);
Print("figure33FlagWedgeForelockConfirmationUp_M15 = ",figure33FlagWedgeForelockConfirmationUp_M15, " figure35TripleBottomConfirmationUp_M15 =          ",figure35TripleBottomConfirmationUp_M15);
Print("figure37PennantWedgeUp_M15 =                  ",figure37PennantWedgeUp_M15,                  " figure39RollbackChannelPennantConfirmationUp_M15 =",figure39RollbackChannelPennantConfirmationUp_M15);
Print("figure41MoreDivergentFlagConfirmationUp_M15 = ",figure41MoreDivergentFlagConfirmationUp_M15, " figure43ChannelFlagUp_M15 =                       ",figure43ChannelFlagUp_M15);
Print("figure45PennantAfterWedgeConfirmationUp_M15 = ",figure45PennantAfterWedgeConfirmationUp_M15, " figure47PennantAfterFlagConfirmationUp_M15 =      ",figure47PennantAfterFlagConfirmationUp_M15);
Print("figure49DoublePennantAfterConfirmationUp_M15 =",figure49DoublePennantAfterConfirmationUp_M15," figure51WedgeConfirmationUp_M15 =                 ",figure51WedgeConfirmationUp_M15);
Print("figure13_1DivergenceFlagConfirmationUp_M15 =   ",figure13_1DivergenceFlagConfirmationUp_M15);

Print("figure1_1FlagUpContinueAfterDecliningUp_H1 =  ",figure1_1FlagUpContinueAfterDecliningUp_H1);
Print("figure5_1PennantUpConfirmationUp_H1 =         ",figure5_1PennantUpConfirmationUp_H1);
Print("figure7_1TurnUpDivergenceUp_H1 =              ",figure7_1TurnUpDivergenceUp_H1);
Print("figure7_2TurnDivergenceConfirmationUp_H1 =    ",figure7_2TurnDivergenceConfirmationUp_H1);
Print("figure1FlagUpContinueUp_H1 =                  ",figure1FlagUpContinueUp_H1,                  " figure3TripleUp_H1 =                              ",figure3TripleUp_H1,               " figure5PennantUp_H1 =         ",figure5PennantUp_H1);
Print("figure7FlagUpDivergenceUp_H1 =                ",figure7FlagUpDivergenceUp_H1,                " figure9FlagUpShiftUp_H1 =                         ",figure9FlagUpShiftUp_H1,          " figure11DoubleBottomUp_H1 =   ",figure11DoubleBottomUp_H1);
Print("figure13DivergentChannelUp_H1 =               ",figure13DivergentChannelUp_H1,               " figure15BalancedTriangleUp_H1 =                   ",figure15BalancedTriangleUp_H1);
Print("figure17FlagConfirmationUp_H1 =               ",figure17FlagConfirmationUp_H1,               " figure19HeadAndShouldersConfirmationUp_H1 =       ",figure19HeadAndShouldersConfirmationUp_H1);
Print("figure21WedgeUp_H1 =                          ",figure21WedgeUp_H1,                          " figure23DiamondUp_H1 =                            ",figure23DiamondUp_H1);
Print("figure25TriangleConfirmationUp_H1 =           ",figure25TriangleConfirmationUp_H1,           " figure27ModerateDivergentFlagConfirmationUp_H1 =  ",figure27ModerateDivergentFlagConfirmationUp_H1);
Print("figure29DoubleBottomConfirmationUp_H1 =       ",figure29DoubleBottomConfirmationUp_H1,       " figure31DivergentFlagConfirmationUp_H1 =          ",figure31DivergentFlagConfirmationUp_H1);
Print("figure33FlagWedgeForelockConfirmationUp_H1 =  ",figure33FlagWedgeForelockConfirmationUp_H1,  " figure35TripleBottomConfirmationUp_H1 =           ",figure35TripleBottomConfirmationUp_H1);
Print("figure37PennantWedgeUp_H1 =                   ",figure37PennantWedgeUp_H1,                   " figure39RollbackChannelPennantConfirmationUp_H1 = ",figure39RollbackChannelPennantConfirmationUp_H1);
Print("figure41MoreDivergentFlagConfirmationUp_H1 =  ",figure41MoreDivergentFlagConfirmationUp_H1,  " figure43ChannelFlagUp_H1 =                        ",figure43ChannelFlagUp_H1);
Print("figure45PennantAfterWedgeConfirmationUp_H1 =  ",figure45PennantAfterWedgeConfirmationUp_H1,  " figure47PennantAfterFlagConfirmationUp_H1 =       ",figure47PennantAfterFlagConfirmationUp_H1);
Print("figure49DoublePennantAfterConfirmationUp_H1 = ",figure49DoublePennantAfterConfirmationUp_H1, " figure51WedgeConfirmationUp_H1 =                  ",figure51WedgeConfirmationUp_H1);
Print("figure13_1DivergenceFlagConfirmationUp_H1 =    ",figure13_1DivergenceFlagConfirmationUp_H1);

Print("figure1_1FlagUpContinueAfterDecliningUp_H4 =  ",figure1_1FlagUpContinueAfterDecliningUp_H4);
Print("figure5_1PennantUpConfirmationUp_H4 =         ",figure5_1PennantUpConfirmationUp_H4);
Print("figure7_1TurnUpDivergenceUp_H4 =              ",figure7_1TurnUpDivergenceUp_H4);
Print("figure7_2TurnDivergenceConfirmationUp_H4 =    ",figure7_2TurnDivergenceConfirmationUp_H4);
Print("figure1FlagUpContinueUp_H4 =                  ",figure1FlagUpContinueUp_H4,                  " figure3TripleUp_H4 =                              ",figure3TripleUp_H4,               " figure5PennantUp_H4 =         ",figure5PennantUp_H4);
Print("figure7FlagUpDivergenceUp_H4 =                ",figure7FlagUpDivergenceUp_H4,                " figure9FlagUpShiftUp_H4 =                         ",figure9FlagUpShiftUp_H4,          " figure11DoubleBottomUp_H4 =   ",figure11DoubleBottomUp_H4);
Print("figure13DivergentChannelUp_H4 =               ",figure13DivergentChannelUp_H4,               " figure15BalancedTriangleUp_H4 =                   ",figure15BalancedTriangleUp_H4);
Print("figure17FlagConfirmationUp_H4 =               ",figure17FlagConfirmationUp_H4,               " figure19HeadAndShouldersConfirmationUp_H4 =       ",figure19HeadAndShouldersConfirmationUp_H4);
Print("figure21WedgeUp_H4 =                          ",figure21WedgeUp_H4,                          " figure23DiamondUp_H4 =                            ",figure23DiamondUp_H4);
Print("figure25TriangleConfirmationUp_H4 =           ",figure25TriangleConfirmationUp_H4,           " figure27ModerateDivergentFlagConfirmationUp_H4 =  ",figure27ModerateDivergentFlagConfirmationUp_H4);
Print("figure29DoubleBottomConfirmationUp_H4 =       ",figure29DoubleBottomConfirmationUp_H4,       " figure31DivergentFlagConfirmationUp_H4 =          ",figure31DivergentFlagConfirmationUp_H4);
Print("figure33FlagWedgeForelockConfirmationUp_H4 =  ",figure33FlagWedgeForelockConfirmationUp_H4,  " figure35TripleBottomConfirmationUp_H4 =           ",figure35TripleBottomConfirmationUp_H4);
Print("figure37PennantWedgeUp_H4 =                   ",figure37PennantWedgeUp_H4,                   " figure39RollbackChannelPennantConfirmationUp_H4 = ",figure39RollbackChannelPennantConfirmationUp_H4);
Print("figure41MoreDivergentFlagConfirmationUp_H4 =  ",figure41MoreDivergentFlagConfirmationUp_H4,  " figure43ChannelFlagUp_H4 =                        ",figure43ChannelFlagUp_H4);
Print("figure45PennantAfterWedgeConfirmationUp_H4 =  ",figure45PennantAfterWedgeConfirmationUp_H4,  " figure47PennantAfterFlagConfirmationUp_H4 =       ",figure47PennantAfterFlagConfirmationUp_H4);
Print("figure49DoublePennantAfterConfirmationUp_H4 = ",figure49DoublePennantAfterConfirmationUp_H4, " figure51WedgeConfirmationUp_H4 =                  ",figure51WedgeConfirmationUp_H4);
Print("figure13_1DivergenceFlagConfirmationUp_H4 =    ",figure13_1DivergenceFlagConfirmationUp_H4);

Print("figure1_1FlagUpContinueAfterDecliningUp_D1 =  ",figure1_1FlagUpContinueAfterDecliningUp_D1);
Print("figure5_1PennantUpConfirmationUp_D1 =         ",figure5_1PennantUpConfirmationUp_D1);
Print("figure7_1TurnUpDivergenceUp_D1 =              ",figure7_1TurnUpDivergenceUp_D1);
Print("figure7_2TurnDivergenceConfirmationUp_D1 =    ",figure7_2TurnDivergenceConfirmationUp_D1);
Print("figure1FlagUpContinueUp_D1 =                  ",figure1FlagUpContinueUp_D1,                  " figure3TripleUp_D1 =                              ",figure3TripleUp_D1,               " figure5PennantUp_D1 =         ",figure5PennantUp_D1);
Print("figure7FlagUpDivergenceUp_D1 =                ",figure7FlagUpDivergenceUp_D1,                " figure9FlagUpShiftUp_D1 =                         ",figure9FlagUpShiftUp_D1,          " figure11DoubleBottomUp_D1 =   ",figure11DoubleBottomUp_D1);
Print("figure13DivergentChannelUp_D1 =               ",figure13DivergentChannelUp_D1,               " figure15BalancedTriangleUp_D1 =                   ",figure15BalancedTriangleUp_D1);
Print("figure17FlagConfirmationUp_D1 =               ",figure17FlagConfirmationUp_D1,               " figure19HeadAndShouldersConfirmationUp_D1 =       ",figure19HeadAndShouldersConfirmationUp_D1);
Print("figure21WedgeUp_D1 =                          ",figure21WedgeUp_D1,                          " figure23DiamondUp_D1 =                            ",figure23DiamondUp_D1);
Print("figure25TriangleConfirmationUp_D1 =           ",figure25TriangleConfirmationUp_D1,           " figure27ModerateDivergentFlagConfirmationUp_D1 =  ",figure27ModerateDivergentFlagConfirmationUp_D1);
Print("figure29DoubleBottomConfirmationUp_D1 =       ",figure29DoubleBottomConfirmationUp_D1,       " figure31DivergentFlagConfirmationUp_D1 =          ",figure31DivergentFlagConfirmationUp_D1);
Print("figure33FlagWedgeForelockConfirmationUp_D1 =  ",figure33FlagWedgeForelockConfirmationUp_D1,  " figure35TripleBottomConfirmationUp_D1 =           ",figure35TripleBottomConfirmationUp_D1);
Print("figure37PennantWedgeUp_D1 =                   ",figure37PennantWedgeUp_D1,                   " figure39RollbackChannelPennantConfirmationUp_D1 = ",figure39RollbackChannelPennantConfirmationUp_D1);
Print("figure41MoreDivergentFlagConfirmationUp_D1 =  ",figure41MoreDivergentFlagConfirmationUp_D1,  " figure43ChannelFlagUp_D1 =                        ",figure43ChannelFlagUp_D1);
Print("figure45PennantAfterWedgeConfirmationUp_D1 =  ",figure45PennantAfterWedgeConfirmationUp_D1,  " figure47PennantAfterFlagConfirmationUp_D1 =       ",figure47PennantAfterFlagConfirmationUp_D1);
Print("figure49DoublePennantAfterConfirmationUp_D1 = ",figure49DoublePennantAfterConfirmationUp_D1, " figure51WedgeConfirmationUp_D1 =                  ",figure51WedgeConfirmationUp_D1);
Print("figure13_1DivergenceFlagConfirmationUp_D1 =    ",figure13_1DivergenceFlagConfirmationUp_D1);

      buy=1;
      }

      if
      (
isFigureDown
      )

      {

Print("figure2_1FlagDownContinueAfterDecreaseDown_M1 =  ", figure2_1FlagDownContinueAfterDecreaseDown_M1);
Print("figure6_1PennantDownConfirmationDown_M1 =        ", figure6_1PennantDownConfirmationDown_M1);
Print("figure8_1TurnDownDivergenceDown_M1 =             ", figure8_1TurnDownDivergenceDown_M1);
Print("figure8_2TurnDivergenceConfirmationDown_M1 =     ", figure8_2TurnDivergenceConfirmationDown_M1);
Print("figure2FlagDownContinueDown_M1 =                 ", figure2FlagDownContinueDown_M1,                  " figure4TripleDown_M1 =                                ", figure4TripleDown_M1,            " figure6PennantDown_M1 =       ", figure6PennantDown_M1);
Print("figure8FlagDownDivergenceDown_M1 =               ", figure8FlagDownDivergenceDown_M1,                " figure10FlagDownShiftDown_M1 =                        ", figure10FlagDownShiftDown_M1,    " figure12DoubleTopDown_M1 =    ", figure12DoubleTopDown_M1);
Print("figure14DivergentChannelDown_M1 =                ", figure14DivergentChannelDown_M1,                 " figure16BalancedTriangleDown_M1 =                     ",figure16BalancedTriangleDown_M1);
Print("figure18FlagConfirmationDown_M1 =                ", figure18FlagConfirmationDown_M1,                 " figure20HeadAndShouldersConfirmationDown_M1 =         ",figure20HeadAndShouldersConfirmationDown_M1);
Print("figure22WedgeDown_M1 =                           ", figure22WedgeDown_M1,                            " figure24DiamondDown_M1 =                              ",figure24DiamondDown_M1);
Print("figure26TriangleConfirmationDown_M1 =            ", figure26TriangleConfirmationDown_M1,             " figure28ModerateDivergentFlagConfirmationDown_M1 =    ",figure28ModerateDivergentFlagConfirmationDown_M1);
Print("figure30DoubleTopConfirmationDown_M1 =           ", figure30DoubleTopConfirmationDown_M1,            " figure32DivergentFlagConfirmationDown_M1 =            ",figure32DivergentFlagConfirmationDown_M1);
Print("figure34FlagWedgeForelockConfirmationDown_M1 =   ", figure34FlagWedgeForelockConfirmationDown_M1,    " figure36TripleTopConfirmationDown_M1 =                ",figure36TripleTopConfirmationDown_M1);
Print("figure38PennantWedgeDown_M1 =                    ", figure38PennantWedgeDown_M1,                     " figure40RollbackChannelPennantConfirmationDown_M1 =   ",figure40RollbackChannelPennantConfirmationDown_M1);
Print("figure42MoreDivergentFlagConfirmationDown_M1 =   ", figure42MoreDivergentFlagConfirmationDown_M1,    " figure44ChannelFlagDown_M1 =                          ",figure44ChannelFlagDown_M1);
Print("figure46PennantAfterWedgeConfirmationDown_M1 =   ", figure46PennantAfterWedgeConfirmationDown_M1,    " figure48PennantAfterFlagConfirmationDown_M1 =         ",figure48PennantAfterFlagConfirmationDown_M1);
Print("figure50DoublePennantAfterConfirmationDown_M1 =  ", figure50DoublePennantAfterConfirmationDown_M1,   " figure52WedgeConfirmationDown_M1 =                    ",figure52WedgeConfirmationDown_M1);
Print("figure14_1DivergenceFlagConfirmationDown_M1  = ", figure14_1DivergenceFlagConfirmationDown_M1);

Print("figure2_1FlagDownContinueAfterDecreaseDown_M5 =  ", figure2_1FlagDownContinueAfterDecreaseDown_M5);
Print("figure6_1PennantDownConfirmationDown_M5 =        ", figure6_1PennantDownConfirmationDown_M5);
Print("figure8_1TurnDownDivergenceDown_M5 =             ", figure8_1TurnDownDivergenceDown_M5);
Print("figure8_2TurnDivergenceConfirmationDown_M5 =     ", figure8_2TurnDivergenceConfirmationDown_M5);
Print("figure2FlagDownContinueDown_M5 =                 ", figure2FlagDownContinueDown_M5,                  " figure4TripleDown_M5 =                                ", figure4TripleDown_M5,            " figure6PennantDown_M5 =       ", figure6PennantDown_M5);
Print("figure8FlagDownDivergenceDown_M5 =               ", figure8FlagDownDivergenceDown_M5,                " figure10FlagDownShiftDown_M5 =                        ", figure10FlagDownShiftDown_M5,    " figure12DoubleTopDown_M5 =    ", figure12DoubleTopDown_M5);
Print("figure14DivergentChannelDown_M5 =                ", figure14DivergentChannelDown_M5,                 " figure16BalancedTriangleDown_M5 =                     ",figure16BalancedTriangleDown_M5);
Print("figure18FlagConfirmationDown_M5 =                ", figure18FlagConfirmationDown_M5,                 " figure20HeadAndShouldersConfirmationDown_M5 =         ",figure20HeadAndShouldersConfirmationDown_M5);
Print("figure22WedgeDown_M5 =                           ", figure22WedgeDown_M5,                            " figure24DiamondDown_M5 =                              ",figure24DiamondDown_M5);
Print("figure26TriangleConfirmationDown_M5 =            ", figure26TriangleConfirmationDown_M5,             " figure28ModerateDivergentFlagConfirmationDown_M5 =    ",figure28ModerateDivergentFlagConfirmationDown_M5);
Print("figure30DoubleTopConfirmationDown_M5 =           ", figure30DoubleTopConfirmationDown_M5,            " figure32DivergentFlagConfirmationDown_M5 =            ",figure32DivergentFlagConfirmationDown_M5);
Print("figure34FlagWedgeForelockConfirmationDown_M5 =   ", figure34FlagWedgeForelockConfirmationDown_M5,    " figure36TripleTopConfirmationDown_M5 =                ",figure36TripleTopConfirmationDown_M5);
Print("figure38PennantWedgeDown_M5 =                    ", figure38PennantWedgeDown_M5,                     " figure40RollbackChannelPennantConfirmationDown_M5 =   ",figure40RollbackChannelPennantConfirmationDown_M5);
Print("figure42MoreDivergentFlagConfirmationDown_M5 =   ", figure42MoreDivergentFlagConfirmationDown_M5,    " figure44ChannelFlagDown_M5 =                          ",figure44ChannelFlagDown_M5);
Print("figure46PennantAfterWedgeConfirmationDown_M5 =   ", figure46PennantAfterWedgeConfirmationDown_M5,    " figure48PennantAfterFlagConfirmationDown_M5 =         ",figure48PennantAfterFlagConfirmationDown_M5);
Print("figure50DoublePennantAfterConfirmationDown_M5 =  ", figure50DoublePennantAfterConfirmationDown_M5,   " figure52WedgeConfirmationDown_M5 =                    ",figure52WedgeConfirmationDown_M5);
Print("figure14_1DivergenceFlagConfirmationDown_M5  = ", figure14_1DivergenceFlagConfirmationDown_M5);


Print("figure2_1FlagDownContinueAfterDecreaseDown_M15 = ", figure2_1FlagDownContinueAfterDecreaseDown_M15);
Print("figure6_1PennantDownConfirmationDown_M15 =       ", figure6_1PennantDownConfirmationDown_M15);
Print("figure8_1TurnDownDivergenceDown_M15 =            ", figure8_1TurnDownDivergenceDown_M15);
Print("figure6_1PennantDownConfirmationDown_M15 =       ", figure2_1FlagDownContinueAfterDecreaseDown_M15);
Print("figure2FlagDownContinueDown_M15 =                ", figure2FlagDownContinueDown_M15,                 " figure4TripleDown_M15 =                               ", figure4TripleDown_M15,            " figure6PennantDown_M15 =       ", figure6PennantDown_M15);
Print("figure8FlagDownDivergenceDown_M15 =              ", figure8FlagDownDivergenceDown_M15,               " figure10FlagDownShiftDown_M15 =                       ", figure10FlagDownShiftDown_M15,    " figure12DoubleTopDown_M15 =    ", figure12DoubleTopDown_M15);
Print("figure14DivergentChannelDown_M15 =               ", figure14DivergentChannelDown_M15,                " figure16BalancedTriangleDown_M15 =                    ", figure16BalancedTriangleDown_M15);
Print("figure18FlagConfirmationDown_M15 =               ", figure18FlagConfirmationDown_M15,                " figure20HeadAndShouldersConfirmationDown_M15 =        ", figure20HeadAndShouldersConfirmationDown_M15);
Print("figure22WedgeDown_M15 =                          ", figure22WedgeDown_M15,                           " figure24DiamondDown_M15 =                             ", figure24DiamondDown_M15);
Print("figure26TriangleConfirmationDown_M15 =           ", figure26TriangleConfirmationDown_M15,            " figure28ModerateDivergentFlagConfirmationDown_M15 =   ", figure28ModerateDivergentFlagConfirmationDown_M15);
Print("figure30DoubleTopConfirmationDown_M15 =          ", figure30DoubleTopConfirmationDown_M15,           " figure32DivergentFlagConfirmationDown_M15 =           ", figure32DivergentFlagConfirmationDown_M15);
Print("figure34FlagWedgeForelockConfirmationDown_M15 =  ", figure34FlagWedgeForelockConfirmationDown_M15,   " figure36TripleTopConfirmationDown_M15 =               ", figure36TripleTopConfirmationDown_M15);
Print("figure38PennantWedgeDown_M15 =                   ", figure38PennantWedgeDown_M15,                    " figure40RollbackChannelPennantConfirmationDown_M15 =  ", figure40RollbackChannelPennantConfirmationDown_M15);
Print("figure42MoreDivergentFlagConfirmationDown_M15 =  ", figure42MoreDivergentFlagConfirmationDown_M15,   " figure44ChannelFlagDown_M15 =                         ", figure44ChannelFlagDown_M15);
Print("figure46PennantAfterWedgeConfirmationDown_M15 =  ", figure46PennantAfterWedgeConfirmationDown_M15,   " figure48PennantAfterFlagConfirmationDown_M15 =        ", figure48PennantAfterFlagConfirmationDown_M15);
Print("figure50DoublePennantAfterConfirmationDown_M15 = ", figure50DoublePennantAfterConfirmationDown_M15,  " figure52WedgeConfirmationDown_M15 =                   ", figure52WedgeConfirmationDown_M15);
Print("figure14_1DivergenceFlagConfirmationDown_M15  = ", figure14_1DivergenceFlagConfirmationDown_M15);


Print("figure2_1FlagDownContinueAfterDecreaseDown_H1 =  ", figure2_1FlagDownContinueAfterDecreaseDown_H1);
Print("figure6_1PennantDownConfirmationDown_H1 =        ", figure6_1PennantDownConfirmationDown_H1);
Print("figure8_1TurnDownDivergenceDown_H1 =             ", figure8_1TurnDownDivergenceDown_H1);
Print("figure8_2TurnDivergenceConfirmationDown_H1 =     ", figure8_2TurnDivergenceConfirmationDown_H1);
Print("figure2FlagDownContinueDown_D1 =                 ", figure2FlagDownContinueDown_H1,                  " figure4TripleDown_H1 =                                ", figure4TripleDown_H1,            " figure6PennantDown_H1 =       ", figure6PennantDown_H1);
Print("figure8FlagDownDivergenceDown_H1 =               ", figure8FlagDownDivergenceDown_H1,                " figure10FlagDownShiftDown_H1 =                        ", figure10FlagDownShiftDown_H1,    " figure12DoubleTopDown_H1 =    ", figure12DoubleTopDown_H1);
Print("figure14DivergentChannelDown_H1 =                ", figure14DivergentChannelDown_H1,                 " figure16BalancedTriangleDown_H1 =                     ",figure16BalancedTriangleDown_H1);
Print("figure18FlagConfirmationDown_H1 =                ", figure18FlagConfirmationDown_H1,                 " figure20HeadAndShouldersConfirmationDown_H1 =         ",figure20HeadAndShouldersConfirmationDown_H1);
Print("figure22WedgeDown_H1 =                           ", figure22WedgeDown_H1,                            " figure24DiamondDown_H1 =                              ",figure24DiamondDown_H1);
Print("figure26TriangleConfirmationDown_H1 =            ", figure26TriangleConfirmationDown_H1,             " figure28ModerateDivergentFlagConfirmationDown_H1 =    ",figure28ModerateDivergentFlagConfirmationDown_H1);
Print("figure30DoubleTopConfirmationDown_H1 =           ", figure30DoubleTopConfirmationDown_H1,            " figure32DivergentFlagConfirmationDown_H1 =            ",figure32DivergentFlagConfirmationDown_H1);
Print("figure34FlagWedgeForelockConfirmationDown_H1 =   ", figure34FlagWedgeForelockConfirmationDown_H1,    " figure36TripleTopConfirmationDown_H1 =                ",figure36TripleTopConfirmationDown_H1);
Print("figure38PennantWedgeDown_H1 =                    ", figure38PennantWedgeDown_H1,                     " figure40RollbackChannelPennantConfirmationDown_H1 =   ",figure40RollbackChannelPennantConfirmationDown_H1);
Print("figure42MoreDivergentFlagConfirmationDown_H1 =   ", figure42MoreDivergentFlagConfirmationDown_H1,    " figure44ChannelFlagDown_H1 =                          ",figure44ChannelFlagDown_H1);
Print("figure46PennantAfterWedgeConfirmationDown_H1 =   ", figure46PennantAfterWedgeConfirmationDown_H1,    " figure48PennantAfterFlagConfirmationDown_H1 =         ",figure48PennantAfterFlagConfirmationDown_H1);
Print("figure50DoublePennantAfterConfirmationDown_H1 =  ", figure50DoublePennantAfterConfirmationDown_H1,   " figure52WedgeConfirmationDown_H1 =                    ",figure52WedgeConfirmationDown_H1);
Print("figure14_1DivergenceFlagConfirmationDown_H1  = ", figure14_1DivergenceFlagConfirmationDown_H1);


Print("figure2_1FlagDownContinueAfterDecreaseDown_H4 =  ", figure2_1FlagDownContinueAfterDecreaseDown_H4);
Print("figure6_1PennantDownConfirmationDown_H4 =        ", figure6_1PennantDownConfirmationDown_H4);
Print("figure8_1TurnDownDivergenceDown_H4 =             ", figure8_1TurnDownDivergenceDown_H4);
Print("figure8_2TurnDivergenceConfirmationDown_H4 =     ", figure8_2TurnDivergenceConfirmationDown_H4);
Print("figure2FlagDownContinueDown_H4 =                 ", figure2FlagDownContinueDown_H4,                  " figure4TripleDown_H4 =                                ", figure4TripleDown_H4,            " figure6PennantDown_H4 =       ", figure6PennantDown_H4);
Print("figure8FlagDownDivergenceDown_H4 =               ", figure8FlagDownDivergenceDown_H4,                " figure10FlagDownShiftDown_H4 =                        ", figure10FlagDownShiftDown_H4,    " figure12DoubleTopDown_H4 =    ", figure12DoubleTopDown_H4);
Print("figure14DivergentChannelDown_H4 =                ", figure14DivergentChannelDown_H4,                 " figure16BalancedTriangleDown_H4 =                     ",figure16BalancedTriangleDown_H4);
Print("figure18FlagConfirmationDown_H4 =                ", figure18FlagConfirmationDown_H4,                 " figure20HeadAndShouldersConfirmationDown_H4 =         ",figure20HeadAndShouldersConfirmationDown_H4);
Print("figure22WedgeDown_H4 =                           ", figure22WedgeDown_H4,                            " figure24DiamondDown_H4 =                              ",figure24DiamondDown_H4);
Print("figure26TriangleConfirmationDown_H4 =            ", figure26TriangleConfirmationDown_H4,             " figure28ModerateDivergentFlagConfirmationDown_H4 =    ",figure28ModerateDivergentFlagConfirmationDown_H4);
Print("figure30DoubleTopConfirmationDown_H4 =           ", figure30DoubleTopConfirmationDown_H4,            " figure32DivergentFlagConfirmationDown_H4 =            ",figure32DivergentFlagConfirmationDown_H4);
Print("figure34FlagWedgeForelockConfirmationDown_H4 =   ", figure34FlagWedgeForelockConfirmationDown_H4,    " figure36TripleTopConfirmationDown_H4 =                ",figure36TripleTopConfirmationDown_H4);
Print("figure38PennantWedgeDown_H4 =                    ", figure38PennantWedgeDown_H4,                     " figure40RollbackChannelPennantConfirmationDown_H4 =   ",figure40RollbackChannelPennantConfirmationDown_H4);
Print("figure42MoreDivergentFlagConfirmationDown_H4 =   ", figure42MoreDivergentFlagConfirmationDown_H4,    " figure44ChannelFlagDown_H4 =                          ",figure44ChannelFlagDown_H4);
Print("figure46PennantAfterWedgeConfirmationDown_H4 =   ", figure46PennantAfterWedgeConfirmationDown_H4,    " figure48PennantAfterFlagConfirmationDown_H4 =         ",figure48PennantAfterFlagConfirmationDown_H4);
Print("figure50DoublePennantAfterConfirmationDown_H4 =  ", figure50DoublePennantAfterConfirmationDown_H4,   " figure52WedgeConfirmationDown_H4 =                    ",figure52WedgeConfirmationDown_H4);
Print("figure14_1DivergenceFlagConfirmationDown_H4  = ", figure14_1DivergenceFlagConfirmationDown_H4);


Print("figure2_1FlagDownContinueAfterDecreaseDown_D1 =  ", figure2_1FlagDownContinueAfterDecreaseDown_D1);
Print("figure6_1PennantDownConfirmationDown_D1 =        ", figure6_1PennantDownConfirmationDown_D1);
Print("figure8_1TurnDownDivergenceDown_D1 =             ", figure8_1TurnDownDivergenceDown_D1);
Print("figure8_2TurnDivergenceConfirmationDown_D1 =     ", figure8_2TurnDivergenceConfirmationDown_D1);
Print("figure2FlagDownContinueDown_D1 =                 ", figure2FlagDownContinueDown_D1,                  " figure4TripleDown_D1 =                                ", figure4TripleDown_D1,            " figure6PennantDown_D1 =       ", figure6PennantDown_D1);
Print("figure8FlagDownDivergenceDown_D1 =               ", figure8FlagDownDivergenceDown_D1,                " figure10FlagDownShiftDown_D1 =                        ", figure10FlagDownShiftDown_D1,    " figure12DoubleTopDown_D1 =    ", figure12DoubleTopDown_D1);
Print("figure14DivergentChannelDown_D1 =                ", figure14DivergentChannelDown_D1,                 " figure16BalancedTriangleDown_D1 =                     ",figure16BalancedTriangleDown_D1);
Print("figure18FlagConfirmationDown_D1 =                ", figure18FlagConfirmationDown_D1,                 " figure20HeadAndShouldersConfirmationDown_D1 =         ",figure20HeadAndShouldersConfirmationDown_D1);
Print("figure22WedgeDown_D1 =                           ", figure22WedgeDown_D1,                            " figure24DiamondDown_D1 =                              ",figure24DiamondDown_D1);
Print("figure26TriangleConfirmationDown_D1 =            ", figure26TriangleConfirmationDown_D1,             " figure28ModerateDivergentFlagConfirmationDown_D1 =    ",figure28ModerateDivergentFlagConfirmationDown_D1);
Print("figure30DoubleTopConfirmationDown_D1 =           ", figure30DoubleTopConfirmationDown_D1,            " figure32DivergentFlagConfirmationDown_D1 =            ",figure32DivergentFlagConfirmationDown_D1);
Print("figure34FlagWedgeForelockConfirmationDown_D1 =   ", figure34FlagWedgeForelockConfirmationDown_D1,    " figure36TripleTopConfirmationDown_D1 =                ",figure36TripleTopConfirmationDown_D1);
Print("figure38PennantWedgeDown_D1 =                    ", figure38PennantWedgeDown_D1,                     " figure40RollbackChannelPennantConfirmationDown_D1 =   ",figure40RollbackChannelPennantConfirmationDown_D1);
Print("figure42MoreDivergentFlagConfirmationDown_D1 =   ", figure42MoreDivergentFlagConfirmationDown_D1,    " figure44ChannelFlagDown_D1 =                          ",figure44ChannelFlagDown_D1);
Print("figure46PennantAfterWedgeConfirmationDown_D1 =   ", figure46PennantAfterWedgeConfirmationDown_D1,    " figure48PennantAfterFlagConfirmationDown_D1 =         ",figure48PennantAfterFlagConfirmationDown_D1);
Print("figure50DoublePennantAfterConfirmationDown_D1 =  ", figure50DoublePennantAfterConfirmationDown_D1,   " figure52WedgeConfirmationDown_D1 =                    ",figure52WedgeConfirmationDown_D1);
Print("figure14_1DivergenceFlagConfirmationDown_D1  = ", figure14_1DivergenceFlagConfirmationDown_D1);

sell=1;
 }

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

         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,currentStopLoss,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
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

               if(Bid>OrderOpenPrice()&& (Bid - OrderOpenPrice())> (Ask - Bid)*2)// если текущая цена БОЛЬШЕ цены открытия И 50% от прибыли больше чем Spread (что бы не было ложных срабатываний)
                 {
                  if(Bid-((Bid - OrderOpenPrice())*0.13)>OrderStopLoss())// если стоп-лосс МЕНЬШЕ чем цена - 50% прибыли
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-((Bid - OrderOpenPrice())*0.13),OrderTakeProfit(),0,Green);// то стоп лосс равен пцена - 50% прибыли
                    }
                 }


              periodGlobal = PERIOD_M5;
              lowAndHighUpdateViaNonSymmForTrailing = false;
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

            if(stopLossForBuyMin>OrderOpenPrice() && stopShift > spread && Bid>stopLossForBuyMin && stopLossForBuyMin>OrderStopLoss())
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


              {
               if(OrderOpenPrice()>Ask && (OrderOpenPrice()-Ask>(Ask - Bid)*2))// если текущая цена + двойной спред МЕНЬШЕ цены открытия (Уберу двойной спред) И 50% от прибыли больше чем Spread (что бы не было ложных срабатываний)
                 {
                  if(Ask+((OrderOpenPrice()-Ask)*0.13)<OrderStopLoss()|| (OrderStopLoss()==0))// если стоп-лосс МЕНЬШЕ  чем цена + 50% прибыли(Уберу двойной спред)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+((OrderOpenPrice()-Ask)*0.13),OrderTakeProfit(),0,Red);//(Уберу двойной спред)
                    }
                 }
              }


               periodGlobal = PERIOD_M5;
              lowAndHighUpdateViaNonSymmForTrailing = false;
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

            if(stopLossForSellMax<OrderOpenPrice() && (stopShift > spread || stopShift <= 0) && Ask<stopLossForSellMax && (stopLossForSellMax<OrderStopLoss() || OrderStopLoss()==0))
              {
               //Print("Sell Position was stoplossed on TimeFrame ","periodGlobal = ",periodGlobal);
               OrderModify(OrderTicket(),OrderOpenPrice(),(stopLossForSellMax+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
               return;
              }
            //                 }

           }
        }
     }

     Sleep(3333);
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
   bool isThirdMin = false, isThirdMax = false;
   bool isFourthMin = false, isFourthMax = false, isFifthMin = false, isFifthMax = false, isSixthMin = false, isSixthMax = false;
   bool pricesUpdate=false;
   double firstMinLocalNonSymmetricMACD=0.00000000,secondMinLocalNonSymmetricMACD=0.00000000,firstMaxLocalNonSymmetricMACD=0.00000000,secondMaxLocalNonSymmetricMACD=0.00000000;
   double thirdMinLocalNonSymmetric=0.00000000, thirdMaxLocalNonSymmetric=0.00000000;
   double macdForMinMax;

   double fourthMinLocalNonSymmetric = 0.00000000;
   double fifthMinLocalNonSymmetric = 0.00000000;
   double sixthMinLocalNonSymmetric = 0.00000000;
   double fourthMaxLocalNonSymmetric = 0.00000000;
   double fifthMaxLocalNonSymmetric = 0.00000000;
   double sixthMaxLocalNonSymmetric = 0.00000000;

   int halfWave_7H4[], halfWave_8H4[], halfWave_9H4[], halfWave_10H4[], halfWave_11H4[], halfWave_12H4[];
   int q7 ,w7,q8,w8,q9,w9,q10,w10,q11,w11,q12,w12;
   int resize7H4, resize8H4, resize9H4, resize10H4, resize11H4, resize12H4;
   bool what_8HalfWaveMACDH4,what_9HalfWaveMACDH4,what_10HalfWaveMACDH4,what_11HalfWaveMACDH4,what_12HalfWaveMACDH4,what_13HalfWaveMACDH4;

   int halfWave_4H4[],halfWave_5H4[],halfWave_6H4[];
   int q, w, q5, q6, w5, w6, resize4H4,resize5H4,resize6H4;
   bool what_5HalfWaveMACDH4,what_6HalfWaveMACDH4,what_7HalfWaveMACDH4;



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

   isC5Min = false;
   isC5Max = false;
   isC6Min = false;
   isC6Max = false;

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
   for(i=begin;countHalfWaves<=12;i++)
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
//         Print("C4W0, wait for secondMaxLocalNonSymmetric");
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
//             Print("NonSymmetric, p, x = ",p," ", x, " secondMaxLocalNonSymmetric = ", secondMaxLocalNonSymmetric);
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
         priceForMinMax=iOpen(NULL,periodGlobal,q);
         secondMinLocalNonSymmetric=priceForMinMax;

         macdForMinMax=iMACD(NULL,periodGlobal,12,26,9,PRICE_OPEN,MODE_MAIN,q);
         secondMinLocalNonSymmetricMACD=macdForMinMax;

         for(q; q<i+2; q++)
           {
            halfWave_4H4[w]=q;
            priceForMinMax = iOpen(NULL,periodGlobal,q);
 //            Print("NonSymmetric, p, x = ",p," ", x, " secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
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
//         Print("secondMinLocalNonSymmetric = ", secondMinLocalNonSymmetric);
        }
// Print("if(countHalfWaves==5 && what_5HalfWaveMACDH4 ==1 && MacdIplus3H4>0 && MacdIplus4H4>0) = ", countHalfWaves," ",what_5HalfWaveMACDH4," ",MacdIplus3H4," ",MacdIplus4H4);
        if(countHalfWaves==5 && what_5HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
//        Print("C5W1, wait for thirdMinLocalNonSymmetric");
       // Print("C5W1 inside if");
            countHalfWaves++;
            what_6HalfWaveMACDH4 = 0;
            q5 = q + 1;
            resize5H4 = (i+2)-q5;
            ArrayResize (halfWave_5H4, resize5H4);
            w5=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q5);
//            Print("NonSymmetric, q, q5 = ",q," ", q5, " thirdMinLocalNonSymmetric = ", thirdMinLocalNonSymmetric);
            thirdMinLocalNonSymmetric = priceForMinMax;
            for(q5;q5<i+2;q5++){
                halfWave_5H4[w5]=q5;
                priceForMinMax = iOpen(NULL,periodGlobal,q5);
                if(thirdMinLocalNonSymmetric > priceForMinMax){
                    thirdMinLocalNonSymmetric = priceForMinMax;
                    isThirdMin = true;
                }
                w5++;
            }
//            Print("thirdMinLocalNonSymmetric = ", thirdMinLocalNonSymmetric);
isC5Min = true;
        }
//Print("if(countHalfWaves==5 && what_5HalfWaveMACDH4 ==0 && MacdIplus3H4<0 && MacdIplus4H4<0) = ", countHalfWaves," ",what_5HalfWaveMACDH4," ",MacdIplus3H4," ",MacdIplus4H4);
        if(countHalfWaves==5 && what_5HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
//            Print("C5W0, wait for thirdMaxLocalNonSymmetric");
//                Print("C5W0 inside if");
                    countHalfWaves++;
                    what_6HalfWaveMACDH4=1;
                    q5 = q + 1;
                    resize5H4 = (i+2)-q5;
                    ArrayResize (halfWave_5H4, resize5H4);
                    w5=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q5);
//                    Print("NonSymmetric, q, q5 = ",q," ", q5, " thirdMaxLocalNonSymmetric = ", thirdMaxLocalNonSymmetric);
                    thirdMaxLocalNonSymmetric = priceForMinMax;
                                // Print("C5W0, priceForMinMax = ", priceForMinMax);
                    for(q5;q5<i+2;q5++){
                        halfWave_5H4[w5]=q5;
                        priceForMinMax = iOpen(NULL,periodGlobal,q5);
                        if(thirdMaxLocalNonSymmetric < priceForMinMax){
                            thirdMaxLocalNonSymmetric = priceForMinMax;
                            isThirdMax = true;
                        }
                        w5++;
                    }
//                                Print("thirdMaxLocalNonSymmetric = ", thirdMaxLocalNonSymmetric);
isC5Max = true;
                }
        if(countHalfWaves==6 && what_6HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_7HalfWaveMACDH4=1;
                    q6 = q5+1;
                    resize6H4 = (i+2)-q6;
                    ArrayResize (halfWave_6H4, resize6H4);
                    w6=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q6);
                    thirdMaxLocalNonSymmetric = priceForMinMax;
                    for(q6;q6<i+2;q6++){
                        halfWave_6H4[w6]=q6;
                        priceForMinMax = iOpen(NULL,periodGlobal,q6);
                        if(thirdMaxLocalNonSymmetric < priceForMinMax){
                            thirdMaxLocalNonSymmetric = priceForMinMax;
                            isThirdMax = true;
                        }
                        w6++;
                    }
isC6Max = true;
                }
        if(countHalfWaves==6 && what_6HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_7HalfWaveMACDH4=0;
            q6 = q5 + 1;
            resize6H4 = (i+2)-q6;
            ArrayResize (halfWave_6H4, resize6H4);
            w6=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q6);
            thirdMinLocalNonSymmetric = priceForMinMax;
            for(q6;q6<i+2;q6++){
                halfWave_6H4[w6]=q6;
                priceForMinMax = iOpen(NULL,periodGlobal,q6);
                if(thirdMinLocalNonSymmetric > priceForMinMax){
                    thirdMinLocalNonSymmetric = priceForMinMax;
                    isThirdMin = true;
                }
                w6++;
            }
isC6Min = true;
        }
        // from 6 to 12
// Fourth 7 0
        if(countHalfWaves==7 && what_7HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_8HalfWaveMACDH4=1;
                    q7 = q6+1;
                    resize7H4 = (i+2)-q7;
                    ArrayResize (halfWave_7H4, resize7H4);
                    w7=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q7);
                    thirdMaxLocalNonSymmetric = priceForMinMax;
                    for(q7;q7<i+2;q7++){
                        halfWave_7H4[w7]=q7;
                        priceForMinMax = iOpen(NULL,periodGlobal,q7);
                        if(fourthMaxLocalNonSymmetric < priceForMinMax){
                            fourthMaxLocalNonSymmetric = priceForMinMax;
                            isFourthMax = true;
                        }
                        w7++;
                    }
                }
// Fourth 7 1
        if(countHalfWaves==7 && what_7HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_8HalfWaveMACDH4=0;
            q7 = q6 + 1;
            resize7H4 = (i+2)-q7;
            ArrayResize (halfWave_7H4, resize7H4);
            w7=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q7);
            fourthMinLocalNonSymmetric = priceForMinMax;
            for(q7;q7<i+2;q7++){
                halfWave_7H4[w7]=q7;
                priceForMinMax = iOpen(NULL,periodGlobal,q7);
                if(fourthMinLocalNonSymmetric > priceForMinMax){
                    fourthMinLocalNonSymmetric = priceForMinMax;
                    isFourthMin = true;
                }
                w7++;
            }
        }

//Fourth 8 0
        if(countHalfWaves==8 && what_8HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_9HalfWaveMACDH4=1;
                    q8 = q7+1;
                    resize8H4 = (i+2)-q8;
                    ArrayResize (halfWave_8H4, resize8H4);
                    w8=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q8);
                    fourthMaxLocalNonSymmetric = priceForMinMax;
                    for(q8;q8<i+2;q8++){
                        halfWave_8H4[w8]=q8;
                        priceForMinMax = iOpen(NULL,periodGlobal,q8);
                        if(fourthMaxLocalNonSymmetric < priceForMinMax){
                            fourthMaxLocalNonSymmetric = priceForMinMax;
                            isFourthMax = true;
                        }
                        w8++;
                    }
                }
// Fourth 8 1
        if(countHalfWaves==8 && what_8HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_9HalfWaveMACDH4=0;
            q8 = q7 + 1;
            resize8H4 = (i+2)-q8;
            ArrayResize (halfWave_8H4, resize8H4);
            w8=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q8);
            fourthMinLocalNonSymmetric = priceForMinMax;
            for(q8;q8<i+2;q8++){
                halfWave_8H4[w8]=q8;
                priceForMinMax = iOpen(NULL,periodGlobal,q8);
                if(fourthMinLocalNonSymmetric > priceForMinMax){
                    fourthMinLocalNonSymmetric = priceForMinMax;
                    isFourthMin = true;
                }
                w8++;
            }
        }
// Fifth 9 0
        if(countHalfWaves==9 && what_9HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_10HalfWaveMACDH4=1;
                    q9 = q8+1;
                    resize9H4 = (i+2)-q9;
                    ArrayResize (halfWave_9H4, resize9H4);
                    w9=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q9);
                    fifthMaxLocalNonSymmetric = priceForMinMax;
                    for(q9;q9<i+2;q9++){
                        halfWave_9H4[w9]=q9;
                        priceForMinMax = iOpen(NULL,periodGlobal,q9);
                        if(fifthMaxLocalNonSymmetric < priceForMinMax){
                            fifthMaxLocalNonSymmetric = priceForMinMax;
                            isFifthMax = true;
                        }
                        w9++;
                    }
                }
// Fifth 9 1
        if(countHalfWaves==9 && what_9HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_10HalfWaveMACDH4=0;
            q9 = q8 + 1;
            resize9H4 = (i+2)-q9;
            ArrayResize (halfWave_9H4, resize9H4);
            w9=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q9);
            fifthMinLocalNonSymmetric = priceForMinMax;
            for(q9;q9<i+2;q9++){
                halfWave_9H4[w9]=q9;
                priceForMinMax = iOpen(NULL,periodGlobal,q9);
                if(fifthMinLocalNonSymmetric > priceForMinMax){
                    fifthMinLocalNonSymmetric = priceForMinMax;
                    isFifthMin = true;
                }
                w9++;
            }
        }

// Fifth 10 0
        if(countHalfWaves==10 && what_10HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_11HalfWaveMACDH4=1;
                    q10 = q9+1;
                    resize10H4 = (i+2)-q10;
                    ArrayResize (halfWave_10H4, resize10H4);
                    w10=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q10);
                    fifthMaxLocalNonSymmetric = priceForMinMax;
                    for(q10;q10<i+2;q10++){
                        halfWave_10H4[w10]=q10;
                        priceForMinMax = iOpen(NULL,periodGlobal,q10);
                        if(fifthMaxLocalNonSymmetric < priceForMinMax){
                            fifthMaxLocalNonSymmetric = priceForMinMax;
                            isFifthMax = true;
                        }
                        w10++;
                    }
                }
// Fifth 10 1
        if(countHalfWaves==10 && what_10HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_11HalfWaveMACDH4=0;
            q10 = q9 + 1;
            resize10H4 = (i+2)-q10;
            ArrayResize (halfWave_10H4, resize10H4);
            w10=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q10);
            fifthMinLocalNonSymmetric = priceForMinMax;
            for(q10;q10<i+2;q10++){
                halfWave_10H4[w10]=q10;
                priceForMinMax = iOpen(NULL,periodGlobal,q10);
                if(fifthMinLocalNonSymmetric > priceForMinMax){
                    fifthMinLocalNonSymmetric = priceForMinMax;
                    isFifthMin = true;
                }
                w10++;
            }
        }

// Sixth 11 0
        if(countHalfWaves==11 && what_11HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_12HalfWaveMACDH4=1;
                    q11 = q10+1;
                    resize11H4 = (i+2)-q11;
                    ArrayResize (halfWave_11H4, resize11H4);
                    w11=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q11);
                    sixthMaxLocalNonSymmetric = priceForMinMax;
                    for(q11;q11<i+2;q11++){
                        halfWave_11H4[w11]=q11;
                        priceForMinMax = iOpen(NULL,periodGlobal,q11);
                        if(sixthMaxLocalNonSymmetric < priceForMinMax){
                            sixthMaxLocalNonSymmetric = priceForMinMax;
                            isSixthMax = true;
                        }
                        w11++;
                    }
                }
// Sixth 11 1
        if(countHalfWaves==11 && what_11HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_12HalfWaveMACDH4=0;
            q11 = q10 + 1;
            resize11H4 = (i+2)-q11;
            ArrayResize (halfWave_11H4, resize11H4);
            w11=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q11);
            thirdMinLocalNonSymmetric = priceForMinMax;
            for(q11;q11<i+2;q11++){
                halfWave_11H4[w11]=q11;
                priceForMinMax = iOpen(NULL,periodGlobal,q11);
                if(thirdMinLocalNonSymmetric > priceForMinMax){
                    thirdMinLocalNonSymmetric = priceForMinMax;
                    isSixthMin = true;
                }
                w11++;
            }
        }

// Sixth 12 0
        if(countHalfWaves==12 && what_12HalfWaveMACDH4==0 && MacdIplus3H4<0 && MacdIplus4H4<0){
                    countHalfWaves++;
                    what_13HalfWaveMACDH4=1;
                    q12 = q11+1;
                    resize12H4 = (i+2)-q12;
                    ArrayResize (halfWave_12H4, resize12H4);
                    w12=0;
                    priceForMinMax = iOpen(NULL,periodGlobal,q12);
                    sixthMaxLocalNonSymmetric = priceForMinMax;
                    for(q12;q12<i+2;q12++){
                        halfWave_12H4[w12]=q12;
                        priceForMinMax = iOpen(NULL,periodGlobal,q12);
                        if(sixthMaxLocalNonSymmetric < priceForMinMax){
                            sixthMaxLocalNonSymmetric = priceForMinMax;
                            isSixthMax = true;
                        }
                        w12++;
                    }
                }
// Sixth 12 1
        if(countHalfWaves==12 && what_12HalfWaveMACDH4==1 && MacdIplus3H4>0 && MacdIplus4H4>0){
            countHalfWaves++;
            what_13HalfWaveMACDH4=0;
            q12 = q11 + 1;
            resize12H4 = (i+2)-q12;
            ArrayResize (halfWave_12H4, resize12H4);
            w12=0;
            priceForMinMax = iOpen(NULL,periodGlobal,q12);
            sixthMinLocalNonSymmetric = priceForMinMax;
            for(q12;q12<i+2;q12++){
                halfWave_12H4[w12]=q12;
                priceForMinMax = iOpen(NULL,periodGlobal,q12);
                if(sixthMinLocalNonSymmetric > priceForMinMax){
                    sixthMinLocalNonSymmetric = priceForMinMax;
                    isSixthMin = true;
                }
                w12++;
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
   firstMinGlobalMACD  = firstMinLocalNonSymmetricMACD;
   secondMinGlobalMACD = secondMinLocalNonSymmetricMACD;
   firstMaxGlobalMACD  = firstMaxLocalNonSymmetricMACD;
   secondMaxGlobalMACD = secondMaxLocalNonSymmetricMACD;
//   Print("thirdMinLocalNonSymmetric", thirdMinLocalNonSymmetric);
//   Print("thirdMaxLocalNonSymmetric", thirdMaxLocalNonSymmetric);
   thirdMinGlobal = thirdMinLocalNonSymmetric;
   thirdMaxGlobal = thirdMaxLocalNonSymmetric;

   fourthMinGlobal  =   fourthMinLocalNonSymmetric;
   fourthMaxGlobal  =   fourthMaxLocalNonSymmetric;
   fifthMinGlobal   =   fifthMinLocalNonSymmetric;
   fifthMaxGlobal   =   fifthMaxLocalNonSymmetric;
   sixthMinGlobal   =   sixthMinLocalNonSymmetric;
   sixthMaxGlobal   =   sixthMaxLocalNonSymmetric;


   pricesUpdate=true;
   return pricesUpdate;
  }

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
   return lowAndHighUpdate;
  }

  void print(string message, ENUM_TIMEFRAMES timeFrameNum){
    string timeFrame;
    countFigures++;


    if(timeFrameNum == 1){
        if(messageGlobalPERIOD_M1 == "nothing"){
            messageGlobalPERIOD_M1 = message;
        } else {
            messageGlobalPERIOD_M1 = StringConcatenate(messageGlobalPERIOD_M1, " + ", message);
        }
    }
    if(timeFrameNum == 5){
        if(messageGlobalPERIOD_M5 == "nothing"){
            messageGlobalPERIOD_M5 = message;
        } else {
            messageGlobalPERIOD_M5 = StringConcatenate(messageGlobalPERIOD_M5, " + ", message);
        }
    }
    if(timeFrameNum == 15){
        if(messageGlobalPERIOD_M15 == "nothing"){
            messageGlobalPERIOD_M15 = message;
        } else {
            messageGlobalPERIOD_M15 = StringConcatenate(messageGlobalPERIOD_M15, " + ", message);
        }
    }
    if(timeFrameNum == 60){
        if(messageGlobalPERIOD_H1 == "nothing"){
            messageGlobalPERIOD_H1 = message;
        } else {
            messageGlobalPERIOD_H1 = StringConcatenate(messageGlobalPERIOD_H1, " + ", message);
        }
    }
    if(timeFrameNum == 240){
        if(messageGlobalPERIOD_H4 == "nothing"){
            messageGlobalPERIOD_H4 = message;
        } else {
            messageGlobalPERIOD_H4 = StringConcatenate(messageGlobalPERIOD_H4, " + ", message);
        }
    }
    if(timeFrameNum == 1440){
        if(messageGlobalPERIOD_D1 == "nothing"){
            messageGlobalPERIOD_D1 = message;
        } else {
            messageGlobalPERIOD_D1 = StringConcatenate(messageGlobalPERIOD_D1, " + ", message);
        }
    }
  }

  void print(){
    string start;
    int total = OrdersTotal();
    if(total>0){
      start = "Open Order";
    } else { start = " "; };
    Comment(
        "\n     ", start ,
        "\nPERIOD_M1     ", messageGlobalPERIOD_M1 ,
        "\nPERIOD_M5     ", messageGlobalPERIOD_M5 ,
        "\nPERIOD_M15   ", messageGlobalPERIOD_M15 ,
        "\nPERIOD_H1     ", messageGlobalPERIOD_H1 ,
        "\nPERIOD_H4     ", messageGlobalPERIOD_H4 ,
        "\nPERIOD_D1     ", messageGlobalPERIOD_D1
    );
  }
  //+------------------------------------------------------------------+
  bool isMACDNewlyCrossedUpFilter1(ENUM_TIMEFRAMES timeFrameForMACD){
    bool isMACDCrossed = false;
    double macd0 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,3);

        if(  macd0>0 && (macd1<0 || macd2<0 || macd3<0)  ) {
          isMACDCrossed = true;
        }

    return isMACDCrossed;
  }
    bool isMACDNewlyCrossedDownFilter1(ENUM_TIMEFRAMES timeFrameForMACD){
      bool isMACDCrossed = false;
      double macd0 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,0);
      double macd1 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,1);
      double macd2 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,2);
      double macd3 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,3);
//      Print("timeFrameForMACD = ",timeFrameForMACD);
//      Print ("macd0 = ",macd0,"macd1 = ",macd1,"macd2 = ",macd2,"macd3 = ",macd3);
          if(  macd0<0 && (macd1>0 || macd2>0 || macd3>0)  ) {
            isMACDCrossed = true;
 //           Print("isMACDCrossed = ", isMACDCrossed);
          }

      return isMACDCrossed;
    }

   bool isSecondHalfWaveCommitedToTrendUpFilter2(double secondMin, ENUM_TIMEFRAMES timeFrameForSecondHalfWaveCommitedToTrend){
    bool isSecondHalfWaveCommitedToTrend = true;
    double currentHalfWavePrice = iClose(NULL,timeFrameForSecondHalfWaveCommitedToTrend,0);

        if(secondMin > currentHalfWavePrice){
            isSecondHalfWaveCommitedToTrend = false;
        }

    return isSecondHalfWaveCommitedToTrend;
   }

      bool isSecondHalfWaveCommitedToTrendDownFilter2(double secondMax, ENUM_TIMEFRAMES timeFrameForSecondHalfWaveCommitedToTrend){
       bool isSecondHalfWaveCommitedToTrend = true;
       double currentHalfWavePrice = iClose(NULL,timeFrameForSecondHalfWaveCommitedToTrend,0);

           if(secondMax < currentHalfWavePrice){
               isSecondHalfWaveCommitedToTrend = false;
           }

       return isSecondHalfWaveCommitedToTrend;
      }

    bool isH1ConsistentForBuyFilter3(){
             bool resultH1 = false;
             double macdH1_0 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
             double macdH1_1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1);

             if(macdH1_0>macdH1_1){
                 resultH1 = true;
             }
             return resultH1;
         }
    bool isH1ConsistentForSellFilter3(){
        bool resultH1 = false;
        double macdH1_0 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
        double macdH1_1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1);

        if(macdH1_0<macdH1_1){
            resultH1 = true;
        }
        return resultH1;
    }

    bool isTrendNoErrorForBuyFilter4(double firstMax, double secondMax, double thirdMax){
        bool trendNoError = true;
        if(firstMax < secondMax && secondMax < thirdMax){
            trendNoError = false;
        }
        return trendNoError;
    }

    bool isTrendNoErrorForSellFilter4(double firstMin, double secondMin, double thirdMin){
        bool trendNoError = true;
        if(firstMin > secondMin && secondMin > thirdMin){
            trendNoError = false;
        }
        return trendNoError;
    }


    bool isTrendNoErrorForBuyReverseFilter5(double firstMin, double secondMin, double thirdMin){
        bool trendNoError = true;
        if(firstMin < secondMin && secondMin < thirdMin){
            trendNoError = false;
        }
        return trendNoError;
    }

    bool isTrendNoErrorForSellReverseFilter5(double firstMax, double secondMax, double thirdMax){
        bool trendNoError = true;
        if(firstMax > secondMax && secondMax > thirdMax){
            trendNoError = false;
        }
        return trendNoError;
    }

    double channelLimiterForLowerEdgeMaxMinMin(double max, double min1, double min2){
        double fmm;
        if(min1 < min2){
            fmm = (max - min2)*2; // deltaMin*2
        } else {
            fmm = (max - min1)*2;
        }
        return max - fmm; // returns lower visual border of channel minimalDelta*2
    }

    double channelLimiterForUpperEdgeMinMaxMax(double min, double max1, double max2){
        double fmm;
        if(max1 < max2){
            fmm = (max1 - min)*2; // deltaMax*2
        } else {
            fmm = (max2 - min)*2;
        }
        return min + fmm; // returns upper visual border of channel minimalDelta*2
    }