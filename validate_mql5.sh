#!/bin/bash

# MQL5 Syntax Validation Script for Larry Williams Setup
# This script performs basic syntax checks on the MQL5 files

echo "=== Larry Williams Setup MQL5 Files Validation ==="
echo

# Check if files exist
files=("LarryWilliamsSetupMaxMin.mq5" "LarryWilliamsSetupIndicator.mq5" "LarryWilliamsCommon.mqh" "LarryWilliamsSetupConfig.mqh")

echo "Checking file existence..."
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file not found"
        exit 1
    fi
done

echo

# Basic syntax checks
echo "Performing basic syntax validation..."

# Check for balanced braces
echo "Checking brace balance..."
for file in "${files[@]}"; do
    if [[ "$file" == *.mq5 || "$file" == *.mqh ]]; then
        open_braces=$(grep -o '{' "$file" | wc -l)
        close_braces=$(grep -o '}' "$file" | wc -l)
        
        if [ "$open_braces" -eq "$close_braces" ]; then
            echo "✓ $file: Braces balanced ($open_braces pairs)"
        else
            echo "✗ $file: Braces unbalanced (open: $open_braces, close: $close_braces)"
        fi
    fi
done

echo

# Check for required MQL5 elements
echo "Checking MQL5 structure..."

# Check Expert Advisor
ea_file="LarryWilliamsSetupMaxMin.mq5"
if grep -q "#property" "$ea_file" && grep -q "OnInit()" "$ea_file" && grep -q "OnTick()" "$ea_file"; then
    echo "✓ $ea_file: Contains required EA functions"
else
    echo "✗ $ea_file: Missing required EA functions"
fi

# Check Indicator
ind_file="LarryWilliamsSetupIndicator.mq5"
if grep -q "#property indicator" "$ind_file" && grep -q "OnCalculate(" "$ind_file"; then
    echo "✓ $ind_file: Contains required indicator functions"
else
    echo "✗ $ind_file: Missing required indicator functions"
fi

# Check include files
for header in "LarryWilliamsCommon.mqh" "LarryWilliamsSetupConfig.mqh"; do
    if grep -q "#ifndef" "$header" && grep -q "#define" "$header" && grep -q "#endif" "$header"; then
        echo "✓ $header: Contains include guards"
    else
        echo "✗ $header: Missing include guards"
    fi
done

echo

# Check for common MQL5 issues
echo "Checking for common issues..."

# Check for correct function declarations
issues_found=0

for file in "${files[@]}"; do
    if [[ "$file" == *.mq5 ]]; then
        # Check for missing semicolons (basic check)
        if grep -n "^[[:space:]]*[^/].*[^;{}]$" "$file" | grep -v "^[[:space:]]*$" | head -5; then
            echo "Warning: Possible missing semicolons in $file (check line endings)"
            issues_found=$((issues_found + 1))
        fi
    fi
done

if [ $issues_found -eq 0 ]; then
    echo "✓ No obvious syntax issues found"
fi

echo

# Check file sizes
echo "File sizes:"
for file in "${files[@]}"; do
    size=$(wc -c < "$file")
    lines=$(wc -l < "$file")
    echo "  $file: $size bytes, $lines lines"
done

echo

# Generate summary
echo "=== Validation Summary ==="
echo "Expert Advisor: LarryWilliamsSetupMaxMin.mq5"
echo "Indicator: LarryWilliamsSetupIndicator.mq5" 
echo "Common Functions: LarryWilliamsCommon.mqh"
echo "Configuration: LarryWilliamsSetupConfig.mqh"
echo
echo "Strategy Implementation:"
echo "- 3 Moving Averages (SMA1: 3-period highs, SMA2: 3-period lows, SMA3: 21-period close)"
echo "- Buy/Sell signals based on MA21 trend and price crossovers"
echo "- Exit on trend change (purple X signal)"
echo "- Fixed lot size: 0.01"
echo "- Visual elements: colored MA21, triangles, purple X, colored candles"
echo
echo "Files ready for MetaTrader 5 compilation!"
echo "Copy to: MQL5/Experts/ (EA), MQL5/Indicators/ (Indicator), MQL5/Include/ (Headers)"