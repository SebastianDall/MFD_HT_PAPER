#!/usr/bin/env bash

#paths
dir_in=('/path/to/mfd_ht_paper/sintax_classification')
dir_out_F=('/path/to/mfd_ht_paper/16S_table/hmm_forward_out')
dir_out_R=('/path/to/mfd_ht_paper/16S_table/hmm_reverse_out')

# find samples - add min and max depth  
find $dir_in -type f -name 'arc_*_forward.hmmout.txt' -exec ln -s '{}' $dir_out_F ';'
find $dir_in -type f -name 'bac_*_forward.hmmout.txt' -exec ln -s '{}' $dir_out_F ';'
find $dir_in -type f -name 'euk_*_forward.hmmout.txt' -exec ln -s '{}' $dir_out_F ';'
find $dir_in -type f -name 'arc_*_reverse.hmmout.txt' -exec ln -s '{}' $dir_out_R ';'
find $dir_in -type f -name 'bac_*_reverse.hmmout.txt' -exec ln -s '{}' $dir_out_R ';'
find $dir_in -type f -name 'euk_*_reverse.hmmout.txt' -exec ln -s '{}' $dir_out_R ';'
