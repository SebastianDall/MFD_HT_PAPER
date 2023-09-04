#!/usr/bin/env bash
# set up environment
set -eu
module purge
module load ea-utils parallel
module load fastp/0.23.2-GCC-10.2.0

# make directories
mkdir mfd_ht_paper
cd mfd_ht_paper
mkdir sequences_trim
mkdir log
mkdir log/json
mkdir log/html

# define paths
dir_in=('/path/to/raw')
log_json=('log/json')
log_html=('log/html')
dir_out=('sequences_trim')

# find directories
find $dir_in -mindepth 2 -maxdepth 2 -type d ! -path "$dir_in/Stats/*" ! -path "$dir_in/Reports/*" | grep -v "LIB*" > directories.txt

# rename and create commands for parallel
while read -r line; do
  dir_name=$(echo ${line##*/} | sed 's/_/-/g' | sed -E 's/[0-9]{5}//')
  input_R1=$(echo $line/*_R1_001.fastq.gz)
  input_R2=$(echo $line/*_R2_001.fastq.gz)
  new_name=$(echo ${input_R1##*/} | sed -E 's/_[^L]+L0/-/' | sed -E 's/_R.+//' | sed -E "s/sample/$dir_name/")
  echo fastp \
  --in1 $input_R1 \
  --in2 $input_R2 \
  --out1 $dir_out/$new_name'_R1_fastp.fastq' \
  --out2 $dir_out/$new_name'_R2_fastp.fastq' \
  --correction \
  --detect_adapter_for_pe \
  --cut_right \
  --cut_right_window_size 4 \
  --cut_right_mean_quality 20 \
  --average_qual 30 \
  --length_required 100 \
  --dedup \
  --dup_calc_accuracy 6 \
  --thread 6 \
  --overrepresentation_analysis \
  --json $log_json/$new_name'_fastp.json' \
  --html $log_html/$new_name'_fastp.html' \
  >> command.txt
done < directories.txt

# run commands in parallel 
cat command.txt | parallel -j10 --tmpdir ../tmp/ &> >(tee -a trim.log)

# multithreaded zipping with pigz - writing fastp output to fastq as intrinsic gzip function is broken: Github issue #180
module purge
module load pigz/2.4-foss-2018a

for i in $dir_out/*.fastq; do
  pigz -9 -p 60 $i
done

