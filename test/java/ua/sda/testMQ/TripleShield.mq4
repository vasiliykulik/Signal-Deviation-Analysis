//+------------------------------------------------------------------+
//|                                                 TripleShield.mq4 |
//|                                  Copyright © 2018, Vasiliy Kylik |
//|                                           http://www.alpari.org/ |
//+------------------------------------------------------------------+

extern double TakeProfit = 1200;
extern double StopLoss = 10000;
extern double Lots = 0.01;
extern double TrailingStop = 10000;


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

   double[]halfWave0Н4;

   bool
   what0HalfWaveMACDH4,
   what_1HalfWaveMACDH4;

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

/*   Алгоритм определения критериев тренда:

   Идём по истории H4
   1) what0HalfWaveMACDH4 (0 это положительная 1 это отрицательная)
   а) складываем тики в массив halfWave0Н4
   2) если произошло пересечение
   а) what_1HalfWaveMACDH4
   б) складываем тики в массив полуволна_1Н4
   3) если произошло пересечение
   а) какая_2ПолуволнаMACDН4
   б) складываем тики в массив полуволна_2Н4
   4) если произошло пересечение
   а) какая_3ПолуволнаMACDН4
   б) складываем тики в массив полуволна_3Н4

   если (what_1HalfWaveMACDH4 ==0 И какая_3ПолуволнаMACDН4 ==0) двойнойКритерийКаналН4 = 0

   если (what_1HalfWaveMACDH4 ==1 И какая_3ПолуволнаMACDН4==1) двойнойКритерийКаналН4 = 1

   Идём по истории H1
   1) какая0ПолуволнаMACDН1 (0 это положительная 1 это отрицательная)
   а) складываем тики в массив полуволна0Н1
   2) если произошло пересечение
   а) какая_1ПолуволнаMACDН1
   б) складываем тики в массив полуволна_1Н1
   3) если произошло пересечение
   а) какая_2ПолуволнаMACDН1
   б) складываем тики в массив полуволна_2Н1
   4) если произошло пересечение
   а) какая_3ПолуволнаMACDН1
   б) складываем тики в массив полуволна_3Н1

   если (какая_1ПолуволнаMACDН1 ==0 И какая_3ПолуволнаMACDН1==0) двойнойКритерийТрендН1 = 0

   если (какая_1ПолуволнаMACDН1 ==1 И какая_3ПолуволнаMACDН1==1) двойнойКритерийТрендН1 = 1

   Идём по истории М15
   1) какая0ПолуволнаMACDМ15
   а) складываем тики в массив полуволна0М15
   2) если произошло пересечение
   а) какая_1ПолуволнаMACDМ15
   б) складываем тики в массив полуволна_1М15
   3) если произошло пересечение
   а) какая_2ПолуволнаMACDМ15
   б) складываем тики в массив полуволна_2М15
   4) если произошло пересечение
   а) какая_3ПолуволнаMACDМ15
   б) складываем тики в массив полуволна_3М15

   если (какая_1ПолуволнаMACDМ15 ==0 И какая_3ПолуволнаMACDМ15==0) двойнойКритерийТочкаВходаМ15 = 0

   если (какая_1ПолуволнаMACDМ15 ==1 И какая_3ПолуволнаMACDМ15==1) двойнойКритерийТочкаВходаМ15 = 1

   Идём по истории М5
   1) какая0ПолуволнаMACDМ5
   а) складываем тики в массив полуволна0М5
   2) если произошло пересечение
   а) какая_1ПолуволнаMACDМ5
   б) складываем тики в массив полуволна_1М5
   3) если произошло пересечение
   а) какая_2ПолуволнаMACDМ5
   б) складываем тики в массив полуволна_2М5
   4) если произошло пересечение
   а) какая_3ПолуволнаMACDМ5
   б) складываем тики в массив полуволна_3М5

   если (какая_1ПолуволнаMACDМ5 ==0 И какая_3ПолуволнаMACDМ5==0) двойнойКритерийМоментВходаМ5 = 0

   если (какая_1ПолуволнаMACDМ5 ==1 И какая_3ПолуволнаMACDМ5==1) двойнойКритерийМоментВходаМ5 = 1

   Идём по истории М1
   1) какая0ПолуволнаMACDМ1
   а) складываем тики в массив полуволна0М1
   2) если произошло пересечение
   а) какая_1ПолуволнаMACDМ1
   б) складываем тики в массив полуволна_1М1
   3) если произошло пересечение
   а) какая_2ПолуволнаMACDМ1
   б) складываем тики в массив полуволна_2М1
   4) если произошло пересечение
   а) какая_3ПолуволнаMACDМ1
   б) складываем тики в массив полуволна_3М1

   если (какая_1ПолуволнаMACDМ1 ==0 И какая_3ПолуволнаMACDМ1==0) двойнойКритерийМ1 = 0

   если (какая_1ПолуволнаMACDМ1 ==1 И какая_3ПолуволнаMACDМ1==1) двойнойКритерийМ1 = 1

   если (Стохастик_1H1<Стохастик0H1) то направлениеСтохастикH1==0
   если (Стохастик_1М15<Стохастик0М15) то направлениеСтохастикМ15==0
   если (Стохастик_1М5<СтохастикМ05) то направлениеСтохастикМ5==0
   если (Стохастик_1М1<Стохастик0М1) то направлениеСтохастикМ1==0

   если (Стохастик_1H1>Стохастик0H1) то направлениеСтохастикH1==1
   если (Стохастик_1М15>Стохастик0М15) то направлениеСтохастикМ15==1
   если (Стохастик_1М5>СтохастикМ05) то направлениеСтохастикМ5==1
   если (Стохастик_1М1>Стохастик0М1) то направлениеСтохастикМ1==1

   если(направлениеСтохастикH1 == 0 И направлениеСтохастикМ15== 0 И направлениеСтохастикМ5 == 0 И направлениеСтохастикМ1 == 0) то весьСтохастик ==0

   если(направлениеСтохастикH1 == 1 И направлениеСтохастикМ15== 1 И направлениеСтохастикМ5 == 1 И направлениеСтохастикМ1 == 1) то весьСтохастик ==1

   если (OsMA_1H1>OsMA0H1) то направлениеOsMAH1==0
   если (OsMA_1М15>OsMA015) то направлениеOsMAМ15==0
   если (OsMA_1М5>OsMA05) то направлениеOsMAМ5==0
   если (OsMA_1М1>OsMA01) то направлениеOsMAМ1==0

   если (OsMA_1H1<OsMA0H1) то направлениеOsMAH1==1
   если (OsMA_1М15<OsMA015) то направлениеOsMAМ15==1
   если (OsMA_1М5<OsMA05) то направлениеOsMAМ5==1
   если (OsMA_1М1<OsMA01) то направлениеOsMAМ1==1

   если(направлениеOsMAH1 == 0 И направлениеOsMAM15== 0 И направлениеOsMAM5 == 0 И направлениеOsMAM1 == 0) то весьOsMA ==0

   если(направлениеOsMAH1 == 1 И направлениеOsMAM15== 1 И направлениеOsMAM5 == 1 И направлениеOsMAM1 == 1) то весьOsMA ==1*/

   buy=0;
   sell=0;
   total=OrdersTotal();
   if(total<1)
     {
      // no opened orders identified
      if(AccountFreeMargin()<(1*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);
        }
/*
Алгоритм открытия Позиции:

если (двойнойКритерийТрендН1 == 0 И двойнойКритерийТочкаВходаМ15 == 0 И двойнойКритерийМоментВходаМ5 == 0 И двойнойКритерийМ1==0 И весьOsMA==0 И весьСтохастик == 0) открыть покупку
если (двойнойКритерийТрендН1 == 1 И двойнойКритерийТочкаВходаМ15 == 1 И двойнойКритерийМоментВходаМ5 == 1 И двойнойКритерийМ1==1 И весьOsMA==1 И весьСтохастик == 1) открыть продажу
*/

      // check for long position (BUY) possibility
      if(buy ==1 && MacdPrevious<0 && MacdCurrent>0)
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
      if(sell ==1 &&iOsMA(NULL,0,12,26,9,PRICE_OPEN,1)>0 && iOsMA(NULL,0,12,26,9,PRICE_OPEN,0)<0)
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
   критерий закрытия (предварительно двойной М15)

   Алгоритм ведения Позиции:
   критерий БезУбытка (взять из Безубытка - реализован в Трейлинг условии реализацией "Посвечный Безубыток")
   критерий ведения (двойной М5)*/

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
