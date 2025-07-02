//+------------------------------------------------------------------+
//| Larry Williams Setup Max Min EA                                    |
//| Developed by: Copilot for augustownt                              |
//| Version: 1.0                                                       |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, Copilot"
#property link      "https://github.com/augustownt"
#property version   "1.0"
#property strict

#include "LarryWilliamsCommon.mqh"

// Input Parameters
input int      MA1_Period = 3;         // MA1 Period (High)
input int      MA2_Period = 3;         // MA2 Period (Low)
input int      MA3_Period = 21;        // MA3 Period (Close)
input double   Lot_Size = 0.01;        // Fixed Lot Size
input int      Magic_Number = 123456;  // EA Magic Number
input bool     Show_Visuals = true;    // Show visual elements on chart

// Global Variables
double ma1[], ma2[], ma3[];
int ma1_handle, ma2_handle, ma3_handle;
bool isLongPosition = false;
bool isShortPosition = false;
color ma3_color = clrGray;
color ma3_color_prev = clrGray;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize MA handles
    ma1_handle = iMA(_Symbol, PERIOD_CURRENT, MA1_Period, 0, MODE_SMA, PRICE_HIGH);
    ma2_handle = iMA(_Symbol, PERIOD_CURRENT, MA2_Period, 0, MODE_SMA, PRICE_LOW);
    ma3_handle = iMA(_Symbol, PERIOD_CURRENT, MA3_Period, 0, MODE_SMA, PRICE_CLOSE);
    
    // Check if handles are valid
    if(ma1_handle == INVALID_HANDLE || ma2_handle == INVALID_HANDLE || ma3_handle == INVALID_HANDLE)
    {
        Print("Error creating MA handles");
        return(INIT_FAILED);
    }
    
    // Initialize arrays
    ArraySetAsSeries(ma1, true);
    ArraySetAsSeries(ma2, true);
    ArraySetAsSeries(ma3, true);
    
    Print("Larry Williams Setup Max Min EA initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up
    IndicatorRelease(ma1_handle);
    IndicatorRelease(ma2_handle);
    IndicatorRelease(ma3_handle);
    
    // Clean up chart objects
    ObjectsDeleteAll(0, "MA1");
    ObjectsDeleteAll(0, "MA2");
    ObjectsDeleteAll(0, "MA3");
    ObjectsDeleteAll(0, "BuySignal");
    ObjectsDeleteAll(0, "SellSignal");
    ObjectsDeleteAll(0, "TrendChange");
    
    Print("Larry Williams Setup Max Min EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
    // Copy MA values
    if(CopyBuffer(ma1_handle, 0, 0, 3, ma1) <= 0 ||
       CopyBuffer(ma2_handle, 0, 0, 3, ma2) <= 0 ||
       CopyBuffer(ma3_handle, 0, 0, 3, ma3) <= 0)
    {
        Print("Error copying MA buffers");
        return;
    }
    
    // Store previous MA3 color
    ma3_color_prev = ma3_color;
    
    // Update MA3 color
    UpdateMA3Color();
    
    // Check for trend change (Purple X)
    if(IsTrendChange())
    {
        CloseAllPositions();
        return;
    }
    
    // Trading logic
    if(!HasOpenPosition())
    {
        // Check for buy signal
        if(IsBuySignal())
        {
            OpenBuyPosition();
        }
        // Check for sell signal
        else if(IsSellSignal())
        {
            OpenSellPosition();
        }
    }
    else
    {
        // Check exit conditions
        CheckExitConditions();
    }
    
    // Draw visual elements
    DrawVisualElements();
}

//+------------------------------------------------------------------+
//| Check if there's an open position                                 |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(PositionSelectByIndex(i))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
               PositionGetInteger(POSITION_MAGIC) == Magic_Number)
                return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Update MA3 Color based on position                                |
//+------------------------------------------------------------------+
void UpdateMA3Color()
{
    if(ma3[0] < ma2[0] && ma3[0] < ma1[0])
        ma3_color = COLOR_BULLISH;  // Green
    else if(ma3[0] > ma2[0] && ma3[0] > ma1[0])
        ma3_color = COLOR_BEARISH;   // Red
    else
        ma3_color = COLOR_NEUTRAL;  // Gray
}

//+------------------------------------------------------------------+
//| Check for buy signal                                              |
//+------------------------------------------------------------------+
bool IsBuySignal()
{
    double close_prev = iClose(_Symbol, PERIOD_CURRENT, 1);
    double close_curr = iClose(_Symbol, PERIOD_CURRENT, 0);
    
    return (ma3_color == COLOR_BULLISH && 
            close_prev <= ma2[1] && 
            close_curr > ma2[0]);
}

//+------------------------------------------------------------------+
//| Check for sell signal                                             |
//+------------------------------------------------------------------+
bool IsSellSignal()
{
    double close_prev = iClose(_Symbol, PERIOD_CURRENT, 1);
    double close_curr = iClose(_Symbol, PERIOD_CURRENT, 0);
    
    return (ma3_color == COLOR_BEARISH && 
            close_prev >= ma1[1] && 
            close_curr < ma1[0]);
}

//+------------------------------------------------------------------+
//| Check for trend change                                            |
//+------------------------------------------------------------------+
bool IsTrendChange()
{
    return (ma3_color != ma3_color_prev);
}

//+------------------------------------------------------------------+
//| Open buy position                                                 |
//+------------------------------------------------------------------+
void OpenBuyPosition()
{
    if(!IsMarketOpen())
    {
        Print("Market is closed, cannot open buy position");
        return;
    }
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    double normalized_lot = NormalizeLotSize(Lot_Size);
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = normalized_lot;
    request.type = ORDER_TYPE_BUY;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.deviation = 10;
    request.magic = Magic_Number;
    request.comment = "Larry Williams Buy";
    request.type_filling = ORDER_FILLING_FOK;
    
    if(!OrderSend(request, result))
    {
        Print("Error opening buy position: ", GetLastError());
    }
    else
    {
        Print("Buy position opened successfully at ", result.price);
    }
}

//+------------------------------------------------------------------+
//| Open sell position                                                |
//+------------------------------------------------------------------+
void OpenSellPosition()
{
    if(!IsMarketOpen())
    {
        Print("Market is closed, cannot open sell position");
        return;
    }
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    double normalized_lot = NormalizeLotSize(Lot_Size);
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = normalized_lot;
    request.type = ORDER_TYPE_SELL;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    request.deviation = 10;
    request.magic = Magic_Number;
    request.comment = "Larry Williams Sell";
    request.type_filling = ORDER_FILLING_FOK;
    
    if(!OrderSend(request, result))
    {
        Print("Error opening sell position: ", GetLastError());
    }
    else
    {
        Print("Sell position opened successfully at ", result.price);
    }
}

//+------------------------------------------------------------------+
//| Close all positions                                               |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(PositionSelectByIndex(i))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
               PositionGetInteger(POSITION_MAGIC) == Magic_Number)
            {
                MqlTradeRequest request = {};
                MqlTradeResult result = {};
                
                request.action = TRADE_ACTION_DEAL;
                request.symbol = _Symbol;
                request.volume = PositionGetDouble(POSITION_VOLUME);
                request.type = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
                request.price = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 
                               SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                request.magic = Magic_Number;
                request.deviation = 10;
                request.type_filling = ORDER_FILLING_FOK;
                
                if(!OrderSend(request, result))
                {
                    Print("Error closing position: ", GetLastError());
                }
                else
                {
                    Print("Position closed successfully");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check exit conditions                                             |
//+------------------------------------------------------------------+
void CheckExitConditions()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(PositionSelectByIndex(i))
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
               PositionGetInteger(POSITION_MAGIC) == Magic_Number)
            {
                double close_curr = iClose(_Symbol, PERIOD_CURRENT, 0);
                
                // Exit long position
                if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                {
                    if(close_curr >= ma1[0] || ma3_color == COLOR_BEARISH)
                        CloseAllPositions();
                }
                // Exit short position
                else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                {
                    if(close_curr <= ma2[0] || ma3_color == COLOR_BULLISH)
                        CloseAllPositions();
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw visual elements                                              |
//+------------------------------------------------------------------+
void DrawVisualElements()
{
    if(!Show_Visuals) return;
    
    datetime time_current = iTime(_Symbol, PERIOD_CURRENT, 0);
    datetime time_prev = iTime(_Symbol, PERIOD_CURRENT, 1);
    double visual_distance = GetVisualDistance();
    
    // Draw moving averages
    string ma1_name = "MA1_" + GetTimeStamp();
    ObjectCreate(0, ma1_name, OBJ_TREND, 0, time_prev, ma1[1], time_current, ma1[0]);
    ObjectSetInteger(0, ma1_name, OBJPROP_COLOR, clrPurple);
    ObjectSetInteger(0, ma1_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, ma1_name, OBJPROP_RAY_RIGHT, false);
    
    string ma2_name = "MA2_" + GetTimeStamp();
    ObjectCreate(0, ma2_name, OBJ_TREND, 0, time_prev, ma2[1], time_current, ma2[0]);
    ObjectSetInteger(0, ma2_name, OBJPROP_COLOR, clrBlue);
    ObjectSetInteger(0, ma2_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, ma2_name, OBJPROP_RAY_RIGHT, false);
    
    string ma3_name = "MA3_" + GetTimeStamp();
    ObjectCreate(0, ma3_name, OBJ_TREND, 0, time_prev, ma3[1], time_current, ma3[0]);
    ObjectSetInteger(0, ma3_name, OBJPROP_COLOR, ma3_color);
    ObjectSetInteger(0, ma3_name, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, ma3_name, OBJPROP_RAY_RIGHT, false);
    
    // Draw signals
    if(IsBuySignal())
    {
        string buy_signal_name = "BuySignal_" + GetTimeStamp();
        ObjectCreate(0, buy_signal_name, OBJ_ARROW_UP, 0, time_current, 
                    iLow(_Symbol, PERIOD_CURRENT, 0) - visual_distance);
        ObjectSetInteger(0, buy_signal_name, OBJPROP_COLOR, COLOR_BULLISH);
        ObjectSetInteger(0, buy_signal_name, OBJPROP_ARROWCODE, ARROW_BUY);
    }
    
    if(IsSellSignal())
    {
        string sell_signal_name = "SellSignal_" + GetTimeStamp();
        ObjectCreate(0, sell_signal_name, OBJ_ARROW_DOWN, 0, time_current, 
                    iHigh(_Symbol, PERIOD_CURRENT, 0) + visual_distance);
        ObjectSetInteger(0, sell_signal_name, OBJPROP_COLOR, COLOR_BEARISH);
        ObjectSetInteger(0, sell_signal_name, OBJPROP_ARROWCODE, ARROW_SELL);
    }
    
    if(IsTrendChange())
    {
        string trend_change_name = "TrendChange_" + GetTimeStamp();
        ObjectCreate(0, trend_change_name, OBJ_ARROW_STOP, 0, time_current, 
                    iLow(_Symbol, PERIOD_CURRENT, 0) - visual_distance * 2);
        ObjectSetInteger(0, trend_change_name, OBJPROP_COLOR, clrPurple);
        ObjectSetInteger(0, trend_change_name, OBJPROP_ARROWCODE, ARROW_TREND_CHANGE);
    }
}