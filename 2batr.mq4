/*
   2BAtr_test EA by jim syyap

   TODO
   - 09242014 - WORKS: open/close trades on windows mt4 demo
        changed atr 14 > 21 to minimize headfakes
    - add time() filter to open trade
*/


#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "jim syyap FX"
#property link  "http://www.jimsyyapfx.blogspot.com"



extern int MagicNumber = 0;
extern bool SignalMail = false;
extern bool EachTickMode = true;
extern double Lots = 0.01;
extern int Slippage = 3;
extern bool UseStopLoss = false;
extern int StopLoss = 100;
extern bool UseTakeProfit = false;
extern int TakeProfit = 6000;
extern bool UseTrailingStop = true;
extern int TrailingStop = 100;

int BarCount;
int Current;
bool TickCheck = false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
    BarCount = Bars;

    if ( EachTickMode ) Current = 0; else Current = 1;

    return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
    return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {
    int Order = SIGNAL_NONE;
    int Total, Ticket;
    double StopLossLevel, TakeProfitLevel;

    if ( EachTickMode && Bars != BarCount ) TickCheck = false;
    Total = OrdersTotal();
    Order = SIGNAL_NONE;

    //--- variables
    double atr_0 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 0);
    double atr_1 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 1);
    double atr_2 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 2);
    double atr_3 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 3);
    double atr_4 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 4);
    double atr_5 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 5);
    double atr_6 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 6);
    double atr_7 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 7);
    double atr_8 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 8);
    double atr_9 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 9);
    double atr_10 = iCustom(NULL, 0, "js_Entry1", 2000, 21.0, 2.0, true, true, false, 0, MODE_MAIN, 10);


    //Check position
    bool IsTrade = false;

    for (int i = 0; i < Total; i ++) {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol()) {
            IsTrade = true;
            if(OrderType() == OP_BUY) {
                //Close

                //+------------------------------------------------------------------+
                //| Signal Begin(Exit Buy)                                           |
                //+------------------------------------------------------------------+

                if (Low[1] > atr_1 && Low[0] < atr_0) 
                {
                    Order = SIGNAL_CLOSEBUY;
                }

                //+------------------------------------------------------------------+
                //| Signal End(Exit Buy)                                             |
                //+------------------------------------------------------------------+

                if ( Order == SIGNAL_CLOSEBUY && 
                        (( EachTickMode && !TickCheck ) || 
                         ( !EachTickMode && 
                           ( Bars != BarCount )))) {
                    OrderClose( OrderTicket(), 
                            OrderLots(), 
                            Bid, Slippage, MediumSeaGreen );
                    if (SignalMail) SendMail("Nan", "");
                    if (!EachTickMode) BarCount = Bars;
                    IsTrade = false;
                    continue;
                }
                //Trailing stop
                if(UseTrailingStop && TrailingStop > 0) {                 
                    if(Bid - OrderOpenPrice() > Point * TrailingStop) {
                        if(OrderStopLoss() < Bid - Point * TrailingStop) {
                            OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                            if (!EachTickMode) BarCount = Bars;
                            continue;
                        }
                    }
                }
            } else {
                //Close

                //+------------------------------------------------------------------+
                //| Signal Begin(Exit Sell)                                          |
                //+------------------------------------------------------------------+

                if (High[1] < atr_1 && High[0] > atr_0)
                {
                    Order = SIGNAL_CLOSESELL;
                }

                //+------------------------------------------------------------------+
                //| Signal End(Exit Sell)                                            |
                //+------------------------------------------------------------------+

                if (Order == SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
                    OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
                    if (SignalMail) SendMail("Nan", "");
                    if (!EachTickMode) BarCount = Bars;
                    IsTrade = false;
                    continue;
                }
                //Trailing stop
                if(UseTrailingStop && TrailingStop > 0) {                 
                    if((OrderOpenPrice() - Ask) > (Point * TrailingStop)) {
                        if((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0)) {
                            OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                            if (!EachTickMode) BarCount = Bars;
                            continue;
                        }
                    }
                }
            }
        }
    }

    //+------------------------------------------------------------------+
    //| Signal Begin(Entry)                                              |
    //+------------------------------------------------------------------+

    // Signal OPEN LONG
    // while (time() > 11:00 && time() < 20:00)
    if (
        High[3] < atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
        && High[0] > High[1] && High[2] < High[1]
       )
    {
        Order = SIGNAL_BUY;
    }
    else if (
            High[3] < atr_3 && High[2] > atr_2 && High[1] > atr_1 
            && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        Order = SIGNAL_BUY;
    }

    //candle minus 2
    else if (
            High[4] < atr_4 && High[3] > atr_3 && High[2] > atr_2 
            && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[4] < atr_4 && High[3] > atr_3 && High[2] > atr_2 
            && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    //candle minus 3
    else if (
            High[5] < atr_5 && High[4] > atr_4 && High[3] > atr_3 && High[2] > atr_2 
            && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )   
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[5] < atr_5 && High[4] > atr_4 && High[3] > atr_3 
            && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    //candle minus 4
    else if (
            High[6] < atr_6 && High[5] > atr_5 && High[4] > atr_4 && High[3] < atr_3 
            && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )   
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[6] < atr_6 && High[5] > atr_5 && High[4] < atr_4 && High[3] < atr_3 
            && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    //candle minus 5
    else if (
            High[7] < atr_7 && High[6] > atr_6 && High[5] < atr_5 && High[4] < atr_4 && High[3] < atr_3 
            && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )   
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[7] < atr_7 && High[6] > atr_6 && High[5] < atr_5 && High[4] < atr_4 && High[3] < atr_3 
            && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    //candle minus 6
    else if (
            High[8] < atr_8 && High[7] > atr_7 && High[6] < atr_6 && High[5] < atr_5 && High[4] < atr_4 
            && High[3] < atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )   
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[8] < atr_8 && High[7] > atr_7 && High[6] > atr_6 && High[5] > atr_5 && High[4] > atr_4 
            && High[3] > atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    //candle minus 7
    else if (
            High[9] < atr_9 && High[8] > atr_8 && High[7] > atr_7 && High[6] > atr_6 && High[5] > atr_5 
            && High[4] > atr_4 && High[3] > atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )   
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[9] < atr_9 && High[8] > atr_8 && High[7] > atr_7 && High[6] > atr_6 && High[5] > atr_5 
            && High[4] > atr_4 && High[3] > atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    //candle minus 8
    else if (
            High[10] < atr_10 && High[9] > atr_9 && High[8] > atr_8 && High[7] > atr_7 && High[6] > atr_6 
            && High[5] > atr_5 && High[4] > atr_4 && High[3] > atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[1] && High[2] < High[1]
            )
    {
        //---- open a BUY position
        Order = SIGNAL_BUY;
    }

    else if (
            High[10] < atr_10 && High[9] > atr_9 && High[8] > atr_8 && High[7] > atr_7 && High[6] > atr_6 
            && High[5] > atr_5 && High[4] > atr_4 && High[3] > atr_3 && High[2] > atr_2 && High[1] > atr_1 && High[0] > atr_0
            && High[0] > High[2] && High[1] < High[2]
            )
    {
        Order = SIGNAL_BUY;
    }

    // Signal Open SHORT
    // while (time() > 11:00 && time() < 20:00)
    if ( 
        Low[3] > atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
        && Low[0] < Low[1] && Low[2] < Low[1]
       )
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (  
            Low[3] > atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] < Low[2]
            )
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 2
    // 4 candles ago, low is above atr. 3 candles ago, low is below atr. wait for 2b-entry.
    else if (
            Low[4] > atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] > Low[2]

            )   
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[4] > atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] > Low[2]
            )

    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 3
    else if (
            Low[5] > atr_5 && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2
            && Low[1] < atr_1 && Low[0] < atr_0 
            && Low[0] < Low[2] && Low[1] > Low[2]
            )   
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[5] > atr_5 && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 
            && Low[1] < atr_1 && Low[0] < atr_0 
            && Low[0] < Low[1] && Low[2] > Low[1]
            )
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 4
    else if (
            Low[6] > atr_6 && Low[5] < atr_5 && Low[4] < atr_4 && Low[3] < atr_3 
            && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0 
            && Low[0] < Low[2] && Low[1] > Low[2]
            )   
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[6] > atr_6 && Low[5] < atr_5 && Low[4] < atr_4 && Low[3] < atr_3 
            && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0 
            && Low[0] < Low[1] && Low[2] > Low[1])
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 5
    else if (
            Low[7] > atr_7 && Low[6] < atr_6 && Low[5] < atr_5 && Low[4] < atr_4 
            && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] > Low[2]
            )   
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[7] > atr_7 && Low[6] < atr_6 && Low[5] < atr_5 && Low[4] < atr_4 
            && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[1] && Low[2] > Low[1])
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 6
    else if (
            Low[8] > atr_8 && Low[7] < atr_7 && Low[6] < atr_6 && Low[5] < atr_5 
            && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] > Low[2]
            )   
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[8] > atr_8 && Low[7] < atr_7 && Low[6] < atr_6 && Low[5] < atr_5 
            && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[1] && Low[2] > Low[1]
            )
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 7
    else if (
            Low[9] > atr_9 && Low[8] < atr_8 && Low[7] < atr_7 && Low[6] < atr_6 && Low[5] < atr_5 
            && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] > Low[2]
            )   
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[9] > atr_9 && Low[8] < atr_8 && Low[7] < atr_7 && Low[6] < atr_6 && Low[5] < atr_5 
            && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[1] && Low[2] > Low[1]
            )
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    //candle minus 8
    else if (
            Low[10] > atr_10 && Low[9] < atr_9 && Low[8] < atr_8 && Low[7] < atr_7 && Low[6] < atr_6 && Low[5] < atr_5 
            && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[2] && Low[1] > Low[2]
            )
    {
        //---- open a SELL position
        Order = SIGNAL_SELL;
    }

    else if (
            Low[10] > atr_10 && Low[9] < atr_9 && Low[8] < atr_8 && Low[7] < atr_7 && Low[6] < atr_6 && Low[5] < atr_5 
            && Low[4] < atr_4 && Low[3] < atr_3 && Low[2] < atr_2 && Low[1] < atr_1 && Low[0] < atr_0
            && Low[0] < Low[1] && Low[2] > Low[1]
            )
    {

        Order = SIGNAL_SELL;
    }

    //+------------------------------------------------------------------+
    //| Signal End                                                       |
    //+------------------------------------------------------------------+

    //Buy
    if (Order == SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
        if(!IsTrade) {
            //Check free margin
            if (AccountFreeMargin() < (1000 * Lots)) {
                Print("Nan", AccountFreeMargin());
                return(0);
            }

            if (UseStopLoss) StopLossLevel = Ask - StopLoss * Point; else StopLossLevel = 0.0;
            if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

            Ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, StopLossLevel, TakeProfitLevel," ", MagicNumber, 0, DodgerBlue);
            if(Ticket > 0) {
                if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
                    Print("Nan", OrderOpenPrice());
                    if (SignalMail) SendMail("Nan", "");
                } else {
                    Print("Nan", GetLastError());
                }
            }
            if (EachTickMode) TickCheck = true;
            if (!EachTickMode) BarCount = Bars;
            return(0);
        }
    }

    //Sell
    if (Order == SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars != BarCount)))) {
        if(!IsTrade) {
            //Check free margin
            if (AccountFreeMargin() < (1000 * Lots)) {
                Print("Nan", AccountFreeMargin());
                return(0);
            }

            if (UseStopLoss) StopLossLevel = Bid + StopLoss * Point; else StopLossLevel = 0.0;
            if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

            Ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, StopLossLevel, TakeProfitLevel, " ", MagicNumber, 0, DeepPink);
            if(Ticket > 0) {
                if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
                    Print("Nan", OrderOpenPrice());
                    if (SignalMail) SendMail("Nan", "");
                } else {
                    Print("Nan", GetLastError());
                }
            }
            if (EachTickMode) TickCheck = true;
            if (!EachTickMode) BarCount = Bars;
            return(0);
        }
    }

    if (!EachTickMode) BarCount = Bars;

    return(0);
}
//+------------------------------------------------------------------+
/*
   - add these to find obos on x (nbr)
        findFractal gives the price of the fractal depending on up/down 
        fractal, timeframe and how many fractals back you want to look at 
        (given by nbr, where nbr = 0 gives the last fractal):

        double findFractal(int nbr, int mode, int timeframe)
        {
           int i=3, n;
           for(n=0;n<=nbr;n++)
           {
              while(iFractals(Symbol(),timeframe,mode,i) == 0)
                 i++;
              if(n<nbr)
                 i++;
           }
           return(iFractals(Symbol(),timeframe,mode,i));
        }

        if( findFractal(1, MODE_UPPER, *timeframe of your choice*) 
            < findFractal(0, MODE_UPPER, *timeframe of your choice*) )
        {
           ***code to close order***
        }
        */
