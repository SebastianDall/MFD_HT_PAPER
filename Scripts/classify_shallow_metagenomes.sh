#!/usr/bin/env bash
#set up environment

# adds a header to echo, for a better console output overview
echoWithHeader() {
  echo " *** [$(date '+%Y-%m-%d %H:%M:%S')]: $*"
}

echoDuration() {
  duration=$(printf '%02dh:%02dm:%02ds\n' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60)))
  echoWithHeader "Done in: $duration!"
}

# define paths
dir_in=('/path/to/wd')
seq_in=('/path/to/sequences_trim')
dir_out_f=('forward')
dir_out_r=('reverse')
hmms=('/path/to/hmms')
udb=('/path/to/sintax_database')

cd $dir_in
mkdir sintax_classification
cd sintax_classification

# list samples for classification
find $seq_in/*_R1_fastp.fastq.gz > samples_classification.txt

# identify, rename and classify 16S/18S read fragments
while read -r line; do
  input=$(echo ${line} | sed -E 's/_R.+/_/')
  new_dir=$(echo ${line##*/} | sed -E 's/_[^-]+$//')
  new_name=$(echo ${line##*/} | sed -E 's/-[^-]+$//')
  echoWithHeader "  - Starting analysis of sample $name..."
  mkdir $new_dir $new_dir/forward $new_dir/reverse $new_dir/tmp
  #mkdir $new_name $new_name/forward $new_name/reverse $new_name/tmp
  echoWithHeader "  - Searching forward reads for 16S and 18S fragments..."
  module purge
  module load HMMER/3.3.2-foss-2020b
  zcat $input'R1_fastp.fastq.gz' | \
  awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
  tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 20 -o /dev/null --noali --tblout $new_dir/forward/'bac_'$new_name'_forward.hmmout.txt' $hmms/bac.hmm -) | \
  tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 20 -o /dev/null --noali --tblout $new_dir/forward/'arc_'$new_name'_forward.hmmout.txt' $hmms/arc.hmm -) | \
  nhmmer --incE 1e-05 -E 1e-05 --cpu 20 -o /dev/null --noali --tblout $new_dir/forward/'euk_'$new_name'_forward.hmmout.txt' $hmms/euk.hmm -
  echoWithHeader "  - Searching reverse reads for 16S and 18S fragments..."
  zcat $input'R2_fastp.fastq.gz' | \
  awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
  tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 20 -o /dev/null --noali --tblout $new_dir/reverse/'bac_'$new_name'_reverse.hmmout.txt' $hmms/bac.hmm -) | \
  tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 20 -o /dev/null --noali --tblout $new_dir/reverse/'arc_'$new_name'_reverse.hmmout.txt' $hmms/arc.hmm -) | \
  nhmmer --incE 1e-05 -E 1e-05 --cpu 20 -o /dev/null --noali --tblout $new_dir/reverse/'euk_'$new_name'_reverse.hmmout.txt' $hmms/euk.hmm -
  echoWithHeader "  - Extracting reads"
  module purge 
  module load SeqKit/2.0.0
  awk -F " " 'NR>2 {print $1}' $new_dir/forward/'bac_'$new_name'_forward.hmmout.txt' | grep -vE "^#" > $new_dir/tmp/forward_IDs.txt
  awk -F " " 'NR>2 {print $1}' $new_dir/forward/'arc_'$new_name'_forward.hmmout.txt' | grep -vE "^#" >> $new_dir/tmp/forward_IDs.txt
  awk -F " " 'NR>2 {print $1}' $new_dir/forward/'euk_'$new_name'_forward.hmmout.txt' | grep -vE "^#" > $new_dir/tmp/forward_euk_IDs.txt
  sort $new_dir/tmp/forward_IDs.txt | uniq - > $new_dir/tmp/forward_IDs_unique.txt
  awk -F " " 'NR>2 {print $1}' $new_dir/reverse/'bac_'$new_name'_reverse.hmmout.txt' | grep -vE "^#" > $new_dir/tmp/reverse_IDs.txt
  awk -F " " 'NR>2 {print $1}' $new_dir/reverse/'arc_'$new_name'_reverse.hmmout.txt' | grep -vE "^#" >> $new_dir/tmp/reverse_IDs.txt
  awk -F " " 'NR>2 {print $1}' $new_dir/reverse/'euk_'$new_name'_reverse.hmmout.txt' | grep -vE "^#" > $new_dir/tmp/reverse_euk_IDs.txt
  sort $new_dir/tmp/reverse_IDs.txt | uniq - > $new_dir/tmp/reverse_IDs_unique.txt
  seqkit grep -f $new_dir/tmp/forward_IDs_unique.txt $input'R1_fastp.fastq.gz' -o $new_dir/forward/'arc_bac_'$new_name'_forward.fq'
  seqkit grep -f $new_dir/tmp/forward_euk_IDs.txt $input'R1_fastp.fastq.gz' -o $new_dir/forward/'euk_'$new_name'_forward.fq'
  seqkit grep -f $new_dir/tmp/reverse_IDs_unique.txt $input'R2_fastp.fastq.gz' -o $new_dir/reverse/'arc_bac_'$new_name'_reverse.fq'
  seqkit grep -f $new_dir/tmp/reverse_euk_IDs.txt $input'R2_fastp.fastq.gz' -o $new_dir/reverse/'euk_'$new_name'_reverse.fq'
  echoWithHeader "  - Classifying reads"
  module purge
  usearch11 -sintax $new_dir/forward/'arc_bac_'$new_name'_forward.fq' -db $udb -tabbedout $new_dir/forward/'arc_bac_'$new_name'_forward.sintax' -strand both -sintax_cutoff 0.8 -threads 60 -quiet
  usearch11 -sintax $new_dir/reverse/'arc_bac_'$new_name'_reverse.fq' -db $udb -tabbedout $new_dir/reverse/'arc_bac_'$new_name'_reverse.sintax' -strand both -sintax_cutoff 0.8 -threads 60 -quiet
  echoDuration 
done < samples_classification.txt &> >(tee -a classify.log)











