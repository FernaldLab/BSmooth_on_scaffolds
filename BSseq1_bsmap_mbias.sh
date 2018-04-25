#!/bin/bash
##########################################################################################
# Nov.20 2015, Austin Hilliard, Stanford University Biology, Fernald lab
# BSseq1_bsmap_mbias.sh
##########################################################################################
#
# This script will run bsmap on raw WGBS read files
#  output .sam files will be sorted and saved as .bam files
#  m-bias plot will be made for each subject, to decide whether to trim bases and re-align
#
# When first called it will print relevant settings and reminders to the console,
#  then wait for a user key press before continuing
#
##########################################################################################
# IMPORTANT: This script is totally inflexible so follow these instructions exactly
##########################################################################################
#
# Input data must be stored as follows:
#  top directory contains one sub-directory for each subject
#  subject directories contain the raw read files and ideally nothing else
#
# Command line args must be in the exact following order with spaces between
#  make sure to put full pathnames for 1,3,4,6
#  1: full path to top directory with data
#      must contain only one sub-dir for each subject and nothing else
#  2: string to grep for raw fastq.gz files within subject dirs
#      format of filenames must be *1$2 and *2$2
#  3: full path to bsmap binary
#  4: full path to genome fasta file
#  5: base filename for bsmap output
#      make sure it reflects the hard-coded bsmap settings
#  6: full path to python script for making m-bias plot
#
# Bio-RDF14:abseq$ BSseq1_bsmap_mbias.sh data_dir raw_data_suffix bsmap_path genome bsmap_out_base mbias_path 
#
##########################################################################################
# Following the code below is an example use and the console output 
##########################################################################################

data_dir="$1"  
raw_data_suffix="$2"
bsmap_path="$3"
genome="$4"
bsmap_out_base="$5"
mbias_path="$6"

cd "$data_dir"
subjects=$(ls)
echo -e "\n========================================================================"
echo -e "Moved to:\n ${data_dir}"
echo "------------------------------------------------------------------------"
echo -e "Subject dirs are:\n${subjects}"
echo "------------------------------------------------------------------------"
echo -e "Name format of raw read files will be:\n *1${raw_data_suffix}\n *2${raw_data_suffix}"
echo "------------------------------------------------------------------------"
echo -e "\nWill use bsmap version:\n ${bsmap_path}"
echo "------------------------------------------------------------------------"
echo -e "bsmap will output files as:\n subject_dir/${bsmap_out_base}.sam"
echo "WARNING:"
echo " bsmap settings are hard-coded in this script, check them and make sure output name is smart"
echo "------------------------------------------------------------------------"
echo -e "Will use genome file:\n ${genome}"
echo "------------------------------------------------------------------------"
echo "Will convert output .sam into sorted .bam file, make index, then delete .sam file"
echo "------------------------------------------------------------------------"
echo "Will use ${mbias_path} to make m-bias plots"
echo -e "========================================================================\n"
echo -e "------------------------------------------------------------------------\n"
read -rsp "If this is all good press any key to continue, or ctrl+c to quit..." -n1 

for s in $subjects
do
	echo -e "\n========================================================================"
	echo "Working on ${s}"
	echo "========================================================================"
	reads1=$(ls "$s/"*"1${raw_data_suffix}")
	reads2=$(ls "$s/"*"2${raw_data_suffix}")
	echo -e "read files:\n ${reads1}\n ${reads2}\n"
	echo -e "will write output file:\n ${s}/${bsmap_out_base}.sam\n"
	"$bsmap_path" \
	-a "$reads1" \
	-b "$reads2" \
	-d "$genome" \
	-o "${s}/${bsmap_out_base}.sam" \
	-A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC \
	-q 30 -m 0 \
	-S 1

	echo -e "\n------------------------------------------------------------------------"
	echo "Converting .sam to sorted .bam and creating index..."
	echo -e "------------------------------------------------------------------------\n"
	samtools view -bS "${s}/${bsmap_out_base}.sam" | \
	samtools sort - "${s}/${bsmap_out_base}"
	samtools index "${s}/${bsmap_out_base}.bam"
	rm "${s}/${bsmap_out_base}.sam"

	echo "------------------------------------------------------------------------"
	echo "Making m-bias plot..."
	echo -e "------------------------------------------------------------------------\n"
	python "$mbias_path" "${s}/${bsmap_out_base}.bam" "$genome"
done

##########################################################################################
# Example 
##########################################################################################
# Comments:
#  After bsmap runs there's an error I don't understand:
#   40125 Abort trap: 6 
#  As far as I can tell bsmap writes a complete, valid .sam file
#  The error may reflect some process trying to write to memory it doesn't own
#
#  There's a samtools/matplotlib error after the m-bias plot script but the plots are fine
#  The plotting script was taken from the bwa-meth github (https://github.com/brentp/bwa-meth) 
#   and I installed some other python libs to get it working, I'm surprised it works at all
#
#  Based on the m-bias plots here I'll trim 3 bases from both ends of all reads then re-align
##########################################################################################
#
# Bio-RDF14:Documents abseq$ /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh \
# 							 /Users/abseq/Documents/_BS-seq_data/ _pf.fastq.gz /Users/abseq/Documents/bsmap-2.90/bsmap \
# 							 /Users/abseq/Documents/H_burtoni_v1.assembly.fa \
# 							 aligned.adapters.q30.m0_bsmap2.9 \
# 							 /Volumes/fishstudies-1/_scripts/bwa-meth_bias-plot.py 
#
# ========================================================================
# Moved to:
#  /Users/abseq/Documents/_BS-seq_data/
# ------------------------------------------------------------------------
# Subject dirs are:
#  3157_TENNISON 3165_BRISCOE 3581_LYNLEY 3677_MONK
# ------------------------------------------------------------------------
# Name format of raw read files will be:
#  *1_pf.fastq.gz
#  *2_pf.fastq.gz
# ------------------------------------------------------------------------
# 
# Will use bsmap version:
#  /Users/abseq/Documents/bsmap-2.90/bsmap
# ------------------------------------------------------------------------
# bsmap will output files as:
#  SUBJECT_DIR/aligned.adapters.q30.m0_bsmap2.9.sam
# WARNING:
#  bsmap settings are hard-coded in this script, check them and make sure output name is smart
# ------------------------------------------------------------------------
# Will use genome file:
#  /Users/abseq/Documents/H_burtoni_v1.assembly.fa
# ------------------------------------------------------------------------
# Will convert output .sam into sorted .bam file, make index, then delete .sam file
# ------------------------------------------------------------------------
# Will use /Volumes/fishstudies-1/_scripts/bwa-meth_bias-plot.py to make m-bias plots
# ========================================================================
# 
# ------------------------------------------------------------------------
# 
# If this is all good press any key to continue, or ctrl+c to quit...
# ------------------------------------------------------------------------
# 
# ========================================================================
# Working on 3157_TENNISON
# ========================================================================
# read files:
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_1_pf.fastq.gz
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_2_pf.fastq.gz
# 
# will write output file:
#  3157_TENNISON/aligned.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Fri Nov 20 16:47:06 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Fri Nov 20 16:47:16 2015 	8001 reference seqs loaded, total size 831411547 bp. 10 secs passed
# [bsmap] @Fri Nov 20 16:47:27 2015 	create seed table. 21 secs passed
# [bsmap] @Fri Nov 20 16:47:27 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_1_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_2_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3157_TENNISON/aligned.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Fri Nov 20 18:07:57 2015 	total read pairs: 114891459 	total time consumed:  4851 secs
# 	aligned pairs: 66356318 (57.8%), unique pairs: 60551212 (52.7%), non-unique pairs: 5805106 (5.1%)
# 	unpaired read #1: 12330042 (10.7%), unique reads: 9151551 (8.0%), non-unique reads: 3178491 (2.8%)
# 	unpaired read #2: 12234190 (10.6%), unique reads: 8739382 (7.6%), non-unique reads: 3494808 (3.0%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 56: 40125 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 65 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3157_TENNISON/aligned.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3157_TENNISON/aligned.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
# ========================================================================
# Working on 3165_BRISCOE
# ========================================================================
# read files:
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_1_pf.fastq.gz
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_2_pf.fastq.gz
# 
# will write output file:
#  3165_BRISCOE/aligned.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Fri Nov 20 19:15:37 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Fri Nov 20 19:15:47 2015 	8001 reference seqs loaded, total size 831411547 bp. 10 secs passed
# [bsmap] @Fri Nov 20 19:15:58 2015 	create seed table. 21 secs passed
# [bsmap] @Fri Nov 20 19:15:58 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_1_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_2_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3165_BRISCOE/aligned.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Fri Nov 20 20:57:28 2015 	total read pairs: 137675454 	total time consumed:  6111 secs
# 	aligned pairs: 73808493 (53.6%), unique pairs: 66568757 (48.4%), non-unique pairs: 7239736 (5.3%)
# 	unpaired read #1: 16415368 (11.9%), unique reads: 12280698 (8.9%), non-unique reads: 4134670 (3.0%)
# 	unpaired read #2: 16835165 (12.2%), unique reads: 11969447 (8.7%), non-unique reads: 4865718 (3.5%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 56: 40242 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 74 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3165_BRISCOE/aligned.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3165_BRISCOE/aligned.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
# ========================================================================
# Working on 3581_LYNLEY
# ========================================================================
# read files:
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_1_pf.fastq.gz
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_2_pf.fastq.gz
# 
# will write output file:
#  3581_LYNLEY/aligned.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Fri Nov 20 22:27:34 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Fri Nov 20 22:27:43 2015 	8001 reference seqs loaded, total size 831411547 bp. 9 secs passed
# [bsmap] @Fri Nov 20 22:27:55 2015 	create seed table. 21 secs passed
# [bsmap] @Fri Nov 20 22:27:55 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_1_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_2_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3581_LYNLEY/aligned.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Sat Nov 21 00:02:50 2015 	total read pairs: 123614639 	total time consumed:  5716 secs
# 	aligned pairs: 69852665 (56.5%), unique pairs: 63142731 (51.1%), non-unique pairs: 6709934 (5.4%)
# 	unpaired read #1: 15266437 (12.4%), unique reads: 11153983 (9.0%), non-unique reads: 4112454 (3.3%)
# 	unpaired read #2: 15069058 (12.2%), unique reads: 10608375 (8.6%), non-unique reads: 4460683 (3.6%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 56: 40410 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 70 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3581_LYNLEY/aligned.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3581_LYNLEY/aligned.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
# ========================================================================
# Working on 3677_MONK
# ========================================================================
# read files:
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_1_pf.fastq.gz
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_2_pf.fastq.gz
# 
# will write output file:
#  3677_MONK/aligned.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Sat Nov 21 01:22:05 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Sat Nov 21 01:22:15 2015 	8001 reference seqs loaded, total size 831411547 bp. 10 secs passed
# [bsmap] @Sat Nov 21 01:22:27 2015 	create seed table. 22 secs passed
# [bsmap] @Sat Nov 21 01:22:27 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_1_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_2_pf.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3677_MONK/aligned.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Sat Nov 21 02:54:04 2015 	total read pairs: 122414964 	total time consumed:  5519 secs
# 	aligned pairs: 68128108 (55.7%), unique pairs: 61988246 (50.6%), non-unique pairs: 6139862 (5.0%)
# 	unpaired read #1: 14551674 (11.9%), unique reads: 10758062 (8.8%), non-unique reads: 3793612 (3.1%)
# 	unpaired read #2: 14624569 (11.9%), unique reads: 10395751 (8.5%), non-unique reads: 4228818 (3.5%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 56: 40595 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 68 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3677_MONK/aligned.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3677_MONK/aligned.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
##########################################################################################

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------

##########################################################################################
# Another example run
##########################################################################################
# Comments:
#  After trimming 3bp from both ends of reads
#  Mapping percentages were slightly better than they were before trimming
##########################################################################################
#
# Bio-RDF14:Documents abseq$ /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh \
# 							 /Users/abseq/Documents/_BS-seq_data/ \
# 							 _pf_trimmed4-98.fastq.gz \
# 							 /Users/abseq/Documents/bsmap-2.90/bsmap \
# 							 /Users/abseq/Documents/H_burtoni_v1.assembly.fa \
# 							 aligned_trimmed4-98.adapters.q30.m0_bsmap2.9 \
# 							 /Volumes/fishstudies-1/_scripts/bwa-meth_bias-plot.py
# 
# ========================================================================
# Moved to:
#  /Users/abseq/Documents/_BS-seq_data/
# ------------------------------------------------------------------------
# Subject dirs are:
#  3157_TENNISON 3165_BRISCOE 3581_LYNLEY 3677_MONK
# ------------------------------------------------------------------------
# Name format of raw read files will be:
#  *1_pf_trimmed4-98.fastq.gz
#  *2_pf_trimmed4-98.fastq.gz
# ------------------------------------------------------------------------
# 
# Will use bsmap version:
#  /Users/abseq/Documents/bsmap-2.90/bsmap
# ------------------------------------------------------------------------
# bsmap will output files as:
#  SUBJECT_DIR/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam
# WARNING:
#  bsmap settings are hard-coded in this script, check them and make sure output name is smart
# ------------------------------------------------------------------------
# Will use genome file:
#  /Users/abseq/Documents/H_burtoni_v1.assembly.fa
# ------------------------------------------------------------------------
# Will convert output .sam into sorted .bam file, make index, then delete .sam file
# ------------------------------------------------------------------------
# Will use /Volumes/fishstudies-1/_scripts/bwa-meth_bias-plot.py to make m-bias plots
# ========================================================================
# 
# ------------------------------------------------------------------------
# 
# If this is all good press any key to continue, or ctrl+c to quit...========================================================================
# Working on 3157_TENNISON
# ========================================================================
# read files:
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_1_pf_trimmed4-98.fastq.gz
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_2_pf_trimmed4-98.fastq.gz
# 
# will write output file:
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Tue Nov 24 11:52:35 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Tue Nov 24 11:52:44 2015 	8001 reference seqs loaded, total size 831411547 bp. 9 secs passed
# [bsmap] @Tue Nov 24 11:52:56 2015 	create seed table. 21 secs passed
# [bsmap] @Tue Nov 24 11:52:56 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_1_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_2_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Tue Nov 24 13:05:03 2015 	total read pairs: 114891459 	total time consumed:  4348 secs
# 	aligned pairs: 67412600 (58.7%), unique pairs: 61112215 (53.2%), non-unique pairs: 6300385 (5.5%)
# 	unpaired read #1: 12589712 (11.0%), unique reads: 9237250 (8.0%), non-unique reads: 3352462 (2.9%)
# 	unpaired read #2: 12458311 (10.8%), unique reads: 8812416 (7.7%), non-unique reads: 3645895 (3.2%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 69:  3104 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 66 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
# ========================================================================
# Working on 3165_BRISCOE
# ========================================================================
# read files:
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_1_pf_trimmed4-98.fastq.gz
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_2_pf_trimmed4-98.fastq.gz
# 
# will write output file:
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Tue Nov 24 14:12:22 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Tue Nov 24 14:12:32 2015 	8001 reference seqs loaded, total size 831411547 bp. 10 secs passed
# [bsmap] @Tue Nov 24 14:12:43 2015 	create seed table. 21 secs passed
# [bsmap] @Tue Nov 24 14:12:43 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_1_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_2_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Tue Nov 24 15:48:40 2015 	total read pairs: 137675454 	total time consumed:  5778 secs
# 	aligned pairs: 75136885 (54.6%), unique pairs: 67270054 (48.9%), non-unique pairs: 7866831 (5.7%)
# 	unpaired read #1: 16963090 (12.3%), unique reads: 12567031 (9.1%), non-unique reads: 4396059 (3.2%)
# 	unpaired read #2: 17207508 (12.5%), unique reads: 12119535 (8.8%), non-unique reads: 5087973 (3.7%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 69:  3353 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 76 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
# ========================================================================
# Working on 3581_LYNLEY
# ========================================================================
# read files:
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_1_pf_trimmed4-98.fastq.gz
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_2_pf_trimmed4-98.fastq.gz
# 
# will write output file:
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Tue Nov 24 17:13:32 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Tue Nov 24 17:13:42 2015 	8001 reference seqs loaded, total size 831411547 bp. 10 secs passed
# [bsmap] @Tue Nov 24 17:13:54 2015 	create seed table. 22 secs passed
# [bsmap] @Tue Nov 24 17:13:54 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_1_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_2_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Tue Nov 24 18:36:37 2015 	total read pairs: 123614639 	total time consumed:  4985 secs
# 	aligned pairs: 71192785 (57.6%), unique pairs: 63872941 (51.7%), non-unique pairs: 7319844 (5.9%)
# 	unpaired read #1: 15587990 (12.6%), unique reads: 11262188 (9.1%), non-unique reads: 4325802 (3.5%)
# 	unpaired read #2: 15398786 (12.5%), unique reads: 10706652 (8.7%), non-unique reads: 4692134 (3.8%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 69:  3984 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 71 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1
# ========================================================================
# Working on 3677_MONK
# ========================================================================
# read files:
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_1_pf_trimmed4-98.fastq.gz
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_2_pf_trimmed4-98.fastq.gz
# 
# will write output file:
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam
# 
# [bsmap] @Tue Nov 24 19:53:05 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa 	(format: FASTA)
# [bsmap] @Tue Nov 24 19:53:15 2015 	8001 reference seqs loaded, total size 831411547 bp. 10 secs passed
# [bsmap] @Tue Nov 24 19:53:27 2015 	create seed table. 22 secs passed
# [bsmap] @Tue Nov 24 19:53:27 2015 	Pair-end alignment(8 threads),
# 	Input read file #1: 3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_1_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Input read file #2: 3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_2_pf_trimmed4-98.fastq.gz 	(format: gzipped FASTQ)
# 	Output file: 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.sam	 (format: SAM)
# [bsmap] @Tue Nov 24 21:14:28 2015 	total read pairs: 122414964 	total time consumed:  4883 secs
# 	aligned pairs: 69427255 (56.7%), unique pairs: 62709140 (51.2%), non-unique pairs: 6718115 (5.5%)
# 	unpaired read #1: 14974490 (12.2%), unique reads: 10944191 (8.9%), non-unique reads: 4030299 (3.3%)
# 	unpaired read #2: 15007540 (12.3%), unique reads: 10531881 (8.6%), non-unique reads: 4475659 (3.7%)
# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh: line 69:  4517 Abort trap: 6           $bsmap_path -a $reads1 -b $reads2 -d $genome -o $s"/"$bsmap_out_base".sam" -A GAGCCGTAAGGACGACTTGG -A ACACTCTTTCCCTACACGAC -q 30 -m 0 -S 1
# 
# ------------------------------------------------------------------------
# Converting .sam to sorted .bam and creating index...
# ------------------------------------------------------------------------
# 
# [bam_sort_core] merging from 69 files...
# ------------------------------------------------------------------------
# Making m-bias plot...
# ------------------------------------------------------------------------
# 
# wrote to 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.txt
# saving to 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bias.png
# /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/matplotlib/tight_layout.py:225: UserWarning: tight_layout : falling back to Agg renderer
#   warnings.warn("tight_layout : falling back to Agg renderer")
# samtools: writing to standard output failed: Broken pipe
# samtools: error closing standard output: -1











# /Volumes/fishstudies-1/_scripts/BSseq1_bsmap_mbias.sh /Users/abseq/Documents/_BS-seq_data/NCBI_genome/ _pf.fastq.gz /Users/abseq/Documents/bsmap-2.90/bsmap /Users/abseq/Documents/_annotationsDec2015/hbu_ref_AstBur1.0_chrUn_reducedHeaders.fa aligned.adapters.q30.m0_bsmap2.9_ncbiGenome /Volumes/fishstudies-1/_scripts/bwa-meth_bias-plot.py