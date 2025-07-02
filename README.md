# Larry Williams Setup Max Min Strategy - MQL5 Expert Advisor

## Overview
This Expert Advisor implements the Larry Williams Setup Max Min strategy for MetaTrader 5. The strategy uses three moving averages and specific crossover rules to generate buy and sell signals.

## Strategy Description

### Moving Averages
- **SMA1**: 3-period Simple Moving Average applied to High prices
- **SMA2**: 3-period Simple Moving Average applied to Low prices  
- **SMA3**: 21-period Simple Moving Average applied to Close prices

### Trading Rules

#### Entry Signals
- **Buy Signal**: When MA21 (SMA3) is in a bullish trend (green) AND price crosses above MA2 (SMA of lows)
- **Sell Signal**: When MA21 (SMA3) is in a bearish trend (red) AND price crosses below MA1 (SMA of highs)

#### Exit Signals
- **Exit Signal**: When trend changes (purple X signal) - occurs when MA21 changes from bullish to bearish or vice versa

#### Risk Management
- Fixed lot size: 0.01 (configurable)
- Magic number for order identification
- Slippage control

## Visual Elements

### Indicators
- **MA21 Colored Line**: Green for bullish trend, Red for bearish trend, Gray for neutral
- **SMA High/Low Lines**: Blue and Orange lines showing the high and low moving averages

### Signal Markers
- **Blue Triangle**: Buy signal marker
- **Red Triangle**: Sell signal marker  
- **Purple X**: Trend change/exit signal marker

### Chart Enhancement
- **Colored Candles**: Candles colored according to current trend (Green/Red/Gray)

## Files Structure

### Core Files
1. **LarryWilliamsSetupMaxMin.mq5** - Main Expert Advisor
2. **LarryWilliamsSetupIndicator.mq5** - Visual indicator for moving averages
3. **LarryWilliamsCommon.mqh** - Common functions and structures header

## Installation Instructions

1. Copy all files to your MetaTrader 5 installation:
   - Expert Advisors: `MQL5/Experts/`
   - Indicators: `MQL5/Indicators/`
   - Include files: `MQL5/Include/`

2. Compile the files in MetaEditor or restart MetaTrader 5

3. Apply the Expert Advisor to a chart

## Configuration Parameters

### Expert Advisor Parameters
- **FixedLot**: Fixed lot size for all trades (default: 0.01)
- **SMA1_Period**: Period for high prices SMA (default: 3)
- **SMA2_Period**: Period for low prices SMA (default: 3)
- **SMA3_Period**: Period for close prices SMA (default: 21)
- **MagicNumber**: Unique identifier for EA orders (default: 12345)
- **Slippage**: Maximum allowed slippage in points (default: 3)
- **ShowVisualSignals**: Enable/disable visual signal markers (default: true)

### Indicator Parameters
- **SMA1_Period**: Period for high prices SMA (default: 3)
- **SMA2_Period**: Period for low prices SMA (default: 3)
- **SMA3_Period**: Period for close prices SMA (default: 21)

## Strategy Logic Details

### Trend Determination
The trend is determined by the 21-period SMA (MA21):
- **Bullish**: Current MA21 > Previous MA21
- **Bearish**: Current MA21 < Previous MA21
- **Neutral**: Current MA21 = Previous MA21

### Signal Generation
1. **Buy Conditions**:
   - MA21 must be in bullish trend
   - Current price must cross above SMA2 (low prices MA)
   - No existing position

2. **Sell Conditions**:
   - MA21 must be in bearish trend
   - Current price must cross below SMA1 (high prices MA)
   - No existing position

3. **Exit Conditions**:
   - Trend change detected (bullish to bearish or vice versa)
   - Applies to all open positions

## Risk Management Features

- **Lot Size Validation**: Automatic validation against broker's minimum/maximum/step requirements
- **Single Position**: Only one position allowed at a time
- **Magic Number Filtering**: Only manages orders with matching magic number
- **Error Handling**: Comprehensive error checking for order operations

## Visual Enhancement Features

- **Real-time Trend Coloring**: MA21 changes color based on trend direction
- **Signal Arrows**: Clear visual markers for all entry and exit signals
- **Colored Candles**: Chart candles reflect current trend state
- **Tooltips**: Hover information for signal markers

## Testing and Validation

### Recommended Testing
1. **Strategy Tester**: Use MetaTrader 5's built-in strategy tester
2. **Demo Account**: Test on demo account before live trading
3. **Different Timeframes**: Test on various timeframes to find optimal settings
4. **Different Symbols**: Validate on different currency pairs/instruments

### Performance Monitoring
- Monitor signal generation frequency
- Track trend change accuracy
- Evaluate entry/exit timing
- Analyze profit/loss patterns

## Important Notes

### Trading Risks
- This strategy is trend-following and may produce false signals in ranging markets
- No stop-loss or take-profit levels are implemented by default
- Fixed lot sizing may not be suitable for all account sizes

### Market Conditions
- Works best in trending markets
- May generate frequent signals in volatile conditions
- Consider market session and volatility when using

### Customization
- All parameters are configurable
- Visual elements can be disabled if not needed
- Strategy logic can be modified in the source code

## Support and Modifications

The code is well-documented and modular, making it easy to:
- Modify trading parameters
- Add additional risk management features
- Implement stop-loss and take-profit levels
- Add position sizing algorithms
- Integrate with other indicators

## License
This Expert Advisor is provided as-is for educational and trading purposes.

## Disclaimer
Trading foreign exchange and CFDs carries a high level of risk. Past performance is not indicative of future results. Only trade with money you can afford to lose.