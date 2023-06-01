#!/usr/bin/env bash

# define paths
dir_in=('/path/to/wd')
dir_out_F=('/path/to/sintax_forward')
dir_out_R=('/path/to/sintax_reverse')

# find samples
find $dir_in -type f -name '*arc_bac*_forward.sintax' -exec ln -s '{}' $dir_out_F ';'
find $dir_in -type f -name '*arc_bac*_reverse.sintax' -exec ln -s '{}' $dir_out_R ';' 

