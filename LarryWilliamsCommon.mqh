//+------------------------------------------------------------------+
//| LarryWilliamsCommon.mqh                                           |
//| Common constants and helper functions for Larry Williams EA      |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, Copilot"
#property link      "https://github.com/augustownt"

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define EA_NAME "Larry Williams Setup Max Min"
#define EA_VERSION "1.0"

// Color constants for MA3
#define COLOR_BULLISH clrLime
#define COLOR_BEARISH clrRed
#define COLOR_NEUTRAL clrGray

// Visual element constants
#define ARROW_BUY 233
#define ARROW_SELL 234
#define ARROW_TREND_CHANGE 251

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get symbol point value with proper scaling                       |
//+------------------------------------------------------------------+
double GetSymbolPoint()
{
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    
    // Adjust for 5-digit brokers
    if(digits == 5 || digits == 3)
        point *= 10;
        
    return point;
}

//+------------------------------------------------------------------+
//| Normalize lot size according to symbol specifications            |
//+------------------------------------------------------------------+
double NormalizeLotSize(double lots)
{
    double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    if(lots < min_lot) lots = min_lot;
    if(lots > max_lot) lots = max_lot;
    
    // Round to lot step
    lots = NormalizeDouble(lots / lot_step, 0) * lot_step;
    
    return lots;
}

//+------------------------------------------------------------------+
//| Check if market is open for trading                              |
//+------------------------------------------------------------------+
bool IsMarketOpen()
{
    return SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
}

//+------------------------------------------------------------------+
//| Get formatted timestamp for object names                         |
//+------------------------------------------------------------------+
string GetTimeStamp()
{
    return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

//+------------------------------------------------------------------+
//| Calculate distance for visual elements placement                  |
//+------------------------------------------------------------------+
double GetVisualDistance()
{
    return GetSymbolPoint() * 20;
}