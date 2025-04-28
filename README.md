## Setup

```bash
git submodule update --init --recursive
gzip -d datasets/*.seq.gz
```

## Repository Structure

```bash
. # Root directory
├── datasets/ # Directory containing a subset of the datasets used in the paper, for testing purposes
│   ├── Illumina.250.100K.seq      # 100K sequences
│   ├── ONT.PromethION-10K.130.seq # 130 sequences
│   ├── PacBio.HF.500.seq          # 500 sequences
├── figures/ # Directory containing the code to generate the figures in the paper
├── scripts/
│   ├── wfa # Directory containing the scripts to run the WFA experiments
│   ├── ksw2 # Directory containing the scripts to run the KSW2 experiments
```

The results of the executions are saved in the `results` directory.