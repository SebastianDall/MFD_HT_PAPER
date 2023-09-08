#!/bin/bash
module load Mamba/4.14.0-0

# Activate R environment
source activate /path/to/conda/envs/R

dir_in=('/path/to/mfd_ht_paper/16S_table')
dir_out=('/path/to/mfd_ht_paper/16S_table/otu_out')

Rscript arcbac_sintax_to_combined_tax
Rscript arcbac_combined_tax_to_OTU