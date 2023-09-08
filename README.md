# High-throughput DNA extraction and cost-effective miniaturized metagenome and amplicon library preparation of soil samples for DNA sequencing

## Introduction

This repo contains the source code for the analysis in "High-throughput DNA extraction and cost-effective miniaturized metagenome and amplicon library preparation of soil samples for DNA sequencing" available at [BioRxiv](https://doi.org/10.1101/2023.09.04.556179)

To reproduce the results open the following Rmarkdown files and run the code chunks in order.

1. [DNA Extraction Benchmark](./Benchmarking/2023-03-29_Benchmarking.Rmd)
2. [Downscaled Illumina Amplicon Library Protocol](./Scaledown/2023-03-22_Scaledown-amplicons.Rmd)
3. [Downscaled Illumina DNA prep Protocol](./Scaledown/2023-03-22_Scaledown-metagenomes.Rmd)

Similarly, the code for the supplementary files can be found at:

- [Supplementary file 1](./Lab_optimization/2023-05-22_Benchmarking_optimization.Rmd)
- [Supplementary file 2](./Lab_optimization/2023-05-22_Benchmarking_optimization.Rmd)
- [Supplementary file 3](./Lab_optimization/2023-04-22_SPB_optimization.Rmd)

## Dependencies

### Downloading the data

Raw data can be downloaded from the [European Nucleotide Archive](https://www.ebi.ac.uk/ena/browser/home) under the project accession number [PRJEB65366](https://www.ebi.ac.uk/ena/browser/view/PRJEB65366).

### Processing the data

#### Amplicons

To process the amplicon reads, use the `AmpProc5.1` available at [github](https://github.com/eyashiro/AmpProc):

1. Make sure that you create an empty directory, where you have just the file containing your sample ID names. Call your file: `samples`.
2. Type in the terminal: `AmpProc5.1`

3. Answer the following questions. Answers are case-sensitive!
   What workflow do you want to run (MiDAS / Standard)? S
   Generate a ZOTU table using UNOISE3? both
   Process single-end reads (SR) and/or paired-end reads (PE)? R1
   Remove primer region R1? 0 bases
   Remove primer region R2? 0 bases
   Amplicon region? V4
   Reference database to use for taxonomy prediction? 3 ) silva99pc1381, SILVA SSUREFNR99% trunc v138.1
   Number of threads: 10
   Make a phylo/cluster tree: no
   Generate beta diversity output: no

This will create the following files: `zotutable.R1.txt`, `otutable.R1.txt`, `zotutable_notax.txt`, and `zotus.R1.fa`.

The `zotus.R1.fa` was subsequently classified using [`SINTAX`](https://www.drive5.com/usearch/manual/sintax_algo.html) and the database `AutoTax_SILVA_138.1_Nr99_sintax_trunc.udb` at `-sintax-cutoff 0.8`. The full command is:

```bash
usearch -sintax zotus.R1.fa -db AutoTax_SILVA_138.1_Nr99_sintax_trunc.udb -tabbedout zotus.R1.sintax \
  -strand both -sintax_cutoff 0.8
```

The `zotutbale_notax.txt` and `zotus.R1.sintax` were used for the analysis.

#### Metagenomes

For metagenomes, the reads were trimmed using [`fastp`](https://github.com/OpenGene/fastp) and subsequently renamed. Use the following script to do so:

```bash
bash Scripts/trim_rename.sh
```

16S fragments were identified using [`HMMER`](https://github.com/EddyRivasLab/hmmer), extracted with [`SeqKit`](https://github.com/shenwei356/seqkit), and classified using `SINTAX` (using the same command as in [Amplicons](#amplicons)). Use the following script to do so:

```bash
bash Scripts/classify_shallow_metagenomes.sh
```

`filter_reads.R` takes the output from `classify_shallow_metagenomes.sh` and evalutes the `hmmout.txt` files for IDs mapping to bacteria and archaea. The output will be six files: `ARC_reads.txt`, `ARC_reads_samples.txt`, `BAC_reads.txt`, `BAC_reads_samples.txt`, `EUK_reads.txt`, and `EUK_reads_samples.txt`. To run the script, use the following command:

```bash
bash Scripts/filter_reads.sh
```

Only the bacterial and archaeal reads were used for the analysis.

### R packages

Data analysis was done with R (4.2) and RStudio (2023.03.0+386). The requirede R packages are specified in the `renv.lock` file. To install them, run the following code:

```r
install.packages("renv")
renv::restore()
```

## Contact

For any questions related to the paper, please contact the corresponding author: Prof. [Mads Albertsen](mailto:ma@bio.aau.dk)
For any questions related to the code, please contact [Thomas Bygh Nymann jensen](mailto:tbnj@bio.aau.dk) or [Sebastian Dall](mailto:semoda@bio.aau.dk)
