#!/usr/bin/env bash

#paths
dir_in=('/path/to/mfd_ht_paper/sintax_classification')
dir_out_F=('/path/to/mfd_ht_paper/16S_table/sintax_forward_out')
dir_out_R=('/path/to/mfd_ht_paper/16S_table/sintax_reverse_out')

# find samples - add min and max depth
find $dir_in -type f -name '*_forward.sintax' -exec ln -s '{}' $dir_out_F ';'
find $dir_in -type f -name '*_reverse.sintax' -exec ln -s '{}' $dir_out_R ';'