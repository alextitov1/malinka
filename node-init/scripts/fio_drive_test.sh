#!/bin/bash -e

TEST_DIR="${1:-/tmp/fio_test}"  # Directory for test files (defaults to /tmp/fio_test)
FILESIZE="1024M"                   # File size
IOENGINE="libaio"               # IO engine
DIRECT=1                         # Direct IO (1 for unbuffered)
SYNC=1                           # sync (0 for Linux to handle flush)

if ! command -v fio &> /dev/null; then
  echo "Error: fio is not installed."
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed."
  exit 1
fi

# # Create test directory if it doesn't exist
# if [ ! -d "$TEST_DIR" ]; then
#   mkdir -p "$TEST_DIR"
# fi

function print_parameters {
  echo "  Block size: $BS"
  echo "  IO depth: $IODEPTH"
  echo "  Number of jobs: $NUMJOBS"
}

# Function to perform FIO test and parse output for specific metric
function perform_test {

  # Build FIO command with arguments
  fio_cmd=" --name=$RW_TYPE"
  fio_cmd+=" --filename=$TEST_DIR/fio_test"
  fio_cmd+=" --readwrite=$RW_TYPE"
  fio_cmd+=" --bs=$BS"
  fio_cmd+=" --ioengine=$IOENGINE"
  fio_cmd+=" --iodepth=$IODEPTH"
  fio_cmd+=" --direct=$DIRECT"
  fio_cmd+=" --numjobs=$NUMJOBS"
  fio_cmd+=" --sync=$SYNC"
  fio_cmd+=" --size=$FILESIZE"
  fio_cmd+=" --output-format=json"
  fio_cmd+=" --group_reporting"

  # Run FIO test
  output=$(fio $fio_cmd)

  # Parse output with jq and extract desired metric
  result=$(echo "$output" | jq -r ".jobs[0].${METRIC}")
  echo "$result"
}



echo "Running storage performance tests"
echo "Common parameters:"
echo "  Test directory: $TEST_DIR"
echo "  File size: $FILESIZE"
echo "  IO engine: $IOENGINE"
echo "  Direct IO: $DIRECT"
echo "  sync: $SYNC"

#### Linear read ####
echo "Linear read (bandwidth)"
BS="4M"        # Block size
IODEPTH=16     # IO depth
NUMJOBS=4      # Number of jobs
RW_TYPE="read"
METRIC="read.bw_bytes"
print_parameters
l_read_result="$(perform_test | numfmt --to=iec-i)/s"
echo "   Result: $l_read_result"
####

#### Ranodm read ####
echo "Random read (IOPS)"
BS="4k"        # Block size
IODEPTH=128    # IO depth
NUMJOBS=4      # Number of jobs
RW_TYPE="randread"
METRIC="read.iops"
print_parameters
r_read_result="$(perform_test | xargs printf "%.0f") IOPS"
echo "   Result: $r_read_result"
####

#### Linear write ####
echo "Linear write (bandwidth)"
BS="4M"        # Block size
IODEPTH=16    # IO depth
NUMJOBS=4      # Number of jobs
RW_TYPE="write"
METRIC="write.bw_bytes"
print_parameters
l_write_result="$(perform_test | numfmt --to=iec-i)/s"
echo "   Result: $l_write_result"
####

#### Random write ####
echo "Random write (IOPS)"
BS="4k"        # Block size
IODEPTH=128    # IO depth
NUMJOBS=4      # Number of jobs
RW_TYPE="randwrite"
METRIC="write.iops"
print_parameters
r_write_result="$(perform_test | xargs printf "%.0f") IOPS"
echo "   Result: $r_write_result"
####

#### Random write single thread####
echo "Random write single thread (IOPS)"
BS="4k"        # Block size
IODEPTH=1      # IO depth
NUMJOBS=1      # Number of jobs
RW_TYPE="randwrite"
METRIC="write.iops"
print_parameters
r_write2_result="$(perform_test | xargs printf "%.0f") IOPS"
echo "   Result: $r_write2_result"
####

# perform_test "write" "write.iops"
# perform_test "write" "write.bw"

# Clean up test files (optional)
# rm -rf "$TEST_DIR"
echo ""
echo "Linear read: $l_read_result"
echo "Random read: $r_read_result"
echo "Linear write: $l_write_result"
echo "Random write: $r_write_result"
echo "Random write single thread: $r_write2_result"

rm -f $TEST_DIR/fio_test
echo "Test completed."
