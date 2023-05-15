# DNA Extraction and Miniaturization of Library Preparations on Soil Samples in a High Throughput Setting

## Introduction

This repo contains the source code for the analysis in "DNA Extraction and Miniaturization of Library Preparations on Soil Samples in a High Throughput Setting"

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

The requirede R packages are specified in the `renv.lock` file. To install them, run the following code in R:

```r
install.packages("renv")
renv::restore()
```

## Contact

For any questions, please contact the corresponding author: [Professor Mads Albertsen](mailto:ma@bio.aau.dk)
