#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath -s $0))../../
cd $SCRIPT_PATH

DATASETS_PATH="./datasets/"

# Allow to filter the datasets to be able to launch independent jobs
FILTER="*"
if [ ! -z "$1" ]
then
    FILTER=$1
fi

# Check if the datasets directory exists
if [ ! -d $DATASETS_PATH ]; then
    echo "[!] Datasets directory does not exist."
    echo "    Please download the datasets and place them in $DATASETS_PATH"
    exit 1
fi

cd WFA2-lib
git checkout -- .
git checkout benchmark-sve
make clean all
cd ..

if [ ! -f "WFA2-lib/bin/align_benchmark" ]; then
    echo "[!] Compilation failed."
    cd WFA2-lib
    make clean external-clean
    git checkout -- .
    git checkout benchmark
    cd ..
    exit 1
fi

RESULTS_PATH="results/"
mkdir -p $RESULTS_PATH

for dataset in $DATASETS_PATH/$FILTER.seq; do
    echo "Running benchmarks on $dataset..."
    # Dry run
    ./WFA2-lib/bin/align_benchmark -a edit-wfa -i $dataset --wfa-memory ultralow > /dev/null 2> /dev/null
    # Executing the benchmark
    ./WFA2-lib/bin/align_benchmark -a ksw2-extd2-sve -i $dataset --wfa-memory ultralow -o $RESULTS_PATH/arm-$(basename $dataset).ksw2.sve.out > $RESULTS_PATH/arm-$(basename $dataset).ksw2.sve.stdout 2> $RESULTS_PATH/arm-$(basename $dataset).ksw2.sve.stderr
    # Collecting the performance data
    perf stat -a -M TopDownL1 -e inst_retired,cpu_cycles -o  $RESULTS_PATH/arm-$(basename $dataset).perf.ksw2.sve.txt ./WFA2-lib/bin/align_benchmark -a ksw2-extd2-sve -i $dataset
done


cd WFA2-lib
git checkout -- .
make clean external-clean
git checkout benchmark
cd ..