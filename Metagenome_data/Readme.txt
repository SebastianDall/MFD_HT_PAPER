#################################### Readme for Microflora Danica minimnal metadata ####################################

The metadata is the combined metadata from app generated data and
the results from preprocessing of the raw Illumina reads.

Column: 			Description:							Format: 
fieldsample_barcode		Linear barcode used on the sample cup. 				MFD00000 
project_id			Project whitin MFD which the sample belong to.			P00_0
seq_id				Flow-cell lane number appended to library ID.			LIB-MJ000-A0
before_total_reads		Paired-end reads before quality trim and filtering.		Integer
before_total_bases		Paired-end bases before quality trim and filtering.		Integer
before_q20_bases		Q>20 bases before quality trim and filtering.			Integer
before_q30_bases		Q>30 bases before quality trim and filtering.			Integer
before_q20_rate			Rate of Q>20 before quality trim and filtering.			Numeric
before_q30_rate			Rate of Q>30 before quality trim and filtering.			Numeric
before_read1_mean_length	Average number of bp of R1 before quality trim and filtering.	Integer (151)
before_read2_mean_length	Average number of bp of R2 before quality trim and filtering.	Integer (151)
before_gc_content		Average GC content before quality trim and filtering.		Numeric
after_total_reads		Paired-end reads after quality trim and filtering.		Integer
after_total_bases		Paired-end bases after quality trim and filtering.		Integer
after_q20_bases			Q>20 bases after quality trim and filtering.			Integer
after_q30_bases			Q>30 bases after quality trim and filtering.			Integer
after_q20_rate			Rate of Q>20 after quality trim and filtering.			Numeric
after_q30_rate			Rate of Q>20 after quality trim and filtering.			Numeric
after_read1_mean_length		Average number of bp of R1 after quality trim and filtering.	Integer
after_read2_mean_length		Average number of bp of R2 after quality trim and filtering.	Integer
after_gc_content		Average GC content before quality trim and filtering.		Numeric
passed_filter_reads		Number of reads passing all filters.				Integer
corrected_reads			Number of reads corrected by overlap analysis.			Integer
corrected_bases			Number of bases corrected by overlap analysis.			Integer
low_quality_reads		Number of reads filtered due to poor quality (quality >= Q30).	Integer
too_many_N_reads		Number of reads filtered due to too many N bases.		Integer
too_short_reads			Number of reads too short (length >= 100 bp).			Integer
too_long_reads			Number of reads too long. 					Integer (0)
duplication_rate		Rate of duplication of the reads (reads are deduplicated).	Numeric
peak				Peak of insert size estimation.					Integer
seq_run				Name of sequencing run. 					Character
extraction_id			Extraction ID of the sample. 					EXT-MJ000-A0
extraction_plate		Extraction plate name.						EXT00000
extraction_column		Column in extraction plate.					[1-12]
extraction_row			Row in extraction plate. 					[A-H]
extraction_concentration	Concentration of DNA eluate (Qubit HS)				Numeric
extraction_method		Kit or method used for DNA extraction. 				Character
library_id			Library ID of the sample. 					LIB-MJ000-A0
library_plate			Library plate name.						EXT00000
library_column			Column in library plate.					[1-12]
library_row			Row in library plate. 						[A-H]
library_concentration		Concentration of final library (Qubit HS 10X diluted)		Numeric
library_type			Kit and workflow used in the library preparations.		Character
subsample			10-digit translation of subsample 2D tube barcode.		Character
sample_type			Type of sample (soil, sediment, water etc.)			Character
gps_location			GPS coordinates of sampling site.				Character (LAT,LONG)
habitat_type			Type of habitat the sample comes from.				Character
habitat_typenumber		4 digit number describing the sample habitat.			Character*
comment_language		Predicted langugage of sampling comment. 			English/Danish
distributed			Was the fieldsample_barcode in the whitelist?			TRUE/FALSE
sitename			Name of site of the sample.					Character
bio_replicates			Number of biological replicates pooled in sample. 		Integer
received			Timestamp of sampling/addition of metadata.			Date/Month/Year Hour:Minute
surrounding_photo		Filename of area photo.						Character
surrounding_photoadditional	Filename of additional area photo.				Character
surrounding_photoclose		Filename of close-up area photo. 				Character
sampling_comment		Comment added at sampling. 					Character

*Only applicable to the habitat_type of natural_soil. Entries for Agriculture relates to type of crop. 
