//+------------------------------------------------------------------+
//| LarryWilliamsSetupTest.mq5                                        |
//| Test script for Larry Williams Setup Max Min EA                   |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, Copilot"
#property version   "1.0"
#property script_show_inputs

#include "LarryWilliamsCommon.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== Larry Williams Setup Max Min EA Test ===");
    
    // Test helper functions
    TestHelperFunctions();
    
    // Test MA calculations
    TestMACalculations();
    
    Print("=== Test completed ===");
}

//+------------------------------------------------------------------+
//| Test helper functions from common include                         |
//+------------------------------------------------------------------+
void TestHelperFunctions()
{
    Print("Testing helper functions...");
    
    // Test symbol point calculation
    double point = GetSymbolPoint();
    Print("Symbol point: ", point);
    
    // Test lot normalization
    double test_lots[] = {0.001, 0.01, 0.1, 1.0, 10.0};
    for(int i = 0; i < ArraySize(test_lots); i++)
    {
        double normalized = NormalizeLotSize(test_lots[i]);
        Print("Lot ", test_lots[i], " normalized to: ", normalized);
    }
    
    // Test market status
    bool market_open = IsMarketOpen();
    Print("Market is open: ", market_open);
    
    // Test timestamp generation
    string timestamp = GetTimeStamp();
    Print("Current timestamp: ", timestamp);
    
    // Test visual distance
    double visual_dist = GetVisualDistance();
    Print("Visual distance: ", visual_dist);
}

//+------------------------------------------------------------------+
//| Test MA calculations                                              |
//+------------------------------------------------------------------+
void TestMACalculations()
{
    Print("Testing MA calculations...");
    
    // Create MA handles for testing
    int ma1_test = iMA(_Symbol, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_HIGH);
    int ma2_test = iMA(_Symbol, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_LOW);
    int ma3_test = iMA(_Symbol, PERIOD_CURRENT, 21, 0, MODE_SMA, PRICE_CLOSE);
    
    if(ma1_test == INVALID_HANDLE || ma2_test == INVALID_HANDLE || ma3_test == INVALID_HANDLE)
    {
        Print("Error: Failed to create MA handles for testing");
        return;
    }
    
    // Test buffer copy
    double ma1_test_buffer[], ma2_test_buffer[], ma3_test_buffer[];
    ArraySetAsSeries(ma1_test_buffer, true);
    ArraySetAsSeries(ma2_test_buffer, true);
    ArraySetAsSeries(ma3_test_buffer, true);
    
    if(CopyBuffer(ma1_test, 0, 0, 3, ma1_test_buffer) <= 0 ||
       CopyBuffer(ma2_test, 0, 0, 3, ma2_test_buffer) <= 0 ||
       CopyBuffer(ma3_test, 0, 0, 3, ma3_test_buffer) <= 0)
    {
        Print("Error: Failed to copy MA buffers");
        IndicatorRelease(ma1_test);
        IndicatorRelease(ma2_test);
        IndicatorRelease(ma3_test);
        return;
    }
    
    Print("MA1[0]: ", ma1_test_buffer[0]);
    Print("MA2[0]: ", ma2_test_buffer[0]);
    Print("MA3[0]: ", ma3_test_buffer[0]);
    
    // Test color logic
    color test_color;
    if(ma3_test_buffer[0] < ma2_test_buffer[0] && ma3_test_buffer[0] < ma1_test_buffer[0])
        test_color = COLOR_BULLISH;
    else if(ma3_test_buffer[0] > ma2_test_buffer[0] && ma3_test_buffer[0] > ma1_test_buffer[0])
        test_color = COLOR_BEARISH;
    else
        test_color = COLOR_NEUTRAL;
    
    string color_name = (test_color == COLOR_BULLISH) ? "BULLISH" : 
                       (test_color == COLOR_BEARISH) ? "BEARISH" : "NEUTRAL";
    Print("Current MA3 color: ", color_name);
    
    // Test signal logic
    double close_prev = iClose(_Symbol, PERIOD_CURRENT, 1);
    double close_curr = iClose(_Symbol, PERIOD_CURRENT, 0);
    
    bool buy_signal = (test_color == COLOR_BULLISH && close_prev <= ma2_test_buffer[1] && close_curr > ma2_test_buffer[0]);
    bool sell_signal = (test_color == COLOR_BEARISH && close_prev >= ma1_test_buffer[1] && close_curr < ma1_test_buffer[0]);
    
    Print("Buy signal: ", buy_signal);
    Print("Sell signal: ", sell_signal);
    
    // Clean up
    IndicatorRelease(ma1_test);
    IndicatorRelease(ma2_test);
    IndicatorRelease(ma3_test);
    
    Print("MA calculation test completed successfully");
}