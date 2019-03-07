//+------------------------------------------------------------------+
//|                                                       TS_5.8.mq4 |
//|                                                    Vasiliy Kulik |
//|                                                       alpari.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Kulik"
#property link      "alpari.com"
#property version   "5.8"
#property strict

extern double TakeProfit=500;
extern double StopLoss=500;
extern double externalLots=0.01;
extern double TrailingStop=10000;

extern bool isAutoMoneyManagmentEnabled = false;
extern int moneyManagement4And8Or12And24_4_Or_12 = 12;

extern double TrailingFiboLevel = 0.382;

extern double maxOrders = 30;
extern double riskOnOneOrderPercent = 2;

extern bool OpenOnHalfWaveUp_M1    = false;
extern bool OpenOnHalfWaveUp_M5    = false;
extern bool OpenOnHalfWaveUp_M15   = false;
extern bool OpenOnHalfWaveDown_M1  = false;
extern bool OpenOnHalfWaveDown_M5  = false;
extern bool OpenOnHalfWaveDown_M15 = false;


string signalAnalyzeConcatenated;
bool isNewSignal = false;
string figureH1Signal;
bool isFigureH1InnerM15HalfwaveIsDone = false;
bool isInvertedM15 = false;

double Lots = externalLots;

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
  // Lot calculation

  string myCurrentPair = Symbol();

  if(isAutoMoneyManagmentEnabled){
    if(myCurrentPair=="EURUSD" || myCurrentPair=="USDJPY" || myCurrentPair=="USDCAD")
      {
          if(moneyManagement4And8Or12And24_4_Or_12 == 12){
              Lots = (AccountEquity()/12)*0.01;
          }
          if(moneyManagement4And8Or12And24_4_Or_12 == 4){
              Lots = (AccountEquity()/4)*0.01;
          }
      }
    else if(myCurrentPair=="GBPJPY" || myCurrentPair=="GBPUSD")
      {
          if(moneyManagement4And8Or12And24_4_Or_12 == 12){
              Lots = (AccountEquity()/24)*0.01;
          }
          if(moneyManagement4And8Or12And24_4_Or_12 == 4){
              Lots = (AccountEquity()/8)*0.01;
          }
      }
    else {
          if(moneyManagement4And8Or12And24_4_Or_12 == 12){
              Lots = (AccountEquity()/24)*0.01;
          }
          if(moneyManagement4And8Or12And24_4_Or_12 == 4){
              Lots = (AccountEquity()/8)*0.01;
          }
        }

    Lots = NormalizeDouble(Lots,2);
  }

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
      bool figure27_1DoubleBottomFlagUp_M1  = false,             figure27_1DoubleBottomFlagUp_M5  = false,            figure27_1DoubleBottomFlagUp_M15 = false,  figure27_1DoubleBottomFlagUp_H1  = false,  figure27_1DoubleBottomFlagUp_H4  = false,  figure27_1DoubleBottomFlagUp_D1  = false;
      bool figure28_1DoubleTopFlagDown_M1  = false,           figure28_1DoubleTopFlagDown_M5  = false,          figure28_1DoubleTopFlagDown_M15 = false,  figure28_1DoubleTopFlagDown_H1  = false,  figure28_1DoubleTopFlagDown_H4  = false,  figure28_1DoubleTopFlagDown_D1  = false;
      bool figure27_2TriangleAsConfirmationUp_M1  = false,             figure27_2TriangleAsConfirmationUp_M5  = false,            figure27_2TriangleAsConfirmationUp_M15 = false,  figure27_2TriangleAsConfirmationUp_H1  = false,  figure27_2TriangleAsConfirmationUp_H4  = false,  figure27_2TriangleAsConfirmationUp_D1  = false;
      bool figure28_2TriangleAsConfirmationDown_M1  = false,           figure28_2TriangleAsConfirmationDown_M5  = false,          figure28_2TriangleAsConfirmationDown_M15 = false,  figure28_2TriangleAsConfirmationDown_H1  = false,  figure28_2TriangleAsConfirmationDown_H4  = false,  figure28_2TriangleAsConfirmationDown_D1  = false;
      bool figure27_3DoubleBottomChannelUp_M1  = false,             figure27_3DoubleBottomChannelUp_M5  = false,            figure27_3DoubleBottomChannelUp_M15 = false,  figure27_3DoubleBottomChannelUp_H1  = false,  figure27_3DoubleBottomChannelUp_H4  = false,  figure27_3DoubleBottomChannelUp_D1  = false;
      bool figure28_3DoubleTopChannelDown_M1  = false,           figure28_3DoubleTopChannelDown_M5  = false,          figure28_3DoubleTopChannelDown_M15 = false,  figure28_3DoubleTopChannelDown_H1  = false,  figure28_3DoubleTopChannelDown_H4  = false,  figure28_3DoubleTopChannelDown_D1  = false;
      bool figure27_4WedgePennantConfirmationUp_M1  = false,             figure27_4WedgePennantConfirmationUp_M5  = false,            figure27_4WedgePennantConfirmationUp_M15 = false,  figure27_4WedgePennantConfirmationUp_H1  = false,  figure27_4WedgePennantConfirmationUp_H4  = false,  figure27_4WedgePennantConfirmationUp_D1  = false;
      bool figure28_4WedgePennantConfirmationDown_M1  = false,           figure28_4WedgePennantConfirmationDown_M5  = false,          figure28_4WedgePennantConfirmationDown_M15 = false,  figure28_4WedgePennantConfirmationDown_H1  = false,  figure28_4WedgePennantConfirmationDown_H4  = false,  figure28_4WedgePennantConfirmationDown_D1  = false;
      bool figure27_5DoubleBottomConDivDivConfirmationUp_M1  = false,             figure27_5DoubleBottomConDivDivConfirmationUp_M5  = false,            figure27_5DoubleBottomConDivDivConfirmationUp_M15 = false,  figure27_5DoubleBottomConDivDivConfirmationUp_H1  = false,  figure27_5DoubleBottomConDivDivConfirmationUp_H4  = false,  figure27_5DoubleBottomConDivDivConfirmationUp_D1  = false;
      bool figure28_5DoubleTopConDivDivConfirmationDown_M1  = false,           figure28_5DoubleTopConDivDivConfirmationDown_M5  = false,          figure28_5DoubleTopConDivDivConfirmationDown_M15 = false,  figure28_5DoubleTopConDivDivConfirmationDown_H1  = false,  figure28_5DoubleTopConDivDivConfirmationDown_H4  = false,  figure28_5DoubleTopConDivDivConfirmationDown_D1  = false;
      bool figure27_6DoubleBottomDivConDivConfirmationUp_M1  = false,             figure27_6DoubleBottomDivConDivConfirmationUp_M5  = false,            figure27_6DoubleBottomDivConDivConfirmationUp_M15 = false,  figure27_6DoubleBottomDivConDivConfirmationUp_H1  = false,  figure27_6DoubleBottomDivConDivConfirmationUp_H4  = false,  figure27_6DoubleBottomDivConDivConfirmationUp_D1  = false;
      bool figure28_6DoubleTopDivConDivConfirmationDown_M1  = false,           figure28_6DoubleTopDivConDivConfirmationDown_M5  = false,          figure28_6DoubleTopDivConDivConfirmationDown_M15 = false,  figure28_6DoubleTopDivConDivConfirmationDown_H1  = false,  figure28_6DoubleTopDivConDivConfirmationDown_H4  = false,  figure28_6DoubleTopDivConDivConfirmationDown_D1  = false;
      bool figure27_7DoubleBottom12PosUp_M1  = false,             figure27_7DoubleBottom12PosUp_M5  = false,            figure27_7DoubleBottom12PosUp_M15 = false,  figure27_7DoubleBottom12PosUp_H1  = false,  figure27_7DoubleBottom12PosUp_H4  = false,  figure27_7DoubleBottom12PosUp_D1  = false;
      bool figure28_7DoubleTop12PosDown_M1  = false,           figure28_7DoubleTop12PosDown_M5  = false,          figure28_7DoubleTop12PosDown_M15 = false,  figure28_7DoubleTop12PosDown_H1  = false,  figure28_7DoubleTop12PosDown_H4  = false,  figure28_7DoubleTop12PosDown_D1  = false;
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
      bool figure59TripleBottomWedgeUp_M1  = false,                             figure59TripleBottomWedgeUp_M5  = false,            figure59TripleBottomWedgeUp_M15 = false,  figure59TripleBottomWedgeUp_H1  = false,  figure59TripleBottomWedgeUp_H4  = false,  figure59TripleBottomWedgeUp_D1  = false;
      bool figure60TripleTopWedgeDown_M1  = false,                           figure60TripleTopWedgeDown_M5  = false,          figure60TripleTopWedgeDown_M15 = false,  figure60TripleTopWedgeDown_H1  = false,  figure60TripleTopWedgeDown_H4  = false,  figure60TripleTopWedgeDown_D1  = false;
      bool figure61TripleBottomConfirmationUp_M1  = false,                             figure61TripleBottomConfirmationUp_M5  = false,            figure61TripleBottomConfirmationUp_M15 = false,  figure61TripleBottomConfirmationUp_H1  = false,  figure61TripleBottomConfirmationUp_H4  = false,  figure61TripleBottomConfirmationUp_D1  = false;
      bool figure62TripleTopConfirmationDown_M1  = false,                           figure62TripleTopConfirmationDown_M5  = false,          figure62TripleTopConfirmationDown_M15 = false,  figure62TripleTopConfirmationDown_H1  = false,  figure62TripleTopConfirmationDown_H4  = false,  figure62TripleTopConfirmationDown_D1  = false;
      bool figure63TripleBottomConfirmationUp_M1  = false,                             figure63TripleBottomConfirmationUp_M5  = false,            figure63TripleBottomConfirmationUp_M15 = false,  figure63TripleBottomConfirmationUp_H1  = false,  figure63TripleBottomConfirmationUp_H4  = false,  figure63TripleBottomConfirmationUp_D1  = false;
      bool figure64TripleTopConfirmationDown_M1  = false,                           figure64TripleTopConfirmationDown_M5  = false,          figure64TripleTopConfirmationDown_M15 = false,  figure64TripleTopConfirmationDown_H1  = false,  figure64TripleTopConfirmationDown_H4  = false,  figure64TripleTopConfirmationDown_D1  = false;
      bool figure65ChannelUp_M1  = false,                             figure65ChannelUp_M5  = false,            figure65ChannelUp_M15 = false,  figure65ChannelUp_H1  = false,  figure65ChannelUp_H4  = false,  figure65ChannelUp_D1  = false;
      bool figure66ChannelDown_M1  = false,                           figure66ChannelDown_M5  = false,          figure66ChannelDown_M15 = false,  figure66ChannelDown_H1  = false,  figure66ChannelDown_H4  = false,  figure66ChannelDown_D1  = false;
      bool figure67TripleBottomUp_M1  = false,                             figure67TripleBottomUp_M5  = false,            figure67TripleBottomUp_M15 = false,  figure67TripleBottomUp_H1  = false,  figure67TripleBottomUp_H4  = false,  figure67TripleBottomUp_D1  = false;
      bool figure68TripleTopDown_M1  = false,                           figure68TripleTopDown_M5  = false,          figure68TripleTopDown_M15 = false,  figure68TripleTopDown_H1  = false,  figure68TripleTopDown_H4  = false,  figure68TripleTopDown_D1  = false;
      bool figure69TripleBottomUp_M1  = false,                             figure69TripleBottomUp_M5  = false,            figure69TripleBottomUp_M15 = false,  figure69TripleBottomUp_H1  = false,  figure69TripleBottomUp_H4  = false,  figure69TripleBottomUp_D1  = false;
      bool figure70TripleTopDown_M1  = false,                           figure70TripleTopDown_M5  = false,          figure70TripleTopDown_M15 = false,  figure70TripleTopDown_H1  = false,  figure70TripleTopDown_H4  = false,  figure70TripleTopDown_D1  = false;
      bool figure71ChannelFlagUp_M1  = false,                             figure71ChannelFlagUp_M5  = false,            figure71ChannelFlagUp_M15 = false,  figure71ChannelFlagUp_H1  = false,  figure71ChannelFlagUp_H4  = false,  figure71ChannelFlagUp_D1  = false;
      bool figure72ChannelFlagDown_M1  = false,                           figure72ChannelFlagDown_M5  = false,          figure72ChannelFlagDown_M15 = false,  figure72ChannelFlagDown_H1  = false,  figure72ChannelFlagDown_H4  = false,  figure72ChannelFlagDown_D1  = false;
      bool figure73HeadAndShouldersUp_M1  = false,                             figure73HeadAndShouldersUp_M5  = false,            figure73HeadAndShouldersUp_M15 = false,  figure73HeadAndShouldersUp_H1  = false,  figure73HeadAndShouldersUp_H4  = false,  figure73HeadAndShouldersUp_D1  = false;
      bool figure74HeadAndShouldersDown_M1  = false,                           figure74HeadAndShouldersDown_M5  = false,          figure74HeadAndShouldersDown_M15 = false,  figure74HeadAndShouldersDown_H1  = false,  figure74HeadAndShouldersDown_H4  = false,  figure74HeadAndShouldersDown_D1  = false;
      bool figure75ChannelConfirmationUp_M1  = false,                             figure75ChannelConfirmationUp_M5  = false,            figure75ChannelConfirmationUp_M15 = false,  figure75ChannelConfirmationUp_H1  = false,  figure75ChannelConfirmationUp_H4  = false,  figure75ChannelConfirmationUp_D1  = false;
      bool figure76ChannelConfirmationDown_M1  = false,                           figure76ChannelConfirmationDown_M5  = false,          figure76ChannelConfirmationDown_M15 = false,  figure76ChannelConfirmationDown_H1  = false,  figure76ChannelConfirmationDown_H4  = false,  figure76ChannelConfirmationDown_D1  = false;
      bool candle1ThreeToOneUp_M1  = false,                             candle1ThreeToOneUp_M5  = false,            candle1ThreeToOneUp_M15 = false,  candle1ThreeToOneUp_H1  = false,  candle1ThreeToOneUp_H4  = false,  candle1ThreeToOneUp_D1  = false;
      bool candle2ThreeToOneDown_M1  = false,                           candle2ThreeToOneDown_M5  = false,          candle2ThreeToOneDown_M15 = false,  candle2ThreeToOneDown_H1  = false,  candle2ThreeToOneDown_H4  = false,  candle2ThreeToOneDown_D1  = false;
      bool candle3_M1  = false, candle3_M5  = false, candle3_M15 = false,  candle3_H1  = false,  candle3_H4  = false,  candle3_D1  = false;
      bool candle4_M1  = false, candle4_M5  = false, candle4_M15 = false,  candle4_H1  = false,  candle4_H4  = false,  candle4_D1  = false;
      bool candle5_M1  = false, candle5_M5  = false, candle5_M15 = false,  candle5_H1  = false,  candle5_H4  = false,  candle5_D1  = false;
      bool candle6_M1  = false, candle6_M5  = false, candle6_M15 = false,  candle6_H1  = false,  candle6_H4  = false,  candle6_D1  = false;
      bool candle7_M1  = false, candle7_M5  = false, candle7_M15 = false,  candle7_H1  = false,  candle7_H4  = false,  candle7_D1  = false;
      bool candle8_M1  = false, candle8_M5  = false, candle8_M15 = false,  candle8_H1  = false,  candle8_H4  = false,  candle8_D1  = false;
      bool candle9_M1  = false, candle9_M5  = false, candle9_M15 = false,  candle9_H1  = false,  candle9_H4  = false,  candle9_D1  = false;
      bool candle10_M1  = false, candle10_M5  = false, candle10_M15 = false,  candle10_H1  = false,  candle10_H4  = false,  candle10_D1  = false;
      bool candle11_M1  = false, candle11_M5  = false, candle11_M15 = false,  candle11_H1  = false,  candle11_H4  = false,  candle11_D1  = false;
      bool candle12_M1  = false, candle12_M5  = false, candle12_M15 = false,  candle12_H1  = false,  candle12_H4  = false,  candle12_D1  = false;
      bool candle13_M1  = false, candle13_M5  = false, candle13_M15 = false,  candle13_H1  = false,  candle13_H4  = false,  candle13_D1  = false;
      bool candle14_M1  = false, candle14_M5  = false, candle14_M15 = false,  candle14_H1  = false,  candle14_H4  = false,  candle14_D1  = false;
      bool candle19_M1  = false, candle19_M5  = false, candle19_M15 = false,  candle19_H1  = false,  candle19_H4  = false,  candle19_D1  = false;
      bool candle20_M1  = false, candle20_M5  = false, candle20_M15 = false,  candle20_H1  = false,  candle20_H4  = false,  candle20_D1  = false;
      bool candle21_M1  = false, candle21_M5  = false, candle21_M15 = false,  candle21_H1  = false,  candle21_H4  = false,  candle21_D1  = false;
      bool candle22_M1  = false, candle22_M5  = false, candle22_M15 = false,  candle22_H1  = false,  candle22_H4  = false,  candle22_D1  = false;
      bool figure_MA_62_Up_M1  = false, figure_MA_62_Up_M5  = false, figure_MA_62_Up_M15 = false,  figure_MA_62_Up_H1  = false,  figure_MA_62_Up_H4  = false,  figure_MA_62_Up_D1  = false;
      bool figure_MA_62_Down_M1  = false, figure_MA_62_Down_M5  = false, figure_MA_62_Down_M15 = false,  figure_MA_62_Down_H1  = false,  figure_MA_62_Down_H4  = false,  figure_MA_62_Down_D1  = false;
      bool twoMinAllTFtoH4Higher_M1  = false, twoMinAllTFtoH4Higher_M5  = false, twoMinAllTFtoH4Higher_M15 = false,  twoMinAllTFtoH4Higher_H1  = false,  twoMinAllTFtoH4Higher_H4  = false;
      bool twoMaxAllTFtoH4Lower_M1  = false, twoMaxAllTFtoH4Lower_M5  = false, twoMaxAllTFtoH4Lower_M15 = false,  twoMaxAllTFtoH4Lower_H1  = false,  twoMaxAllTFtoH4Lower_H4  = false;

      bool fourTimeFramesSignalUp = false;
      bool fourTimeFramesSignalDown = false;



      bool isM1FigureUp =  false;   bool isM5FigureUp =  false;   bool isM15FigureUp = false; bool isH1FigureUp = false; bool isH4FigureUp = false; bool isD1FigureUp = false;
      bool isM1FigureDown =  false; bool isM5FigureDown =  false; bool isM15FigureDown = false; bool isH1FigureDown = false; bool isH4FigureDown = false; bool isD1FigureDown = false;

      bool isM1CandleUp =  false;   bool isM5CandleUp =  false;   bool isM15CandleUp = false; bool isH1CandleUp = false; bool isH4CandleUp = false; bool isD1CandleUp = false;
      bool isM1CandleDown =  false; bool isM5CandleDown =  false; bool isM15CandleDown = false; bool isH1CandleDown = false; bool isH4CandleDown = false; bool isD1CandleDown = false;

      bool isFigureUp = false; bool isFigureDown = false;
      bool isCandleDown = false; bool isCandleUp = false;


      bool blockingFigure9BlockingFlagUpShiftUp_M1 = false;         bool blockingFigure9BlockingFlagUpShiftUp_M5 = false;       bool blockingFigure9BlockingFlagUpShiftUp_M15 = false;       bool blockingFigure9BlockingFlagUpShiftUp_H1 = false;       bool blockingFigure9BlockingFlagUpShiftUp_H4 = false;       bool blockingFigure9BlockingFlagUpShiftUp_D1 = false;
      bool blockingFigure10BlockingFlagUpShiftDown_M1 = false;      bool blockingFigure10BlockingFlagUpShiftDown_M5 = false;    bool blockingFigure10BlockingFlagUpShiftDown_M15 = false;    bool blockingFigure10BlockingFlagUpShiftDown_H1 = false;    bool blockingFigure10BlockingFlagUpShiftDown_H4 = false;    bool blockingFigure10BlockingFlagUpShiftDown_D1 = false;
      bool blockingFigure15BlockingBalancedTriangleUp_M1 = false;   bool blockingFigure15BlockingBalancedTriangleUp_M5 = false; bool blockingFigure15BlockingBalancedTriangleUp_M15 = false; bool blockingFigure15BlockingBalancedTriangleUp_H1 = false; bool blockingFigure15BlockingBalancedTriangleUp_H4 = false; bool blockingFigure15BlockingBalancedTriangleUp_D1 = false;
      bool blockingFigure16BlockingBalancedTriangleUp_M1 = false;   bool blockingFigure16BlockingBalancedTriangleUp_M5 = false; bool blockingFigure16BlockingBalancedTriangleUp_M15 = false; bool blockingFigure16BlockingBalancedTriangleUp_H1 = false; bool blockingFigure16BlockingBalancedTriangleUp_H4 = false; bool blockingFigure16BlockingBalancedTriangleUp_D1 = false;

      bool isM1FigureUpBlocked = false; bool isM5FigureUpBlocked = false; bool isM15FigureUpBlocked = false; bool isH1FigureUpBlocked = false; bool isH4FigureUpBlocked = false; bool isD1FigureUpBlocked = false;
      bool isM1FigureDownBlocked = false; bool isM5FigureDownBlocked = false; bool isM15FigureDownBlocked = false; bool isH1FigureDownBlocked = false; bool isH4FigureDownBlocked = false; bool isD1FigureDownBlocked = false;

bool is11PositionFigureUp_M15 = false, is10PositionFigureUp_M15 = false, is9PositionFigureUp_M15 = false, is11PositionFigureDown_M15 = false, is10PositionFigureDown_M15 = false, is9PositionFigureDown_M15 = false;
// Block 2.1 Определение Тренда
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max

        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure8FlagDownDivergenceDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure8FlagDownDivergenceDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure8FlagDownDivergenceDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure8FlagDownDivergenceDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure8FlagDownDivergenceDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure8FlagDownDivergenceDown_D1  = true;}
            print("Figure 8 FlagDownDivergenceDown Removed", timeFrames[i]);
    }


    // Figure 7_1 "TurnUpDivergenceUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure7_1TurnUpDivergenceUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure7_1TurnUpDivergenceUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure7_1TurnUpDivergenceUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure7_1TurnUpDivergenceUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure7_1TurnUpDivergenceUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure7_1TurnUpDivergenceUp_D1  = true;}
            print("Figure 7_1 TurnUpDivergenceUp ", timeFrames[i]);
    }

    // Figure 8_1 "TurnDownDivergenceDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure8_1TurnDownDivergenceDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure8_1TurnDownDivergenceDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure8_1TurnDownDivergenceDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure8_1TurnDownDivergenceDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure8_1TurnDownDivergenceDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure8_1TurnDownDivergenceDown_D1  = true;}
            print("Figure 8_1 TurnDownDivergenceDown ", timeFrames[i]);
    }



    // Figure 7_2 "TurnDivergenceConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal < fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i])*/
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMinGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        /*&& isTrendNoErrorForSellReverseFilter5(firstMaxGlobal, secondMaxGlobal, thirdMaxGlobal)
        && isTrendNoErrorForSellFilter4(firstMinGlobal, secondMinGlobal, thirdMinGlobal)
        && isH1ConsistentForSellFilter3()
        && isSecondHalfWaveCommitedToTrendDownFilter2(secondMaxGlobal, timeFrames[i]*/
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure20HeadAndShouldersConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure20HeadAndShouldersConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure20HeadAndShouldersConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure20HeadAndShouldersConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure20HeadAndShouldersConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure20HeadAndShouldersConfirmationDown_D1  = true;}
            print("Figure 20 HeadAndShouldersConfirmationDown ", timeFrames[i]);
    }

    // Figure 21 "WedgeUp"

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
            isC5Min

        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])

        ){
            if(timeFrames[i]==PERIOD_M1) {figure21WedgeUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure21WedgeUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure21WedgeUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure21WedgeUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure21WedgeUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure21WedgeUp_D1  = true;}
            print("Figure 21 WedgeUp", timeFrames[i]);
    }

    // Figure 22 "WedgeDown"

    if(
        firstMaxGlobal > firstMinGlobal &&
        secondMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(firstMinGlobal, firstMaxGlobal,secondMaxGlobal) &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && /*firstMinGlobal and thirdMaxGlobal*/ firstMinGlobal > thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&
        isC5Max
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure22WedgeDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure22WedgeDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure22WedgeDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure22WedgeDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure22WedgeDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure22WedgeDown_D1  = true;}
            print("Figure 22 WedgeDown", timeFrames[i]);
    }

    // Figure 23 "DiamondUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal<secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27ModerateDivergentFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27ModerateDivergentFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27ModerateDivergentFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27ModerateDivergentFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27ModerateDivergentFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27ModerateDivergentFlagConfirmationUp_D1  = true;}
            print("Figure 27 ModerateDivergentFlagConfirmationUp Removed", timeFrames[i]);
    }

    // Figure 28 "ModerateDivergentFlagConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && /*secondMaxGlobal and thirdMinGlobal */ secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28ModerateDivergentFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28ModerateDivergentFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28ModerateDivergentFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28ModerateDivergentFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28ModerateDivergentFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28ModerateDivergentFlagConfirmationDown_D1  = true;}
            print("Figure 28 ModerateDivergentFlagConfirmationDown  Removed", timeFrames[i]);
    }

    // Figure 27_1 "DoubleBottomFlagUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal < fourthMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && /*secondMaxGlobal and fourthMinGlobal &&*/ secondMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_1DoubleBottomFlagUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_1DoubleBottomFlagUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_1DoubleBottomFlagUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_1DoubleBottomFlagUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_1DoubleBottomFlagUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_1DoubleBottomFlagUp_D1  = true;}
            print("Figure 27_1 DoubleBottomFlagUp", timeFrames[i]);
    }

    // Figure 28_1 "DoubleTopFlagDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && /*secondMinGlobal and fourthMaxGlobal &&*/ secondMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_1DoubleTopFlagDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_1DoubleTopFlagDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_1DoubleTopFlagDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_1DoubleTopFlagDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_1DoubleTopFlagDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_1DoubleTopFlagDown_D1  = true;}
            print("Figure 28_1 DoubleTopFlagDown", timeFrames[i]);
    }


    // Figure 27_2 "TriangleAsConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > firstMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && /*thirdMinGlobal and fourthMaxGlobal &&*/ thirdMinGlobal > fifthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_2TriangleAsConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_2TriangleAsConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_2TriangleAsConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_2TriangleAsConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_2TriangleAsConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_2TriangleAsConfirmationUp_D1  = true;}
            print("Figure 27_2 TriangleAsConfirmationUp", timeFrames[i]);
    }

    // Figure 28_2 "TriangleAsConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && /*thirdMaxGlobal and fourthMinGlobal*/ thirdMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_2TriangleAsConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_2TriangleAsConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_2TriangleAsConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_2TriangleAsConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_2TriangleAsConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_2TriangleAsConfirmationDown_D1  = true;}
            print("Figure 28_2 TriangleAsConfirmationDown", timeFrames[i]);
    }

    // Figure 27_3 "DoubleBottomChannelUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fourthMaxGlobal && firstMinGlobal > fifthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal > fourthMinGlobal && secondMinGlobal > fourthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && /*thirdMinGlobal and fourthMaxGlobal &&*/ thirdMinGlobal > fifthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_3DoubleBottomChannelUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_3DoubleBottomChannelUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_3DoubleBottomChannelUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_3DoubleBottomChannelUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_3DoubleBottomChannelUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_3DoubleBottomChannelUp_D1  = true;}
            print("Figure 27_3 DoubleBottomChannelUp", timeFrames[i]);
    }

    // Figure 28_3 "DoubleTopChannelDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fourthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && /*thirdMaxGlobal and fourthMinGlobal*/ thirdMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fourthMinGlobal && thirdMinGlobal < fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_3DoubleTopChannelDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_3DoubleTopChannelDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_3DoubleTopChannelDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_3DoubleTopChannelDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_3DoubleTopChannelDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_3DoubleTopChannelDown_D1  = true;}
            print("Figure 28_3 DoubleTopChannelDown", timeFrames[i]);
    }

    // Figure 27_4 "WedgePennantConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fifthMinGlobal && firstMinGlobal > fifthMaxGlobal && firstMinGlobal > sixthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal > fifthMaxGlobal && firstMaxGlobal > sixthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal < fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal > fifthMaxGlobal && secondMinGlobal > sixthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal && secondMaxGlobal > fifthMaxGlobal && secondMaxGlobal > sixthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fifthMinGlobal && thirdMinGlobal > fifthMaxGlobal && thirdMinGlobal > sixthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal > fifthMaxGlobal && thirdMaxGlobal > sixthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal && fourthMinGlobal > fifthMaxGlobal && fourthMinGlobal > sixthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal > fifthMaxGlobal && fourthMaxGlobal > sixthMinGlobal &&
        fifthMinGlobal < fifthMaxGlobal && fifthMinGlobal > sixthMinGlobal &&
        fifthMaxGlobal > sixthMinGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_4WedgePennantConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_4WedgePennantConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_4WedgePennantConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_4WedgePennantConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_4WedgePennantConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_4WedgePennantConfirmationUp_D1  = true;}
            print("Figure 27_4 WedgePennantConfirmationUp", timeFrames[i]);
    }

    // Figure 28_4 "WedgePennantConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal && firstMaxGlobal < fifthMinGlobal && firstMaxGlobal < sixthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fifthMaxGlobal && firstMinGlobal < fifthMinGlobal && firstMinGlobal < sixthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMaxGlobal < fifthMinGlobal && secondMaxGlobal < sixthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal < fifthMinGlobal && secondMinGlobal < sixthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal < fifthMinGlobal && thirdMaxGlobal < sixthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal < fifthMinGlobal && thirdMinGlobal < sixthMaxGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal && fourthMaxGlobal < fifthMinGlobal && fourthMaxGlobal < sixthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal < fifthMinGlobal && fourthMinGlobal < sixthMaxGlobal &&
        fifthMaxGlobal > fifthMinGlobal && fifthMaxGlobal < sixthMaxGlobal &&
        fifthMinGlobal < sixthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_4WedgePennantConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_4WedgePennantConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_4WedgePennantConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_4WedgePennantConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_4WedgePennantConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_4WedgePennantConfirmationDown_D1  = true;}
            print("Figure 28_4 WedgePennantConfirmationDown", timeFrames[i]);
    }


    // Figure 27_5 "DoubleBottomConDivDivConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fifthMinGlobal && firstMinGlobal < fifthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fifthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal > fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fifthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fifthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fifthMinGlobal && thirdMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fifthMinGlobal && thirdMaxGlobal < fifthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal < fifthMinGlobal && fourthMinGlobal < fifthMaxGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fifthMinGlobal < fifthMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_5DoubleBottomConDivDivConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_5DoubleBottomConDivDivConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_5DoubleBottomConDivDivConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_5DoubleBottomConDivDivConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_5DoubleBottomConDivDivConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_5DoubleBottomConDivDivConfirmationUp_D1  = true;}
            print("Figure 27_5 DoubleBottomConDivDivConfirmationUp", timeFrames[i]);
    }

    // Figure 28_5 "DoubleTopConDivDivConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fifthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fifthMaxGlobal && firstMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fifthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fifthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fifthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fifthMaxGlobal && thirdMinGlobal > fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMaxGlobal && fourthMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        fifthMaxGlobal > fifthMinGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_5DoubleTopConDivDivConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_5DoubleTopConDivDivConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_5DoubleTopConDivDivConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_5DoubleTopConDivDivConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_5DoubleTopConDivDivConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_5DoubleTopConDivDivConfirmationDown_D1  = true;}
            print("Figure 28_5 DoubleTopConDivDivConfirmationDown", timeFrames[i]);
    }


    // Figure 27_6 "DoubleBottomDivConDivConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fifthMinGlobal && firstMinGlobal < fifthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal < fifthMinGlobal && firstMaxGlobal < fifthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal > fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fifthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal < fifthMinGlobal && secondMaxGlobal < fifthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fifthMinGlobal && thirdMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal < fifthMinGlobal && thirdMaxGlobal < fifthMaxGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal < fifthMinGlobal && fourthMinGlobal < fifthMaxGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal < fifthMaxGlobal &&
        fifthMinGlobal < fifthMaxGlobal &&

        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_6DoubleBottomDivConDivConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_6DoubleBottomDivConDivConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_6DoubleBottomDivConDivConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_6DoubleBottomDivConDivConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_6DoubleBottomDivConDivConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_6DoubleBottomDivConDivConfirmationUp_D1  = true;}
            print("Figure 27_6 DoubleBottomDivConDivConfirmationUp", timeFrames[i]);
    }

    // Figure 28_6 "DoubleTopDivConDivConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fifthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal > fifthMaxGlobal && firstMinGlobal > fifthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fifthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal > fifthMaxGlobal && secondMinGlobal > fifthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fifthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal > fifthMaxGlobal && thirdMinGlobal > fifthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMaxGlobal && fourthMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal > fifthMinGlobal &&
        fifthMaxGlobal > fifthMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_6DoubleTopDivConDivConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_6DoubleTopDivConDivConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_6DoubleTopDivConDivConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_6DoubleTopDivConDivConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_6DoubleTopDivConDivConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_6DoubleTopDivConDivConfirmationDown_D1  = true;}
            print("Figure 28_6 DoubleTopDivConDivConfirmationDown", timeFrames[i]);
    }


    // Figure 27_7 "DoubleBottom12PosUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fifthMinGlobal && firstMinGlobal < fifthMaxGlobal && firstMinGlobal < sixthMinGlobal && fifthMinGlobal < sixthMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal < fifthMaxGlobal && firstMaxGlobal < sixthMinGlobal && firstMaxGlobal < sixthMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal < fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal < sixthMinGlobal && secondMinGlobal < secondMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMaxGlobal < sixthMinGlobal && secondMaxGlobal < sixthMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fifthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal < sixthMinGlobal && thirdMinGlobal < sixthMaxGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal < sixthMinGlobal && thirdMaxGlobal < sixthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal > fifthMinGlobal && fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal < sixthMinGlobal && fourthMinGlobal < sixthMaxGlobal &&
        fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal < fifthMaxGlobal && fourthMaxGlobal < sixthMinGlobal && fourthMaxGlobal < sixthMaxGlobal &&
        fifthMinGlobal < fifthMaxGlobal && fifthMinGlobal < sixthMinGlobal && fifthMinGlobal < sixthMaxGlobal &&
        fifthMaxGlobal > sixthMinGlobal && fifthMaxGlobal < sixthMaxGlobal &&
        sixthMinGlobal < sixthMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure27_7DoubleBottom12PosUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure27_7DoubleBottom12PosUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure27_7DoubleBottom12PosUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure27_7DoubleBottom12PosUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure27_7DoubleBottom12PosUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure27_7DoubleBottom12PosUp_D1  = true;}
            print("Figure 27_7 DoubleBottom12PosUp", timeFrames[i]);
    }

    // Figure 28_7 "DoubleTop12PosDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal > fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fifthMaxGlobal && firstMaxGlobal > fifthMinGlobal && firstMaxGlobal > sixthMaxGlobal && firstMaxGlobal > sixthMinGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fifthMaxGlobal && firstMinGlobal > fifthMinGlobal && firstMinGlobal > sixthMaxGlobal && firstMinGlobal > sixthMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fifthMaxGlobal && secondMaxGlobal > fifthMinGlobal && secondMaxGlobal > sixthMaxGlobal && secondMaxGlobal > sixthMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal < fifthMaxGlobal && secondMinGlobal > fifthMinGlobal && secondMinGlobal > sixthMaxGlobal && secondMinGlobal > sixthMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fifthMaxGlobal && thirdMaxGlobal > fifthMinGlobal && thirdMaxGlobal > sixthMaxGlobal && thirdMaxGlobal > sixthMinGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal && thirdMinGlobal > fifthMinGlobal && thirdMinGlobal > sixthMaxGlobal && thirdMinGlobal > sixthMinGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal < fifthMaxGlobal && fourthMaxGlobal > fifthMinGlobal && fourthMaxGlobal > sixthMaxGlobal && fourthMaxGlobal > sixthMinGlobal &&
        fourthMinGlobal < fifthMaxGlobal && fourthMinGlobal > fifthMinGlobal && fourthMinGlobal > sixthMaxGlobal && fourthMinGlobal > sixthMinGlobal &&
        fifthMaxGlobal > fifthMinGlobal && fifthMaxGlobal > sixthMaxGlobal && fifthMaxGlobal > sixthMinGlobal &&
        fifthMinGlobal < sixthMaxGlobal && fifthMinGlobal < sixthMinGlobal &&
        sixthMaxGlobal > sixthMinGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure28_7DoubleTop12PosDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure28_7DoubleTop12PosDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure28_7DoubleTop12PosDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure28_7DoubleTop12PosDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure28_7DoubleTop12PosDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure28_7DoubleTop12PosDown_D1  = true;}
            print("Figure 28_7 DoubleTop12PosDown", timeFrames[i]);
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal &&  firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax(secondMaxGlobal,firstMaxGlobal,thirdMaxGlobal)/*thirdMaxGlobal*/ && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure37PennantWedgeUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure37PennantWedgeUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure37PennantWedgeUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure37PennantWedgeUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure37PennantWedgeUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure37PennantWedgeUp_D1  = true;}
            print("Figure 37 PennantWedgeUp ChangedPlaced ", timeFrames[i]);
    }

    // Figure 38 "PennantWedgeDown"

    if(
            firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > channelLimiterForLowerEdgeMaxMinMin(secondMinGlobal, firstMinGlobal,thirdMinGlobal) /*thirdMinGlobal*/ && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
            firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
            secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
            secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
            thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
            thirdMaxGlobal > fourthMinGlobal &&
            isC5Min
            // && isMACDNewlyCrossedUpFilter1(timeFrames[i])

        ){
            if(timeFrames[i]==PERIOD_M1) {figure38PennantWedgeDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure38PennantWedgeDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure38PennantWedgeDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure38PennantWedgeDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure38PennantWedgeDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure38PennantWedgeDown_D1  = true;}
            print("Figure 38 PennantWedgeDown ChangedPlaced ", timeFrames[i]);
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal  && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure41MoreDivergentFlagConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure41MoreDivergentFlagConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure41MoreDivergentFlagConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure41MoreDivergentFlagConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure41MoreDivergentFlagConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure41MoreDivergentFlagConfirmationUp_D1  = true;}
            print("Figure 41 MoreDivergentFlagConfirmationUp ChangedPlaced", timeFrames[i]);
    }

    // Figure 42 "MoreDivergentFlagConfirmationDown"

    if(
            firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
            firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
            secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
            secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
            thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
            thirdMaxGlobal > fourthMinGlobal &&
            isC5Min
            // && isMACDNewlyCrossedUpFilter1(timeFrames[i])

        ){
            if(timeFrames[i]==PERIOD_M1) {figure42MoreDivergentFlagConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure42MoreDivergentFlagConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure42MoreDivergentFlagConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure42MoreDivergentFlagConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure42MoreDivergentFlagConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure42MoreDivergentFlagConfirmationDown_D1  = true;}
            print("Figure 42 MoreDivergentFlagConfirmationDown ChangedPlaced", timeFrames[i]);
    }

    // Figure 43 "ChannelFlagUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal > fourthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax (secondMinGlobal, fifthMaxGlobal, secondMaxGlobal)/*secondMaxGlobal*/ && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > thirdMaxGlobal && secondMinGlobal > fourthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal &&
        secondMinGlobal > channelLimiterForLowerEdgeMaxMinMin (firstMaxGlobal, secondMinGlobal, firstMinGlobal) &&
        firstMinGlobal > channelLimiterForLowerEdgeMaxMinMin (firstMaxGlobal, secondMinGlobal, firstMinGlobal) &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        firstMaxGlobal < channelLimiterForUpperEdgeMinMaxMax (firstMinGlobal, secondMaxGlobal, firstMaxGlobal) &&
        secondMaxGlobal < channelLimiterForUpperEdgeMinMaxMax (firstMinGlobal, secondMaxGlobal, firstMaxGlobal) &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
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
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
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
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure52WedgeConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure52WedgeConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure52WedgeConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure52WedgeConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure52WedgeConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure52WedgeConfirmationDown_D1  = true;}
            print("Figure 52 WedgeConfirmationDown ", timeFrames[i]);
    }

   // Figure 59 "TripleBottomWedgeUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure59TripleBottomWedgeUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure59TripleBottomWedgeUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure59TripleBottomWedgeUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure59TripleBottomWedgeUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure59TripleBottomWedgeUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure59TripleBottomWedgeUp_D1  = true;}
            print("Figure 59 TripleBottomWedgeUp ", timeFrames[i]);
    }

    // Figure 60 "TripleTopWedgeDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal > thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure60TripleTopWedgeDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure60TripleTopWedgeDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure60TripleTopWedgeDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure60TripleTopWedgeDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure60TripleTopWedgeDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure60TripleTopWedgeDown_D1  = true;}
            print("Figure 60 TripleTopWedgeDown ", timeFrames[i]);
    }

   // Figure 61 "TripleBottomConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > thirdMinGlobal &&

        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure61TripleBottomConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure61TripleBottomConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure61TripleBottomConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure61TripleBottomConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure61TripleBottomConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure61TripleBottomConfirmationUp_D1  = true;}
            print("Figure 61 TripleBottomConfirmationUp ", timeFrames[i]);
    }

    // Figure 62 "TripleTopConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal< thirdMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal &&


        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure62TripleTopConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure62TripleTopConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure62TripleTopConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure62TripleTopConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure62TripleTopConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure62TripleTopConfirmationDown_D1  = true;}
            print("Figure 62 TripleTopConfirmationDown ", timeFrames[i]);
    }


   // Figure 63 "TripleBottomConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > thirdMinGlobal &&

        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure63TripleBottomConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure63TripleBottomConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure63TripleBottomConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure63TripleBottomConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure63TripleBottomConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure63TripleBottomConfirmationUp_D1  = true;}
            print("Figure 63 TripleBottomConfirmationUp ", timeFrames[i]);
    }

    // Figure 64 "TripleTopConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal< thirdMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal &&


        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure64TripleTopConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure64TripleTopConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure64TripleTopConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure64TripleTopConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure64TripleTopConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure64TripleTopConfirmationDown_D1  = true;}
            print("Figure 64 TripleTopConfirmationDown ", timeFrames[i]);
    }

   // Figure 65 "ChannelUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal > thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure65ChannelUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure65ChannelUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure65ChannelUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure65ChannelUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure65ChannelUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure65ChannelUp_D1  = true;}
            print("Figure 65 ChannelUp ", timeFrames[i]);
    }

    // Figure 66 "ChannelDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal < thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure66ChannelDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure66ChannelDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure66ChannelDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure66ChannelDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure66ChannelDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure66ChannelDown_D1  = true;}
            print("Figure 66 ChannelDown ", timeFrames[i]);
    }



   // Figure 67 "TripleBottomUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure67TripleBottomUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure67TripleBottomUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure67TripleBottomUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure67TripleBottomUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure67TripleBottomUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure67TripleBottomUp_D1  = true;}
            print("Figure 67 TripleBottomUp ", timeFrames[i]);
    }

    // Figure 68 "TripleTopDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal < secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure68TripleTopDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure68TripleTopDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure68TripleTopDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure68TripleTopDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure68TripleTopDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure68TripleTopDown_D1  = true;}
            print("Figure 68 TripleTopDown ", timeFrames[i]);
    }




   // Figure 69 "TripleBottomUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure69TripleBottomUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure69TripleBottomUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure69TripleBottomUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure69TripleBottomUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure69TripleBottomUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure69TripleBottomUp_D1  = true;}
            print("Figure 69 TripleBottomUp ", timeFrames[i]);
    }

    // Figure 70 "TripleTopDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure70TripleTopDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure70TripleTopDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure70TripleTopDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure70TripleTopDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure70TripleTopDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure70TripleTopDown_D1  = true;}
            print("Figure 70 TripleTopDown ", timeFrames[i]);
    }


    // Figure 71 "ChannelFlagUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal < thirdMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal < fifthMinGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fifthMinGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&  secondMinGlobal > fourthMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal < fifthMinGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fifthMinGlobal &&
        thirdMinGlobal < thirdMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal < fifthMinGlobal &&
        thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fifthMinGlobal &&
        fourthMinGlobal < fourthMaxGlobal && fourthMinGlobal < fifthMinGlobal &&
        fourthMaxGlobal > fifthMinGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure71ChannelFlagUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure71ChannelFlagUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure71ChannelFlagUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure71ChannelFlagUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure71ChannelFlagUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure71ChannelFlagUp_D1  = true;}
            print("Figure 71 ChannelFlagUp", timeFrames[i]);
    }

    // Figure 72 "ChannelFlagDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  && firstMaxGlobal < fourthMaxGlobal && firstMaxGlobal > fourthMinGlobal && firstMaxGlobal > fifthMaxGlobal &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal > thirdMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < fourthMaxGlobal && firstMinGlobal > fourthMinGlobal && firstMinGlobal < fifthMaxGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < fourthMaxGlobal && secondMaxGlobal > fourthMinGlobal && secondMaxGlobal > fifthMaxGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < fourthMaxGlobal && secondMinGlobal > fourthMinGlobal && secondMinGlobal < fifthMaxGlobal &&
        thirdMaxGlobal > thirdMinGlobal && thirdMaxGlobal < fourthMaxGlobal && thirdMaxGlobal > fourthMinGlobal && thirdMaxGlobal > fifthMaxGlobal &&
        thirdMinGlobal < fourthMaxGlobal && thirdMinGlobal > fourthMinGlobal && thirdMinGlobal < fifthMaxGlobal &&
        fourthMaxGlobal > fourthMinGlobal && fourthMaxGlobal > fifthMaxGlobal &&
        fourthMinGlobal < fifthMaxGlobal &&
        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure72ChannelFlagDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure72ChannelFlagDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure72ChannelFlagDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure72ChannelFlagDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure72ChannelFlagDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure72ChannelFlagDown_D1  = true;}
            print("Figure 72 ChannelFlagDown", timeFrames[i]);
    }


   // Figure 73 "HeadAndShouldersUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal < thirdMinGlobal && firstMinGlobal < thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal < thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal < thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal < thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure73HeadAndShouldersUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure73HeadAndShouldersUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure73HeadAndShouldersUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure73HeadAndShouldersUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure73HeadAndShouldersUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure73HeadAndShouldersUp_D1  = true;}
            print("Figure 73 HeadAndShouldersUp ", timeFrames[i]);
    }

    // Figure 74 "HeadAndShouldersDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal > thirdMaxGlobal && firstMaxGlobal > thirdMinGlobal  &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal > thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal > thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal > thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure74HeadAndShouldersDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure74HeadAndShouldersDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure74HeadAndShouldersDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure74HeadAndShouldersDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure74HeadAndShouldersDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure74HeadAndShouldersDown_D1  = true;}
            print("Figure 74 HeadAndShouldersDown ", timeFrames[i]);
    }

   // Figure 75 "ChannelConfirmationUp"

    if(
        firstMinGlobal < firstMaxGlobal && firstMinGlobal > secondMinGlobal && firstMinGlobal < secondMaxGlobal && firstMinGlobal > thirdMinGlobal && firstMinGlobal > thirdMaxGlobal &&
        firstMaxGlobal > secondMinGlobal && firstMaxGlobal > secondMaxGlobal && firstMaxGlobal > thirdMinGlobal && firstMaxGlobal > thirdMaxGlobal &&
        secondMinGlobal < secondMaxGlobal && secondMinGlobal > thirdMinGlobal && secondMinGlobal < thirdMaxGlobal &&
        secondMaxGlobal > thirdMinGlobal && secondMaxGlobal > thirdMaxGlobal &&
        thirdMinGlobal < thirdMaxGlobal &&
        isC5Min
        // && isMACDNewlyCrossedUpFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure75ChannelConfirmationUp_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure75ChannelConfirmationUp_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure75ChannelConfirmationUp_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure75ChannelConfirmationUp_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure75ChannelConfirmationUp_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure75ChannelConfirmationUp_D1  = true;}
            print("Figure 75 ChannelConfirmationUp ", timeFrames[i]);
    }

    // Figure 76 "ChannelConfirmationDown"

    if(
        firstMaxGlobal > firstMinGlobal && firstMaxGlobal < secondMaxGlobal && firstMaxGlobal > secondMinGlobal && firstMaxGlobal < thirdMaxGlobal && firstMaxGlobal < thirdMinGlobal  &&
        firstMinGlobal < secondMaxGlobal && firstMinGlobal < secondMinGlobal && firstMinGlobal< thirdMaxGlobal && firstMinGlobal < thirdMinGlobal &&
        secondMaxGlobal > secondMinGlobal && secondMaxGlobal < thirdMaxGlobal && secondMaxGlobal > thirdMinGlobal &&
        secondMinGlobal < thirdMaxGlobal && secondMinGlobal < thirdMinGlobal &&
        thirdMaxGlobal > thirdMinGlobal &&

        isC5Max
        // && isMACDNewlyCrossedDownFilter1(timeFrames[i])
        ){
            if(timeFrames[i]==PERIOD_M1) {figure76ChannelConfirmationDown_M1  = true;}
            if(timeFrames[i]==PERIOD_M5) {figure76ChannelConfirmationDown_M5  = true;}
            if(timeFrames[i]==PERIOD_M15){figure76ChannelConfirmationDown_M15 = true;}
            if(timeFrames[i]==PERIOD_H1) {figure76ChannelConfirmationDown_H1  = true;}
            if(timeFrames[i]==PERIOD_H4) {figure76ChannelConfirmationDown_H4  = true;}
            if(timeFrames[i]==PERIOD_D1) {figure76ChannelConfirmationDown_D1  = true;}
            print("Figure 76 ChannelConfirmationDown ", timeFrames[i]);
    }
            // Candle 3 ""
            if(isCandle3(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle3_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle3_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle3_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle3_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle3_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle3_D1  = true;}
                    print("Candle 3  ", timeFrames[i]);
            }

            // Candle 4 ""
            else if(isCandle4(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle4_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle4_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle4_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle4_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle4_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle4_D1  = true;}
                    print("Candle 4  ", timeFrames[i]);
            }

            // Candle 5 ""
            else if(isCandle5(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle5_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle5_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle5_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle5_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle5_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle5_D1  = true;}
                    print("Candle 5  ", timeFrames[i]);
            }

            // Candle 6 ""
            else if(isCandle6(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle6_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle6_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle6_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle6_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle6_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle6_D1  = true;}
                    print("Candle 6  ", timeFrames[i]);
            }
            // Candle 7 ""
            else if(isCandle7(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle7_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle7_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle7_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle7_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle7_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle7_D1  = true;}
                    print("Candle 7  ", timeFrames[i]);
            }

            // Candle 8 ""
            else if(isCandle8(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle8_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle8_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle8_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle8_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle8_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle8_D1  = true;}
                    print("Candle 8  ", timeFrames[i]);
            }
            // Candle 9 ""
            else if(isCandle9(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle9_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle9_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle9_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle9_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle9_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle9_D1  = true;}
                    print("Candle 9  ", timeFrames[i]);
            }

            // Candle 10 ""
            else if(isCandle10(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle10_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle10_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle10_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle10_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle10_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle10_D1  = true;}
                    print("Candle 10  ", timeFrames[i]);
            }
            // Candle 11 ""
            else if(isCandle11(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle11_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle11_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle11_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle11_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle11_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle11_D1  = true;}
                    print("Candle 11  ", timeFrames[i]);
            }

            // Candle 12 ""
            else if(isCandle12(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle12_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle12_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle12_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle12_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle12_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle12_D1  = true;}
                    print("Candle 12  ", timeFrames[i]);
            }
            // Candle 13 ""
            else if(isCandle13(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle13_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle13_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle13_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle13_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle13_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle13_D1  = true;}
                    print("Candle 13  ", timeFrames[i]);
            }

            // Candle 14 ""
            else if(isCandle14(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle14_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle14_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle14_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle14_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle14_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle14_D1  = true;}
                    print("Candle 14  ", timeFrames[i]);
            }
            // Candle 19 ""
            else if(isCandle19(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle19_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle19_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle19_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle19_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle19_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle19_D1  = true;}
                    print("Candle 19  ", timeFrames[i]);
            }

            // Candle 20 ""
            else if(isCandle20(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle20_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle20_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle20_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle20_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle20_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle20_D1  = true;}
                    print("Candle 20  ", timeFrames[i]);
            }
            // Candle 21 ""
            else if(isCandle21(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle21_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle21_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle21_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle21_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle21_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle21_D1  = true;}
                    print("Candle 21  ", timeFrames[i]);
            }

            // Candle 22 ""
            else if(isCandle22(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {candle22_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {candle22_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){candle22_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {candle22_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {candle22_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {candle22_D1  = true;}
                    print("Candle 22  ", timeFrames[i]);
            }

                    else{
                       // Candle 1 "ThreeToOneUp"
                        if(isCandle1ThreeToOneUp(timeFrames[i])){
                                if(timeFrames[i]==PERIOD_M1) {candle1ThreeToOneUp_M1  = true;}
                                if(timeFrames[i]==PERIOD_M5) {candle1ThreeToOneUp_M5  = true;}
                                if(timeFrames[i]==PERIOD_M15){candle1ThreeToOneUp_M15 = true;}
                                if(timeFrames[i]==PERIOD_H1) {candle1ThreeToOneUp_H1  = true;}
                                if(timeFrames[i]==PERIOD_H4) {candle1ThreeToOneUp_H4  = true;}
                                if(timeFrames[i]==PERIOD_D1) {candle1ThreeToOneUp_D1  = true;}
                                print("Candle 1 ThreeToOneUp ", timeFrames[i]);
                        }

                        // Candle 2 "ThreeToOneDown"
                        if(isCandle2ThreeToOneDown(timeFrames[i])){
                                if(timeFrames[i]==PERIOD_M1) {candle2ThreeToOneDown_M1  = true;}
                                if(timeFrames[i]==PERIOD_M5) {candle2ThreeToOneDown_M5  = true;}
                                if(timeFrames[i]==PERIOD_M15){candle2ThreeToOneDown_M15 = true;}
                                if(timeFrames[i]==PERIOD_H1) {candle2ThreeToOneDown_H1  = true;}
                                if(timeFrames[i]==PERIOD_H4) {candle2ThreeToOneDown_H4  = true;}
                                if(timeFrames[i]==PERIOD_D1) {candle2ThreeToOneDown_D1  = true;}
                                print("Candle 2 ThreeToOneDown ", timeFrames[i]);
                        }
                    }

            // Figure_MA_62_Up
            if(isFigure_MA_62_Up(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {figure_MA_62_Up_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {figure_MA_62_Up_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){figure_MA_62_Up_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {figure_MA_62_Up_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {figure_MA_62_Up_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {figure_MA_62_Up_D1  = true;}
                    print("Figure_MA_62_Up  ", timeFrames[i]);
            }

            // Figure_MA_62_Down ""
            if(isFigure_MA_62_Down(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {figure_MA_62_Down_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {figure_MA_62_Down_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){figure_MA_62_Down_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {figure_MA_62_Down_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {figure_MA_62_Down_H4  = true;}
                    if(timeFrames[i]==PERIOD_D1) {figure_MA_62_Down_D1  = true;}
                    print("Figure_MA_62_Down  ", timeFrames[i]);
            }
            // twoMinAllTFtoH4Higher
            if(isTwoMinAllTFtoH4Higher_Up(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {twoMinAllTFtoH4Higher_Up_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {twoMinAllTFtoH4Higher_Up_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){twoMinAllTFtoH4Higher_Up_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {twoMinAllTFtoH4Higher_Up_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {twoMinAllTFtoH4Higher_Up_H4  = true;}
                    print("twoMinAllTFtoH4Higher  ", timeFrames[i]);
            }

            // twoMaxAllTFtoH4Lower
            if(isTwoMaxAllTFtoH4Lower_Down(timeFrames[i])){
                    if(timeFrames[i]==PERIOD_M1) {twoMaxAllTFtoH4Lower_Down_M1  = true;}
                    if(timeFrames[i]==PERIOD_M5) {twoMaxAllTFtoH4Lower_Down_M5  = true;}
                    if(timeFrames[i]==PERIOD_M15){twoMaxAllTFtoH4Lower_Down_M15 = true;}
                    if(timeFrames[i]==PERIOD_H1) {twoMaxAllTFtoH4Lower_Down_H1  = true;}
                    if(timeFrames[i]==PERIOD_H4) {twoMaxAllTFtoH4Lower_Down_H4  = true;}
                    print("twoMaxAllTFtoH4Lower  ", timeFrames[i]);
            }

}

bool OpenOnHalfWaveOpenPermitUp_M1     = false;
bool OpenOnHalfWaveOpenPermitUp_M5     = false;
bool OpenOnHalfWaveOpenPermitUp_M15    = false;
bool OpenOnHalfWaveOpenPermitDown_M1   = false;
bool OpenOnHalfWaveOpenPermitDown_M5   = false;
bool OpenOnHalfWaveOpenPermitDown_M15  = false;

// Method returns true if two ticks from one side and two from another.
// So flag(s) are criterions
 if( OpenOnHalfWaveUp_M1) {
    OpenOnHalfWaveOpenPermitUp_M1    = isOpenOnHalfWaveUp_M1();
 }
 if( OpenOnHalfWaveUp_M5) {
    OpenOnHalfWaveOpenPermitUp_M5    = isOpenOnHalfWaveUp_M5();
 }
 if( OpenOnHalfWaveUp_M15) {
    OpenOnHalfWaveOpenPermitUp_M15   = isOpenOnHalfWaveUp_M15();
 }
 if( OpenOnHalfWaveDown_M1) {
    OpenOnHalfWaveOpenPermitDown_M1  = isOpenOnHalfWaveDown_M1();
 }
 if( OpenOnHalfWaveDown_M5) {
    OpenOnHalfWaveOpenPermitDown_M5  = isOpenOnHalfWaveDown_M5();
 }
 if( OpenOnHalfWaveDown_M15) {
    OpenOnHalfWaveOpenPermitDown_M15 = isOpenOnHalfWaveDown_M15();
 }

// MACD Filter Block
double macd0_M5  = 0.0; double macd1_M5  = 0.0; double macd2_M5  = 0.0;
double macd0_M15  = 0.0; double macd1_M15  = 0.0; double macd2_M15  = 0.0;
double macd0_H1  = 0.0; double macd1_H1  = 0.0; double macd2_H1  = 0.0;
double osma0_H1  = 0.0; double osma1_H1  = 0.0; double osma2_H1  = 0.0;
double macd0_H4  = 0.0; double macd1_H4  = 0.0; double macd2_H4  = 0.0; double macd0_D1  = 0.0; double macd1_D1  = 0.0; double macd2_D1  = 0.0;
double macd0_MN1 = 0.0; double macd1_MN1 = 0.0; double macd2_MN1 = 0.0;

macd0_M5 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_M5 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_M5 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,2);

macd0_M15 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_M15 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_M15 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,2);

macd0_H1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_H1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_H1 = iMACD(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,MODE_MAIN,2);

osma0_H1 = iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,0);
osma1_H1 = iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,1);
osma2_H1 = iOsMA(NULL,PERIOD_H1,12,26,9,PRICE_OPEN,2);

macd0_H4 = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_H4 = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_H4 = iMACD(NULL,PERIOD_H4,12,26,9,PRICE_OPEN,MODE_MAIN,2);


macd0_D1 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_D1 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_D1 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,2);

macd0_MN1 = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
macd1_MN1 = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
macd2_MN1 = iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_OPEN,MODE_MAIN,2);

// Block 4 TF
/*if(
    macd0_H4 > 0 &&
    macd0_H1 > macd1_H1 && macd1_H1 > macd2_H1 && osma0_H1 > osma1_H1 && osma1_H1 > osma2_H1  &&
    macd0_M15 <0 && macd0_M15 > macd1_M15 && macd1_M15 > macd2_M15 &&
    macd0_M5 > 0 && macd1_M5 < 0
){
    print("4TF signal UP ", PERIOD_M5);
    fourTimeFramesSignalUp = true;
}

if(
    macd0_H4 < 0 &&
    macd0_H1 < macd1_H1 && macd1_H1 < macd2_H1 && osma0_H1 < osma1_H1 && osma1_H1 < osma2_H1  &&
    macd0_M15 >0 && macd0_M15 < macd1_M15 && macd1_M15 < macd2_M15 &&
    macd0_M5 < 0 && macd1_M5 > 0
){
    print("4TF signal UP ", PERIOD_M5);
    fourTimeFramesSignalDown = true;
}*/

   if(total<maxOrders)
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


     isD1FigureUp  =  figure1FlagUpContinueUp_D1 || figure1_1FlagUpContinueAfterDecliningUp_D1 || figure3TripleUp_D1    || figure5PennantUp_D1  || figure5_1PennantUpConfirmationUp_D1  || figure7FlagUpDivergenceUp_D1  || figure7_1TurnUpDivergenceUp_D1  || figure7_2TurnDivergenceConfirmationUp_D1 || figure9FlagUpShiftUp_D1   || figure11DoubleBottomUp_D1  || figure13DivergentChannelUp_D1  || figure13_1DivergenceFlagConfirmationUp_D1  || figure15BalancedTriangleUp_D1 || figure17FlagConfirmationUp_D1 || figure19HeadAndShouldersConfirmationUp_D1 || figure21WedgeUp_D1 || figure23DiamondUp_D1 || figure25TriangleConfirmationUp_D1                                                      || figure27ModerateDivergentFlagConfirmationUp_D1   || figure27_1DoubleBottomFlagUp_D1  || figure27_2TriangleAsConfirmationUp_D1 || figure27_3DoubleBottomChannelUp_D1 || figure27_4WedgePennantConfirmationUp_D1 || figure27_5DoubleBottomConDivDivConfirmationUp_D1 || figure27_6DoubleBottomDivConDivConfirmationUp_D1 || figure27_7DoubleBottom12PosUp_D1 ||  figure29DoubleBottomConfirmationUp_D1 || figure31DivergentFlagConfirmationUp_D1 || figure33FlagWedgeForelockConfirmationUp_D1 || figure35TripleBottomConfirmationUp_D1 || figure37PennantWedgeUp_D1 || figure39RollbackChannelPennantConfirmationUp_D1 || figure41MoreDivergentFlagConfirmationUp_D1 || figure43ChannelFlagUp_D1 || figure45PennantAfterWedgeConfirmationUp_D1 || figure47PennantAfterFlagConfirmationUp_D1 || figure49DoublePennantAfterConfirmationUp_D1                    || figure51WedgeConfirmationUp_D1  || figure59TripleBottomWedgeUp_D1  || figure61TripleBottomConfirmationUp_D1  || figure63TripleBottomConfirmationUp_D1  || figure65ChannelUp_D1  || figure67TripleBottomUp_D1  || figure69TripleBottomUp_D1  || figure71ChannelFlagUp_D1  || figure73HeadAndShouldersUp_D1  || figure75ChannelConfirmationUp_D1  ;
     isH4FigureUp  =  figure1FlagUpContinueUp_H4 || figure1_1FlagUpContinueAfterDecliningUp_H4 || figure3TripleUp_H4    || figure5PennantUp_H4  || figure5_1PennantUpConfirmationUp_H4  || figure7FlagUpDivergenceUp_H4  || figure7_1TurnUpDivergenceUp_H4  || figure7_2TurnDivergenceConfirmationUp_H4 || figure9FlagUpShiftUp_H4   || figure11DoubleBottomUp_H4  || figure13DivergentChannelUp_H4  || figure13_1DivergenceFlagConfirmationUp_H4  || figure15BalancedTriangleUp_H4 || figure17FlagConfirmationUp_H4 || figure19HeadAndShouldersConfirmationUp_H4 || figure21WedgeUp_H4 || figure23DiamondUp_H4 || figure25TriangleConfirmationUp_H4                                                      || figure27ModerateDivergentFlagConfirmationUp_H4   || figure27_1DoubleBottomFlagUp_H4  || figure27_2TriangleAsConfirmationUp_H4 || figure27_3DoubleBottomChannelUp_H4 || figure27_4WedgePennantConfirmationUp_H4 || figure27_5DoubleBottomConDivDivConfirmationUp_H4 || figure27_6DoubleBottomDivConDivConfirmationUp_H4 || figure27_7DoubleBottom12PosUp_H4 ||  figure29DoubleBottomConfirmationUp_H4 || figure31DivergentFlagConfirmationUp_H4 || figure33FlagWedgeForelockConfirmationUp_H4 || figure35TripleBottomConfirmationUp_H4 || figure37PennantWedgeUp_H4 || figure39RollbackChannelPennantConfirmationUp_H4 || figure41MoreDivergentFlagConfirmationUp_H4 || figure43ChannelFlagUp_H4 || figure45PennantAfterWedgeConfirmationUp_H4 || figure47PennantAfterFlagConfirmationUp_H4 || figure49DoublePennantAfterConfirmationUp_H4                    || figure51WedgeConfirmationUp_H4  || figure59TripleBottomWedgeUp_H4  || figure61TripleBottomConfirmationUp_H4  || figure63TripleBottomConfirmationUp_H4  || figure65ChannelUp_H4  || figure67TripleBottomUp_H4  || figure69TripleBottomUp_H4  || figure71ChannelFlagUp_H4  || figure73HeadAndShouldersUp_H4  || figure75ChannelConfirmationUp_H4  ;
     isH1FigureUp  =  figure1FlagUpContinueUp_H1 || figure1_1FlagUpContinueAfterDecliningUp_H1 || figure3TripleUp_H1    || figure5PennantUp_H1  || figure5_1PennantUpConfirmationUp_H1  || figure7FlagUpDivergenceUp_H1  || figure7_1TurnUpDivergenceUp_H1  || figure7_2TurnDivergenceConfirmationUp_H1 || figure9FlagUpShiftUp_H1   || figure11DoubleBottomUp_H1  || figure13DivergentChannelUp_H1  || figure13_1DivergenceFlagConfirmationUp_H1  || figure15BalancedTriangleUp_H1 || figure17FlagConfirmationUp_H1 || figure19HeadAndShouldersConfirmationUp_H1 || figure21WedgeUp_H1 || figure23DiamondUp_H1 || figure25TriangleConfirmationUp_H1                                                      || figure27ModerateDivergentFlagConfirmationUp_H1   || figure27_1DoubleBottomFlagUp_H1  || figure27_2TriangleAsConfirmationUp_H1 || figure27_3DoubleBottomChannelUp_H1 || figure27_4WedgePennantConfirmationUp_H1 || figure27_5DoubleBottomConDivDivConfirmationUp_H1 || figure27_6DoubleBottomDivConDivConfirmationUp_H1 || figure27_7DoubleBottom12PosUp_H1 ||  figure29DoubleBottomConfirmationUp_H1 || figure31DivergentFlagConfirmationUp_H1 || figure33FlagWedgeForelockConfirmationUp_H1 || figure35TripleBottomConfirmationUp_H1 || figure37PennantWedgeUp_H1 || figure39RollbackChannelPennantConfirmationUp_H1 || figure41MoreDivergentFlagConfirmationUp_H1 || figure43ChannelFlagUp_H1 || figure45PennantAfterWedgeConfirmationUp_H1 || figure47PennantAfterFlagConfirmationUp_H1 || figure49DoublePennantAfterConfirmationUp_H1                    || figure51WedgeConfirmationUp_H1  || figure59TripleBottomWedgeUp_H1  || figure61TripleBottomConfirmationUp_H1  || figure63TripleBottomConfirmationUp_H1  || figure65ChannelUp_H1  || figure67TripleBottomUp_H1  || figure69TripleBottomUp_H1  || figure71ChannelFlagUp_H1  || figure73HeadAndShouldersUp_H1  || figure75ChannelConfirmationUp_H1  ;
     isM15FigureUp =  figure1FlagUpContinueUp_M15 || figure1_1FlagUpContinueAfterDecliningUp_M15 || figure3TripleUp_M15 || figure5PennantUp_M15 || figure5_1PennantUpConfirmationUp_M15 || figure7FlagUpDivergenceUp_M15 || figure7_1TurnUpDivergenceUp_M15 || figure7_2TurnDivergenceConfirmationUp_M15 || figure9FlagUpShiftUp_M15 || figure11DoubleBottomUp_M15 || figure13DivergentChannelUp_M15 || figure13_1DivergenceFlagConfirmationUp_M15 || figure15BalancedTriangleUp_M15 || figure17FlagConfirmationUp_M15 || figure19HeadAndShouldersConfirmationUp_M15 || figure21WedgeUp_M15 || figure23DiamondUp_M15 || figure25TriangleConfirmationUp_M15                                                || figure27ModerateDivergentFlagConfirmationUp_M15  || figure27_1DoubleBottomFlagUp_M15 || figure27_2TriangleAsConfirmationUp_M15 || figure27_3DoubleBottomChannelUp_M15 || figure27_4WedgePennantConfirmationUp_M15 || figure27_5DoubleBottomConDivDivConfirmationUp_M15 || figure27_6DoubleBottomDivConDivConfirmationUp_M15 || figure27_7DoubleBottom12PosUp_M15 ||  figure29DoubleBottomConfirmationUp_M15 || figure31DivergentFlagConfirmationUp_M15 || figure33FlagWedgeForelockConfirmationUp_M15 || figure35TripleBottomConfirmationUp_M15 || figure37PennantWedgeUp_M15 || figure39RollbackChannelPennantConfirmationUp_M15 || figure41MoreDivergentFlagConfirmationUp_M15 || figure43ChannelFlagUp_M15 || figure45PennantAfterWedgeConfirmationUp_M15 || figure47PennantAfterFlagConfirmationUp_M15 || figure49DoublePennantAfterConfirmationUp_M15   || figure51WedgeConfirmationUp_M15 || figure59TripleBottomWedgeUp_M15 || figure61TripleBottomConfirmationUp_M15 || figure63TripleBottomConfirmationUp_M15 || figure65ChannelUp_M15 || figure67TripleBottomUp_M15 || figure69TripleBottomUp_M15 || figure71ChannelFlagUp_M15 || figure73HeadAndShouldersUp_M15 || figure75ChannelConfirmationUp_M15 ;
     isM5FigureUp  =  figure1FlagUpContinueUp_M5 || figure1_1FlagUpContinueAfterDecliningUp_M5 || figure3TripleUp_M5    || figure5PennantUp_M5  || figure5_1PennantUpConfirmationUp_M5  || figure7FlagUpDivergenceUp_M5  || figure7_1TurnUpDivergenceUp_M5  || figure7_2TurnDivergenceConfirmationUp_M5 || figure9FlagUpShiftUp_M5   || figure11DoubleBottomUp_M5  || figure13DivergentChannelUp_M5  || figure13_1DivergenceFlagConfirmationUp_M5  || figure15BalancedTriangleUp_M5 || figure17FlagConfirmationUp_M5 || figure19HeadAndShouldersConfirmationUp_M5 || figure21WedgeUp_M5 || figure23DiamondUp_M5 || figure25TriangleConfirmationUp_M5                                                      || figure27ModerateDivergentFlagConfirmationUp_M5   || figure27_1DoubleBottomFlagUp_M5  || figure27_2TriangleAsConfirmationUp_M5 || figure27_3DoubleBottomChannelUp_M5 || figure27_4WedgePennantConfirmationUp_M5 || figure27_5DoubleBottomConDivDivConfirmationUp_M5 || figure27_6DoubleBottomDivConDivConfirmationUp_M5 || figure27_7DoubleBottom12PosUp_M5 ||  figure29DoubleBottomConfirmationUp_M5 || figure31DivergentFlagConfirmationUp_M5 || figure33FlagWedgeForelockConfirmationUp_M5 || figure35TripleBottomConfirmationUp_M5 || figure37PennantWedgeUp_M5 || figure39RollbackChannelPennantConfirmationUp_M5 || figure41MoreDivergentFlagConfirmationUp_M5 || figure43ChannelFlagUp_M5 || figure45PennantAfterWedgeConfirmationUp_M5 || figure47PennantAfterFlagConfirmationUp_M5 || figure49DoublePennantAfterConfirmationUp_M5                    || figure51WedgeConfirmationUp_M5  || figure59TripleBottomWedgeUp_M5  || figure61TripleBottomConfirmationUp_M5  || figure63TripleBottomConfirmationUp_M5  || figure65ChannelUp_M5  || figure67TripleBottomUp_M5  || figure69TripleBottomUp_M5  || figure71ChannelFlagUp_M5  || figure73HeadAndShouldersUp_M5  || figure75ChannelConfirmationUp_M5  ;
     isM1FigureUp  =  figure1FlagUpContinueUp_M1 || figure1_1FlagUpContinueAfterDecliningUp_M1 || figure3TripleUp_M1    || figure5PennantUp_M1  || figure5_1PennantUpConfirmationUp_M1  || figure7FlagUpDivergenceUp_M1  || figure7_1TurnUpDivergenceUp_M1  || figure7_2TurnDivergenceConfirmationUp_M1 || figure9FlagUpShiftUp_M1   || figure11DoubleBottomUp_M1  || figure13DivergentChannelUp_M1  || figure13_1DivergenceFlagConfirmationUp_M1  || figure15BalancedTriangleUp_M1 || figure17FlagConfirmationUp_M1 || figure19HeadAndShouldersConfirmationUp_M1 || figure21WedgeUp_M1 || figure23DiamondUp_M1 || figure25TriangleConfirmationUp_M1                                                      || figure27ModerateDivergentFlagConfirmationUp_M1   || figure27_1DoubleBottomFlagUp_M1  || figure27_2TriangleAsConfirmationUp_M1 || figure27_3DoubleBottomChannelUp_M1 || figure27_4WedgePennantConfirmationUp_M1 || figure27_5DoubleBottomConDivDivConfirmationUp_M1 || figure27_6DoubleBottomDivConDivConfirmationUp_M1 || figure27_7DoubleBottom12PosUp_M1 ||  figure29DoubleBottomConfirmationUp_M1 || figure31DivergentFlagConfirmationUp_M1 || figure33FlagWedgeForelockConfirmationUp_M1 || figure35TripleBottomConfirmationUp_M1 || figure37PennantWedgeUp_M1 || figure39RollbackChannelPennantConfirmationUp_M1 || figure41MoreDivergentFlagConfirmationUp_M1 || figure43ChannelFlagUp_M1 || figure45PennantAfterWedgeConfirmationUp_M1 || figure47PennantAfterFlagConfirmationUp_M1 || figure49DoublePennantAfterConfirmationUp_M1                    || figure51WedgeConfirmationUp_M1  || figure59TripleBottomWedgeUp_M1  || figure61TripleBottomConfirmationUp_M1  || figure63TripleBottomConfirmationUp_M1  || figure65ChannelUp_M1  || figure67TripleBottomUp_M1  || figure69TripleBottomUp_M1  || figure71ChannelFlagUp_M1  || figure73HeadAndShouldersUp_M1  || figure75ChannelConfirmationUp_M1  ;

     isD1CandleUp  =  candle1ThreeToOneUp_D1  ||  candle3_D1 ||  candle5_D1 ||  candle7_D1 ||  candle9_D1  ||  candle11_D1  ||  candle13_D1  ||  candle19_D1  ||  candle21_D1    ;
     isH4CandleUp  =  candle1ThreeToOneUp_H4  ||  candle3_H4 ||  candle5_H4 ||  candle7_H4 ||  candle9_H4  ||  candle11_H4  ||  candle13_H4  ||  candle19_H4  ||  candle21_H4    ;
     isH1CandleUp  =  candle1ThreeToOneUp_H1  ||  candle3_H1 ||  candle5_H1 ||  candle7_H1 ||  candle9_H1  ||  candle11_H1  ||  candle13_H1  ||  candle19_H1  ||  candle21_H1    ;
     isM15CandleUp =  candle1ThreeToOneUp_M15 || candle3_M15 || candle5_M15 || candle7_M15 ||  candle9_M15 ||  candle11_M15 ||  candle13_M15 ||  candle19_M15 ||  candle21_M15    ;
     isM5CandleUp  =  candle1ThreeToOneUp_M5  ||  candle3_M5 ||  candle5_M5 ||  candle7_M5 ||  candle9_M5  ||  candle11_M5  ||  candle13_M5  ||  candle19_M5  ||  candle21_M5    ;
     isM1CandleUp  =  candle1ThreeToOneUp_M1  ||  candle3_M1 ||  candle5_M1 ||  candle7_M1 ||  candle9_M1  ||  candle11_M1  ||  candle13_M1  ||  candle19_M1  ||  candle21_M1    ;

     isD1FigureDown  =  figure2FlagDownContinueDown_D1 || figure2_1FlagDownContinueAfterDecreaseDown_D1 ||figure4TripleDown_D1     || figure6PennantDown_D1  || figure6_1PennantDownConfirmationDown_D1  || figure8FlagDownDivergenceDown_D1  || figure8_1TurnDownDivergenceDown_D1  || figure8_2TurnDivergenceConfirmationDown_D1  || figure10FlagDownShiftDown_D1  || figure12DoubleTopDown_D1  || figure14DivergentChannelDown_D1  || figure14_1DivergenceFlagConfirmationDown_D1 || figure16BalancedTriangleDown_D1 || figure18FlagConfirmationDown_D1 || figure20HeadAndShouldersConfirmationDown_D1 || figure22WedgeDown_D1 || figure24DiamondDown_D1       || figure26TriangleConfirmationDown_D1   || figure28ModerateDivergentFlagConfirmationDown_D1  || figure28_1DoubleTopFlagDown_D1     || figure28_2TriangleAsConfirmationDown_D1 || figure28_3DoubleTopChannelDown_D1 || figure28_4WedgePennantConfirmationDown_D1 || figure28_5DoubleTopConDivDivConfirmationDown_D1 || figure28_6DoubleTopDivConDivConfirmationDown_D1 || figure28_7DoubleTop12PosDown_D1 || figure30DoubleTopConfirmationDown_D1 || figure32DivergentFlagConfirmationDown_D1 || figure34FlagWedgeForelockConfirmationDown_D1 || figure36TripleTopConfirmationDown_D1 || figure38PennantWedgeDown_D1 || figure40RollbackChannelPennantConfirmationDown_D1 || figure42MoreDivergentFlagConfirmationDown_D1 || figure44ChannelFlagDown_D1 || figure46PennantAfterWedgeConfirmationDown_D1 || figure48PennantAfterFlagConfirmationDown_D1 || figure50DoublePennantAfterConfirmationDown_D1                      || figure52WedgeConfirmationDown_D1  || figure60TripleTopWedgeDown_D1  || figure62TripleTopConfirmationDown_D1  || figure64TripleTopConfirmationDown_D1  || figure66ChannelDown_D1  || figure68TripleTopDown_D1  || figure70TripleTopDown_D1  || figure72ChannelFlagDown_D1  || figure74HeadAndShouldersDown_D1  || figure76ChannelConfirmationDown_D1  ;
     isH4FigureDown  =  figure2FlagDownContinueDown_H4 || figure2_1FlagDownContinueAfterDecreaseDown_H4 ||figure4TripleDown_H4     || figure6PennantDown_H4  || figure6_1PennantDownConfirmationDown_H4  || figure8FlagDownDivergenceDown_H4  || figure8_1TurnDownDivergenceDown_H4  || figure8_2TurnDivergenceConfirmationDown_H4  || figure10FlagDownShiftDown_H4  || figure12DoubleTopDown_H4  || figure14DivergentChannelDown_H4  || figure14_1DivergenceFlagConfirmationDown_H4 || figure16BalancedTriangleDown_H4 || figure18FlagConfirmationDown_H4 || figure20HeadAndShouldersConfirmationDown_H4 || figure22WedgeDown_H4 || figure24DiamondDown_H4 || figure26TriangleConfirmationDown_H4         || figure28ModerateDivergentFlagConfirmationDown_H4  || figure28_1DoubleTopFlagDown_H4     || figure28_2TriangleAsConfirmationDown_H4 || figure28_3DoubleTopChannelDown_H4 || figure28_4WedgePennantConfirmationDown_H4 || figure28_5DoubleTopConDivDivConfirmationDown_H4 || figure28_6DoubleTopDivConDivConfirmationDown_H4 || figure28_7DoubleTop12PosDown_H4 || figure30DoubleTopConfirmationDown_H4 || figure32DivergentFlagConfirmationDown_H4 || figure34FlagWedgeForelockConfirmationDown_H4 || figure36TripleTopConfirmationDown_H4 || figure38PennantWedgeDown_H4 || figure40RollbackChannelPennantConfirmationDown_H4 || figure42MoreDivergentFlagConfirmationDown_H4 || figure44ChannelFlagDown_H4 || figure46PennantAfterWedgeConfirmationDown_H4 || figure48PennantAfterFlagConfirmationDown_H4 || figure50DoublePennantAfterConfirmationDown_H4                      || figure52WedgeConfirmationDown_H4  || figure60TripleTopWedgeDown_H4  || figure62TripleTopConfirmationDown_H4  || figure64TripleTopConfirmationDown_H4  || figure66ChannelDown_H4  || figure68TripleTopDown_H4  || figure70TripleTopDown_H4  || figure72ChannelFlagDown_H4  || figure74HeadAndShouldersDown_H4  || figure76ChannelConfirmationDown_H4  ;
     isH1FigureDown  =  figure2FlagDownContinueDown_H1 || figure2_1FlagDownContinueAfterDecreaseDown_H1 ||figure4TripleDown_H1     || figure6PennantDown_H1  || figure6_1PennantDownConfirmationDown_H1  || figure8FlagDownDivergenceDown_H1  || figure8_1TurnDownDivergenceDown_H1  || figure8_2TurnDivergenceConfirmationDown_H1  || figure10FlagDownShiftDown_H1  || figure12DoubleTopDown_H1  || figure14DivergentChannelDown_H1  || figure14_1DivergenceFlagConfirmationDown_H1 || figure16BalancedTriangleDown_H1 || figure18FlagConfirmationDown_H1 || figure20HeadAndShouldersConfirmationDown_H1 || figure22WedgeDown_H1 || figure24DiamondDown_H1 || figure26TriangleConfirmationDown_H1         || figure28ModerateDivergentFlagConfirmationDown_H1  || figure28_1DoubleTopFlagDown_H1     || figure28_2TriangleAsConfirmationDown_H1 || figure28_3DoubleTopChannelDown_H1 || figure28_4WedgePennantConfirmationDown_H1 || figure28_5DoubleTopConDivDivConfirmationDown_H1 || figure28_6DoubleTopDivConDivConfirmationDown_H1 || figure28_7DoubleTop12PosDown_H1 || figure30DoubleTopConfirmationDown_H1 || figure32DivergentFlagConfirmationDown_H1 || figure34FlagWedgeForelockConfirmationDown_H1 || figure36TripleTopConfirmationDown_H1 || figure38PennantWedgeDown_H1 || figure40RollbackChannelPennantConfirmationDown_H1 || figure42MoreDivergentFlagConfirmationDown_H1 || figure44ChannelFlagDown_H1 || figure46PennantAfterWedgeConfirmationDown_H1 || figure48PennantAfterFlagConfirmationDown_H1 || figure50DoublePennantAfterConfirmationDown_H1                      || figure52WedgeConfirmationDown_H1  || figure60TripleTopWedgeDown_H1  || figure62TripleTopConfirmationDown_H1  || figure64TripleTopConfirmationDown_H1  || figure66ChannelDown_H1  || figure68TripleTopDown_H1  || figure70TripleTopDown_H1  || figure72ChannelFlagDown_H1  || figure74HeadAndShouldersDown_H1  || figure76ChannelConfirmationDown_H1  ;
     isM15FigureDown =  figure2FlagDownContinueDown_M15 || figure2_1FlagDownContinueAfterDecreaseDown_M15 ||figure4TripleDown_M15  || figure6PennantDown_M15 || figure6_1PennantDownConfirmationDown_M15 || figure8FlagDownDivergenceDown_M15 || figure8_1TurnDownDivergenceDown_M15 || figure8_2TurnDivergenceConfirmationDown_M15 || figure10FlagDownShiftDown_M15 || figure12DoubleTopDown_M15 || figure14DivergentChannelDown_M15 || figure14_1DivergenceFlagConfirmationDown_M15 || figure16BalancedTriangleDown_M15 || figure18FlagConfirmationDown_M15 || figure20HeadAndShouldersConfirmationDown_M15 || figure22WedgeDown_M15 || figure24DiamondDown_M15 || figure26TriangleConfirmationDown_M15  || figure28ModerateDivergentFlagConfirmationDown_M15 || figure28_1DoubleTopFlagDown_M15    || figure28_2TriangleAsConfirmationDown_M15 || figure28_3DoubleTopChannelDown_M15 || figure28_4WedgePennantConfirmationDown_M15 || figure28_5DoubleTopConDivDivConfirmationDown_M15 || figure28_6DoubleTopDivConDivConfirmationDown_M15 || figure28_7DoubleTop12PosDown_M15 || figure30DoubleTopConfirmationDown_M15 || figure32DivergentFlagConfirmationDown_M15 || figure34FlagWedgeForelockConfirmationDown_M15 || figure36TripleTopConfirmationDown_M15 || figure38PennantWedgeDown_M15 || figure40RollbackChannelPennantConfirmationDown_M15 || figure42MoreDivergentFlagConfirmationDown_M15 || figure44ChannelFlagDown_M15 || figure46PennantAfterWedgeConfirmationDown_M15 || figure48PennantAfterFlagConfirmationDown_M15 || figure50DoublePennantAfterConfirmationDown_M15     || figure52WedgeConfirmationDown_M15 || figure60TripleTopWedgeDown_M15 || figure62TripleTopConfirmationDown_M15 || figure64TripleTopConfirmationDown_M15 || figure66ChannelDown_M15 || figure68TripleTopDown_M15 || figure70TripleTopDown_M15 || figure72ChannelFlagDown_M15 || figure74HeadAndShouldersDown_M15 || figure76ChannelConfirmationDown_M15 ;
     isM5FigureDown  =  figure2FlagDownContinueDown_M5 || figure2_1FlagDownContinueAfterDecreaseDown_M5 ||figure4TripleDown_M5     || figure6PennantDown_M5  || figure6_1PennantDownConfirmationDown_M5  || figure8FlagDownDivergenceDown_M5  || figure8_1TurnDownDivergenceDown_M5  || figure8_2TurnDivergenceConfirmationDown_M5  || figure10FlagDownShiftDown_M5  || figure12DoubleTopDown_M5  || figure14DivergentChannelDown_M5  || figure14_1DivergenceFlagConfirmationDown_M5 || figure16BalancedTriangleDown_M5 || figure18FlagConfirmationDown_M5 || figure20HeadAndShouldersConfirmationDown_M5 || figure22WedgeDown_M5 || figure24DiamondDown_M5 || figure26TriangleConfirmationDown_M5         || figure28ModerateDivergentFlagConfirmationDown_M5  || figure28_1DoubleTopFlagDown_M5     || figure28_2TriangleAsConfirmationDown_M5 || figure28_3DoubleTopChannelDown_M5 || figure28_4WedgePennantConfirmationDown_M5 || figure28_5DoubleTopConDivDivConfirmationDown_M5 || figure28_6DoubleTopDivConDivConfirmationDown_M5 || figure28_7DoubleTop12PosDown_M5 || figure30DoubleTopConfirmationDown_M5 || figure32DivergentFlagConfirmationDown_M5 || figure34FlagWedgeForelockConfirmationDown_M5 || figure36TripleTopConfirmationDown_M5 || figure38PennantWedgeDown_M5 || figure40RollbackChannelPennantConfirmationDown_M5 || figure42MoreDivergentFlagConfirmationDown_M5 || figure44ChannelFlagDown_M5 || figure46PennantAfterWedgeConfirmationDown_M5 || figure48PennantAfterFlagConfirmationDown_M5 || figure50DoublePennantAfterConfirmationDown_M5                      || figure52WedgeConfirmationDown_M5  || figure60TripleTopWedgeDown_M5  || figure62TripleTopConfirmationDown_M5  || figure64TripleTopConfirmationDown_M5  || figure66ChannelDown_M5  || figure68TripleTopDown_M5  || figure70TripleTopDown_M5  || figure72ChannelFlagDown_M5  || figure74HeadAndShouldersDown_M5  || figure76ChannelConfirmationDown_M5  ;
     isM1FigureDown  =  figure2FlagDownContinueDown_M1 || figure2_1FlagDownContinueAfterDecreaseDown_M1 ||figure4TripleDown_M1     || figure6PennantDown_M1  || figure6_1PennantDownConfirmationDown_M1  || figure8FlagDownDivergenceDown_M1  || figure8_1TurnDownDivergenceDown_M1  || figure8_2TurnDivergenceConfirmationDown_M1  || figure10FlagDownShiftDown_M1  || figure12DoubleTopDown_M1  || figure14DivergentChannelDown_M1  || figure14_1DivergenceFlagConfirmationDown_M1 || figure16BalancedTriangleDown_M1 || figure18FlagConfirmationDown_M1 || figure20HeadAndShouldersConfirmationDown_M1 || figure22WedgeDown_M1 || figure24DiamondDown_M1 || figure26TriangleConfirmationDown_M1         || figure28ModerateDivergentFlagConfirmationDown_M1  || figure28_1DoubleTopFlagDown_M1     || figure28_2TriangleAsConfirmationDown_M1 || figure28_3DoubleTopChannelDown_M1 || figure28_4WedgePennantConfirmationDown_M1 || figure28_5DoubleTopConDivDivConfirmationDown_M1 || figure28_6DoubleTopDivConDivConfirmationDown_M1 || figure28_7DoubleTop12PosDown_M1 || figure30DoubleTopConfirmationDown_M1 || figure32DivergentFlagConfirmationDown_M1 || figure34FlagWedgeForelockConfirmationDown_M1 || figure36TripleTopConfirmationDown_M1 || figure38PennantWedgeDown_M1 || figure40RollbackChannelPennantConfirmationDown_M1 || figure42MoreDivergentFlagConfirmationDown_M1 || figure44ChannelFlagDown_M1 || figure46PennantAfterWedgeConfirmationDown_M1 || figure48PennantAfterFlagConfirmationDown_M1 || figure50DoublePennantAfterConfirmationDown_M1                      || figure52WedgeConfirmationDown_M1  || figure60TripleTopWedgeDown_M1  || figure62TripleTopConfirmationDown_M1  || figure64TripleTopConfirmationDown_M1  || figure66ChannelDown_M1  || figure68TripleTopDown_M1  || figure70TripleTopDown_M1  || figure72ChannelFlagDown_M1  || figure74HeadAndShouldersDown_M1  || figure76ChannelConfirmationDown_M1  ;

     isD1CandleDown  =  candle2ThreeToOneDown_D1 ||  candle4_D1 ||  candle6_D1  ||  candle8_D1  ||  candle10_D1  ||  candle12_D1  ||  candle14_D1  ||  candle20_D1  ||  candle22_D1  ;
     isH4CandleDown  =  candle2ThreeToOneDown_H4 ||  candle4_H4 ||  candle6_H4  ||  candle8_H4  ||  candle10_H4  ||  candle12_H4  ||  candle14_H4  ||  candle20_H4  ||  candle22_H4  ;
     isH1CandleDown  =  candle2ThreeToOneDown_H1 ||  candle4_H1 ||  candle6_H1  ||  candle8_H1  ||  candle10_H1  ||  candle12_H1  ||  candle14_H1  ||  candle20_H1  ||  candle22_H1  ;
     isM15CandleDown =  candle2ThreeToOneDown_M15 || candle4_M15 || candle6_M15 ||  candle8_M15 ||  candle10_M15 ||  candle12_M15 ||  candle14_M15 ||  candle20_M15 ||  candle22_M15 ;
     isM5CandleDown  =  candle2ThreeToOneDown_M5 ||  candle4_M5 ||  candle6_M5  ||  candle8_M5  ||  candle10_M5  ||  candle12_M5  ||  candle14_M5  ||  candle20_M5  ||  candle22_M5  ;
     isM1CandleDown  =  candle2ThreeToOneDown_M1 ||  candle4_M1 ||  candle6_M1  ||  candle8_M1  ||  candle10_M1  ||  candle12_M1  ||  candle14_M1  ||  candle20_M1  ||  candle22_M1  ;

/*  // After third round of removed figures
     isD1FigureUp  =  figure1_1FlagUpContinueAfterDecliningUp_D1      || figure7_1TurnUpDivergenceUp_D1  || figure7_2TurnDivergenceConfirmationUp_D1    || figure19HeadAndShouldersConfirmationUp_D1           || figure27_1DoubleBottomFlagUp_D1  || figure27_2TriangleAsConfirmationUp_D1 || figure27_3DoubleBottomChannelUp_D1 || figure27_4WedgePennantConfirmationUp_D1 || figure27_5DoubleBottomConDivDivConfirmationUp_D1 || figure27_6DoubleBottomDivConDivConfirmationUp_D1 || figure27_7DoubleBottom12PosUp_D1 ||  figure29DoubleBottomConfirmationUp_D1  || figure33FlagWedgeForelockConfirmationUp_D1 || figure35TripleBottomConfirmationUp_D1       || figure39RollbackChannelPennantConfirmationUp_D1  || figure45PennantAfterWedgeConfirmationUp_D1 || figure47PennantAfterFlagConfirmationUp_D1 || figure49DoublePennantAfterConfirmationUp_D1 || figure51WedgeConfirmationUp_D1;
     isH4FigureUp  =  figure1_1FlagUpContinueAfterDecliningUp_H4      || figure7_1TurnUpDivergenceUp_H4  || figure7_2TurnDivergenceConfirmationUp_H4    || figure19HeadAndShouldersConfirmationUp_H4           || figure27_1DoubleBottomFlagUp_H4  || figure27_2TriangleAsConfirmationUp_H4 || figure27_3DoubleBottomChannelUp_H4 || figure27_4WedgePennantConfirmationUp_H4 || figure27_5DoubleBottomConDivDivConfirmationUp_H4 || figure27_6DoubleBottomDivConDivConfirmationUp_H4 || figure27_7DoubleBottom12PosUp_H4 ||  figure29DoubleBottomConfirmationUp_H4  || figure33FlagWedgeForelockConfirmationUp_H4 || figure35TripleBottomConfirmationUp_H4       || figure39RollbackChannelPennantConfirmationUp_H4  || figure45PennantAfterWedgeConfirmationUp_H4 || figure47PennantAfterFlagConfirmationUp_H4 || figure49DoublePennantAfterConfirmationUp_H4 || figure51WedgeConfirmationUp_H4;
     isH1FigureUp  =  figure1_1FlagUpContinueAfterDecliningUp_H1      || figure7_1TurnUpDivergenceUp_H1  || figure7_2TurnDivergenceConfirmationUp_H1    || figure19HeadAndShouldersConfirmationUp_H1           || figure27_1DoubleBottomFlagUp_H1  || figure27_2TriangleAsConfirmationUp_H1 || figure27_3DoubleBottomChannelUp_H1 || figure27_4WedgePennantConfirmationUp_H1 || figure27_5DoubleBottomConDivDivConfirmationUp_H1 || figure27_6DoubleBottomDivConDivConfirmationUp_H1 || figure27_7DoubleBottom12PosUp_H1 ||  figure29DoubleBottomConfirmationUp_H1  || figure33FlagWedgeForelockConfirmationUp_H1 || figure35TripleBottomConfirmationUp_H1       || figure39RollbackChannelPennantConfirmationUp_H1  || figure45PennantAfterWedgeConfirmationUp_H1 || figure47PennantAfterFlagConfirmationUp_H1 || figure49DoublePennantAfterConfirmationUp_H1 || figure51WedgeConfirmationUp_H1;
     isM15FigureUp =   figure1_1FlagUpContinueAfterDecliningUp_M15    || figure7_1TurnUpDivergenceUp_M15 || figure7_2TurnDivergenceConfirmationUp_M15   || figure19HeadAndShouldersConfirmationUp_M15          || figure27_1DoubleBottomFlagUp_M15 || figure27_2TriangleAsConfirmationUp_M15 || figure27_3DoubleBottomChannelUp_M15 || figure27_4WedgePennantConfirmationUp_M15 || figure27_5DoubleBottomConDivDivConfirmationUp_M15 || figure27_6DoubleBottomDivConDivConfirmationUp_M15 || figure27_7DoubleBottom12PosUp_M15 ||  figure29DoubleBottomConfirmationUp_M15  || figure33FlagWedgeForelockConfirmationUp_M15 || figure35TripleBottomConfirmationUp_M15 || figure39RollbackChannelPennantConfirmationUp_M15  || figure45PennantAfterWedgeConfirmationUp_M15 || figure47PennantAfterFlagConfirmationUp_M15 || figure49DoublePennantAfterConfirmationUp_M15 || figure51WedgeConfirmationUp_M15;
     isM5FigureUp  =  figure1_1FlagUpContinueAfterDecliningUp_M5      || figure7_1TurnUpDivergenceUp_M5  || figure7_2TurnDivergenceConfirmationUp_M5    || figure19HeadAndShouldersConfirmationUp_M5           || figure27_1DoubleBottomFlagUp_M5  || figure27_2TriangleAsConfirmationUp_M5 || figure27_3DoubleBottomChannelUp_M5 || figure27_4WedgePennantConfirmationUp_M5 || figure27_5DoubleBottomConDivDivConfirmationUp_M5 || figure27_6DoubleBottomDivConDivConfirmationUp_M5 || figure27_7DoubleBottom12PosUp_M5 ||  figure29DoubleBottomConfirmationUp_M5  || figure33FlagWedgeForelockConfirmationUp_M5 || figure35TripleBottomConfirmationUp_M5       || figure39RollbackChannelPennantConfirmationUp_M5  || figure45PennantAfterWedgeConfirmationUp_M5 || figure47PennantAfterFlagConfirmationUp_M5 || figure49DoublePennantAfterConfirmationUp_M5 || figure51WedgeConfirmationUp_M5;
     isM1FigureUp  =  figure1_1FlagUpContinueAfterDecliningUp_M1      || figure7_1TurnUpDivergenceUp_M1  || figure7_2TurnDivergenceConfirmationUp_M1    || figure19HeadAndShouldersConfirmationUp_M1           || figure27_1DoubleBottomFlagUp_M1  || figure27_2TriangleAsConfirmationUp_M1 || figure27_3DoubleBottomChannelUp_M1 || figure27_4WedgePennantConfirmationUp_M1 || figure27_5DoubleBottomConDivDivConfirmationUp_M1 || figure27_6DoubleBottomDivConDivConfirmationUp_M1 || figure27_7DoubleBottom12PosUp_M1 ||  figure29DoubleBottomConfirmationUp_M1  || figure33FlagWedgeForelockConfirmationUp_M1 || figure35TripleBottomConfirmationUp_M1       || figure39RollbackChannelPennantConfirmationUp_M1  || figure45PennantAfterWedgeConfirmationUp_M1 || figure47PennantAfterFlagConfirmationUp_M1 || figure49DoublePennantAfterConfirmationUp_M1 || figure51WedgeConfirmationUp_M1;


     isD1FigureDown  =  figure2_1FlagDownContinueAfterDecreaseDown_D1       || figure8_1TurnDownDivergenceDown_D1  || figure8_2TurnDivergenceConfirmationDown_D1     || figure20HeadAndShouldersConfirmationDown_D1                 || figure28_1DoubleTopFlagDown_D1  || figure28_2TriangleAsConfirmationDown_D1 || figure28_3DoubleTopChannelDown_D1 || figure28_4WedgePennantConfirmationDown_D1 || figure28_5DoubleTopConDivDivConfirmationDown_D1 || figure28_6DoubleTopDivConDivConfirmationDown_D1 || figure28_7DoubleTop12PosDown_D1 || figure30DoubleTopConfirmationDown_D1   || figure34FlagWedgeForelockConfirmationDown_D1 || figure36TripleTopConfirmationDown_D1           || figure40RollbackChannelPennantConfirmationDown_D1 || figure42MoreDivergentFlagConfirmationDown_D1    || figure46PennantAfterWedgeConfirmationDown_D1 || figure48PennantAfterFlagConfirmationDown_D1 || figure50DoublePennantAfterConfirmationDown_D1 || figure52WedgeConfirmationDown_D1;
     isH4FigureDown  =  figure2_1FlagDownContinueAfterDecreaseDown_H4       || figure8_1TurnDownDivergenceDown_H4  || figure8_2TurnDivergenceConfirmationDown_H4     || figure20HeadAndShouldersConfirmationDown_H4                 || figure28_1DoubleTopFlagDown_H4  || figure28_2TriangleAsConfirmationDown_H4 || figure28_3DoubleTopChannelDown_H4 || figure28_4WedgePennantConfirmationDown_H4 || figure28_5DoubleTopConDivDivConfirmationDown_H4 || figure28_6DoubleTopDivConDivConfirmationDown_H4 || figure28_7DoubleTop12PosDown_H4 || figure30DoubleTopConfirmationDown_H4  || figure34FlagWedgeForelockConfirmationDown_H4 || figure36TripleTopConfirmationDown_H4     || figure40RollbackChannelPennantConfirmationDown_H4 || figure42MoreDivergentFlagConfirmationDown_H4    || figure46PennantAfterWedgeConfirmationDown_H4 || figure48PennantAfterFlagConfirmationDown_H4 || figure50DoublePennantAfterConfirmationDown_H4 || figure52WedgeConfirmationDown_H4;
     isH1FigureDown  =  figure2_1FlagDownContinueAfterDecreaseDown_H1       || figure8_1TurnDownDivergenceDown_H1  || figure8_2TurnDivergenceConfirmationDown_H1     || figure20HeadAndShouldersConfirmationDown_H1                 || figure28_1DoubleTopFlagDown_H1  || figure28_2TriangleAsConfirmationDown_H1 || figure28_3DoubleTopChannelDown_H1 || figure28_4WedgePennantConfirmationDown_H1 || figure28_5DoubleTopConDivDivConfirmationDown_H1 || figure28_6DoubleTopDivConDivConfirmationDown_H1 || figure28_7DoubleTop12PosDown_H1 || figure30DoubleTopConfirmationDown_H1  || figure34FlagWedgeForelockConfirmationDown_H1 || figure36TripleTopConfirmationDown_H1     || figure40RollbackChannelPennantConfirmationDown_H1 || figure42MoreDivergentFlagConfirmationDown_H1    || figure46PennantAfterWedgeConfirmationDown_H1 || figure48PennantAfterFlagConfirmationDown_H1 || figure50DoublePennantAfterConfirmationDown_H1 || figure52WedgeConfirmationDown_H1;
     isM15FigureDown =   figure2_1FlagDownContinueAfterDecreaseDown_M15     || figure8_1TurnDownDivergenceDown_M15 || figure8_2TurnDivergenceConfirmationDown_M15    || figure20HeadAndShouldersConfirmationDown_M15                || figure28_1DoubleTopFlagDown_M15  || figure28_2TriangleAsConfirmationDown_M15 || figure28_3DoubleTopChannelDown_M15 || figure28_4WedgePennantConfirmationDown_M15 || figure28_5DoubleTopConDivDivConfirmationDown_M15 || figure28_6DoubleTopDivConDivConfirmationDown_M15 || figure28_7DoubleTop12PosDown_M15 || figure30DoubleTopConfirmationDown_M15  || figure34FlagWedgeForelockConfirmationDown_M15 || figure36TripleTopConfirmationDown_M15 || figure40RollbackChannelPennantConfirmationDown_M15 || figure42MoreDivergentFlagConfirmationDown_M15  || figure46PennantAfterWedgeConfirmationDown_M15 || figure48PennantAfterFlagConfirmationDown_M15 || figure50DoublePennantAfterConfirmationDown_M15 || figure52WedgeConfirmationDown_M15;
     isM5FigureDown  =  figure2_1FlagDownContinueAfterDecreaseDown_M5       || figure8_1TurnDownDivergenceDown_M5  || figure8_2TurnDivergenceConfirmationDown_M5     || figure20HeadAndShouldersConfirmationDown_M5                 || figure28_1DoubleTopFlagDown_M5  || figure28_2TriangleAsConfirmationDown_M5 || figure28_3DoubleTopChannelDown_M5 || figure28_4WedgePennantConfirmationDown_M5 || figure28_5DoubleTopConDivDivConfirmationDown_M5 || figure28_6DoubleTopDivConDivConfirmationDown_M5 || figure28_7DoubleTop12PosDown_M5 || figure30DoubleTopConfirmationDown_M5  || figure34FlagWedgeForelockConfirmationDown_M5 || figure36TripleTopConfirmationDown_M5     || figure40RollbackChannelPennantConfirmationDown_M5 || figure42MoreDivergentFlagConfirmationDown_M5    || figure46PennantAfterWedgeConfirmationDown_M5 || figure48PennantAfterFlagConfirmationDown_M5 || figure50DoublePennantAfterConfirmationDown_M5 || figure52WedgeConfirmationDown_M5;
     isM1FigureDown  =  figure2_1FlagDownContinueAfterDecreaseDown_M1       || figure8_1TurnDownDivergenceDown_M1  || figure8_2TurnDivergenceConfirmationDown_M1     || figure20HeadAndShouldersConfirmationDown_M1                 || figure28_1DoubleTopFlagDown_M1  || figure28_2TriangleAsConfirmationDown_M1 || figure28_3DoubleTopChannelDown_M1 || figure28_4WedgePennantConfirmationDown_M1 || figure28_5DoubleTopConDivDivConfirmationDown_M1 || figure28_6DoubleTopDivConDivConfirmationDown_M1 || figure28_7DoubleTop12PosDown_M1 || figure30DoubleTopConfirmationDown_M1  || figure34FlagWedgeForelockConfirmationDown_M1 || figure36TripleTopConfirmationDown_M1     || figure40RollbackChannelPennantConfirmationDown_M1 || figure42MoreDivergentFlagConfirmationDown_M1    || figure46PennantAfterWedgeConfirmationDown_M1 || figure48PennantAfterFlagConfirmationDown_M1 || figure50DoublePennantAfterConfirmationDown_M1 || figure52WedgeConfirmationDown_M1;
*/



/*  //All
     isD1FigureUp  =  figure1FlagUpContinueUp_D1 || figure1_1FlagUpContinueAfterDecliningUp_D1 || figure3TripleUp_D1    || figure5PennantUp_D1  || figure5_1PennantUpConfirmationUp_D1  || figure7FlagUpDivergenceUp_D1  || figure7_1TurnUpDivergenceUp_D1  || figure7_2TurnDivergenceConfirmationUp_D1 || figure9FlagUpShiftUp_D1   || figure11DoubleBottomUp_D1  || figure13DivergentChannelUp_D1  || figure13_1DivergenceFlagConfirmationUp_D1  || figure15BalancedTriangleUp_D1 || figure17FlagConfirmationUp_D1 || figure19HeadAndShouldersConfirmationUp_D1 || figure21WedgeUp_D1 || figure23DiamondUp_D1 || figure25TriangleConfirmationUp_D1                                                      || figure27ModerateDivergentFlagConfirmationUp_D1   || figure27_1DoubleBottomFlagUp_D1  || figure27_2TriangleAsConfirmationUp_D1 || figure27_3DoubleBottomChannelUp_D1 || figure27_4WedgePennantConfirmationUp_D1 || figure27_5DoubleBottomConDivDivConfirmationUp_D1 || figure27_6DoubleBottomDivConDivConfirmationUp_D1 || figure27_7DoubleBottom12PosUp_D1 ||  figure29DoubleBottomConfirmationUp_D1 || figure31DivergentFlagConfirmationUp_D1 || figure33FlagWedgeForelockConfirmationUp_D1 || figure35TripleBottomConfirmationUp_D1 || figure37PennantWedgeUp_D1 || figure39RollbackChannelPennantConfirmationUp_D1 || figure41MoreDivergentFlagConfirmationUp_D1 || figure43ChannelFlagUp_D1 || figure45PennantAfterWedgeConfirmationUp_D1 || figure47PennantAfterFlagConfirmationUp_D1 || figure49DoublePennantAfterConfirmationUp_D1                    || figure51WedgeConfirmationUp_D1  || figure59TripleBottomWedgeUp_D1  ;
     isH4FigureUp  =  figure1FlagUpContinueUp_H4 || figure1_1FlagUpContinueAfterDecliningUp_H4 || figure3TripleUp_H4    || figure5PennantUp_H4  || figure5_1PennantUpConfirmationUp_H4  || figure7FlagUpDivergenceUp_H4  || figure7_1TurnUpDivergenceUp_H4  || figure7_2TurnDivergenceConfirmationUp_H4 || figure9FlagUpShiftUp_H4   || figure11DoubleBottomUp_H4  || figure13DivergentChannelUp_H4  || figure13_1DivergenceFlagConfirmationUp_H4  || figure15BalancedTriangleUp_H4 || figure17FlagConfirmationUp_H4 || figure19HeadAndShouldersConfirmationUp_H4 || figure21WedgeUp_H4 || figure23DiamondUp_H4 || figure25TriangleConfirmationUp_H4                                                      || figure27ModerateDivergentFlagConfirmationUp_H4   || figure27_1DoubleBottomFlagUp_H4  || figure27_2TriangleAsConfirmationUp_H4 || figure27_3DoubleBottomChannelUp_H4 || figure27_4WedgePennantConfirmationUp_H4 || figure27_5DoubleBottomConDivDivConfirmationUp_H4 || figure27_6DoubleBottomDivConDivConfirmationUp_H4 || figure27_7DoubleBottom12PosUp_H4 ||  figure29DoubleBottomConfirmationUp_H4 || figure31DivergentFlagConfirmationUp_H4 || figure33FlagWedgeForelockConfirmationUp_H4 || figure35TripleBottomConfirmationUp_H4 || figure37PennantWedgeUp_H4 || figure39RollbackChannelPennantConfirmationUp_H4 || figure41MoreDivergentFlagConfirmationUp_H4 || figure43ChannelFlagUp_H4 || figure45PennantAfterWedgeConfirmationUp_H4 || figure47PennantAfterFlagConfirmationUp_H4 || figure49DoublePennantAfterConfirmationUp_H4                    || figure51WedgeConfirmationUp_H4  || figure59TripleBottomWedgeUp_H4  ;
     isH1FigureUp  =  figure1FlagUpContinueUp_H1 || figure1_1FlagUpContinueAfterDecliningUp_H1 || figure3TripleUp_H1    || figure5PennantUp_H1  || figure5_1PennantUpConfirmationUp_H1  || figure7FlagUpDivergenceUp_H1  || figure7_1TurnUpDivergenceUp_H1  || figure7_2TurnDivergenceConfirmationUp_H1 || figure9FlagUpShiftUp_H1   || figure11DoubleBottomUp_H1  || figure13DivergentChannelUp_H1  || figure13_1DivergenceFlagConfirmationUp_H1  || figure15BalancedTriangleUp_H1 || figure17FlagConfirmationUp_H1 || figure19HeadAndShouldersConfirmationUp_H1 || figure21WedgeUp_H1 || figure23DiamondUp_H1 || figure25TriangleConfirmationUp_H1                                                      || figure27ModerateDivergentFlagConfirmationUp_H1   || figure27_1DoubleBottomFlagUp_H1  || figure27_2TriangleAsConfirmationUp_H1 || figure27_3DoubleBottomChannelUp_H1 || figure27_4WedgePennantConfirmationUp_H1 || figure27_5DoubleBottomConDivDivConfirmationUp_H1 || figure27_6DoubleBottomDivConDivConfirmationUp_H1 || figure27_7DoubleBottom12PosUp_H1 ||  figure29DoubleBottomConfirmationUp_H1 || figure31DivergentFlagConfirmationUp_H1 || figure33FlagWedgeForelockConfirmationUp_H1 || figure35TripleBottomConfirmationUp_H1 || figure37PennantWedgeUp_H1 || figure39RollbackChannelPennantConfirmationUp_H1 || figure41MoreDivergentFlagConfirmationUp_H1 || figure43ChannelFlagUp_H1 || figure45PennantAfterWedgeConfirmationUp_H1 || figure47PennantAfterFlagConfirmationUp_H1 || figure49DoublePennantAfterConfirmationUp_H1                    || figure51WedgeConfirmationUp_H1  || figure59TripleBottomWedgeUp_H1  ;
     isM15FigureUp =  figure1FlagUpContinueUp_M15 || figure1_1FlagUpContinueAfterDecliningUp_M15 || figure3TripleUp_M15 || figure5PennantUp_M15 || figure5_1PennantUpConfirmationUp_M15 || figure7FlagUpDivergenceUp_M15 || figure7_1TurnUpDivergenceUp_M15 || figure7_2TurnDivergenceConfirmationUp_M15 || figure9FlagUpShiftUp_M15 || figure11DoubleBottomUp_M15 || figure13DivergentChannelUp_M15 || figure13_1DivergenceFlagConfirmationUp_M15 || figure15BalancedTriangleUp_M15 || figure17FlagConfirmationUp_M15 || figure19HeadAndShouldersConfirmationUp_M15 || figure21WedgeUp_M15 || figure23DiamondUp_M15 || figure25TriangleConfirmationUp_M15                                                || figure27ModerateDivergentFlagConfirmationUp_M15  || figure27_1DoubleBottomFlagUp_M15 || figure27_2TriangleAsConfirmationUp_M15 || figure27_3DoubleBottomChannelUp_M15 || figure27_4WedgePennantConfirmationUp_M15 || figure27_5DoubleBottomConDivDivConfirmationUp_M15 || figure27_6DoubleBottomDivConDivConfirmationUp_M15 || figure27_7DoubleBottom12PosUp_M15 ||  figure29DoubleBottomConfirmationUp_M15 || figure31DivergentFlagConfirmationUp_M15 || figure33FlagWedgeForelockConfirmationUp_M15 || figure35TripleBottomConfirmationUp_M15 || figure37PennantWedgeUp_M15 || figure39RollbackChannelPennantConfirmationUp_M15 || figure41MoreDivergentFlagConfirmationUp_M15 || figure43ChannelFlagUp_M15 || figure45PennantAfterWedgeConfirmationUp_M15 || figure47PennantAfterFlagConfirmationUp_M15 || figure49DoublePennantAfterConfirmationUp_M15   || figure51WedgeConfirmationUp_M15 || figure59TripleBottomWedgeUp_M15 ;
     isM5FigureUp  =  figure1FlagUpContinueUp_M5 || figure1_1FlagUpContinueAfterDecliningUp_M5 || figure3TripleUp_M5    || figure5PennantUp_M5  || figure5_1PennantUpConfirmationUp_M5  || figure7FlagUpDivergenceUp_M5  || figure7_1TurnUpDivergenceUp_M5  || figure7_2TurnDivergenceConfirmationUp_M5 || figure9FlagUpShiftUp_M5   || figure11DoubleBottomUp_M5  || figure13DivergentChannelUp_M5  || figure13_1DivergenceFlagConfirmationUp_M5  || figure15BalancedTriangleUp_M5 || figure17FlagConfirmationUp_M5 || figure19HeadAndShouldersConfirmationUp_M5 || figure21WedgeUp_M5 || figure23DiamondUp_M5 || figure25TriangleConfirmationUp_M5                                                      || figure27ModerateDivergentFlagConfirmationUp_M5   || figure27_1DoubleBottomFlagUp_M5  || figure27_2TriangleAsConfirmationUp_M5 || figure27_3DoubleBottomChannelUp_M5 || figure27_4WedgePennantConfirmationUp_M5 || figure27_5DoubleBottomConDivDivConfirmationUp_M5 || figure27_6DoubleBottomDivConDivConfirmationUp_M5 || figure27_7DoubleBottom12PosUp_M5 ||  figure29DoubleBottomConfirmationUp_M5 || figure31DivergentFlagConfirmationUp_M5 || figure33FlagWedgeForelockConfirmationUp_M5 || figure35TripleBottomConfirmationUp_M5 || figure37PennantWedgeUp_M5 || figure39RollbackChannelPennantConfirmationUp_M5 || figure41MoreDivergentFlagConfirmationUp_M5 || figure43ChannelFlagUp_M5 || figure45PennantAfterWedgeConfirmationUp_M5 || figure47PennantAfterFlagConfirmationUp_M5 || figure49DoublePennantAfterConfirmationUp_M5                    || figure51WedgeConfirmationUp_M5  || figure59TripleBottomWedgeUp_M5  ;
     isM1FigureUp  =  figure1FlagUpContinueUp_M1 || figure1_1FlagUpContinueAfterDecliningUp_M1 || figure3TripleUp_M1    || figure5PennantUp_M1  || figure5_1PennantUpConfirmationUp_M1  || figure7FlagUpDivergenceUp_M1  || figure7_1TurnUpDivergenceUp_M1  || figure7_2TurnDivergenceConfirmationUp_M1 || figure9FlagUpShiftUp_M1   || figure11DoubleBottomUp_M1  || figure13DivergentChannelUp_M1  || figure13_1DivergenceFlagConfirmationUp_M1  || figure15BalancedTriangleUp_M1 || figure17FlagConfirmationUp_M1 || figure19HeadAndShouldersConfirmationUp_M1 || figure21WedgeUp_M1 || figure23DiamondUp_M1 || figure25TriangleConfirmationUp_M1                                                      || figure27ModerateDivergentFlagConfirmationUp_M1   || figure27_1DoubleBottomFlagUp_M1  || figure27_2TriangleAsConfirmationUp_M1 || figure27_3DoubleBottomChannelUp_M1 || figure27_4WedgePennantConfirmationUp_M1 || figure27_5DoubleBottomConDivDivConfirmationUp_M1 || figure27_6DoubleBottomDivConDivConfirmationUp_M1 || figure27_7DoubleBottom12PosUp_M1 ||  figure29DoubleBottomConfirmationUp_M1 || figure31DivergentFlagConfirmationUp_M1 || figure33FlagWedgeForelockConfirmationUp_M1 || figure35TripleBottomConfirmationUp_M1 || figure37PennantWedgeUp_M1 || figure39RollbackChannelPennantConfirmationUp_M1 || figure41MoreDivergentFlagConfirmationUp_M1 || figure43ChannelFlagUp_M1 || figure45PennantAfterWedgeConfirmationUp_M1 || figure47PennantAfterFlagConfirmationUp_M1 || figure49DoublePennantAfterConfirmationUp_M1                    || figure51WedgeConfirmationUp_M1  || figure59TripleBottomWedgeUp_M1  ;


     isD1FigureDown  =  figure2FlagDownContinueDown_D1 || figure2_1FlagDownContinueAfterDecreaseDown_D1 ||figure4TripleDown_D1     || figure6PennantDown_D1  || figure6_1PennantDownConfirmationDown_D1  || figure8FlagDownDivergenceDown_D1  || figure8_1TurnDownDivergenceDown_D1  || figure8_2TurnDivergenceConfirmationDown_D1  || figure10FlagDownShiftDown_D1  || figure12DoubleTopDown_D1  || figure14DivergentChannelDown_D1  || figure14_1DivergenceFlagConfirmationDown_D1 || figure16BalancedTriangleDown_D1 || figure18FlagConfirmationDown_D1 || figure20HeadAndShouldersConfirmationDown_D1 || figure22WedgeDown_D1 || figure24DiamondDown_D1       || figure26TriangleConfirmationDown_D1   || figure28ModerateDivergentFlagConfirmationDown_D1  || figure28_1DoubleTopFlagDown_D1     || figure28_2TriangleAsConfirmationDown_D1 || figure28_3DoubleTopChannelDown_D1 || figure28_4WedgePennantConfirmationDown_D1 || figure28_5DoubleTopConDivDivConfirmationDown_D1 || figure28_6DoubleTopDivConDivConfirmationDown_D1 || figure28_7DoubleTop12PosDown_D1 || figure30DoubleTopConfirmationDown_D1 || figure32DivergentFlagConfirmationDown_D1 || figure34FlagWedgeForelockConfirmationDown_D1 || figure36TripleTopConfirmationDown_D1 || figure38PennantWedgeDown_D1 || figure40RollbackChannelPennantConfirmationDown_D1 || figure42MoreDivergentFlagConfirmationDown_D1 || figure44ChannelFlagDown_D1 || figure46PennantAfterWedgeConfirmationDown_D1 || figure48PennantAfterFlagConfirmationDown_D1 || figure50DoublePennantAfterConfirmationDown_D1                      || figure52WedgeConfirmationDown_D1  || figure60TripleTopWedgeDown_D1 ;
     isH4FigureDown  =  figure2FlagDownContinueDown_H4 || figure2_1FlagDownContinueAfterDecreaseDown_H4 ||figure4TripleDown_H4     || figure6PennantDown_H4  || figure6_1PennantDownConfirmationDown_H4  || figure8FlagDownDivergenceDown_H4  || figure8_1TurnDownDivergenceDown_H4  || figure8_2TurnDivergenceConfirmationDown_H4  || figure10FlagDownShiftDown_H4  || figure12DoubleTopDown_H4  || figure14DivergentChannelDown_H4  || figure14_1DivergenceFlagConfirmationDown_H4 || figure16BalancedTriangleDown_H4 || figure18FlagConfirmationDown_H4 || figure20HeadAndShouldersConfirmationDown_H4 || figure22WedgeDown_H4 || figure24DiamondDown_H4 || figure26TriangleConfirmationDown_H4         || figure28ModerateDivergentFlagConfirmationDown_H4  || figure28_1DoubleTopFlagDown_H4     || figure28_2TriangleAsConfirmationDown_H4 || figure28_3DoubleTopChannelDown_H4 || figure28_4WedgePennantConfirmationDown_H4 || figure28_5DoubleTopConDivDivConfirmationDown_H4 || figure28_6DoubleTopDivConDivConfirmationDown_H4 || figure28_7DoubleTop12PosDown_H4 || figure30DoubleTopConfirmationDown_H4 || figure32DivergentFlagConfirmationDown_H4 || figure34FlagWedgeForelockConfirmationDown_H4 || figure36TripleTopConfirmationDown_H4 || figure38PennantWedgeDown_H4 || figure40RollbackChannelPennantConfirmationDown_H4 || figure42MoreDivergentFlagConfirmationDown_H4 || figure44ChannelFlagDown_H4 || figure46PennantAfterWedgeConfirmationDown_H4 || figure48PennantAfterFlagConfirmationDown_H4 || figure50DoublePennantAfterConfirmationDown_H4                      || figure52WedgeConfirmationDown_H4  || figure60TripleTopWedgeDown_H4 ;
     isH1FigureDown  =  figure2FlagDownContinueDown_H1 || figure2_1FlagDownContinueAfterDecreaseDown_H1 ||figure4TripleDown_H1     || figure6PennantDown_H1  || figure6_1PennantDownConfirmationDown_H1  || figure8FlagDownDivergenceDown_H1  || figure8_1TurnDownDivergenceDown_H1  || figure8_2TurnDivergenceConfirmationDown_H1  || figure10FlagDownShiftDown_H1  || figure12DoubleTopDown_H1  || figure14DivergentChannelDown_H1  || figure14_1DivergenceFlagConfirmationDown_H1 || figure16BalancedTriangleDown_H1 || figure18FlagConfirmationDown_H1 || figure20HeadAndShouldersConfirmationDown_H1 || figure22WedgeDown_H1 || figure24DiamondDown_H1 || figure26TriangleConfirmationDown_H1         || figure28ModerateDivergentFlagConfirmationDown_H1  || figure28_1DoubleTopFlagDown_H1     || figure28_2TriangleAsConfirmationDown_H1 || figure28_3DoubleTopChannelDown_H1 || figure28_4WedgePennantConfirmationDown_H1 || figure28_5DoubleTopConDivDivConfirmationDown_H1 || figure28_6DoubleTopDivConDivConfirmationDown_H1 || figure28_7DoubleTop12PosDown_H1 || figure30DoubleTopConfirmationDown_H1 || figure32DivergentFlagConfirmationDown_H1 || figure34FlagWedgeForelockConfirmationDown_H1 || figure36TripleTopConfirmationDown_H1 || figure38PennantWedgeDown_H1 || figure40RollbackChannelPennantConfirmationDown_H1 || figure42MoreDivergentFlagConfirmationDown_H1 || figure44ChannelFlagDown_H1 || figure46PennantAfterWedgeConfirmationDown_H1 || figure48PennantAfterFlagConfirmationDown_H1 || figure50DoublePennantAfterConfirmationDown_H1                      || figure52WedgeConfirmationDown_H1  || figure60TripleTopWedgeDown_H1 ;
     isM15FigureDown =  figure2FlagDownContinueDown_M15 || figure2_1FlagDownContinueAfterDecreaseDown_M15 ||figure4TripleDown_M15  || figure6PennantDown_M15 || figure6_1PennantDownConfirmationDown_M15 || figure8FlagDownDivergenceDown_M15 || figure8_1TurnDownDivergenceDown_M15 || figure8_2TurnDivergenceConfirmationDown_M15 || figure10FlagDownShiftDown_M15 || figure12DoubleTopDown_M15 || figure14DivergentChannelDown_M15 || figure14_1DivergenceFlagConfirmationDown_M15 || figure16BalancedTriangleDown_M15 || figure18FlagConfirmationDown_M15 || figure20HeadAndShouldersConfirmationDown_M15 || figure22WedgeDown_M15 || figure24DiamondDown_M15 || figure26TriangleConfirmationDown_M15  || figure28ModerateDivergentFlagConfirmationDown_M15 || figure28_1DoubleTopFlagDown_M15    || figure28_2TriangleAsConfirmationDown_M15 || figure28_3DoubleTopChannelDown_M15 || figure28_4WedgePennantConfirmationDown_M15 || figure28_5DoubleTopConDivDivConfirmationDown_M15 || figure28_6DoubleTopDivConDivConfirmationDown_M15 || figure28_7DoubleTop12PosDown_M15 || figure30DoubleTopConfirmationDown_M15 || figure32DivergentFlagConfirmationDown_M15 || figure34FlagWedgeForelockConfirmationDown_M15 || figure36TripleTopConfirmationDown_M15 || figure38PennantWedgeDown_M15 || figure40RollbackChannelPennantConfirmationDown_M15 || figure42MoreDivergentFlagConfirmationDown_M15 || figure44ChannelFlagDown_M15 || figure46PennantAfterWedgeConfirmationDown_M15 || figure48PennantAfterFlagConfirmationDown_M15 || figure50DoublePennantAfterConfirmationDown_M15    || figure52WedgeConfirmationDown_M15 || figure60TripleTopWedgeDown_M15;
     isM5FigureDown  =  figure2FlagDownContinueDown_M5 || figure2_1FlagDownContinueAfterDecreaseDown_M5 ||figure4TripleDown_M5     || figure6PennantDown_M5  || figure6_1PennantDownConfirmationDown_M5  || figure8FlagDownDivergenceDown_M5  || figure8_1TurnDownDivergenceDown_M5  || figure8_2TurnDivergenceConfirmationDown_M5  || figure10FlagDownShiftDown_M5  || figure12DoubleTopDown_M5  || figure14DivergentChannelDown_M5  || figure14_1DivergenceFlagConfirmationDown_M5 || figure16BalancedTriangleDown_M5 || figure18FlagConfirmationDown_M5 || figure20HeadAndShouldersConfirmationDown_M5 || figure22WedgeDown_M5 || figure24DiamondDown_M5 || figure26TriangleConfirmationDown_M5         || figure28ModerateDivergentFlagConfirmationDown_M5  || figure28_1DoubleTopFlagDown_M5     || figure28_2TriangleAsConfirmationDown_M5 || figure28_3DoubleTopChannelDown_M5 || figure28_4WedgePennantConfirmationDown_M5 || figure28_5DoubleTopConDivDivConfirmationDown_M5 || figure28_6DoubleTopDivConDivConfirmationDown_M5 || figure28_7DoubleTop12PosDown_M5 || figure30DoubleTopConfirmationDown_M5 || figure32DivergentFlagConfirmationDown_M5 || figure34FlagWedgeForelockConfirmationDown_M5 || figure36TripleTopConfirmationDown_M5 || figure38PennantWedgeDown_M5 || figure40RollbackChannelPennantConfirmationDown_M5 || figure42MoreDivergentFlagConfirmationDown_M5 || figure44ChannelFlagDown_M5 || figure46PennantAfterWedgeConfirmationDown_M5 || figure48PennantAfterFlagConfirmationDown_M5 || figure50DoublePennantAfterConfirmationDown_M5                      || figure52WedgeConfirmationDown_M5  || figure60TripleTopWedgeDown_M5 ;
     isM1FigureDown  =  figure2FlagDownContinueDown_M1 || figure2_1FlagDownContinueAfterDecreaseDown_M1 ||figure4TripleDown_M1     || figure6PennantDown_M1  || figure6_1PennantDownConfirmationDown_M1  || figure8FlagDownDivergenceDown_M1  || figure8_1TurnDownDivergenceDown_M1  || figure8_2TurnDivergenceConfirmationDown_M1  || figure10FlagDownShiftDown_M1  || figure12DoubleTopDown_M1  || figure14DivergentChannelDown_M1  || figure14_1DivergenceFlagConfirmationDown_M1 || figure16BalancedTriangleDown_M1 || figure18FlagConfirmationDown_M1 || figure20HeadAndShouldersConfirmationDown_M1 || figure22WedgeDown_M1 || figure24DiamondDown_M1 || figure26TriangleConfirmationDown_M1         || figure28ModerateDivergentFlagConfirmationDown_M1  || figure28_1DoubleTopFlagDown_M1     || figure28_2TriangleAsConfirmationDown_M1 || figure28_3DoubleTopChannelDown_M1 || figure28_4WedgePennantConfirmationDown_M1 || figure28_5DoubleTopConDivDivConfirmationDown_M1 || figure28_6DoubleTopDivConDivConfirmationDown_M1 || figure28_7DoubleTop12PosDown_M1 || figure30DoubleTopConfirmationDown_M1 || figure32DivergentFlagConfirmationDown_M1 || figure34FlagWedgeForelockConfirmationDown_M1 || figure36TripleTopConfirmationDown_M1 || figure38PennantWedgeDown_M1 || figure40RollbackChannelPennantConfirmationDown_M1 || figure42MoreDivergentFlagConfirmationDown_M1 || figure44ChannelFlagDown_M1 || figure46PennantAfterWedgeConfirmationDown_M1 || figure48PennantAfterFlagConfirmationDown_M1 || figure50DoublePennantAfterConfirmationDown_M1                      || figure52WedgeConfirmationDown_M1  || figure60TripleTopWedgeDown_M1 ;
*/


 //    isFigureUp     = isD1FigureUp   || isH4FigureUp   || isH1FigureUp   || isM15FigureUp   || isM5FigureUp ;
 //    isFigureDown   = isD1FigureDown || isH4FigureDown || isH1FigureDown || isM15FigureDown || isM5FigureDown ;
     isFigureUp     =  isH4FigureUp   || isH1FigureUp   || isM15FigureUp   ;
     isFigureDown   =  isH4FigureDown || isH1FigureDown || isM15FigureDown ;

     isCandleDown = isH4CandleDown || isH1CandleDown || isM15CandleDown;
     isCandleUp =   isH4CandleUp || isH1CandleUp || isM15CandleUp;

bool isTwoMinAllTFtoH4Higher = false;
bool isTwoMaxAllTFtoH4Lower = false;
isTwoMinAllTFtoH4Higher = twoMinAllTFtoH4Higher_Up_M1 && twoMinAllTFtoH4Higher_Up_M5 && twoMinAllTFtoH4Higher_Up_M15 && twoMinAllTFtoH4Higher_Up_H1 && twoMinAllTFtoH4Higher_Up_H4;
isTwoMaxAllTFtoH4Lower = twoMaxAllTFtoH4Lower_Down_M1 && twoMaxAllTFtoH4Lower_Down_M5 && twoMaxAllTFtoH4Lower_Down_M15 && twoMaxAllTFtoH4Lower_Down_H1 && twoMaxAllTFtoH4Lower_Down_H4;
if(isTwoMinAllTFtoH4Higher && isTwoMaxAllTFtoH4Lower) {
    isTwoMinAllTFtoH4Higher = false;
    isTwoMaxAllTFtoH4Lower = false;
}

  print();
//  is determined by the conditions M5,M15,H1

  string currentSignalAnalyzeConcatenated = StringConcatenate(messageGlobalPERIOD_M1, messageGlobalPERIOD_M5, messageGlobalPERIOD_M15, messageGlobalPERIOD_H1, messageGlobalPERIOD_H4);
  int compareResult = StringCompare(signalAnalyzeConcatenated,currentSignalAnalyzeConcatenated,false);
  if (compareResult != 0){
    isNewSignal = true;
    signalAnalyzeConcatenated = currentSignalAnalyzeConcatenated;
  }

// 19.02.2019 TS_7.0 14.1)
 /*  if (isH1FigureDown && isTrendBull_M15){
        isM15FigureDown = false;
        isM15FigureUp = true;
    }
    if (isH1FigureUp && isTrendBear_M15){
        isM15FigureUp = false;
        isM15FigureDown = true;
    }
*/
// 19.02.2019 TS_7.0 14.5)

// Если сигнал на H1 отличается
/*
      string currentFigureH1Signal = messageGlobalPERIOD_H1;
      int compareResultForInvert = StringCompare(figureH1Signal,currentFigureH1Signal,false);
      if (compareResultForInvert != 0){
        isFigureH1InnerM15HalfwaveIsDone = false;
        figureH1Signal = currentFigureH1Signal;
      }

//  если условие isH1FigureUp && macd0_M15>0   - сработало значит прошли активную фазу, в таком случае ставим флаг  isFigureH1InnerM15HalfwaveIsDone в true
if (isH1FigureUp && macd0_M15>0){
    isNewSignal = false;
    isFigureH1InnerM15HalfwaveIsDone = true;
}

// если условие isH1FigureDown && macd0_M15<0 - сработало значит прошли активную фазу, в таком случае ставим флаг  в true
if (isH1FigureDown && macd0_M15<0){
    isNewSignal = false;
    isFigureH1InnerM15HalfwaveIsDone = true;
}
// Что бы бесконечно не инвертировать, что надо сделать ? Введем флаг isInverted?
if(isH1FigureUp && isFigureH1InnerM15HalfwaveIsDone && !isInvertedM15){
    isH1FigureUp = false;
    isH1FigureDown = true;
}

if(isH1FigureDown && isFigureH1InnerM15HalfwaveIsDone && !isInvertedM15){
    isH1FigureUp = true;
    isH1FigureDown = false;
}

// Фильтруем инвертированную волну на М15 14.9)

//  если условие isH1FigureUp && macd0_M15>0   - сработало значит прошли активную фазу, в таком случае ставим флаг  isFigureH1InnerM15HalfwaveIsDone в true
if (isH1FigureUp && macd0_M15>0){
    isNewSignal = false;
}

// если условие isH1FigureDown && macd0_M15<0 - сработало значит прошли активную фазу, в таком случае ставим флаг  в true
if (isH1FigureDown && macd0_M15<0){
    isNewSignal = false;
}
*/

// 1) таким образом я просто инвертирую все сделки, а не только во второй половине
/*if (isH1FigureUp && macd0_H1<macd1_H1){
    isH1FigureUp = false;
    isH1FigureDown = true;
}

if (isH1FigureDown && macd0_H1>macd1_H1){
    isH1FigureDown = false;
    isH1FigureUp = true;
}*/
/*
    Введем флаг в данном случае на H1, isFigureH1InnerM15HalfwaveIsDone, который будем использовать что бы отметить что сигнал Н1, отработал
свою ПВ М15,(isNewSignal, которые формируется StringCompare(signalAnalyzeConcatenated,currentSignalAnalyzeConcatenated,false)).
    Что бы использовать его как маркер состояния окончания первой ПВ
    И проставлять isFigureH1InnerM15HalfwaveIsDone будем в  следующем блоке
    if (isH1FigureUp && macd0_M15>0){
        isNewSignal = false;
    }
    и будем держать его в таком состоянии пока не прийдет новый сигнал figureH1Signal.
    Инициализация:



    флаг находится в таком состоянии пока не придет новый сигнал на H1, а проверку на новый сигнал выносим вперед.
 */



// Print ("signalAnalyzeConcatenated = ", signalAnalyzeConcatenated);
// Print ("currentSignalAnalyzeConcatenated = ", currentSignalAnalyzeConcatenated);
// Print ("compareResult = ", compareResult);
// Print ("isNewSignal = ", isNewSignal);
      if
      (
//      isNewSignal && (OpenOnHalfWaveOpenPermitUp_M1 || OpenOnHalfWaveOpenPermitUp_M5 || OpenOnHalfWaveOpenPermitUp_M15)
        isNewSignal && isTwoMinAllTFtoH4Higher && isMACDM1CrossedUp()

      // для блокировки сигнала M15 && !isFigureH1InnerM15HalfwaveIsDone по умолчанию происходит инввертирование
 //  ((isM5FigureUp && isM15FigureUp)||(isM5FigureUp && isH1FigureUp)||(isM15FigureUp && isH1FigureUp))

/*        isMACDForelockUpFilter1 (PERIOD_M15) &&
        isOSMAForelockUpFilter1(PERIOD_M15) &&
        isDivergenceOrConvergence_D1() &&
        (OpenOnHalfWaveOpenPermitUp_M1 || OpenOnHalfWaveOpenPermitUp_M5 || OpenOnHalfWaveOpenPermitUp_M15)*/
      )

      {
/*
Print("figure1_1FlagUpContinueAfterDecliningUp_M1 =  ",figure1_1FlagUpContinueAfterDecliningUp_M1, "figure1FlagUpContinueUp_M1 = ", figure1FlagUpContinueUp_M1, "figure1FlagUpContinueUp_M1 = ", figure1FlagUpContinueUp_M1);
Print("figure5_1PennantUpConfirmationUp_M1 =         ",figure5_1PennantUpConfirmationUp_M1, "figure5PennantUp_M1 = ",figure5PennantUp_M1, "figure5PennantUp_M1 = ",figure5PennantUp_M1);
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
Print("figure27_1DoubleBottomFlagUp_M1 = ", figure27_1DoubleBottomFlagUp_M1);
Print("figure27_2TriangleAsConfirmationUp_M1 = ", figure27_2TriangleAsConfirmationUp_M1);
Print("figure27_3DoubleBottomChannelUp_M1 = ", figure27_3DoubleBottomChannelUp_M1);
Print("figure27_4WedgePennantConfirmationUp_M1 = ", figure27_4WedgePennantConfirmationUp_M1);
Print("figure27_5DoubleBottomConDivDivConfirmationUp_M1 = ", figure27_5DoubleBottomConDivDivConfirmationUp_M1);
Print("figure27_6DoubleBottomDivConDivConfirmationUp_M1 = ", figure27_6DoubleBottomDivConDivConfirmationUp_M1);
Print("figure27_7DoubleBottom12PosUp_M1 = ", figure27_7DoubleBottom12PosUp_M1);
Print("figure59TripleBottomWedgeUp_M1 = ", figure59TripleBottomWedgeUp_M1);

Print("figure1_1FlagUpContinueAfterDecliningUp_M5 =  ",figure1_1FlagUpContinueAfterDecliningUp_M5, "figure1FlagUpContinueUp_M5 = ", figure1FlagUpContinueUp_M5);
Print("figure5_1PennantUpConfirmationUp_M5 =         ",figure5_1PennantUpConfirmationUp_M5, "figure5PennantUp_M5 = ",figure5PennantUp_M5);
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
Print("figure27_1DoubleBottomFlagUp_M5 = ", figure27_1DoubleBottomFlagUp_M5);
Print("figure27_2TriangleAsConfirmationUp_M5 = ", figure27_2TriangleAsConfirmationUp_M5);
Print("figure27_3DoubleBottomChannelUp_M5 = ", figure27_3DoubleBottomChannelUp_M5);
Print("figure27_4WedgePennantConfirmationUp_M5 = ", figure27_4WedgePennantConfirmationUp_M5);
Print("figure27_5DoubleBottomConDivDivConfirmationUp_M5 = ", figure27_5DoubleBottomConDivDivConfirmationUp_M5);
Print("figure27_6DoubleBottomDivConDivConfirmationUp_M5 = ", figure27_6DoubleBottomDivConDivConfirmationUp_M5);
Print("figure27_7DoubleBottom12PosUp_M5 = ", figure27_7DoubleBottom12PosUp_M5);
Print("figure59TripleBottomWedgeUp_M5 = ", figure59TripleBottomWedgeUp_M5);

Print("figure1_1FlagUpContinueAfterDecliningUp_M15 = ",figure1_1FlagUpContinueAfterDecliningUp_M15, "figure1FlagUpContinueUp_M15 = ", figure1FlagUpContinueUp_M15);
Print("figure5_1PennantUpConfirmationUp_M15 =        ",figure5_1PennantUpConfirmationUp_M15, "figure5PennantUp_M15 = ",figure5PennantUp_M15);
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
Print("figure27_1DoubleBottomFlagUp_M15 = ", figure27_1DoubleBottomFlagUp_M15);
Print("figure27_2TriangleAsConfirmationUp_M15 = ", figure27_2TriangleAsConfirmationUp_M15);
Print("figure27_3DoubleBottomChannelUp_M15 = ", figure27_3DoubleBottomChannelUp_M15);
Print("figure27_4WedgePennantConfirmationUp_M15 = ", figure27_4WedgePennantConfirmationUp_M15);
Print("figure27_5DoubleBottomConDivDivConfirmationUp_M15 = ", figure27_5DoubleBottomConDivDivConfirmationUp_M15);
Print("figure27_6DoubleBottomDivConDivConfirmationUp_M15 = ", figure27_6DoubleBottomDivConDivConfirmationUp_M15);
Print("figure27_7DoubleBottom12PosUp_M15 = ", figure27_7DoubleBottom12PosUp_M15);
Print("figure59TripleBottomWedgeUp_M15 = ", figure59TripleBottomWedgeUp_M15);

Print("figure1_1FlagUpContinueAfterDecliningUp_H1 =  ",figure1_1FlagUpContinueAfterDecliningUp_H1, "figure1FlagUpContinueUp_H1 = ", figure1FlagUpContinueUp_H1);
Print("figure5_1PennantUpConfirmationUp_H1 =         ",figure5_1PennantUpConfirmationUp_H1, "figure5PennantUp_H1 = ",figure5PennantUp_H1);
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
Print("figure27_1DoubleBottomFlagUp_H1 = ", figure27_1DoubleBottomFlagUp_H1);
Print("figure27_2TriangleAsConfirmationUp_H1 = ", figure27_2TriangleAsConfirmationUp_H1);
Print("figure27_3DoubleBottomChannelUp_H1 = ", figure27_3DoubleBottomChannelUp_H1);
Print("figure27_4WedgePennantConfirmationUp_H1 = ", figure27_4WedgePennantConfirmationUp_H1);
Print("figure27_5DoubleBottomConDivDivConfirmationUp_H1 = ", figure27_5DoubleBottomConDivDivConfirmationUp_H1);
Print("figure27_6DoubleBottomDivConDivConfirmationUp_H1 = ", figure27_6DoubleBottomDivConDivConfirmationUp_H1);
Print("figure27_7DoubleBottom12PosUp_H1 = ", figure27_7DoubleBottom12PosUp_H1);
Print("figure59TripleBottomWedgeUp_H1 = ", figure59TripleBottomWedgeUp_H1);

Print("figure1_1FlagUpContinueAfterDecliningUp_H4 =  ",figure1_1FlagUpContinueAfterDecliningUp_H4, "figure1FlagUpContinueUp_H4 = ", figure1FlagUpContinueUp_H4);
Print("figure5_1PennantUpConfirmationUp_H4 =         ",figure5_1PennantUpConfirmationUp_H4, "figure5PennantUp_H4 = ",figure5PennantUp_H4);
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
Print("figure27_1DoubleBottomFlagUp_H4 = ", figure27_1DoubleBottomFlagUp_H4);
Print("figure27_2TriangleAsConfirmationUp_H4 = ", figure27_2TriangleAsConfirmationUp_H4);
Print("figure27_3DoubleBottomChannelUp_H4 = ", figure27_3DoubleBottomChannelUp_H4);
Print("figure27_4WedgePennantConfirmationUp_H4 = ", figure27_4WedgePennantConfirmationUp_H4);
Print("figure27_5DoubleBottomConDivDivConfirmationUp_H4 = ", figure27_5DoubleBottomConDivDivConfirmationUp_H4);
Print("figure27_6DoubleBottomDivConDivConfirmationUp_H4 = ", figure27_6DoubleBottomDivConDivConfirmationUp_H4);
Print("figure27_7DoubleBottom12PosUp_H4 = ", figure27_7DoubleBottom12PosUp_H4);
Print("figure59TripleBottomWedgeUp_H4 = ", figure59TripleBottomWedgeUp_H4);

Print("figure1_1FlagUpContinueAfterDecliningUp_D1 =  ",figure1_1FlagUpContinueAfterDecliningUp_D1, "figure1FlagUpContinueUp_D1 = ", figure1FlagUpContinueUp_D1);
Print("figure5_1PennantUpConfirmationUp_D1 =         ",figure5_1PennantUpConfirmationUp_D1, "figure5PennantUp_D1 = ",figure5PennantUp_D1);
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
Print("figure27_1DoubleBottomFlagUp_D1 = ", figure27_1DoubleBottomFlagUp_D1);
Print("figure27_2TriangleAsConfirmationUp_D1 = ", figure27_2TriangleAsConfirmationUp_D1);
Print("figure27_3DoubleBottomChannelUp_D1 = ", figure27_3DoubleBottomChannelUp_D1);
Print("figure27_4WedgePennantConfirmationUp_D1 = ", figure27_4WedgePennantConfirmationUp_D1);
Print("figure27_5DoubleBottomConDivDivConfirmationUp_D1 = ", figure27_5DoubleBottomConDivDivConfirmationUp_D1);
Print("figure27_6DoubleBottomDivConDivConfirmationUp_D1 = ", figure27_6DoubleBottomDivConDivConfirmationUp_D1);
Print("figure27_7DoubleBottom12PosUp_D1 = ", figure27_7DoubleBottom12PosUp_D1);
Print("figure59TripleBottomWedgeUp_D1 = ", figure59TripleBottomWedgeUp_D1);
*/

      buy=1;

      }

      if
      (
//      isNewSignal && (OpenOnHalfWaveOpenPermitUp_M1 || OpenOnHalfWaveOpenPermitUp_M5 || OpenOnHalfWaveOpenPermitUp_M15)
        isNewSignal && isTwoMaxAllTFtoH4Lower && isMACDM1CrossedDown()

           // для блокировки сигнала M15 && !isFigureH1InnerM15HalfwaveIsDone по умолчанию происходит инввертирование
    //  ((isM5FigureDown && isM15FigureDown)||(isM5FigureDown && isH1FigureDown)||(isM15FigureDown && isH1FigureDown))
/*        isMACDForelockDownFilter1(PERIOD_M15) &&
        isOSMAForelockDownFilter1(PERIOD_M15) &&
        (OpenOnHalfWaveOpenPermitUp_M1 || OpenOnHalfWaveOpenPermitUp_M5 || OpenOnHalfWaveOpenPermitUp_M15)*/
      )

      {

/*Print("figure2_1FlagDownContinueAfterDecreaseDown_M1 =  ", figure2_1FlagDownContinueAfterDecreaseDown_M1);
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
Print("figure28_1DoubleTopFlagDown_M1 = ",figure28_1DoubleTopFlagDown_M1);
Print("figure28_2TriangleAsConfirmationDown_M1 = ",figure28_2TriangleAsConfirmationDown_M1);
Print("figure28_3DoubleTopChannelDown_M1 = ",figure28_3DoubleTopChannelDown_M1);
Print("figure28_4WedgePennantConfirmationDown_M1 = ", figure28_4WedgePennantConfirmationDown_M1);
Print("figure28_5DoubleTopConDivDivConfirmationDown_M1 = ", figure28_5DoubleTopConDivDivConfirmationDown_M1);
Print("figure28_6DoubleTopDivConDivConfirmationDown_M1 = ", figure28_6DoubleTopDivConDivConfirmationDown_M1);
Print("figure28_7DoubleTop12PosDown_M1 = ", figure28_7DoubleTop12PosDown_M1);
Print("figure60TripleTopWedgeDown_M1 = ",figure60TripleTopWedgeDown_M1);

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
Print("figure28_1DoubleTopFlagDown_M5 = ",figure28_1DoubleTopFlagDown_M5);
Print("figure28_2TriangleAsConfirmationDown_M5 = ",figure28_2TriangleAsConfirmationDown_M5);
Print("figure28_3DoubleTopChannelDown_M5 = ",figure28_3DoubleTopChannelDown_M5);
Print("figure28_4WedgePennantConfirmationDown_M5 = ", figure28_4WedgePennantConfirmationDown_M5);
Print("figure28_5DoubleTopConDivDivConfirmationDown_M5 = ", figure28_5DoubleTopConDivDivConfirmationDown_M5);
Print("figure28_6DoubleTopDivConDivConfirmationDown_M5 = ", figure28_6DoubleTopDivConDivConfirmationDown_M5);
Print("figure28_7DoubleTop12PosDown_M5 = ", figure28_7DoubleTop12PosDown_M5);
Print("figure60TripleTopWedgeDown_M5 = ",figure60TripleTopWedgeDown_M5);


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
Print("figure28_1DoubleTopFlagDown_M15 = ",figure28_1DoubleTopFlagDown_M15);
Print("figure28_2TriangleAsConfirmationDown_M15 = ",figure28_2TriangleAsConfirmationDown_M15);
Print("figure28_3DoubleTopChannelDown_M15 = ",figure28_3DoubleTopChannelDown_M15);
Print("figure28_4WedgePennantConfirmationDown_M15 = ", figure28_4WedgePennantConfirmationDown_M15);
Print("figure28_5DoubleTopConDivDivConfirmationDown_M15 = ", figure28_5DoubleTopConDivDivConfirmationDown_M15);
Print("figure28_6DoubleTopDivConDivConfirmationDown_M15 = ", figure28_6DoubleTopDivConDivConfirmationDown_M15);
Print("figure28_7DoubleTop12PosDown_M15 = ", figure28_7DoubleTop12PosDown_M15);
Print("figure60TripleTopWedgeDown_M15 = ",figure60TripleTopWedgeDown_M15);


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
Print("figure28_1DoubleTopFlagDown_H1 = ",figure28_1DoubleTopFlagDown_H1);
Print("figure28_2TriangleAsConfirmationDown_H1 = ",figure28_2TriangleAsConfirmationDown_H1);
Print("figure28_3DoubleTopChannelDown_H1 = ",figure28_3DoubleTopChannelDown_H1);
Print("figure28_4WedgePennantConfirmationDown_H1 = ", figure28_4WedgePennantConfirmationDown_H1);
Print("figure28_5DoubleTopConDivDivConfirmationDown_H1 = ", figure28_5DoubleTopConDivDivConfirmationDown_H1);
Print("figure28_6DoubleTopDivConDivConfirmationDown_H1 = ", figure28_6DoubleTopDivConDivConfirmationDown_H1);
Print("figure28_7DoubleTop12PosDown_H1 = ", figure28_7DoubleTop12PosDown_H1);
Print("figure60TripleTopWedgeDown_H1 = ",figure60TripleTopWedgeDown_H1);


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
Print("figure28_1DoubleTopFlagDown_H4 = ",figure28_1DoubleTopFlagDown_H4);
Print("figure28_2TriangleAsConfirmationDown_H4 = ",figure28_2TriangleAsConfirmationDown_H4);
Print("figure28_3DoubleTopChannelDown_H4 = ",figure28_3DoubleTopChannelDown_H4);
Print("figure28_4WedgePennantConfirmationDown_H4 = ", figure28_4WedgePennantConfirmationDown_H4);
Print("figure28_5DoubleTopConDivDivConfirmationDown_H4 = ", figure28_5DoubleTopConDivDivConfirmationDown_H4);
Print("figure28_6DoubleTopDivConDivConfirmationDown_H4 = ", figure28_6DoubleTopDivConDivConfirmationDown_H4);
Print("figure28_7DoubleTop12PosDown_H4 = ", figure28_7DoubleTop12PosDown_H4);
Print("figure60TripleTopWedgeDown_H4 = ",figure60TripleTopWedgeDown_H4);


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
Print("figure28_1DoubleTopFlagDown_D1 = ",figure28_1DoubleTopFlagDown_D1);
Print("figure28_2TriangleAsConfirmationDown_D1 = ",figure28_2TriangleAsConfirmationDown_D1);
Print("figure28_3DoubleTopChannelDown_D1 = ",figure28_3DoubleTopChannelDown_D1);
Print("figure28_4WedgePennantConfirmationDown_D1 = ", figure28_4WedgePennantConfirmationDown_D1);
Print("figure28_5DoubleTopConDivDivConfirmationDown_D1 = ", figure28_5DoubleTopConDivDivConfirmationDown_D1);
Print("figure28_6DoubleTopDivConDivConfirmationDown_D1 = ", figure28_6DoubleTopDivConDivConfirmationDown_D1);
Print("figure28_7DoubleTop12PosDown_D1 = ", figure28_7DoubleTop12PosDown_D1);
Print("figure60TripleTopWedgeDown_D1 = ",figure60TripleTopWedgeDown_D1);*/

sell=1;
 }

//buy = 0;
//sell = 0;
      if(AccountFreeMargin()<(1*Lots))
        {
         //Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
// Block 3 Открытие позиций
      // check for long position (BUY) possibility

      // Print("isDoubleSymmetricH4BuyReady || isDoubleSymmetricH1BuyReady || isDoubleSymmetricM15BuyReady || isDoubleSymmetricM5BuyReady) ", isDoubleSymmetricH4BuyReady, isDoubleSymmetricH1BuyReady, isDoubleSymmetricM15BuyReady, isDoubleSymmetricM5BuyReady);
      if(buy==1)
        {
         double stopLossForBuyMin;
         if(firstMinGlobal>secondMinGlobal) {stopLossForBuyMin=secondMinGlobal;}
         else {stopLossForBuyMin=firstMinGlobal;}
         double currentStopLoss=Bid-StopLoss*Point;
         // не допустим супер стопа
         if(stopLossForBuyMin<currentStopLoss) {stopLossForBuyMin=currentStopLoss;}

         if(isBuyOrdersProfitableOrNone())
         {
            ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,currentStopLoss,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         }

         //Print(" Buy Position was opened on TimeFrame ","periodGlobal = ",periodGlobal);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice()," signal = ", currentSignalAnalyzeConcatenated);
            isNewSignal = false;
            updateSLandTPForBuyOrders(currentStopLoss,Ask+TakeProfit*Point);
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

         if(isSellOrdersProfitableOrNone())
         {
            ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,currentStopLoss,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         }

         //Print("Sell Position was opened on TimeFrame ","periodGlobal = ",periodGlobal);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice()," signal = ", currentSignalAnalyzeConcatenated);
            isNewSignal = false;
            updateSLandTPForSellOrders(currentStopLoss,Bid-TakeProfit*Point);
           }
         else Print("Error opening SELL order : ",GetLastError());
         return;
        }
// it is important to enter the market correctly,
// but it is more important to exit it correctly...

// Block 4 Ведение позиций
/*Вызывая метод nonSymm
   для periodGlobal мы будем update-ить цену*/
   // Trying to fix one orderStop
total=OrdersTotal();
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
                  if(Bid-((Bid - OrderOpenPrice())*TrailingFiboLevel)>OrderStopLoss())// если стоп-лосс МЕНЬШЕ чем цена - 50% прибыли
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-((Bid - OrderOpenPrice())*TrailingFiboLevel),OrderTakeProfit(),0,Green);// то стоп лосс равен пцена - 50% прибыли
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
            OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); //21.02.2019 trying to fix disappearing (more precisely - OrderTakeProfit() = 0.00000 in this section)  tp for sell position and moving backward manual stopLoss
            double stopShift=stopLossForBuyMin-OrderStopLoss();

            if(
            stopLossForBuyMin>OrderOpenPrice() && // условие БезУбытка
             stopShift > spread &&
              Bid>stopLossForBuyMin &&
               stopLossForBuyMin>OrderStopLoss()
               )
              {
              OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); //07.03.2019 trying to fix disappearing (more precisely - OrderTakeProfit() = 0.00000 in this section)  tp for sell position and moving backward manual stopLoss
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
                  if(Ask+((OrderOpenPrice()-Ask)*TrailingFiboLevel)<OrderStopLoss()|| (OrderStopLoss()==0))// если стоп-лосс МЕНЬШЕ  чем цена + 50% прибыли(Уберу двойной спред)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+((OrderOpenPrice()-Ask)*TrailingFiboLevel),OrderTakeProfit(),0,Red);//(Уберу двойной спред)
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

            if(
            stopLossForSellMax<OrderOpenPrice() && // условие БезУбытка
            (stopShift > spread || stopShift <= 0) &&
             Ask<stopLossForSellMax &&
             (stopLossForSellMax<OrderStopLoss() || OrderStopLoss()==0)
            )
              {
              OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); //07.03.2019 trying to fix disappearing (more precisely - OrderTakeProfit() = 0.00000 in this section)  tp for sell position and moving backward manual stopLoss
               //Print("Sell Position was stoplossed on TimeFrame ","periodGlobal = ",periodGlobal);
               OrderModify(OrderTicket(),OrderOpenPrice(),(stopLossForSellMax+(Ask-Bid)*2),OrderTakeProfit(),0,Red);
               return;
              }
            //                 }

           }
        }
     }
     }


     Sleep(3333);
  }

// Block 5 nonSymm() - проставляем цены в  global переменных для ПолуВолн, используется в блоке 4
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
    string strOpenOnHalfWaveUp_M1   ;
    string strOpenOnHalfWaveUp_M5   ;
    string strOpenOnHalfWaveUp_M15  ;
    string strOpenOnHalfWaveDown_M1 ;
    string strOpenOnHalfWaveDown_M5 ;
    string strOpenOnHalfWaveDown_M15;
    string strMoneyManagment;
    int total = OrdersTotal();
    if(total>0){
      start = "Open Order";
    } else { start = " "; };


     if( OpenOnHalfWaveUp_M1) {
        strOpenOnHalfWaveUp_M1    = "OpenOnHalfWaveUp_M1 now is Active";
     } else {strOpenOnHalfWaveUp_M1    = " ";}
     if( OpenOnHalfWaveUp_M5) {
        strOpenOnHalfWaveUp_M5    = "OpenOnHalfWaveUp_M5 now is Active";
     } else {strOpenOnHalfWaveUp_M5    = " ";}
     if( OpenOnHalfWaveUp_M15) {
        strOpenOnHalfWaveUp_M15   = "OpenOnHalfWaveUp_M15 now is Active";
     } else {strOpenOnHalfWaveUp_M15   = " ";}
     if( OpenOnHalfWaveDown_M1) {
        strOpenOnHalfWaveDown_M1  = "OpenOnHalfWaveDown_M1 now is Active";
     } else {strOpenOnHalfWaveDown_M1  = " ";}
     if( OpenOnHalfWaveDown_M5) {
        strOpenOnHalfWaveDown_M5  = "OpenOnHalfWaveDown_M5 now is Active";
     } else {strOpenOnHalfWaveDown_M5  = " ";}
     if( OpenOnHalfWaveDown_M15) {
        strOpenOnHalfWaveDown_M15 =  "OpenOnHalfWaveDown_M15 now is Active";
     } else {strOpenOnHalfWaveDown_M15 = " ";}

     if(isAutoMoneyManagmentEnabled && moneyManagement4And8Or12And24_4_Or_12 == 4){
        strMoneyManagment = "MoneyManagment 4/8 USD, confident movement. Lots = " + Lots;
     }

     if(isAutoMoneyManagmentEnabled && moneyManagement4And8Or12And24_4_Or_12 == 12){
        strMoneyManagment = "MoneyManagment 12/24 USD, no explicit movement. Lots = " + Lots;
     }

    Comment(
        "\n     ", start ,
        "\nPERIOD_M1     ", messageGlobalPERIOD_M1 ,
        "\nPERIOD_M5     ", messageGlobalPERIOD_M5 ,
        "\nPERIOD_M15   ", messageGlobalPERIOD_M15 ,
        "\nPERIOD_H1     ", messageGlobalPERIOD_H1 ,
        "\nPERIOD_H4     ", messageGlobalPERIOD_H4 ,
        "\nPERIOD_D1     ", messageGlobalPERIOD_D1 ,
        "\n", strOpenOnHalfWaveUp_M1    ,
        "\n", strOpenOnHalfWaveUp_M5    ,
        "\n", strOpenOnHalfWaveUp_M15   ,
        "\n", strOpenOnHalfWaveDown_M1  ,
        "\n", strOpenOnHalfWaveDown_M5  ,
        "\n", strOpenOnHalfWaveDown_M15 ,
        "\n", strMoneyManagment
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


      bool isOSMANewlyCrossedUpFilter1(ENUM_TIMEFRAMES timeFrameForOSMA){
        bool isOSMACrossed = false;
        double osma0 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,0);
        double osma1 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,1);
        double osma2 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,2);
        double osma3 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,3);
        double osma4 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,4);

            if(  osma0>0 && (osma1 < 0 || osma2 < 0 || osma3 < 0 || osma4 < 0)  ) {
              isOSMACrossed = true;
            }

        return isOSMACrossed;
      }
        bool isOSMANewlyCrossedDownFilter1(ENUM_TIMEFRAMES timeFrameForOSMA){
          bool isOSMACrossed = false;
          double osma0 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,0);
          double osma1 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,1);
          double osma2 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,2);
          double osma3 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,3);
          double osma4 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,4);
    //      Print("timeFrameForOSMA = ",timeFrameForOSMA);
    //      Print ("osma0 = ",osma0,"osma1 = ",osma1,"osma2 = ",osma2,"osma3 = ",osma3);
              if(  osma0<0 && (osma1 > 0 || osma2 > 0 || osma3 > 0 || osma4 > 0)  ) {
                isOSMACrossed = true;
     //           Print("isOSMACrossed = ", isOSMACrossed);
              }

          return isOSMACrossed;
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


     bool isMACDForelockUpFilter1(ENUM_TIMEFRAMES timeFrameForMACD){
        bool isMACDCrossed = false;
        double macd0 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,0);
        double macd1 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,1);
        double macd2 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,2);
        double macd3 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,3);
        double macd4 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,4);
        double macd5 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,5);

            if(  macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 && macd5 < 0 &&
                 macd5 < macd4 && macd4 < macd3 && macd3 < macd2 && macd2 < macd1 && macd1 < macd0
              ) {
              isMACDCrossed = true;
            }

        return isMACDCrossed;
      }
        bool isMACDForelockDownFilter1(ENUM_TIMEFRAMES timeFrameForMACD){
          bool isMACDCrossed = false;
          double macd0 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,0);
          double macd1 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,1);
          double macd2 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,2);
          double macd3 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,3);
          double macd4 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,4);
          double macd5 = iMACD(NULL,timeFrameForMACD,12,26,9,PRICE_OPEN,MODE_MAIN,5);
    //      Print("timeFrameForMACD = ",timeFrameForMACD);
    //      Print ("macd0 = ",macd0,"macd1 = ",macd1,"macd2 = ",macd2,"macd3 = ",macd3);
              if(  macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 && macd5 > 0 &&
                   macd5 > macd4 && macd4 > macd3 && macd3 > macd2 && macd2 > macd1 && macd1 > macd0
                ) {
                isMACDCrossed = true;
     //           Print("isMACDCrossed = ", isMACDCrossed);
              }

          return isMACDCrossed;
        }


          bool isOSMAForelockUpFilter1(ENUM_TIMEFRAMES timeFrameForOSMA){
            bool isOSMACrossed = false;
            double osma0 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,0);
            double osma1 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,1);
            double osma2 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,2);
            double osma3 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,3);

                if(  osma0>0 && osma1 > 0 && osma2 > 0 && osma3 < 0   ) {
                  isOSMACrossed = true;
                }

            return isOSMACrossed;
          }
            bool isOSMAForelockDownFilter1(ENUM_TIMEFRAMES timeFrameForOSMA){
              bool isOSMACrossed = false;
              double osma0 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,0);
              double osma1 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,1);
              double osma2 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,2);
              double osma3 = iOsMA(NULL,timeFrameForOSMA,12,26,9,PRICE_OPEN,3);
        //      Print("timeFrameForOSMA = ",timeFrameForOSMA);
        //      Print ("osma0 = ",osma0,"osma1 = ",osma1,"osma2 = ",osma2,"osma3 = ",osma3);
                  if(  osma0<0 && osma1 < 0 && osma2 < 0 && osma3 > 0 ) {
                    isOSMACrossed = true;
         //           Print("isOSMACrossed = ", isOSMACrossed);
                  }

              return isOSMACrossed;
            }

            bool isDivergenceOrConvergence_D1(){
                bool result = false;
                double macd100 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
                double macd101 = iMACD(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,MODE_MAIN,1);

                double osma100 = iOsMA(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,0);
                double osma101 = iOsMA(NULL,PERIOD_D1,12,26,9,PRICE_OPEN,1);
                if((macd101 < macd100 && osma101 > osma100) || (macd101 > macd100 && osma101<osma101)) {
                    result = true;
                }

                return result;
            }



          bool isOSMAThreeUp(ENUM_TIMEFRAMES timeframe){
            bool isThreeUp = false;
            double osma0 = iOsMA(NULL,timeframe,12,26,9,PRICE_OPEN,0);
            double osma1 = iOsMA(NULL,timeframe,12,26,9,PRICE_OPEN,1);
            double osma2 = iOsMA(NULL,timeframe,12,26,9,PRICE_OPEN,2);


                if(  osma0>osma1 && osma1 > osma2) {
                  isThreeUp = true;
                }

            return isThreeUp;
          }

            bool isOSMAThreeDown(ENUM_TIMEFRAMES timeframe){
              bool isThreeDown = false;
              double osma0 = iOsMA(NULL,timeframe,12,26,9,PRICE_OPEN,0);
              double osma1 = iOsMA(NULL,timeframe,12,26,9,PRICE_OPEN,1);
              double osma2 = iOsMA(NULL,timeframe,12,26,9,PRICE_OPEN,2);

        //      Print("timeFrameForOSMA = ",timeFrameForOSMA);
        //      Print ("osma0 = ",osma0,"osma1 = ",osma1,"osma2 = ",osma2,"osma3 = ",osma3);
                  if(  osma0<osma1 && osma1 < osma2 ) {
                    isThreeDown = true;
         //           Print("isOSMACrossed = ", isOSMACrossed);
                  }

              return isThreeDown;
            }

    bool isOpenOnHalfWaveUp_M1 (){
        bool resultOpenOnHalfWave = false;
            double macd0 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,2);
            double macd3 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,3);
            if (macd0 > 0 && macd1 > 0 && macd2 < 0 && macd3 < 0){
                resultOpenOnHalfWave = true;
            }
        return resultOpenOnHalfWave;
    }
    bool isOpenOnHalfWaveUp_M5 (){
        bool resultOpenOnHalfWave = false;
            double macd0 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,2);
            double macd3 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,3);
            if (macd0 > 0 && macd1 > 0 && macd2 < 0 && macd3 < 0){
                resultOpenOnHalfWave = true;
            }
        return resultOpenOnHalfWave;
    }
    bool isOpenOnHalfWaveUp_M15(){
        bool resultOpenOnHalfWave = false;
            double macd0 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,2);
            double macd3 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,3);
            if (macd0 > 0 && macd1 > 0 && macd2 < 0 && macd3 < 0){
                resultOpenOnHalfWave = true;
            }
        return resultOpenOnHalfWave;
    }

    bool isOpenOnHalfWaveDown_M1 (){
        bool resultOpenOnHalfWave = false;
            double macd0 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,2);
            double macd3 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,3);
            if (macd0 < 0 && macd1 < 0 && macd2 > 0 && macd3 >0){
                resultOpenOnHalfWave = true;
            }
        return resultOpenOnHalfWave;
    }
    bool isOpenOnHalfWaveDown_M5 (){
        bool resultOpenOnHalfWave = false;
            double macd0 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,2);
            double macd3 = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_OPEN,MODE_MAIN,3);
            if (macd0 < 0 && macd1 < 0 && macd2 > 0 && macd3 >0){
                resultOpenOnHalfWave = true;
            }
        return resultOpenOnHalfWave;
    }
    bool isOpenOnHalfWaveDown_M15(){
        bool resultOpenOnHalfWave = false;
            double macd0 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,2);
            double macd3 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_OPEN,MODE_MAIN,3);
            if (macd0 < 0 && macd1 < 0 && macd2 > 0 && macd3 >0){
                resultOpenOnHalfWave = true;
            }
        return resultOpenOnHalfWave;
    }

    bool isMA133And333Up(ENUM_TIMEFRAMES timeFrame) {
        bool result = false;
        double ma133_0 = iMA(NULL,timeFrame,133,0,MODE_SMA,PRICE_OPEN,0);
        double ma133_1 = iMA(NULL,timeFrame,133,0,MODE_SMA,PRICE_OPEN,1);
        double ma333_0 = iMA(NULL,timeFrame,333,0,MODE_SMA,PRICE_OPEN,0);
        double ma333_1 = iMA(NULL,timeFrame,333,0,MODE_SMA,PRICE_OPEN,1);

        if(ma133_0 > ma133_1 && ma333_0 > ma333_1){
            result = true;
        }
        return result;
    }

    bool isMA133And333Down(ENUM_TIMEFRAMES timeFrame) {
        bool result = false;
        double ma133_0 = iMA(NULL,timeFrame,133,0,MODE_SMA,PRICE_OPEN,0);
        double ma133_1 = iMA(NULL,timeFrame,133,0,MODE_SMA,PRICE_OPEN,1);
        double ma333_0 = iMA(NULL,timeFrame,333,0,MODE_SMA,PRICE_OPEN,0);
        double ma333_1 = iMA(NULL,timeFrame,333,0,MODE_SMA,PRICE_OPEN,1);

        if(ma133_0 < ma133_1 && ma333_0 < ma333_1){
            result = true;
        }
        return result;
    }

    bool isOsMAorMACDCrossedUpOneTick(ENUM_TIMEFRAMES timeFrame){
        bool result = false;
            double macd0 = iMACD(NULL,timeFrame,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,timeFrame,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,timeFrame,12,26,9,PRICE_OPEN,MODE_MAIN,2);

            double osma0 = iOsMA(NULL,timeFrame,12,26,9,PRICE_OPEN,0);
            double osma1 = iOsMA(NULL,timeFrame,12,26,9,PRICE_OPEN,1);
            double osma2 = iOsMA(NULL,timeFrame,12,26,9,PRICE_OPEN,2);

            if (macd0 > 0 && macd1 < 0 && macd2 < 0){
                result = true;
            }
            if (osma0 > 0 && osma1 < 0 && osma2 < 0){
                result = true;
            }
            return result;
    }

    bool isOsMAorMACDCrossedDownOneTick(ENUM_TIMEFRAMES timeFrame){
        bool result = false;
            double macd0 = iMACD(NULL,timeFrame,12,26,9,PRICE_OPEN,MODE_MAIN,0);
            double macd1 = iMACD(NULL,timeFrame,12,26,9,PRICE_OPEN,MODE_MAIN,1);
            double macd2 = iMACD(NULL,timeFrame,12,26,9,PRICE_OPEN,MODE_MAIN,2);

            double osma0 = iOsMA(NULL,timeFrame,12,26,9,PRICE_OPEN,0);
            double osma1 = iOsMA(NULL,timeFrame,12,26,9,PRICE_OPEN,1);
            double osma2 = iOsMA(NULL,timeFrame,12,26,9,PRICE_OPEN,2);

            if (macd0 < 0 && macd1 > 0 && macd2 > 0){
                result = true;
            }
            if (osma0 < 0 && osma1 > 0 && osma2 > 0){
                result = true;
            }
            return result;
    }


bool isCloseLowerThanMA83ForBuy(ENUM_TIMEFRAMES timeFrame){
    bool result = false;
    double close_0 = iClose(0,timeFrame,0);
    double ma_0 = iMA(NULL,timeFrame,83,0,MODE_SMA,PRICE_OPEN,0);
    if( close_0 < ma_0){
        result = true;
    }
    return result;
}

bool isCloseHigherThanMA83ForSell(ENUM_TIMEFRAMES timeFrame){
    bool result = false;
    double close_0 = iClose(0,timeFrame,0);
    double ma_0 = iMA(NULL,timeFrame,83,0,MODE_SMA,PRICE_OPEN,0);
    if( close_0 > ma_0){
        result = true;
    }
    return result;
}




bool isNextTimeframeMACDSignalUp(ENUM_TIMEFRAMES timeframe){
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_SIGNAL,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_SIGNAL,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_SIGNAL,2);
    bool result = false;
        if(
        macd0 > macd1 && macd1 > macd2
        ){
            result = true;
        }
    return result;
}
bool isNextTimeframeMACDSignalDown(ENUM_TIMEFRAMES timeframe){
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_SIGNAL,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_SIGNAL,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_SIGNAL,2);
    bool result = false;
        if(
        macd0 < macd1 && macd1 < macd2
        ){
            result = true;
        }
    return result;
}


bool isCandle1ThreeToOneUp(ENUM_TIMEFRAMES timeframe){
    bool result = false;

    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}

        return result;
}


bool isCandle2ThreeToOneDown(ENUM_TIMEFRAMES timeframe){
    bool result = false;

    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}

        return result;
}

bool isCandle3(ENUM_TIMEFRAMES timeframe){
    bool result = false;

    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);

        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) < iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) < iOpen(NULL,timeframe,6)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}

        return result;
}


bool isCandle4(ENUM_TIMEFRAMES timeframe){
    bool result = false;

    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) > iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) > iOpen(NULL,timeframe,6)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}

        return result;
}

bool isCandle5(ENUM_TIMEFRAMES timeframe){
    bool result = false;

    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) > iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) < iOpen(NULL,timeframe,6) &&

            iOpen(NULL,timeframe,6)  > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,6) < iClose(NULL,timeframe,4)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}

        return result;
}


bool isCandle6(ENUM_TIMEFRAMES timeframe){
    bool result = false;

    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) < iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) > iOpen(NULL,timeframe,6) &&

            iOpen(NULL,timeframe,6)  < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,6) > iClose(NULL,timeframe,4)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}

        return result;
}

bool isCandle7(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) > iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) > iOpen(NULL,timeframe,6)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}
        return result;
}
bool isCandle8(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) < iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) < iOpen(NULL,timeframe,6)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}
        return result;
}

bool isCandle9(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) < iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) > iOpen(NULL,timeframe,6) &&
            iOpen(NULL,timeframe,6)  > iOpen(NULL,timeframe,4)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}
        return result;
}
bool isCandle10(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) > iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) < iOpen(NULL,timeframe,6) &&
            iOpen(NULL,timeframe,6)  < iClose(NULL,timeframe,4)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}
        return result;
}

bool isCandle11(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) > iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) < iOpen(NULL,timeframe,6) &&
            iOpen(NULL,timeframe,6)  > iClose(NULL,timeframe,5)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}
        return result;
}
bool isCandle12(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) < iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) > iOpen(NULL,timeframe,6) &&
            iOpen(NULL,timeframe,6)  < iClose(NULL,timeframe,5)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}
        return result;
}

bool isCandle13(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) < iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) > iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) < iOpen(NULL,timeframe,6) &&
            iClose(NULL,timeframe,4) > iClose(NULL,timeframe,6)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}
        return result;
}
bool isCandle14(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iClose(NULL,timeframe,4) > iOpen(NULL,timeframe,4) &&
            iClose(NULL,timeframe,5) < iOpen(NULL,timeframe,5) &&
            iClose(NULL,timeframe,6) > iOpen(NULL,timeframe,6) &&
            iClose(NULL,timeframe,6) > iClose(NULL,timeframe,4)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}
        return result;
}

bool isCandle19(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iHigh(NULL,timeframe,2)  > iHigh(NULL,timeframe,1) &&
            iHigh(NULL,timeframe,2)  > iHigh(NULL,timeframe,3) &&
            iLow(NULL,timeframe,2)   > iLow(NULL,timeframe,1) &&
            iLow(NULL,timeframe,2)   > iLow(NULL,timeframe,3)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}
        return result;
}
bool isCandle20(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iHigh(NULL,timeframe,2)  < iHigh(NULL,timeframe,1) &&
            iHigh(NULL,timeframe,2)  < iHigh(NULL,timeframe,3) &&
            iLow(NULL,timeframe,2)   < iLow(NULL,timeframe,1) &&
            iLow(NULL,timeframe,2)   < iLow(NULL,timeframe,3)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}
        return result;
}

bool isCandle21(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 < 0 && macd1 < 0 && macd2 < 0 && macd3 < 0 && macd4 < 0 &&
            iClose(NULL,timeframe,1) < iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) > iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) < iOpen(NULL,timeframe,3) &&
            iHigh(NULL,timeframe,2)  < iHigh(NULL,timeframe,1) &&
            iHigh(NULL,timeframe,2)  < iHigh(NULL,timeframe,3) &&
            iLow(NULL,timeframe,2)   < iLow(NULL,timeframe,1) &&
            iLow(NULL,timeframe,2)   < iLow(NULL,timeframe,3)
            && macd2 > macd3 &&  macd3 > macd4 && macd4 > macd5
        )
        {result = true;}
        return result;
}
bool isCandle22(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double macd2 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,2);
    double macd3 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,3);
    double macd4 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,4);
    double macd5 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,5);
        if(
            // macd0 > 0 && macd1 > 0 && macd2 > 0 && macd3 > 0 && macd4 > 0 &&
            iClose(NULL,timeframe,1) > iOpen(NULL,timeframe,1) &&
            iClose(NULL,timeframe,2) < iOpen(NULL,timeframe,2) &&
            iClose(NULL,timeframe,3) > iOpen(NULL,timeframe,3) &&
            iHigh(NULL,timeframe,2)  > iHigh(NULL,timeframe,1) &&
            iHigh(NULL,timeframe,2)  > iHigh(NULL,timeframe,3) &&
            iLow(NULL,timeframe,2)   > iLow(NULL,timeframe,1) &&
            iLow(NULL,timeframe,2)   > iLow(NULL,timeframe,3)
            && macd2 < macd3 &&  macd3 < macd4 && macd4 < macd5
        )
        {result = true;}
        return result;
}
bool isFigure_MA_62_Up(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double ma_0 = iMA(NULL,timeframe,62,0,MODE_SMA,PRICE_OPEN,0);
    double ma_1 = iMA(NULL,timeframe,62,0,MODE_SMA,PRICE_OPEN,0);
    double open_0 = iOpen(NULL,timeframe,0);
    double open_1 = iOpen(NULL,timeframe,1);
    if(
        macd1 < 0 && macd0 > 0 && open_1 < ma_0 && open_0 > ma_0
    ){
        result = true;
    }

    return result;
}

bool isFigure_MA_62_Down(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    double ma_0 = iMA(NULL,timeframe,62,0,MODE_SMA,PRICE_OPEN,0);
    double ma_1 = iMA(NULL,timeframe,62,0,MODE_SMA,PRICE_OPEN,0);
    double open_0 = iOpen(NULL,timeframe,0);
    double open_1 = iOpen(NULL,timeframe,1);
    if(
        macd1 > 0 && macd0 < 0 && open_1 > ma_0 && open_0 < ma_0
    ){
        result = true;
    }

    return result;
}

bool isTwoMinAllTFtoH4Higher_Up(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    if(
        firstMinGlobal < Bid &&
        secondMinGlobal < Bid
    ){
        result = true;
    }
    return result;
}
bool isTwoMaxAllTFtoH4Lower_Down(ENUM_TIMEFRAMES timeframe){
    bool result = false;
    if(
        firstMaxGlobal > Ask &&
        secondMaxGlobal > Ask
    ){
        result = true;
    }
    return result;
}


bool isMACDM1CrossedUp(){
    bool result = false;
    double macd0 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,timeframe,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    if(macd0<0 && macd1>0){
        result = true;
    }
    return result;
}
bool isMACDM1CrossedDown(){
    bool result = false;
    double macd0 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,0);
    double macd1 = iMACD(NULL,PERIOD_M1,12,26,9,PRICE_OPEN,MODE_MAIN,1);
    if(macd0>0 && macd1<0){
        result = true;
    }
    return result;
}

bool isBuyOrdersProfitableOrNone(){
   bool result = false;

   int total=OrdersTotal();
   if(total<1){
        result = true;
        return result;
   }
   if(!result){
    for(cnt=0;cnt<total;cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_BUY && OrderSymbol()==Symbol())   // check for opened position, // check for symbol
         {
            if(Bid>OrderOpenPrice()){
                result = true;
            }
            else{
                result = false;
                return result;
            }
         }
      }
   }
   return result;
}

bool isSellOrdersProfitableOrNone(){
   bool result = false;

   int total=OrdersTotal();
   if(total<1){
        result = true;
        return result;
   }
   if(!result){
    for(cnt=0;cnt<total;cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())   // check for opened position, // check for symbol
         {
            if(Ask<OrderOpenPrice()){
                result = true;
            }
            else{
                result = false;
                return result;
            }
         }
      }
   }
   return result;
}

bool updateSLandTPForBuyOrders(double stopLoss, double takeProfit){
    for(cnt=0;cnt<total;cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_BUY && OrderSymbol()==Symbol())   // check for opened position, // check for symbol
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),stopLoss,takeProfit,0,Green);
         }
      }
}
bool updateSLandTPForSellOrders(double stopLoss, double takeProfit){
    for(cnt=0;cnt<total;cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())   // check for opened position, // check for symbol
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),stopLoss,takeProfit,0,Green);
         }
      }
}