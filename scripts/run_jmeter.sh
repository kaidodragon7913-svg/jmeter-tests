#!/bin/bash
set -e

TEST_PLAN=${1:-load_test.jmx}
THREADS=${2:-1}
RAMPUP=${3:-0}
DURATION=${4:-300}
URL=${5:-http://localhost}
THROUGHPUT=${6:-1}

WORK_DIR=$(pwd)

rm -rf results/*
mkdir -p results

jmeter -n \
  -t "${WORK_DIR}/test-plans/${TEST_PLAN}" \
  -q "${WORK_DIR}/properties/test.properties" \
  -Jthreads="${THREADS}" \
  -JrampUp="${RAMPUP}" \
  -Jduration="${DURATION}" \
  -Jurl="${URL}" \
  -Jthroughput="${THROUGHPUT}" \
  -l "${WORK_DIR}/results/results.jtl" \
  -e -o "${WORK_DIR}/results/html-report"
