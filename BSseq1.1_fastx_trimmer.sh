#!/bin/bash
##########################################################################################
# Nov.20 2015, Austin Hilliard, Stanford University Biology, Fernald lab
# BSseq1.1_fastx_trimmer.sh
##########################################################################################
#
# This script runs fastx_trimmer on compressed raw reads
# The data should be organized in the same way as required for BSseq1_bsmap_mbias.sh
#
##########################################################################################
# IMPORTANT: This script is totally inflexible so follow these instructions exactly
##########################################################################################
#
# Input data must be stored as follows:
#  top directory contains one sub-directory for each subject
#  subject directories contain the raw read files and ideally nothing else
#
# There are 4 command line arguments to this script:
# They must be in the exact following order with spaces between
#  1: full path to top directory with data
#      must contain only one sub-dir for each subject and nothing else
#  2: string to grep for raw fastq.gz files within subject dirs
#      format of filenames must be *1$2 and *2$2
#  3: -f option to fastx_trimmer (first base to keep)
#  4: -l option to fastx_trimmer (last base to keep)
#
# It's assumed the input raw read files and output trimmed files are compressed
#
##########################################################################################
# Following the code below is an example use and the console output 
##########################################################################################

data_dir="$1"
raw_data_suffix="$2"
first_to_keep="$3"
last_to_keep="$4"

cd "$data_dir"
subjects=$(ls)
echo -e "\n========================================================================"
echo -e "Moved to:\n ${data_dir}"
echo "------------------------------------------------------------------------"
echo -e "Subject dirs are:\n${subjects}"
echo "------------------------------------------------------------------------"
echo -e "Name format of raw read files will be:\n *1${raw_data_suffix}\n *2${raw_data_suffix}"
echo "------------------------------------------------------------------------"
echo "========================================================================"
echo -e "Trimming... \n"
for s in $subjects
do
	echo "------------------------------------------------------------------------"
	echo "$s"
	echo "------------------------------------------------------------------------"
	date
	reads1=$(ls "$s/"*"1${raw_data_suffix}")
	reads2=$(ls "$s/"*"2${raw_data_suffix}")
	stripped1=$(echo "$reads1" | awk '{gsub(/.fastq.gz/,"");print}')
	stripped2=$(echo "$reads2" | awk '{gsub(/.fastq.gz/,"");print}')
	out1="${stripped1}_trimmed${first_to_keep}-${last_to_keep}.fastq.gz"
	out2="${stripped2}_trimmed${first_to_keep}-${last_to_keep}.fastq.gz"
	echo -e "input read files:\n ${reads1}\n ${reads2}\n"
	echo -e "output files:\n ${out1}\n ${out2}\n"
	gunzip -c "$reads1" | \
	fastx_trimmer -f "$first_to_keep" -l "$last_to_keep" -z -o "$out1"
	gunzip -c "$reads2" | \
	fastx_trimmer -f "$first_to_keep" -l "$last_to_keep" -z -o "$out2"
done

##########################################################################################
# Example 
##########################################################################################
#
# Bio-RDF14:Documents abseq$ /Volumes/fishstudies-1/_scripts/BSseq1.1_fastx_trimmer.sh \
# 							 /Users/abseq/Documents/_BS-seq_data \
# 							 _pf.fastq.gz \
# 							 4 \
# 							 98
# 
# ========================================================================
# Moved to:
#  /Users/abseq/Documents/_BS-seq_data
# ------------------------------------------------------------------------
# Subject dirs are:
#  3157_TENNISON 3165_BRISCOE 3581_LYNLEY 3677_MONK
# ------------------------------------------------------------------------
# Name format of raw read files will be:
#  *1_pf.fastq.gz
#  *2_pf.fastq.gz
# ------------------------------------------------------------------------
# ========================================================================
# Trimming... 
# 
# ------------------------------------------------------------------------
# 3157_TENNISON
# ------------------------------------------------------------------------
# Mon Nov 23 14:27:46 PST 2015
# input read files:
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_1_pf.fastq.gz
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_2_pf.fastq.gz
# 
# output files:
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_1_pf_trimmed4-98.fastq.gz
#  3157_TENNISON/130917_TENNISON_0250_AD2H9VACXX_L4_2_pf_trimmed4-98.fastq.gz
# 
# ------------------------------------------------------------------------
# 3165_BRISCOE
# ------------------------------------------------------------------------
# Mon Nov 23 15:42:55 PST 2015
# input read files:
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_1_pf.fastq.gz
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_2_pf.fastq.gz
# 
# output files:
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_1_pf_trimmed4-98.fastq.gz
#  3165_BRISCOE/130920_BRISCOE_0120_BC2HPBACXX_L2_2_pf_trimmed4-98.fastq.gz
# 
# ------------------------------------------------------------------------
# 3581_LYNLEY
# ------------------------------------------------------------------------
# Mon Nov 23 17:15:00 PST 2015
# input read files:
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_1_pf.fastq.gz
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_2_pf.fastq.gz
# 
# output files:
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_1_pf_trimmed4-98.fastq.gz
#  3581_LYNLEY/131004_LYNLEY_0370_AD2HMEACXX_L6_2_pf_trimmed4-98.fastq.gz
# 
# ------------------------------------------------------------------------
# 3677_MONK
# ------------------------------------------------------------------------
# Mon Nov 23 18:36:24 PST 2015
# input read files:
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_1_pf.fastq.gz
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_2_pf.fastq.gz
# 
# output files:
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_1_pf_trimmed4-98.fastq.gz
#  3677_MONK/131023_MONK_0319_AC2YY8ACXX_L3_2_pf_trimmed4-98.fastq.gz

#/Volumes/fishstudies-1/_scripts/BSseq1.1_fastx_trimmer.sh /Users/abseq/Documents/_BS-seq_data/NCBI_genome _pf.fastq.gz 4 98