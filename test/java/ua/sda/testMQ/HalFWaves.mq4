//+------------------------------------------------------------------+
//|                                                    HalfWaves.mq4 |
//|                                                    Vasiliy Kulik |
//|                                                       alpari.com |
//+------------------------------------------------------------------+
#property copyright "Vasiliy Kulik"
#property link      ".com"
#property version   "1.00"
extern double TakeProfit = 1200;
extern double StopLoss = 10000;
extern double Lots = 0.01;
extern double TrailingStop = 10000;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPerson
  {
protected:
   string            m_name;                     // имя
public:
   void              SetName(string n){m_name=n;}// устанавливает имя
   string            GetName(){return (m_name);} // возвращает имя
  };
int start()
  {
  if (CPerson.GetName)
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
   Macd303,
   StdDev1,StdDev2,
   bbu,bbu1,
   bbd,bbd1,
   bbu30,bbu301,
   bbd30,bbd301,
   StdDev0;
   int
   cnt,
   ticket,
   total,
   buy,
   sell;
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
// to simplify the coding and speed up access
// data are put into internal variables
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
   bbu = iBands(NULL,PERIOD_M5,20,2,0,PRICE_LOW,MODE_UPPER,0);
   bbd = iBands(NULL,PERIOD_M5,20,2,0,PRICE_HIGH,MODE_LOWER,0);
   bbu1 = iBands(NULL,PERIOD_M5,20,2,0,PRICE_LOW,MODE_UPPER,1);
   bbd1 = iBands(NULL,PERIOD_M5,20,2,0,PRICE_HIGH,MODE_LOWER,1);
   StdDev0=iStdDev(NULL,0,20,0,MODE_SMMA,PRICE_OPEN,0);
   StdDev1=iStdDev(NULL,0,20,0,MODE_SMMA,PRICE_OPEN,1);
   StdDev2=iStdDev(NULL,0,20,0,MODE_SMMA,PRICE_OPEN,2);
   buy=1;
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
      // check for long position (BUY) possibility
//+------------------------------------------------------------------+
//|                                                                   |
//+------------------------------------------------------------------+

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
      if(sell ==1 && MacdPrevious>0 && MacdCurrent<0)
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
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
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
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
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