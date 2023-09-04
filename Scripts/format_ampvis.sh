#!/bin/bash
module load R/3.5.0-foss-2018a-X11-20180131

dir_in=('/path/to/mfd_ht_paper/16S_table')
dir_out=('/path/to/mfd_ht_paper/16S_table/otu_out')

Rscript arcbac_sintax_to_combined_tax
Rscript arcbac_combined_tax_to_OTU