#!/bin/bash

# Ramp-up Load Test Script
# This script runs siege tests with increasing concurrent users (30, 40, 50)
# Each test runs for 10 seconds with no delay between requests
# No parsing of HTML and no following redirects

LOG_FILE="./logs/siege_test_case_01.log"

echo "Starting ramp-up load test..."
echo "Log file: $LOG_FILE"

for c in 30 40 50; do
  echo "Concurrent users: $c"
  siege -t 10S -b -d0 -c$c --no-parser --no-follow -f siege.txt 2>&1 \
  | sed -r "s/\x1B\[[0-9;]*[mK]//g" | grep -v "^HTTP/" >> "$LOG_FILE"
  sleep 5
done