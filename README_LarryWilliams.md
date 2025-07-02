# Larry Williams Setup Max Min Expert Advisor

## Overview

This Expert Advisor implements the Larry Williams Setup Max Min trading strategy for MetaTrader 5. The strategy is based on three moving averages that create dynamic entry and exit signals based on their relative positions and color changes.

## Strategy Description

The Larry Williams Setup Max Min strategy uses three moving averages:

- **MA1**: 3-period Simple Moving Average of High prices (Purple line)
- **MA2**: 3-period Simple Moving Average of Low prices (Blue line)
- **MA3**: 21-period Simple Moving Average of Close prices (Color-changing line)

### MA3 Color Logic

- **Green (Lime)**: MA3 < MA2 AND MA3 < MA1 (Bullish condition)
- **Red**: MA3 > MA2 AND MA3 > MA1 (Bearish condition)
- **Gray**: Neither condition met (Neutral)

### Trading Signals

#### Buy Signal (Green Triangle Up)
- MA3 is Green (bullish condition)
- Previous close <= MA2[1]
- Current close > MA2[0]

#### Sell Signal (Red Triangle Down)
- MA3 is Red (bearish condition)
- Previous close >= MA1[1]
- Current close < MA1[0]

#### Exit Conditions

**Long Position Exit:**
- Current close >= MA1[0], OR
- MA3 color changes to Red

**Short Position Exit:**
- Current close <= MA2[0], OR
- MA3 color changes to Green

#### Trend Change Detection (Purple X)
When MA3 color changes, all positions are immediately closed as a risk management measure.

## Input Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| MA1_Period | 3 | Period for MA1 (High prices) |
| MA2_Period | 3 | Period for MA2 (Low prices) |
| MA3_Period | 21 | Period for MA3 (Close prices) |
| Lot_Size | 0.01 | Fixed lot size for all trades |
| Magic_Number | 123456 | Unique identifier for EA trades |

## Visual Elements

The EA creates several visual elements on the chart:

1. **Moving Average Lines:**
   - Purple line: MA1 (High MA)
   - Blue line: MA2 (Low MA)
   - Color-changing line: MA3 (Green/Red/Gray based on conditions)

2. **Trading Signals:**
   - Green arrows up: Buy signals
   - Red arrows down: Sell signals
   - Purple X marks: Trend change detection

## Risk Management

- **Fixed Lot Size**: Uses a fixed lot size for all trades
- **Trend Change Detection**: Automatically closes all positions when trend changes
- **Magic Number**: Ensures the EA only manages its own trades
- **Error Handling**: Comprehensive error checking for trade operations

## Installation

1. Copy `LarryWilliamsSetupMaxMin.mq5` to your MetaTrader 5 `Experts` folder
2. Compile the EA in MetaEditor
3. Attach to a chart and configure input parameters
4. Enable automated trading

## Important Notes

- This EA is designed for educational and research purposes
- Always test on a demo account before using with real money
- The strategy works best in trending markets
- Consider your risk tolerance and position sizing
- Past performance does not guarantee future results

## Version History

- **v1.0**: Initial implementation with complete trading logic and visual elements

## Author

Developed by Copilot for augustownt
GitHub: https://github.com/augustownt

## Disclaimer

Trading in financial markets involves substantial risk and is not suitable for all investors. This Expert Advisor is provided for educational purposes only. Always conduct thorough testing and consider seeking advice from financial professionals before using any automated trading system.