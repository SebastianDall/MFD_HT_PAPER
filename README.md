# High-throughput DNA extraction and cost-effective miniaturized metagenome and amplicon library preparation of soil samples for DNA sequencing

## Introduction

This repo contains the source code for the analysis in "High-throughput DNA extraction and cost-effective miniaturized metagenome and amplicon library preparation of soil samples for DNA sequencing" available at [BioRxiv](https://doi.org/10.1101/2023.09.04.556179)

Each results section has its own code folder. To reproduce the results open the `master.Rmd` file and run the code chunks in order.

1. [DNA Extraction Benchmark](./Benchmarking/)
2. [Downscaled Illumina Amplicon Library Protocol](./Amplicon_scaledown/)
3. [Downscaled Illumina DNA prep Protocol](./Illumina_scaledown/)

Similarly, the code for the supplementary files can be found at:

1. [Supplementary File 1](./) > Change me
2. [Supplementary File 2](./) > Change me
3. [Supplementary File 3](./) > Change me

## Dependencies

### Downloading the data

The data is available at ...

### R packages

Data analysis was done with R (4.2) and RStudio (2023.03.0+386). The requirede R packages are specified in the `renv.lock` file. To install them, run the following code:

```r
install.packages("renv")
renv::restore()
```

## Contact

For any questions related to the paper, please contact the corresponding author: Prof. [Mads Albertsen](mailto:ma@bio.aau.dk)
For any questions related to the code, please contact [Thomas Bygh Nymann jensen](mailto:tbnj@bio.aau.dk) or [Sebastian Dall](mailto:semoda@bio.aau.dk)
