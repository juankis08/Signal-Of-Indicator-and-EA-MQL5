//+------------------------------------------------------------------+
//|                                                 TripleSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| include files                                                    |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
//#include "..\ExpertSignal.mqh"   // The CExpertSignal class is in the file ExpertSignal
#property tester_indicator "Examples\\Custom Moving Average.ex5";
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                			|
//| Title=Signals of indicator 'Triple Signal EMA'                  	|
//| Type=SignalAdvanced                                              |
//| Name=Moving Average                                              |   
//| ShortName=EMA                                                    |
//| Class=TripleSignal                                               |
//| Page=Not needed                                                  |
//| Parameter=FastEMA,int,8,FastEMA Fast Period for EMA              |
//| Parameter=MediumEMA,int,13,MediumEMA Medium Period for EMA       |
//| Parameter=SlowEMA,int,21,SlowEMA Slow Period for  EMA            |
//| Parameter=FastAnchorEMA,int,160,FastAnchorEMA for Anchor Trend   |
//| Parameter=SlowAnchorEMA,int,420,SlowAnchorEMA for Anchor Trend   |
//+------------------------------------------------------------------+
// wizard description 
//+------------------------------------------------------------------+
//| Class TripleSignal.                                        		|
//| Purpose: Class of generator of trade signals based on    			|
//|          the 'Moving Average' indicator.                         |
//| Is derived from the CExpertSignal class.                   	   |
//+------------------------------------------------------------------+
class TripleSignal : public CExpertSignal
 {
 
private:
   CiCustom          CI_EMA_FAST;		// The indicator as an object
   CiCustom          CI_EMA_MEDIUM;		
   CiCustom          CI_EMA_SLOW;
   CiCustom          CI_EMA_FAST_ANCHOR;
   CiCustom          CI_EMA_SLOW_ANCHOR;
   //--- Configurable module parameters
   int               EMA_FAST;          // Fast Period for Exponential MA
   int               EMA_MEDIUM;        // Medium Period for Exponential MA
   int               EMA_SLOW;          // Slow Period for Exponential MA
   int               EMA_FAST_ANCHOR;   // Fast Period for Anchor Trend using Exponential MA
   int               EMA_SLOW_ANCHOR;   // Slow Period for Anchor Trend suing Exponential MA
   
         
   
public:
   //--- Constructor of class
                     TripleSignal(void);
   //--- Destructor of class
                    ~TripleSignal(void);
   //--- Methods for setting
   void              FastEMA(const int value)                 { EMA_FAST=value; }
   void              MediumEMA(const int value)               { EMA_MEDIUM=value; }
   void              SlowEMA(const int value)                 { EMA_SLOW=value; }
   void              FastAnchorEMA(const int value)           { EMA_FAST_ANCHOR=value; }
   void              SlowAnchorEMA(const int value)           { EMA_SLOW_ANCHOR=value; }      
   
   //--- Checking correctness of input data
   bool              ValidationSettings(void);
   //--- Creating indicators and timeseries for the module of signals
   bool              InitIndicators(CIndicators *indicators);
   //--- Access to indicator data
   double            GD_EMA_FAST(const int index)               const { return(CI_EMA_FAST.GetData(0,index)); }
   double            GD_EMA_MEDIUM(const int index)             const { return(CI_EMA_MEDIUM.GetData(0,index)); }
   double            GD_EMA_SLOW(const int index)               const { return(CI_EMA_SLOW.GetData(0,index)); }
   double            GD_EMA_FAST_ANCHOR(const int index)        const { return(CI_EMA_FAST_ANCHOR.GetData(0,index)); }
   double            GD_EMA_SLOW_ANCHOR(const int index)        const { return(CI_EMA_SLOW_ANCHOR.GetData(0,index)); }
	//--- Checking Buy and Sell conditions
   virtual int       LongCondition();
   virtual int       ShortCondition();
   
protected:
   //--- Creating EMA indicators
   bool              Indicator_EMA_FAST(CIndicators *indicators); 
   bool              Indicator_EMA_MEDIUM(CIndicators *indicators);
   bool              Indicator_EMA_SLOW(CIndicators *indicators);
   bool              Indicator_EMA_FAST_ANCHOR(CIndicators *indicators);
   bool              Indicator_EMA_SLOW_ANCHOR(CIndicators *indicators);
  };
  
//+------------------------------------------------------------------+
//|  Constructor                                                     |
//+------------------------------------------------------------------+
TripleSignal::TripleSignal(void) : EMA_FAST(8),               // Deafult value of fast EMA period on M5 chart
                                   EMA_MEDIUM(13),             // Deafult value of medium EMA period on M5 chart
                                   EMA_SLOW(21),               // Deafult value of slow EMA period on M5 chart   
							              EMA_FAST_ANCHOR(160),      // Default value of fast anchor trend
                                   EMA_SLOW_ANCHOR(420)      // Default value of slow anchor trend
                    
  {
  }
//+------------------------------------------------------------------+
//|  Destructor                                                                 |
//+------------------------------------------------------------------+
TripleSignal::~TripleSignal(void)
  {
  }
//+------------------------------------------------------------------+

  
//+------------------------------------------------------------------+
//| Checks input parameters and returns true if everything is OK     |
//+------------------------------------------------------------------+
bool TripleSignal:: ValidationSettings(void)
  {
   //--- Call the base class method
   if(!CExpertSignal::ValidationSettings())  return(false);
   //--- Check periods, number of bars for the calculation of the EMA >=1
   if(EMA_FAST<1 || EMA_MEDIUM<2 || EMA_SLOW<3 || EMA_FAST_ANCHOR<4 || EMA_SLOW_ANCHOR<5)
     {
      PrintFormat("Incorrect value set for one of the periods! FastPeriod=%d, MediumPeriod=%d, SlowPeriod=%d, FastAnchor=%d, SlowAnchor=%d",
                  EMA_FAST,EMA_MEDIUM,EMA_SLOW,EMA_FAST_ANCHOR,EMA_SLOW_ANCHOR);
      return false;
     }
//--- Slow EMA period must be greater that the fast EMA period
   if(EMA_FAST > EMA_MEDIUM )
     {
      PrintFormat("FastPeriod=%d must be smaller than MediumPeriod=%d!"
                  ,EMA_FAST,EMA_MEDIUM);
      return false;
     }
  if( EMA_MEDIUM > EMA_SLOW)
     {
      PrintFormat("MediumPeriod=%d must be smaller than SlowPeriod=%d!"
                  ,EMA_MEDIUM,EMA_SLOW);
      return false;
     }
		if(EMA_SLOW > EMA_FAST_ANCHOR )
     {
      PrintFormat("FastAnchor=%d must be greater than SlowPeriod=%d!"
                  ,EMA_FAST_ANCHOR,EMA_SLOW);
      return false;
     }
    if(EMA_FAST_ANCHOR > EMA_SLOW_ANCHOR)
      {
      PrintFormat("SlowAnchor=%d must be greater than FastAnchor=%d!"
                  ,EMA_SLOW_ANCHOR,EMA_FAST_ANCHOR);
      return false;
     }
//--- All checks are completed, everything is ok
   return true;
  }  
  
bool TripleSignal::InitIndicators(CIndicators* indicators)
   {
    
//--- Standard check of the collection of indicators for NULL
   if(indicators==NULL)                           return(false);
//--- Initializing indicators and timeseries in additional filters
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- Creating our EMA indicators

   if(!Indicator_EMA_FAST(indicators))return(false); 
   if(!Indicator_EMA_MEDIUM(indicators))return(false);
   if(!Indicator_EMA_SLOW(indicators))return(false);
   if(!Indicator_EMA_FAST_ANCHOR(indicators))return(false);
   if(!Indicator_EMA_SLOW_ANCHOR(indicators))return(false);
   
//--- Reached this part, so the function was successful, return true
   return(true);
   }
   
//+------------------------------------------------------------------+
//| Creates the " EMA with Period 8 for M5 chart" indicator                                  |
//+------------------------------------------------------------------+
bool TripleSignal::Indicator_EMA_FAST(CIndicators *indicators)
  {
     
//--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(CI_EMA_FAST)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast EMA");
      return(false);
     }
//--- Setting parameters of the fast EMA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=EMA_FAST;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=MODE_EMA;      // Moving Averaging method
  
//--- Object initialization  
   if(!CI_EMA_FAST.Create(Symbol(),Period(),IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the fast EMA");
      return(false);
     }
//--- Number of buffers
   if(!CI_EMA_FAST.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the " EMA with Period 8 for M5 chart" indicator          |
//+------------------------------------------------------------------+
bool TripleSignal::Indicator_EMA_MEDIUM(CIndicators *indicators)
  {
   //--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(CI_EMA_MEDIUM)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast EMA");
      return(false);
     }
//--- Setting parameters of the fast EMA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=EMA_MEDIUM;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=MODE_EMA;      // Moving Averaging method
  
//--- Object initialization  
   if(!CI_EMA_MEDIUM.Create(Symbol(),Period(),IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the fast EMA");
      return(false);
     }
//--- Number of buffers
   if(!CI_EMA_MEDIUM.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
   
  }
//+------------------------------------------------------------------+
//| Creates the " EMA with Period 8 for M5 chart" indicator                                  |
//+------------------------------------------------------------------+  
bool TripleSignal::Indicator_EMA_SLOW(CIndicators *indicators)
  {   
   //--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(CI_EMA_SLOW)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast EMA");
      return(false);
     }
//--- Setting parameters of the fast EMA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=EMA_SLOW;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;            // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=MODE_EMA;      // Moving Averaging method
 
//--- Object initialization  
   if(!CI_EMA_SLOW.Create(Symbol(),Period(),IND_CUSTOM,4,parameters)) 
     {
      printf(__FUNCTION__+": Error initializing the object of the fast EMA");
      return(false);
     }
//--- Number of buffers
   if(!CI_EMA_SLOW.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
  
  
  
  
bool TripleSignal::Indicator_EMA_FAST_ANCHOR(CIndicators *indicators)
  {   
   //--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(CI_EMA_FAST_ANCHOR)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast EMA");
      return(false);
     }
//--- Setting parameters of the fast EMA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=EMA_FAST_ANCHOR;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;            // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=MODE_EMA;      // Moving Averaging method
 
//--- Object initialization  
   if(!CI_EMA_FAST_ANCHOR.Create(Symbol(),Period(),IND_CUSTOM,4,parameters)) 
     {
      printf(__FUNCTION__+": Error initializing the object of the fast EMA");
      return(false);
     }
//--- Number of buffers
   if(!CI_EMA_FAST_ANCHOR.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }  
  
  
  
  
  
bool TripleSignal::Indicator_EMA_SLOW_ANCHOR(CIndicators *indicators)
  {   
   //--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(CI_EMA_SLOW_ANCHOR)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast EMA");
      return(false);
     }
//--- Setting parameters of the fast EMA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Custom Moving Average.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=EMA_SLOW_ANCHOR;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;            // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=MODE_EMA;      // Moving Averaging method
 
//--- Object initialization  
   if(!CI_EMA_SLOW_ANCHOR.Create(Symbol(),Period(),IND_CUSTOM,4,parameters)) 
     {
      printf(__FUNCTION__+": Error initializing the object of the fast EMA");
      return(false);
     }
//--- Number of buffers
   if(!CI_EMA_SLOW_ANCHOR.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }  
  
  
  
  //+------------------------------------------------------------------+
//| Returns the strength of the buy signal                           |
//+------------------------------------------------------------------+
int TripleSignal::LongCondition()
  {
   int signal=0;
   int idx=StartIndex();
   double CurrentPrice = iClose(Symbol(),Period(),0);
   double Signal_EMA_FAST=GD_EMA_FAST(0);
   double Signal_EMA_MEDIUM=GD_EMA_MEDIUM(0);
   double Signal_EMA_SLOW=GD_EMA_SLOW(0);
   double Signal_EMA_FAST_ANCHOR=GD_EMA_FAST_ANCHOR(0);
   double Signal_EMA_SLOW_ANCHOR=GD_EMA_SLOW_ANCHOR(0);
   
   if(Signal_EMA_SLOW_ANCHOR<Signal_EMA_FAST_ANCHOR && Signal_EMA_FAST_ANCHOR < CurrentPrice )
   {
      if(Signal_EMA_SLOW<Signal_EMA_MEDIUM && Signal_EMA_MEDIUM<Signal_EMA_FAST && CurrentPrice < Signal_EMA_FAST && CurrentPrice > Signal_EMA_MEDIUM )
      {
      signal = 100;
      }
   }
//--- Return the signal value
   return(signal);
  }
//+------------------------------------------------------------------+
//| Returns the strength of the sell signal                          |
//+------------------------------------------------------------------+
int TripleSignal::ShortCondition()
  {
  
   int signal=0;
   int idx=StartIndex();
   double CurrentPrice = iClose(Symbol(),Period(),0);
   double Signal_EMA_FAST=GD_EMA_FAST(0);
   double Signal_EMA_MEDIUM=GD_EMA_MEDIUM(0);
   double Signal_EMA_SLOW=GD_EMA_SLOW(0);
   double Signal_EMA_FAST_ANCHOR=GD_EMA_FAST_ANCHOR(0);
   double Signal_EMA_SLOW_ANCHOR=GD_EMA_SLOW_ANCHOR(0);
   
   
  if(Signal_EMA_SLOW_ANCHOR>Signal_EMA_FAST_ANCHOR && Signal_EMA_FAST_ANCHOR > CurrentPrice )
   {
      if(Signal_EMA_SLOW>Signal_EMA_MEDIUM && Signal_EMA_MEDIUM>Signal_EMA_FAST && CurrentPrice > Signal_EMA_FAST && CurrentPrice < Signal_EMA_MEDIUM )
      {
      signal = 100;
      }
   }
//--- Return the signal value
   return(signal);
  }
   

//+------------------------------------------------------------------+
