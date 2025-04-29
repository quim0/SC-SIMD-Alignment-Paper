SCRIPT_PATH=$(dirname $(realpath -s $0))../../
cd $SCRIPT_PATH

DATASETS_PATH="./datasets"

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

for dataset in $DATASETS_PATH/*.seq; do
    echo "Running benchmarks on $dataset..."
    # Dry run
    ./WFA2-lib/bin/align_benchmark -a edit-wfa -i $dataset --wfa-memory ultralow > /dev/null 2> /dev/null
    # Executing the benchmark
    ./WFA2-lib/bin/align_benchmark -a gap-affine2p-wfa -i $dataset --wfa-memory ultralow -o $RESULTS_PATH/arm-$(basename $dataset).wfa.sve.out > $RESULTS_PATH/arm-$(basename $dataset).wfa.sve.stdout 2> $RESULTS_PATH/arm-$(basename $dataset).wfa.sve.stderr
    # Collecting the performance data
    perf stat -a -M TopDownL1 -e inst_retired,cpu_cycles -o $RESULTS_PATH/arm-$(basename $dataset).perf.wfa.sve.txt -- ./WFA2-lib/bin/align_benchmark -a gap-affine2p-wfa --wfa-memory ultralow -i $dataset
done

# Restore the original files
cd WFA2-lib
make clean external-clean
git checkout -- .
git checkout benchmark
cd ..