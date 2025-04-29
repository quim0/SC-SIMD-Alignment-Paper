# Get all the .seq files in $DATASETS_PATH and run the benchmarks on them
# Output: The results of the benchmarks are stored in the ./results/ directory

SCRIPT_PATH=$(dirname $(realpath -s $0))/../../
cd $SCRIPT_PATH

DATASETS_PATH="./datasets/"

# Make sure we are in an x86_64 machine
if [ "$(uname -m)" != "x86_64" ]; then
    echo "[!] This script is only for x86_64 machines."
    exit 1
fi

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
git checkout benchmark
make external-clean
git checkout -- .
# Patch to make it compile faster
git apply ../patches/no-libgaba-blockaligner-parasail.patch

# Replace AVX512 with 0 and AVX2 with 0
find wavefront/ -type f -exec sed -i 's/__AVX512CD__/0/g' {} \;
find wavefront/ -type f -exec sed -i 's/__AVX512VL__/0/g' {} \;
find wavefront/ -type f -exec sed -i 's/__AVX2__/1/g' {} \;

# Compile the WFA2-lib
make clean all
cd ..

if [ ! -f "WFA2-lib/bin/align_benchmark" ]; then
    echo "[!] Compilation failed."
    # Restore the original files
    cd WFA2-lib
    git checkout -- .
    exit 1
fi

RESULTS_PATH="results/"
mkdir -p $RESULTS_PATH

for dataset in $DATASETS_PATH/$FILTER.seq; do
    echo "Running benchmarks on $dataset..."
    # Dry run
    ./WFA2-lib/bin/align_benchmark -a edit-wfa -i $dataset --wfa-memory ultralow > /dev/null 2> /dev/null
    # Executing the benchmark
    ./WFA2-lib/bin/align_benchmark -a ksw2-extd2-avx2 -i $dataset -o $RESULTS_PATH/$(basename $dataset).ksw2.avx2.out > $RESULTS_PATH/$(basename $dataset).ksw2.avx2.stdout 2> $RESULTS_PATH/$(basename $dataset).ksw2.avx2.stderr
    # Collecting the performance data
    perf stat -a -e instructions,cycles,cache-misses -M TopdownL1 -o $RESULTS_PATH/$(basename $dataset).perf.ksw2.avx2.txt -- ./WFA2-lib/bin/align_benchmark -a ksw2-extd2-avx2 -i $dataset
done

# Restore the original files
cd WFA2-lib
git checkout -- .
make external-clean clean
