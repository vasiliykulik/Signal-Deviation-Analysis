//+------------------------------------------------------------------+
//|                                                      LotSize.mq4 |
//|                                     Copyright 2019, Vasiliy Kylik|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "opyright 2019, Vasiliy Kylik"
#property link      ""

#property indicator_chart_window
//--- input parameters

extern string    t4="---Число знаков в размере лота---";
extern int       p=2;
extern string    t5="---Цвет текста---";
extern color     text=RoyalBlue;

input double  Risk = 5.0; // процент риска для депозита
input double  LotNew  = 0.01; // если Risk = 0, то рабочий лот будет таким

double           RiskDepo, Lot;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

if(ObjectFind("STOP")==-1){ObjectCreate( "STOP", OBJ_HLINE, 0, 0, Open[0]-Point*50); ObjectSet("STOP",OBJPROP_COLOR,Red);}
if(ObjectFind("START")==-1){ObjectCreate( "START", OBJ_HLINE, 0, 0, Open[0]+Point*50);ObjectSet("START",OBJPROP_COLOR,Green);}
if(ObjectFind("MARKETlot")==-1){ObjectCreate( "MARKETlot", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);ObjectSet("MARKETlot",OBJPROP_CORNER,0);ObjectSet("MARKETlot",OBJPROP_XDISTANCE,0);ObjectSet("MARKETlot",OBJPROP_YDISTANCE,65);}
if(ObjectFind("MARKETRisk")==-1){ObjectCreate( "MARKETRisk", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);ObjectSet("MARKETRisk",OBJPROP_CORNER,0);ObjectSet("MARKETRisk",OBJPROP_XDISTANCE,0);ObjectSet("MARKETRisk",OBJPROP_YDISTANCE,80);}
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

ObjectDelete("STOP");
ObjectDelete("START");
ObjectDelete("MARKETlot");
ObjectDelete("MARKETRisk");


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   RiskDepo=AccountFreeMargin()*Risk/100;
   double LOTNew = WorkingLot(Risk,Lot); // LOT и будет тот вожделенный торговый лот.
   // для полного счастья, ЛОТ можно нормализовать. Даже желательно:
   LOTNew = NormalizeDouble(LOTNew,2);

   ObjectGet("STOP", OBJPROP_PRICE1);
   ObjectGet("START", OBJPROP_PRICE1);

   ObjectSetText( "MARKETlot","Лот по рынку: "+DoubleToStr(LOTNew,p) , 10, "Times New Roman", text);
   ObjectSetText( "MARKETRisk","Риск: "+DoubleToStr(Risk,1)+"% / "+ DoubleToStr(RiskDepo,0), 10, "Times New Roman", text);

   return(0);
  }
//+------------------------------------------------------------------+

/*
risk - процент риска
lots - если risk = 0, то лот будет равен lots
*/
double WorkingLot(double risk,double lots)
  {
   double Lots;
   double Free    = AccountFreeMargin();
   double One_Lot = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   double Stepx   = MarketInfo(Symbol(),MODE_LOTSTEP);
   double Min_Lot = MarketInfo(Symbol(),MODE_MINLOT);
   double Max_Lot = MarketInfo(Symbol(),MODE_MAXLOT);

   if(risk>0)
     {
      Lots=MathFloor(Free*risk/105/One_Lot/Stepx)*Stepx;
      if(Lots<Min_Lot) Lots=Min_Lot;
      if(Lots>Max_Lot) Lots=Max_Lot;
    //  return (Lots);
     }
   if(risk==0)
     {
      Lots=lots;
      if(Lots<Min_Lot) Lots=Min_Lot;
      if(Lots>Max_Lot) Lots=Max_Lot;
     }
//  ==========  наличие свободных денег для открытия ордеров   ===============
    if((Lots)*One_Lot>AccountFreeMargin())
     {
      Print("Нет свободных средств для открытия ордера");
      return(0);
     }
    return (Lots);
  }