//+------------------------------------------------------------------+
//|                                LarryWilliamsSetupIndicator.mq5 |
//|                        Larry Williams Setup Visual Indicator    |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Larry Williams Setup Indicator"
#property version   "1.00"
#property description "Visual indicator for Larry Williams Setup Max Min strategy"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3

//--- Input parameters
input int SMA1_Period = 3;     // SMA1 period (applied to highs)
input int SMA2_Period = 3;     // SMA2 period (applied to lows)  
input int SMA3_Period = 21;    // SMA3 period (applied to close)

//--- Plot parameters
#property indicator_label1 "SMA High"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 "SMA Low"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrOrange
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "SMA Close (Colored)"
#property indicator_type3  DRAW_COLOR_LINE
#property indicator_color3 clrLime, clrRed, clrGray
#property indicator_style3 STYLE_SOLID
#property indicator_width3 3

//--- Indicator buffers
double SMA_High_Buffer[];
double SMA_Low_Buffer[];
double SMA_Close_Buffer[];
double SMA_Close_Color_Buffer[];
double TempBuffer1[];
double TempBuffer2[];

//--- Handles for moving averages
int sma_high_handle;
int sma_low_handle;
int sma_close_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Create moving average handles
   sma_high_handle = iMA(_Symbol, _Period, SMA1_Period, 0, MODE_SMA, PRICE_HIGH);
   sma_low_handle = iMA(_Symbol, _Period, SMA2_Period, 0, MODE_SMA, PRICE_LOW);
   sma_close_handle = iMA(_Symbol, _Period, SMA3_Period, 0, MODE_SMA, PRICE_CLOSE);
   
   //--- Check handles
   if(sma_high_handle == INVALID_HANDLE || sma_low_handle == INVALID_HANDLE || sma_close_handle == INVALID_HANDLE)
   {
      Print("Error creating moving average handles in indicator");
      return INIT_FAILED;
   }
   
   //--- Set indicator buffers
   SetIndexBuffer(0, SMA_High_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, SMA_Low_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, SMA_Close_Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, SMA_Close_Color_Buffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, TempBuffer1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, TempBuffer2, INDICATOR_CALCULATIONS);
   
   //--- Set indicator properties
   PlotIndexSetString(0, PLOT_LABEL, "SMA(" + IntegerToString(SMA1_Period) + ") High");
   PlotIndexSetString(1, PLOT_LABEL, "SMA(" + IntegerToString(SMA2_Period) + ") Low");
   PlotIndexSetString(2, PLOT_LABEL, "SMA(" + IntegerToString(SMA3_Period) + ") Close");
   
   //--- Set arrays as series
   ArraySetAsSeries(SMA_High_Buffer, true);
   ArraySetAsSeries(SMA_Low_Buffer, true);
   ArraySetAsSeries(SMA_Close_Buffer, true);
   ArraySetAsSeries(SMA_Close_Color_Buffer, true);
   
   //--- Set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME, "Larry Williams Setup (" + 
                     IntegerToString(SMA1_Period) + "," + 
                     IntegerToString(SMA2_Period) + "," + 
                     IntegerToString(SMA3_Period) + ")");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release handles
   if(sma_high_handle != INVALID_HANDLE)
      IndicatorRelease(sma_high_handle);
   if(sma_low_handle != INVALID_HANDLE)
      IndicatorRelease(sma_low_handle);
   if(sma_close_handle != INVALID_HANDLE)
      IndicatorRelease(sma_close_handle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //--- Check if we have enough data
   if(rates_total < SMA3_Period)
      return 0;
   
   //--- Calculate start position
   int start = prev_calculated;
   if(start == 0)
      start = SMA3_Period - 1;
   
   //--- Calculate number of bars to process
   int to_copy = rates_total - start + 1;
   if(to_copy <= 0)
      return prev_calculated;
   
   //--- Copy moving averages data
   if(CopyBuffer(sma_high_handle, 0, start, to_copy, SMA_High_Buffer) <= 0)
      return prev_calculated;
   if(CopyBuffer(sma_low_handle, 0, start, to_copy, SMA_Low_Buffer) <= 0)
      return prev_calculated;
   if(CopyBuffer(sma_close_handle, 0, start, to_copy, SMA_Close_Buffer) <= 0)
      return prev_calculated;
   
   //--- Calculate colors for SMA Close based on trend
   for(int i = start; i < rates_total; i++)
   {
      //--- Determine trend direction
      if(i > 0)
      {
         if(SMA_Close_Buffer[i] > SMA_Close_Buffer[i-1])
            SMA_Close_Color_Buffer[i] = 0; // Green (bullish)
         else if(SMA_Close_Buffer[i] < SMA_Close_Buffer[i-1])
            SMA_Close_Color_Buffer[i] = 1; // Red (bearish)
         else
            SMA_Close_Color_Buffer[i] = 2; // Gray (neutral)
      }
      else
      {
         SMA_Close_Color_Buffer[i] = 2; // Gray for first bar
      }
   }
   
   //--- Return number of calculated bars
   return rates_total;
}

//+------------------------------------------------------------------+