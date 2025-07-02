//+------------------------------------------------------------------+
//|                                  LarryWilliamsSetupConfig.mqh  |
//|                           Configuration and Parameter Settings  |
//|                                                                  |
//+------------------------------------------------------------------+

#ifndef LARRY_WILLIAMS_CONFIG_MQH
#define LARRY_WILLIAMS_CONFIG_MQH

//--- Trading Parameters
struct SLarryWilliamsConfig
{
   // Moving Average Periods
   int sma1_period;        // SMA period for high prices
   int sma2_period;        // SMA period for low prices
   int sma3_period;        // SMA period for close prices (trend determination)
   
   // Risk Management
   double fixed_lot_size;  // Fixed lot size for all trades
   int magic_number;       // Magic number for order identification
   int slippage_points;    // Maximum allowed slippage in points
   
   // Visual Settings
   bool show_visual_signals;     // Show signal arrows and markers
   bool show_colored_candles;    // Show colored candles
   bool show_ma_lines;          // Show moving average lines
   
   // Colors
   color bullish_color;    // Color for bullish trend
   color bearish_color;    // Color for bearish trend
   color neutral_color;    // Color for neutral trend
   color buy_signal_color; // Color for buy signals
   color sell_signal_color;// Color for sell signals
   color exit_signal_color;// Color for exit signals
};

//--- Default configuration
void InitDefaultConfig(SLarryWilliamsConfig &config)
{
   // Moving Average Periods
   config.sma1_period = 3;
   config.sma2_period = 3;
   config.sma3_period = 21;
   
   // Risk Management
   config.fixed_lot_size = 0.01;
   config.magic_number = 12345;
   config.slippage_points = 3;
   
   // Visual Settings
   config.show_visual_signals = true;
   config.show_colored_candles = true;
   config.show_ma_lines = true;
   
   // Colors
   config.bullish_color = clrLime;
   config.bearish_color = clrRed;
   config.neutral_color = clrGray;
   config.buy_signal_color = clrBlue;
   config.sell_signal_color = clrRed;
   config.exit_signal_color = clrMagenta;
}

//--- Aggressive trading configuration (faster signals)
void InitAggressiveConfig(SLarryWilliamsConfig &config)
{
   InitDefaultConfig(config);
   
   // Shorter MA periods for more signals
   config.sma1_period = 2;
   config.sma2_period = 2;
   config.sma3_period = 14;
   
   // Smaller lot size for more risk management
   config.fixed_lot_size = 0.01;
}

//--- Conservative trading configuration (slower signals)
void InitConservativeConfig(SLarryWilliamsConfig &config)
{
   InitDefaultConfig(config);
   
   // Longer MA periods for fewer but more reliable signals
   config.sma1_period = 5;
   config.sma2_period = 5;
   config.sma3_period = 30;
   
   // Standard lot size
   config.fixed_lot_size = 0.01;
}

//--- Scalping configuration (very fast signals)
void InitScalpingConfig(SLarryWilliamsConfig &config)
{
   InitDefaultConfig(config);
   
   // Very short MA periods
   config.sma1_period = 2;
   config.sma2_period = 2;
   config.sma3_period = 8;
   
   // Small lot size for scalping
   config.fixed_lot_size = 0.01;
   
   // Higher slippage tolerance for fast execution
   config.slippage_points = 5;
}

//--- Swing trading configuration (slower signals)
void InitSwingConfig(SLarryWilliamsConfig &config)
{
   InitDefaultConfig(config);
   
   // Longer MA periods for swing trading
   config.sma1_period = 5;
   config.sma2_period = 5;
   config.sma3_period = 50;
   
   // Larger lot size for swing trades
   config.fixed_lot_size = 0.05;
}

//--- Validate configuration parameters
bool ValidateConfig(const SLarryWilliamsConfig &config)
{
   // Check MA periods
   if(config.sma1_period < 1 || config.sma2_period < 1 || config.sma3_period < 1)
   {
      Print("Error: MA periods must be greater than 0");
      return false;
   }
   
   if(config.sma3_period <= MathMax(config.sma1_period, config.sma2_period))
   {
      Print("Warning: SMA3 period should be longer than SMA1 and SMA2 periods for better trend detection");
   }
   
   // Check lot size
   if(config.fixed_lot_size <= 0)
   {
      Print("Error: Lot size must be greater than 0");
      return false;
   }
   
   // Check magic number
   if(config.magic_number < 0)
   {
      Print("Error: Magic number cannot be negative");
      return false;
   }
   
   // Check slippage
   if(config.slippage_points < 0)
   {
      Print("Error: Slippage cannot be negative");
      return false;
   }
   
   return true;
}

//--- Print configuration summary
void PrintConfigSummary(const SLarryWilliamsConfig &config)
{
   Print("=== Larry Williams Setup Configuration ===");
   Print("SMA Periods: ", config.sma1_period, " (High), ", 
         config.sma2_period, " (Low), ", config.sma3_period, " (Close)");
   Print("Lot Size: ", config.fixed_lot_size);
   Print("Magic Number: ", config.magic_number);
   Print("Slippage: ", config.slippage_points, " points");
   Print("Visual Signals: ", config.show_visual_signals ? "Enabled" : "Disabled");
   Print("Colored Candles: ", config.show_colored_candles ? "Enabled" : "Disabled");
   Print("MA Lines: ", config.show_ma_lines ? "Enabled" : "Disabled");
   Print("==========================================");
}

#endif // LARRY_WILLIAMS_CONFIG_MQH
//+------------------------------------------------------------------+