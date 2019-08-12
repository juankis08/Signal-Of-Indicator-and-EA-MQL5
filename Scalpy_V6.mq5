//+------------------------------------------------------------------+
//|                                                    Scalpy_V6.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\TripleSignal.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title            ="Scalpy_V6"; // Document name
ulong        Expert_MagicNumber      =20341;       // 
bool         Expert_EveryTick        =false;       // 
//--- inputs for main signal
input int    Signal_ThresholdOpen    =10;          // Signal threshold value to open [0...100]
input int    Signal_ThresholdClose   =10;          // Signal threshold value to close [0...100]
input double Signal_PriceLevel       =0.0;         // Price level to execute a deal
input double Signal_StopLevel        =50.0;        // Stop Loss level (in points)
input double Signal_TakeLevel        =50.0;        // Take Profit level (in points)
input int    Signal_Expiration       =4;           // Expiration of pending orders (in bars)
input int    Signal_EMA_FastEMA      =8;           // Moving Average(8,13,21,160,...) FastEMA Fast Period for EMA
input int    Signal_EMA_MediumEMA    =13;          // Moving Average(8,13,21,160,...) MediumEMA Medium Period for EMA
input int    Signal_EMA_SlowEMA      =21;          // Moving Average(8,13,21,160,...) SlowEMA Slow Period for  EMA
input int    Signal_EMA_FastAnchorEMA=160;         // Moving Average(8,13,21,160,...) FastAnchorEMA for Anchor Trend
input int    Signal_EMA_SlowAnchorEMA=420;         // Moving Average(8,13,21,160,...) SlowAnchorEMA for Anchor Trend
input double Signal_EMA_Weight       =1.0;         // Moving Average(8,13,21,160,...) Weight [0...1.0]
//--- inputs for money
input double Money_FixLot_Percent    =10.0;        // Percent
input double Money_FixLot_Lots       =0.1;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter TripleSignal
   TripleSignal *filter0=new TripleSignal;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.FastEMA(Signal_EMA_FastEMA);
   filter0.MediumEMA(Signal_EMA_MediumEMA);
   filter0.SlowEMA(Signal_EMA_SlowEMA);
   filter0.FastAnchorEMA(Signal_EMA_FastAnchorEMA);
   filter0.SlowAnchorEMA(Signal_EMA_SlowAnchorEMA);
   filter0.Weight(Signal_EMA_Weight);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
