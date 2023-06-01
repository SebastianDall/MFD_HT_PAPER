#!/bin/bash
module load R/3.5.0-foss-2018a-X11-20180131

dir_in=('/path/to/wd')
dir_out=('/path/to/wd/otu_out')

Rscript sintax_to_combined_tax.R
Rscript combined_tax_to_OTU.R