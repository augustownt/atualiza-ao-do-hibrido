//+------------------------------------------------------------------+
//|                                    LarryWilliamsSetupMaxMin.mq5 |
//|                                         Larry Williams Strategy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Larry Williams Setup Max Min EA"
#property version   "1.00"
#property description "Expert Advisor implementing Larry Williams Setup Max Min strategy"

//--- Include common functions
#include "LarryWilliamsCommon.mqh"

//--- Input parameters
input double   FixedLot = DEFAULT_LOT_SIZE;        // Fixed lot size
input int      SMA1_Period = DEFAULT_SMA1_PERIOD;  // SMA1 period (applied to highs)
input int      SMA2_Period = DEFAULT_SMA2_PERIOD;  // SMA2 period (applied to lows)
input int      SMA3_Period = DEFAULT_SMA3_PERIOD;  // SMA3 period (applied to close)
input int      MagicNumber = LARRY_WILLIAMS_MAGIC; // Magic number for orders
input int      Slippage = 3;                       // Allowed slippage in points
input bool     ShowVisualSignals = true;           // Show visual signals on chart

//--- Global variables
int sma1_handle, sma2_handle, sma3_handle;
SMovingAveragesData ma_data;
ENUM_TREND_STATE current_trend = TREND_NEUTRAL;
ENUM_TREND_STATE previous_trend = TREND_NEUTRAL;
int signal_count = 0;

//--- Visual elements
string indicator_name = "LarryWilliamsSetup";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Create moving average handles
   sma1_handle = iMA(_Symbol, _Period, SMA1_Period, 0, MODE_SMA, PRICE_HIGH);
   sma2_handle = iMA(_Symbol, _Period, SMA2_Period, 0, MODE_SMA, PRICE_LOW);
   sma3_handle = iMA(_Symbol, _Period, SMA3_Period, 0, MODE_SMA, PRICE_CLOSE);
   
   //--- Check if handles are valid
   if(sma1_handle == INVALID_HANDLE || sma2_handle == INVALID_HANDLE || sma3_handle == INVALID_HANDLE)
   {
      Print("Error creating moving average handles");
      return INIT_FAILED;
   }
   
   //--- Validate lot size
   FixedLot = ValidateLotSize(FixedLot);
   
   //--- Initialize visual elements
   if(ShowVisualSignals)
      CreateVisualElements();
   
   Print("Larry Williams Setup Max Min EA initialized successfully");
   Print("SMA Periods: ", SMA1_Period, " (High), ", SMA2_Period, " (Low), ", SMA3_Period, " (Close)");
   Print("Fixed Lot Size: ", FixedLot);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(sma1_handle != INVALID_HANDLE)
      IndicatorRelease(sma1_handle);
   if(sma2_handle != INVALID_HANDLE)
      IndicatorRelease(sma2_handle);
   if(sma3_handle != INVALID_HANDLE)
      IndicatorRelease(sma3_handle);
   
   //--- Remove visual elements
   RemoveVisualElements();
   
   Print("Larry Williams Setup Max Min EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Update moving averages data
   if(!UpdateMovingAveragesData())
      return;
   
   //--- Update trend state
   UpdateTrendState();
   
   //--- Update visual elements
   if(ShowVisualSignals)
      UpdateVisualElements();
   
   //--- Check for exit signals first
   if(PositionsTotal() > 0)
   {
      CheckExitSignals();
   }
   
   //--- Check for entry signals
   if(PositionsTotal() == 0)
   {
      CheckEntrySignals();
   }
}

//+------------------------------------------------------------------+
//| Update moving averages data                                      |
//+------------------------------------------------------------------+
bool UpdateMovingAveragesData()
{
   double sma1_buffer[2], sma2_buffer[2], sma3_buffer[2];
   
   //--- Copy moving averages data
   if(CopyBuffer(sma1_handle, 0, 0, 2, sma1_buffer) < 2)
      return false;
   if(CopyBuffer(sma2_handle, 0, 0, 2, sma2_buffer) < 2)
      return false;
   if(CopyBuffer(sma3_handle, 0, 0, 2, sma3_buffer) < 2)
      return false;
   
   //--- Update structure
   ma_data.sma_high_current = sma1_buffer[0];
   ma_data.sma_high_previous = sma1_buffer[1];
   ma_data.sma_low_current = sma2_buffer[0];
   ma_data.sma_low_previous = sma2_buffer[1];
   ma_data.sma_close_current = sma3_buffer[0];
   ma_data.sma_close_previous = sma3_buffer[1];
   
   return true;
}

//+------------------------------------------------------------------+
//| Update trend state                                               |
//+------------------------------------------------------------------+
void UpdateTrendState()
{
   previous_trend = current_trend;
   current_trend = GetTrendState(ma_data.sma_close_current, ma_data.sma_close_previous);
}

//+------------------------------------------------------------------+
//| Check for entry signals                                          |
//+------------------------------------------------------------------+
void CheckEntrySignals()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //--- Get previous prices for crossover detection
   double prev_ask = ask; // In real implementation, you'd get previous tick price
   double prev_bid = bid;
   
   //--- Check for buy signal
   if(CheckBuySignal(ma_data, ask, prev_ask))
   {
      if(OpenBuyOrder())
      {
         if(ShowVisualSignals)
            CreateSignalArrow(SIGNAL_BUY);
         Print("Buy signal executed at ", ask);
      }
   }
   
   //--- Check for sell signal
   if(CheckSellSignal(ma_data, bid, prev_bid))
   {
      if(OpenSellOrder())
      {
         if(ShowVisualSignals)
            CreateSignalArrow(SIGNAL_SELL);
         Print("Sell signal executed at ", bid);
      }
   }
}

//+------------------------------------------------------------------+
//| Check for exit signals                                           |
//+------------------------------------------------------------------+
void CheckExitSignals()
{
   //--- Check for trend change (exit signal)
   if(CheckTrendChange(current_trend, previous_trend))
   {
      CloseAllPositions();
      if(ShowVisualSignals)
         CreateSignalArrow(SIGNAL_EXIT);
      Print("Exit signal - trend change detected from ", 
            EnumToString(previous_trend), " to ", EnumToString(current_trend));
   }
}

//+------------------------------------------------------------------+
//| Open buy order                                                   |
//+------------------------------------------------------------------+
bool OpenBuyOrder()
{
   MqlTradeRequest request;
   MqlTradeResult result;
   
   ZeroMemory(request);
   ZeroMemory(result);
   
   double validated_lot = ValidateLotSize(FixedLot);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = validated_lot;
   request.type = ORDER_TYPE_BUY;
   request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   request.deviation = Slippage;
   request.magic = MagicNumber;
   request.comment = "Larry Williams Buy";
   
   bool success = OrderSend(request, result);
   if(!success)
   {
      Print("Buy order failed: ", result.retcode, " - ", result.comment);
   }
   else
   {
      Print("Buy order successful. Ticket: ", result.order, ", Volume: ", validated_lot);
   }
   
   return success;
}

//+------------------------------------------------------------------+
//| Open sell order                                                  |
//+------------------------------------------------------------------+
bool OpenSellOrder()
{
   MqlTradeRequest request;
   MqlTradeResult result;
   
   ZeroMemory(request);
   ZeroMemory(result);
   
   double validated_lot = ValidateLotSize(FixedLot);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = validated_lot;
   request.type = ORDER_TYPE_SELL;
   request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   request.deviation = Slippage;
   request.magic = MagicNumber;
   request.comment = "Larry Williams Sell";
   
   bool success = OrderSend(request, result);
   if(!success)
   {
      Print("Sell order failed: ", result.retcode, " - ", result.comment);
   }
   else
   {
      Print("Sell order successful. Ticket: ", result.order, ", Volume: ", validated_lot);
   }
   
   return success;
}

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            MqlTradeRequest request;
            MqlTradeResult result;
            
            ZeroMemory(request);
            ZeroMemory(result);
            
            request.action = TRADE_ACTION_DEAL;
            request.symbol = PositionGetString(POSITION_SYMBOL);
            request.volume = PositionGetDouble(POSITION_VOLUME);
            request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
            request.price = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            request.deviation = Slippage;
            request.magic = MagicNumber;
            request.comment = "Larry Williams Close";
            
            OrderSend(request, result);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Create visual elements                                           |
//+------------------------------------------------------------------+
void CreateVisualElements()
{
   //--- Create indicator for colored MA21
   ObjectCreate(0, "MA21_Line", OBJ_TREND, 0, 0, 0, 0, 0);
   ObjectSetInteger(0, "MA21_Line", OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, "MA21_Line", OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, "MA21_Line", OBJPROP_WIDTH, 2);
}

//+------------------------------------------------------------------+
//| Remove visual elements                                           |
//+------------------------------------------------------------------+
void RemoveVisualElements()
{
   //--- Remove all objects created by this EA
   ObjectsDeleteAll(0, indicator_name);
   ObjectDelete(0, "MA21_Line");
   
   //--- Remove triangles and X marks
   for(int i = 0; i < 1000; i++)
   {
      ObjectDelete(0, "BuyTriangle_" + IntegerToString(i));
      ObjectDelete(0, "SellTriangle_" + IntegerToString(i));
      ObjectDelete(0, "TrendChangeX_" + IntegerToString(i));
   }
}

//+------------------------------------------------------------------+
//| Update visual elements                                           |
//+------------------------------------------------------------------+
void UpdateVisualElements()
{
   //--- Update MA21 color based on trend
   color ma21_color = GetTrendColor(current_trend);
   
   //--- Update MA21 line if it exists
   if(ObjectFind(0, "MA21_Line") >= 0)
   {
      ObjectSetInteger(0, "MA21_Line", OBJPROP_COLOR, ma21_color);
   }
   
   //--- Update candle colors
   UpdateCandleColors();
}

//+------------------------------------------------------------------+
//| Update candle colors                                             |
//+------------------------------------------------------------------+
void UpdateCandleColors()
{
   static int last_bar = -1;
   int current_bar = Bars(_Symbol, _Period) - 1;
   
   if(current_bar != last_bar && current_bar > 0)
   {
      datetime time = iTime(_Symbol, _Period, 0);
      double open = iOpen(_Symbol, _Period, 0);
      double close = iClose(_Symbol, _Period, 0);
      double high = iHigh(_Symbol, _Period, 0);
      double low = iLow(_Symbol, _Period, 0);
      
      //--- Get trend color
      color candle_color = GetTrendColor(current_trend);
      
      //--- Create candle outline
      string obj_name = "Candle_" + IntegerToString(current_bar);
      ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, time, MathMin(open, close), 
                   time + PeriodSeconds(_Period) * 0.8, MathMax(open, close));
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, candle_color);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
      
      //--- Create wick lines
      string wick_name = "Wick_" + IntegerToString(current_bar);
      ObjectCreate(0, wick_name, OBJ_TREND, 0, time + PeriodSeconds(_Period) * 0.4, low, 
                   time + PeriodSeconds(_Period) * 0.4, high);
      ObjectSetInteger(0, wick_name, OBJPROP_COLOR, candle_color);
      ObjectSetInteger(0, wick_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, wick_name, OBJPROP_BACK, true);
      ObjectSetInteger(0, wick_name, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, wick_name, OBJPROP_RAY_RIGHT, false);
      
      last_bar = current_bar;
   }
}

//+------------------------------------------------------------------+
//| Create signal arrow                                              |
//+------------------------------------------------------------------+
void CreateSignalArrow(ENUM_LARRY_SIGNAL signal_type)
{
   signal_count++;
   
   string obj_name = "Signal_" + EnumToString(signal_type) + "_" + IntegerToString(signal_count);
   datetime time = TimeCurrent();
   double price;
   
   //--- Set price based on signal type
   switch(signal_type)
   {
      case SIGNAL_BUY:
         price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         break;
      case SIGNAL_SELL:
         price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         break;
      case SIGNAL_EXIT:
         price = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) + SymbolInfoDouble(_Symbol, SYMBOL_BID)) / 2;
         break;
      default:
         return;
   }
   
   //--- Create arrow object
   ObjectCreate(0, obj_name, OBJ_ARROW, 0, time, price);
   ObjectSetInteger(0, obj_name, OBJPROP_ARROWCODE, GetSignalArrowCode(signal_type));
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, GetSignalColor(signal_type));
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, signal_type == SIGNAL_EXIT ? 4 : 3);
   
   //--- Set tooltip
   ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, GetSignalDescription(signal_type) + 
                  " at " + TimeToString(time) + " price " + DoubleToString(price, _Digits));
}

//+------------------------------------------------------------------+