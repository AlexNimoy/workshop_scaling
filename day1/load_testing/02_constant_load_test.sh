#!/bin/bash

# Constant Load Test Script
# This script runs a siege test with 50 concurrent users for 1 minute
# The test is run in benchmark mode (-b) with no delay between requests (-d0)
# No parsing of HTML (-no-parser) and no following redirects (-no-follow)

LOG_FILE="./logs/siege_test_case_02.log"

echo "Starting constant load test with 50 concurrent users for 1 minute..."
echo "Log file: $LOG_FILE"

siege -t 1M -b -d0 -c50 --no-parser --no-follow -f siege.txt 2>&1 \
| sed -r "s/\x1B\[[0-9;]*[mK]//g" | grep -v "^HTTP/" > "$LOG_FILE"
