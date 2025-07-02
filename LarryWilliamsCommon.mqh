//+------------------------------------------------------------------+
//|                                        LarryWilliamsCommon.mqh |
//|                            Common functions and structures      |
//|                                                                  |
//+------------------------------------------------------------------+

#ifndef LARRY_WILLIAMS_COMMON_MQH
#define LARRY_WILLIAMS_COMMON_MQH

//--- Constants for the strategy
#define LARRY_WILLIAMS_MAGIC 12345
#define DEFAULT_SMA1_PERIOD 3
#define DEFAULT_SMA2_PERIOD 3  
#define DEFAULT_SMA3_PERIOD 21
#define DEFAULT_LOT_SIZE 0.01

//--- Signal types
enum ENUM_LARRY_SIGNAL
{
   SIGNAL_NONE = 0,        // No signal
   SIGNAL_BUY = 1,         // Buy signal
   SIGNAL_SELL = -1,       // Sell signal
   SIGNAL_EXIT = 2         // Exit signal (trend change)
};

//--- Trend states
enum ENUM_TREND_STATE
{
   TREND_NEUTRAL = 0,      // Neutral/transition
   TREND_BULLISH = 1,      // Bullish trend
   TREND_BEARISH = -1      // Bearish trend
};

//--- Structure for signal data
struct SLarrySignalData
{
   ENUM_LARRY_SIGNAL signal_type;
   datetime signal_time;
   double signal_price;
   ENUM_TREND_STATE trend_state;
   bool trend_changed;
};

//--- Structure for moving averages data
struct SMovingAveragesData
{
   double sma_high_current;
   double sma_high_previous;
   double sma_low_current;
   double sma_low_previous;
   double sma_close_current;
   double sma_close_previous;
};

//+------------------------------------------------------------------+
//| Check if trend is bullish based on MA21                         |
//+------------------------------------------------------------------+
bool IsTrendBullish(double ma_current, double ma_previous)
{
   return (ma_current > ma_previous);
}

//+------------------------------------------------------------------+
//| Check if trend is bearish based on MA21                         |
//+------------------------------------------------------------------+
bool IsTrendBearish(double ma_current, double ma_previous)
{
   return (ma_current < ma_previous);
}

//+------------------------------------------------------------------+
//| Get trend state                                                  |
//+------------------------------------------------------------------+
ENUM_TREND_STATE GetTrendState(double ma_current, double ma_previous)
{
   if(IsTrendBullish(ma_current, ma_previous))
      return TREND_BULLISH;
   else if(IsTrendBearish(ma_current, ma_previous))
      return TREND_BEARISH;
   else
      return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| Check for buy signal                                             |
//+------------------------------------------------------------------+
bool CheckBuySignal(const SMovingAveragesData &ma_data, double current_price, double previous_price)
{
   //--- Buy when MA21 is bullish and price crosses above MA2 (low)
   bool trend_bullish = IsTrendBullish(ma_data.sma_close_current, ma_data.sma_close_previous);
   bool price_cross_up = (current_price > ma_data.sma_low_current && previous_price <= ma_data.sma_low_previous);
   
   return (trend_bullish && price_cross_up);
}

//+------------------------------------------------------------------+
//| Check for sell signal                                            |
//+------------------------------------------------------------------+
bool CheckSellSignal(const SMovingAveragesData &ma_data, double current_price, double previous_price)
{
   //--- Sell when MA21 is bearish and price crosses below MA1 (high)
   bool trend_bearish = IsTrendBearish(ma_data.sma_close_current, ma_data.sma_close_previous);
   bool price_cross_down = (current_price < ma_data.sma_high_current && previous_price >= ma_data.sma_high_previous);
   
   return (trend_bearish && price_cross_down);
}

//+------------------------------------------------------------------+
//| Check for trend change (exit signal)                            |
//+------------------------------------------------------------------+
bool CheckTrendChange(ENUM_TREND_STATE current_trend, ENUM_TREND_STATE previous_trend)
{
   //--- Trend change occurs when switching from bullish to bearish or vice versa
   return ((previous_trend == TREND_BULLISH && current_trend == TREND_BEARISH) ||
           (previous_trend == TREND_BEARISH && current_trend == TREND_BULLISH));
}

//+------------------------------------------------------------------+
//| Get color based on trend state                                  |
//+------------------------------------------------------------------+
color GetTrendColor(ENUM_TREND_STATE trend_state)
{
   switch(trend_state)
   {
      case TREND_BULLISH: return clrLime;
      case TREND_BEARISH: return clrRed;
      default: return clrGray;
   }
}

//+------------------------------------------------------------------+
//| Validate lot size                                                |
//+------------------------------------------------------------------+
double ValidateLotSize(double lot_size)
{
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   //--- Normalize lot size
   if(lot_size < min_lot)
      lot_size = min_lot;
   if(lot_size > max_lot)
      lot_size = max_lot;
   
   //--- Round to lot step
   lot_size = NormalizeDouble(lot_size / lot_step, 0) * lot_step;
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| Get arrow code for signal type                                  |
//+------------------------------------------------------------------+
int GetSignalArrowCode(ENUM_LARRY_SIGNAL signal_type)
{
   switch(signal_type)
   {
      case SIGNAL_BUY: return 233;    // Up triangle
      case SIGNAL_SELL: return 234;   // Down triangle
      case SIGNAL_EXIT: return 251;   // X mark
      default: return 0;
   }
}

//+------------------------------------------------------------------+
//| Get color for signal type                                       |
//+------------------------------------------------------------------+
color GetSignalColor(ENUM_LARRY_SIGNAL signal_type)
{
   switch(signal_type)
   {
      case SIGNAL_BUY: return clrBlue;
      case SIGNAL_SELL: return clrRed;
      case SIGNAL_EXIT: return clrMagenta;
      default: return clrGray;
   }
}

//+------------------------------------------------------------------+
//| Format signal description                                        |
//+------------------------------------------------------------------+
string GetSignalDescription(ENUM_LARRY_SIGNAL signal_type)
{
   switch(signal_type)
   {
      case SIGNAL_BUY: return "Buy Signal";
      case SIGNAL_SELL: return "Sell Signal";
      case SIGNAL_EXIT: return "Exit Signal (Trend Change)";
      default: return "No Signal";
   }
}

#endif // LARRY_WILLIAMS_COMMON_MQH
//+------------------------------------------------------------------+