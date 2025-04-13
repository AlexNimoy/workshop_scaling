#!/bin/bash

# Peak Load Test Script
# This script runs a siege test with 100 concurrent users for 20 seconds
# The test is run in benchmark mode (-b) with no delay between requests (-d0)
# No parsing of HTML (-no-parser) and no following redirects (-no-follow)

LOG_FILE="./logs/siege_test_case_03.log"

echo "Starting peak load test with 100 concurrent users for 20 seconds..."
echo "Log file: $LOG_FILE"

siege -t 20S -b -d0 -c100 --no-parser --no-follow -f siege.txt 2>&1 \
| sed -r "s/\x1B\[[0-9;]*[mK]//g" | grep -v "^HTTP/" > "$LOG_FILE" 