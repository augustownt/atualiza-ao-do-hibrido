//+------------------------------------------------------------------+
//|                                Larry Williams Setup Max Min EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

//--- Input parameters
input double LotSize = 0.1;                    // Lot size for trades
input int MagicNumber = 12345;                  // Magic number for this EA
input int StopLoss = 100;                      // Stop loss in points
input int TakeProfit = 200;                    // Take profit in points
input int RSI_Period = 14;                     // RSI period
input int RSI_Overbought = 70;                 // RSI overbought level
input int RSI_Oversold = 30;                   // RSI oversold level

//--- Global variables
CTrade trade;
int rsi_handle;
bool init_error = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set magic number for trade operations
    trade.SetExpertMagicNumber(MagicNumber);
    
    // Create RSI indicator handle
    rsi_handle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
    
    if(rsi_handle == INVALID_HANDLE)
    {
        Print("Error creating RSI indicator handle: ", GetLastError());
        init_error = true;
        return(INIT_FAILED);
    }
    
    Print("Larry Williams Setup Max Min EA initialized successfully");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release indicator handle
    if(rsi_handle != INVALID_HANDLE)
        IndicatorRelease(rsi_handle);
    
    Print("Larry Williams Setup Max Min EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for initialization error
    if(init_error)
        return;
    
    // Check if there's an open position
    bool hasOpen = HasOpenTrade();
    
    // Get current RSI value
    double rsi_value = GetRSIValue();
    if(rsi_value == -1) // Error getting RSI value
        return;
    
    // Generate trading signals
    bool buy_signal = (rsi_value < RSI_Oversold);
    bool sell_signal = (rsi_value > RSI_Overbought);
    
    // If we have an open position, check for opposite signals to close it
    if(hasOpen)
    {
        ulong ticket = GetOpenPositionTicket();
        if(ticket > 0)
        {
            ENUM_POSITION_TYPE pos_type = GetPositionType(ticket);
            
            // Close position if opposite signal occurs
            if((pos_type == POSITION_TYPE_BUY && sell_signal) ||
               (pos_type == POSITION_TYPE_SELL && buy_signal))
            {
                ClosePosition(ticket);
                return; // Exit to prevent opening new position immediately
            }
        }
    }
    else // No open position, check for entry signals
    {
        if(buy_signal)
        {
            OpenBuyPosition();
        }
        else if(sell_signal)
        {
            OpenSellPosition();
        }
    }
}

//+------------------------------------------------------------------+
//| Check if there are open trades by this EA                       |
//+------------------------------------------------------------------+
bool HasOpenTrade()
{
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                return true;
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Get the ticket of the open position                             |
//+------------------------------------------------------------------+
ulong GetOpenPositionTicket()
{
    for(int i = 0; i < PositionsTotal(); i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(PositionSelectByTicket(ticket))
        {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                return ticket;
            }
        }
    }
    return 0;
}

//+------------------------------------------------------------------+
//| Get position type                                                |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE GetPositionType(ulong ticket)
{
    if(PositionSelectByTicket(ticket))
    {
        return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Close position by ticket                                         |
//+------------------------------------------------------------------+
void ClosePosition(ulong ticket)
{
    if(!PositionSelectByTicket(ticket))
    {
        Print("Error selecting position by ticket: ", ticket, " Error: ", GetLastError());
        return;
    }
    
    bool result = trade.PositionClose(ticket);
    
    if(result)
    {
        Print("Position closed successfully. Ticket: ", ticket);
    }
    else
    {
        int error = GetLastError();
        Print("Error closing position. Ticket: ", ticket, " Error: ", error, " Description: ", 
              trade.ResultRetcodeDescription());
        
        // Log additional trade operation details
        Print("Trade result: RetCode=", trade.ResultRetcode(), 
              " Deal=", trade.ResultDeal(), 
              " Order=", trade.ResultOrder(), 
              " Volume=", trade.ResultVolume(), 
              " Price=", trade.ResultPrice());
    }
}

//+------------------------------------------------------------------+
//| Open buy position                                                |
//+------------------------------------------------------------------+
void OpenBuyPosition()
{
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double sl = (StopLoss > 0) ? ask - StopLoss * _Point : 0;
    double tp = (TakeProfit > 0) ? ask + TakeProfit * _Point : 0;
    
    bool result = trade.Buy(LotSize, _Symbol, ask, sl, tp, "Larry Williams Buy");
    
    if(result)
    {
        Print("Buy order sent successfully. Price: ", ask);
    }
    else
    {
        int error = GetLastError();
        Print("Error opening buy position. Error: ", error, " Description: ", 
              trade.ResultRetcodeDescription());
        
        // Log additional trade operation details
        Print("Trade result: RetCode=", trade.ResultRetcode(), 
              " Deal=", trade.ResultDeal(), 
              " Order=", trade.ResultOrder());
    }
}

//+------------------------------------------------------------------+
//| Open sell position                                               |
//+------------------------------------------------------------------+
void OpenSellPosition()
{
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = (StopLoss > 0) ? bid + StopLoss * _Point : 0;
    double tp = (TakeProfit > 0) ? bid - TakeProfit * _Point : 0;
    
    bool result = trade.Sell(LotSize, _Symbol, bid, sl, tp, "Larry Williams Sell");
    
    if(result)
    {
        Print("Sell order sent successfully. Price: ", bid);
    }
    else
    {
        int error = GetLastError();
        Print("Error opening sell position. Error: ", error, " Description: ", 
              trade.ResultRetcodeDescription());
        
        // Log additional trade operation details
        Print("Trade result: RetCode=", trade.ResultRetcode(), 
              " Deal=", trade.ResultDeal(), 
              " Order=", trade.ResultOrder());
    }
}

//+------------------------------------------------------------------+
//| Get current RSI value                                            |
//+------------------------------------------------------------------+
double GetRSIValue()
{
    double rsi_buffer[1];
    
    if(CopyBuffer(rsi_handle, 0, 0, 1, rsi_buffer) <= 0)
    {
        Print("Error copying RSI buffer: ", GetLastError());
        return -1;
    }
    
    return rsi_buffer[0];
}

//+------------------------------------------------------------------+