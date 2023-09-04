#!/bin/bash
module load Mamba/4.14.0-0

# Activate R environment
source activate /path/to/conda/envs/R

Rscript filter_reads.R