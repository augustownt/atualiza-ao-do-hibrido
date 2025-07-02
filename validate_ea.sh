#!/bin/bash

# Validation script for Larry Williams Setup Max Min EA

echo "=== Larry Williams Setup Max Min EA Validation ==="
echo

# Check if the MQL5 file exists
if [ ! -f "Larry Williams Setup Max Min EA.mq5" ]; then
    echo "❌ ERROR: Larry Williams Setup Max Min EA.mq5 not found"
    exit 1
fi

echo "✅ MQL5 file found"

# Check for required functions
echo
echo "Checking required functions..."

if grep -q "bool HasOpenTrade()" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ HasOpenTrade() function found"
else
    echo "❌ HasOpenTrade() function missing"
fi

if grep -q "void OnTick()" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ OnTick() function found"
else
    echo "❌ OnTick() function missing"
fi

if grep -q "PositionSelectByTicket" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ PositionSelectByTicket usage found"
else
    echo "❌ PositionSelectByTicket usage missing"
fi

if grep -q "trade.PositionClose" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ trade.PositionClose usage found"
else
    echo "❌ trade.PositionClose usage missing"
fi

# Check for error handling
echo
echo "Checking error handling..."

if grep -q "GetLastError()" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ Error handling with GetLastError() found"
else
    echo "❌ Error handling missing"
fi

if grep -q "Print.*Error" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ Error logging found"
else
    echo "❌ Error logging missing"
fi

# Check for magic number filtering
echo
echo "Checking magic number implementation..."

if grep -q "POSITION_MAGIC.*MagicNumber" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ Magic number filtering found"
else
    echo "❌ Magic number filtering missing"
fi

# Check for opposite signal handling
echo
echo "Checking opposite signal handling..."

if grep -q "opposite.*signal\|sell_signal.*buy\|buy_signal.*sell" "Larry Williams Setup Max Min EA.mq5"; then
    echo "✅ Opposite signal handling found"
else
    echo "❌ Opposite signal handling missing"
fi

echo
echo "=== Validation Complete ==="

# Count total lines for reference
total_lines=$(wc -l < "Larry Williams Setup Max Min EA.mq5")
echo "Total lines of code: $total_lines"

echo
echo "Manual verification recommended:"
echo "1. Compile in MetaEditor"
echo "2. Test in Strategy Tester"
echo "3. Verify logging output"