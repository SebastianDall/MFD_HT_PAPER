#!/usr/bin/env bash
#set up environment
#set -eu
module purge
module load bcl2fastq2/2.20.0-foss-2018a
RUNNAME= $ # name of the sequencing run
SAMPLESHEET=/incoming/microflora_danica/sample_sheets/$ # sample sheet .csv 
OUTDIR=/path/to/output/${RUNNAME}
RUNFOLDER=/path/to/raw/${RUNNAME}/
bcl2fastq \
--runfolder-dir $RUNFOLDER \
--output-dir $OUTDIR \
--ignore-missing-bcls \
--ignore-missing-filter \
--ignore-missing-positions \
--mask-short-adapter-reads 0 \
--sample-sheet $SAMPLESHEET \
--loading-threads 4 \
--processing-threads 20 \
--writing-threads 4 \
&> /tmp/${RUNNAME}.log && \
mv /tmp/${RUNNAME}.log /$OUTDIR/${RUNNAME}.log
