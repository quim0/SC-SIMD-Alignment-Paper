## Setup

```bash
git clone https://github.com/quim0/SC-SIMD-Alignment-Paper.git
cd SC-SIMD-Alignment-Paper/
git submodule update --init --recursive
```

This repository include a subset of the original datasets used in the paper for testing purposes. They should be uncompressed before running the experiments:

```
gzip -d datasets/*.seq.gz
```

The full datasets can be downloaded from the following link: [https://doi.org/10.5281/zenodo.15301455](https://doi.org/10.5281/zenodo.15301455)

## Repository Structure

```bash
. # Root directory
├── datasets/ # Directory containing a subset of the datasets used in the paper, for testing purposes
│   ├── Illumina.250.100K.seq      # 100K sequences
│   ├── ONT.PromethION-10K.130.seq # 130 sequences
│   ├── PacBio.HF.500.seq          # 500 sequences
├── scripts/
│   ├── wfa # Directory containing the scripts to run the WFA experiments
│   ├── ksw2 # Directory containing the scripts to run the KSW2 experiments
```

The results of the executions are saved in the `results` directory. Note that the output of the benchmarks is on the stderr.