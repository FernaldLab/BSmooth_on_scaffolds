#!/bin/bash
##########################################################################################
# Dec.09 2015, Austin Hilliard, Stanford University Biology, Fernald lab
# BSseq2_methratio.sh
##########################################################################################
#
# This script will run methratio.py (from bsmap) on .bam files
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
#  subject directories contain the .bam files
#
# methratio.py will run twice for each subject
#  the second run will combine CpGs across strands (use -g option)
#  output files will be filtered down to CpGs only, creating a total of 4 output files
#
# Command line args must be in the exact following order with spaces between
#  make sure to put full pathnames for 1,3,4
#  1: full path to top directory with data
#      must contain only one sub-dir for each subject and nothing else
#  2: string to grep for suffixes of .bam files within subject dirs
#      should match only a single .bam file in the subject directory
#  3: full path to methratio.py script
#  4: full path to genome fasta file
#  5: base filename for output files
#      will be appended to .bam file name and followed by value for -m option
#  6: required coverage (-m option)
#
# Bio-RDF14:abseq$ BSseq2_methratio.sh data_dir bam_suffix script_path genome out_base req_cov
#
##########################################################################################
# Following the code below is an example use and the console output 
##########################################################################################

data_dir="$1"  
bam_suffix="$2"
script_path="$3"
genome="$4"
out_base="$5"
req_cov="$6"

# need to use old samtools because of methratio.py reference to deprecated -X flag for samtools view
sam_path="~/Documents/samtools-0.1.19"

cd "$data_dir"
subjects=$(ls)
echo -e "\n========================================================================"
echo -e "Moved to:\n ${data_dir}"
echo "------------------------------------------------------------------------"
echo -e "Subject dirs are:\n ${subjects}"
echo "------------------------------------------------------------------------"
echo -e "Will analyze .bam files ending in:\n ${bam_suffix}"
echo "------------------------------------------------------------------------"
echo -e "Will use methratio.py at:\n ${script_path}"
echo "------------------------------------------------------------------------"
echo -e "Will use genome file:\n ${genome}"
echo -e "========================================================================\n"
read -rsp "If this is all good press any key to continue, or ctrl+c to quit..." -n1 
echo
for s in $subjects
do
	echo -e "\n========================================================================"
	echo "Working on ${s}"
	echo "========================================================================"
	bam=$(ls "${s}/"*"${bam_suffix}")
	echo -e "Analyzing:\n ${bam}"
	echo -e "Will write output files:\n ${bam}_${out_base}-m${req_cov}"
	echo " ${bam}_${out_base}-m${req_cov}.CG"
	echo " ${bam}_${out_base}-m${req_cov}-CpGcombined"
	echo " ${bam}_${out_base}-m${req_cov}-CpGcombined.CG"

	echo -e "\n------------------------------------------------------------------------"
	echo "Running, no -g option..."
	echo "------------------------------------------------------------------------"
	"$script_path" \
	-o "${bam}_${out_base}-m${req_cov}" \
	-d "$genome" \
	-s "$sam_path" \
	-u -p -z -r -m "$req_cov" \
	"$bam"
	
	echo -e "\n------------------------------------------------------------------------"
	echo "Running, yes -g option..."
	echo "------------------------------------------------------------------------"
	"$script_path" \
	-o "${bam}_${out_base}-m${req_cov}-CpGcombined" \
	-d "$genome" \
	-s "$sam_path" \
	-u -p -z -r -g -m "$req_cov" \
	"$bam"
	
	echo -e "\n------------------------------------------------------------------------"
	echo "Filtering both output files for CpGs..."
	echo "------------------------------------------------------------------------"

##########################################################################################
# 	### Old regexes required for older versions of methratio.py script that reported context as
#   ###  e.g. GGCGTT instead of CG, ATCTGG instead of CHG, GTCAAA instead of CHH,
#   ###  and did not convert nucleotides for minus strand hits

# 	awk '($3=="-" && $4~/^.{1}CG/ ) || ($3=="+" &&  $4~/^.{2}CG/)' \
# 	$bam"_"$out_base"-m"$req_cov > $bam"_"$out_base"-m"$req_cov".CG"
# 	awk '($3=="-" && $4~/^.{1}CG/ ) || ($3=="+" &&  $4~/^.{2}CG/)' \
# 	$bam"_"$out_base"-m"$req_cov"-CpGcombined" > $bam"_"$out_base"-m"$req_cov"-CpGcombined.CG"
# 	
##########################################################################################

	echo $bam"_"$out_base"-m"$req_cov"..."
	awk '$4=="CG"' $bam"_"$out_base"-m"$req_cov \
	> $bam"_"$out_base"-m"$req_cov".CG"
	
	echo $bam"_"$out_base"-m"$req_cov"-CpGcombined..."
	awk '$4=="CG"' $bam"_"$out_base"-m"$req_cov"-CpGcombined" \
	> $bam"_"$out_base"-m"$req_cov"-CpGcombined.CG"
done

##########################################################################################
# Example 
##########################################################################################

##########################################################################################
#
# Bio-RDF14:3157_TENNISON abseq$ /Volumes/fishstudies-1/_scripts/BSseq2_methratio.sh \
# 								 ~/Documents/_BS-seq_data/ \
# 								 trimmed4-98.adapters.q30.m0_bsmap2.9.bam \
# 								 ~/Documents/bsmap-2.90/methratio.py \
# 								 ~/Documents/H_burtoni_v1.assembly.fa \
# 								 methratio_samtools0.1.19 \
# 								 5
# 
# ========================================================================
# Moved to:
#  /Users/abseq/Documents/_BS-seq_data/
# ------------------------------------------------------------------------
# Subject dirs are:
#  3157_TENNISON 3165_BRISCOE 3581_LYNLEY 3677_MONK
# ------------------------------------------------------------------------
# Will analyze .bam files ending in:
#  trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# ------------------------------------------------------------------------
# Will use methratio.py at:
#  /Users/abseq/Documents/bsmap-2.90/methratio.py
# ------------------------------------------------------------------------
# Will use genome file:
#  /Users/abseq/Documents/H_burtoni_v1.assembly.fa
# ========================================================================
# 
# If this is all good press any key to continue, or ctrl+c to quit...
# 
# ========================================================================
# Working on 3157_TENNISON
# ========================================================================
# Analyzing:
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5.CG
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 16:22:20 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 16:25:16 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 16:27:43 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 16:30:01 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 16:32:24 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 16:34:43 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 16:36:59 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 16:39:12 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 16:41:27 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 16:43:36 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 16:45:44 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 16:47:45 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 16:49:50 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 16:51:46 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 16:53:30 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 16:54:58 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 16:56:08 2015 	read 159873223 lines
# [methratio] @Fri Dec 11 16:56:08 2015 	writing 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5 ...
# [methratio] @Fri Dec 11 17:01:06 2015 	total 49698939 valid mappings, 44880351 covered cytosines, average coverage: 18.62 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 17:01:07 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 17:04:01 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 17:06:27 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 17:08:44 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 17:11:07 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 17:13:24 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 17:15:40 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 17:17:53 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 17:20:07 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 17:22:15 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 17:24:21 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 17:26:21 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 17:28:25 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 17:30:19 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 17:32:02 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 17:33:28 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 17:34:37 2015 	read 159873223 lines
# [methratio] @Fri Dec 11 17:34:37 2015 	combining CpG methylation from both strands ...
# [methratio] @Fri Dec 11 17:34:53 2015 	writing 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined ...
# [methratio] @Fri Dec 11 17:39:41 2015 	total 49698939 valid mappings, 44016638 covered cytosines, average coverage: 19.05 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5...
# 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined...
# 
# ========================================================================
# Working on 3165_BRISCOE
# ========================================================================
# Analyzing:
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5.CG
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 17:44:10 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 17:46:59 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 17:49:16 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 17:51:27 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 17:53:41 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 17:56:00 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 17:58:10 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 18:00:23 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 18:02:32 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 18:04:37 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 18:06:40 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 18:08:43 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 18:10:35 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 18:12:33 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 18:14:27 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 18:16:14 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 18:17:49 2015 	read 160000000 lines
# [methratio] @Fri Dec 11 18:19:09 2015 	read 170000000 lines
# [methratio] @Fri Dec 11 18:20:12 2015 	read 180000000 lines
# [methratio] @Fri Dec 11 18:20:43 2015 	read 184444368 lines
# [methratio] @Fri Dec 11 18:20:43 2015 	writing 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5 ...
# [methratio] @Fri Dec 11 18:24:57 2015 	total 52514031 valid mappings, 37877721 covered cytosines, average coverage: 24.04 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 18:24:58 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 18:27:50 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 18:30:08 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 18:32:19 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 18:34:34 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 18:36:54 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 18:39:05 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 18:41:15 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 18:43:22 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 18:45:26 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 18:47:26 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 18:49:26 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 18:51:16 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 18:53:12 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 18:55:04 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 18:56:49 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 18:58:21 2015 	read 160000000 lines
# [methratio] @Fri Dec 11 18:59:39 2015 	read 170000000 lines
# [methratio] @Fri Dec 11 19:00:42 2015 	read 180000000 lines
# [methratio] @Fri Dec 11 19:01:13 2015 	read 184444368 lines
# [methratio] @Fri Dec 11 19:01:13 2015 	combining CpG methylation from both strands ...
# [methratio] @Fri Dec 11 19:01:29 2015 	writing 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined ...
# [methratio] @Fri Dec 11 19:05:37 2015 	total 52514031 valid mappings, 37144358 covered cytosines, average coverage: 24.56 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5...
# 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined...
# 
# ========================================================================
# Working on 3581_LYNLEY
# ========================================================================
# Analyzing:
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5.CG
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 19:09:25 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 19:12:16 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 19:14:35 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 19:16:48 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 19:19:04 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 19:21:23 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 19:23:26 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 19:25:37 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 19:27:50 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 19:29:48 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 19:31:55 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 19:33:44 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 19:35:40 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 19:37:34 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 19:39:25 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 19:41:00 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 19:42:21 2015 	read 160000000 lines
# [methratio] @Fri Dec 11 19:43:25 2015 	read 170000000 lines
# [methratio] @Fri Dec 11 19:43:48 2015 	read 173372346 lines
# [methratio] @Fri Dec 11 19:43:48 2015 	writing 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5 ...
# [methratio] @Fri Dec 11 19:47:52 2015 	total 49890822 valid mappings, 36088670 covered cytosines, average coverage: 23.94 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 19:47:53 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 19:50:50 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 19:53:12 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 19:55:27 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 19:57:45 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 20:00:06 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 20:02:15 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 20:04:28 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 20:06:43 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 20:08:43 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 20:10:51 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 20:12:42 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 20:14:40 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 20:16:36 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 20:18:29 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 20:20:05 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 20:21:27 2015 	read 160000000 lines
# [methratio] @Fri Dec 11 20:22:32 2015 	read 170000000 lines
# [methratio] @Fri Dec 11 20:22:55 2015 	read 173372346 lines
# [methratio] @Fri Dec 11 20:22:55 2015 	combining CpG methylation from both strands ...
# [methratio] @Fri Dec 11 20:23:11 2015 	writing 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined ...
# [methratio] @Fri Dec 11 20:27:12 2015 	total 49890822 valid mappings, 35410330 covered cytosines, average coverage: 24.44 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5...
# 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined...
# 
# ========================================================================
# Working on 3677_MONK
# ========================================================================
# Analyzing:
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5.CG
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 20:30:53 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 20:33:50 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 20:36:17 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 20:38:36 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 20:41:00 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 20:43:24 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 20:45:35 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 20:47:52 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 20:50:09 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 20:52:14 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 20:54:29 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 20:56:22 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 20:58:26 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 21:00:28 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 21:02:20 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 21:04:00 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 21:05:19 2015 	read 160000000 lines
# [methratio] @Fri Dec 11 21:06:18 2015 	read 168836540 lines
# [methratio] @Fri Dec 11 21:06:18 2015 	writing 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5 ...
# [methratio] @Fri Dec 11 21:10:28 2015 	total 50337454 valid mappings, 36441917 covered cytosines, average coverage: 23.81 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Fri Dec 11 21:10:29 2015 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Fri Dec 11 21:13:22 2015 	read 10000000 lines
# [methratio] @Fri Dec 11 21:15:46 2015 	read 20000000 lines
# [methratio] @Fri Dec 11 21:18:03 2015 	read 30000000 lines
# [methratio] @Fri Dec 11 21:20:23 2015 	read 40000000 lines
# [methratio] @Fri Dec 11 21:22:45 2015 	read 50000000 lines
# [methratio] @Fri Dec 11 21:24:54 2015 	read 60000000 lines
# [methratio] @Fri Dec 11 21:27:08 2015 	read 70000000 lines
# [methratio] @Fri Dec 11 21:29:22 2015 	read 80000000 lines
# [methratio] @Fri Dec 11 21:31:25 2015 	read 90000000 lines
# [methratio] @Fri Dec 11 21:33:36 2015 	read 100000000 lines
# [methratio] @Fri Dec 11 21:35:27 2015 	read 110000000 lines
# [methratio] @Fri Dec 11 21:37:29 2015 	read 120000000 lines
# [methratio] @Fri Dec 11 21:39:28 2015 	read 130000000 lines
# [methratio] @Fri Dec 11 21:41:16 2015 	read 140000000 lines
# [methratio] @Fri Dec 11 21:42:52 2015 	read 150000000 lines
# [methratio] @Fri Dec 11 21:44:09 2015 	read 160000000 lines
# [methratio] @Fri Dec 11 21:45:08 2015 	read 168836540 lines
# [methratio] @Fri Dec 11 21:45:08 2015 	combining CpG methylation from both strands ...
# [methratio] @Fri Dec 11 21:45:24 2015 	writing 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined ...
# [methratio] @Fri Dec 11 21:49:30 2015 	total 50337454 valid mappings, 35769103 covered cytosines, average coverage: 24.31 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5...
# 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m5-CpGcombined...



###########
# 
# Bio-RDF14:_BS-seq_data abseq$ /Volumes/fishstudies-1/_scripts/BSseq2_methratio.sh \
# 							 	~/Documents/_BS-seq_data/BROAD_genome/ \
# 								trimmed4-98.adapters.q30.m0_bsmap2.9.bam \
# 								~/Documents/bsmap-2.90/methratio.py \
# 								~/Documents/H_burtoni_v1.assembly.fa \
# 								methratio_samtools0.1.19 \
# 								4
# 
# ========================================================================
# Moved to:
#  /Users/abseq/Documents/_BS-seq_data/BROAD_genome/
# ------------------------------------------------------------------------
# Subject dirs are:
#  3157_TENNISON
# 3165_BRISCOE
# 3581_LYNLEY
# 3677_MONK
# ------------------------------------------------------------------------
# Will analyze .bam files ending in:
#  trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# ------------------------------------------------------------------------
# Will use methratio.py at:
#  /Users/abseq/Documents/bsmap-2.90/methratio.py
# ------------------------------------------------------------------------
# Will use genome file:
#  /Users/abseq/Documents/H_burtoni_v1.assembly.fa
# ========================================================================
# 
# If this is all good press any key to continue, or ctrl+c to quit...
# 
# ========================================================================
# Working on 3157_TENNISON
# ========================================================================
# Analyzing:
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4.CG
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined
#  3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 17:04:48 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 17:07:41 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 17:10:07 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 17:12:26 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 17:14:54 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 17:17:18 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 17:19:36 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 17:21:50 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 17:24:06 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 17:26:16 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 17:28:24 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 17:30:26 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 17:32:34 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 17:34:30 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 17:36:14 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 17:38:03 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 17:39:39 2016 	read 159873223 lines
# [methratio] @Mon Mar 14 17:39:39 2016 	writing 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4 ...
# [methratio] @Mon Mar 14 17:45:55 2016 	total 49698939 valid mappings, 50195186 covered cytosines, average coverage: 17.07 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 17:45:56 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 17:49:40 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 17:52:46 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 17:55:39 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 17:58:05 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 18:00:23 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 18:02:40 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 18:04:52 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 18:07:07 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 18:09:16 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 18:11:22 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 18:13:25 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 18:15:46 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 18:17:57 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 18:19:41 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 18:21:08 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 18:22:17 2016 	read 159873223 lines
# [methratio] @Mon Mar 14 18:22:17 2016 	combining CpG methylation from both strands ...
# [methratio] @Mon Mar 14 18:22:33 2016 	writing 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined ...
# [methratio] @Mon Mar 14 18:27:42 2016 	total 49698939 valid mappings, 49127032 covered cytosines, average coverage: 17.49 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4...
# 3157_TENNISON/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined...
# 
# ========================================================================
# Working on 3165_BRISCOE
# ========================================================================
# Analyzing:
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4.CG
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined
#  3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 18:32:41 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 18:35:30 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 18:37:47 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 18:39:57 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 18:42:12 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 18:44:31 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 18:46:41 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 18:48:51 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 18:51:00 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 18:53:06 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 18:55:07 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 18:57:08 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 18:59:02 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 19:00:58 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 19:02:49 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 19:04:36 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 19:06:09 2016 	read 160000000 lines
# [methratio] @Mon Mar 14 19:07:28 2016 	read 170000000 lines
# [methratio] @Mon Mar 14 19:08:30 2016 	read 180000000 lines
# [methratio] @Mon Mar 14 19:09:00 2016 	read 184444368 lines
# [methratio] @Mon Mar 14 19:09:00 2016 	writing 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4 ...
# [methratio] @Mon Mar 14 19:13:32 2016 	total 52514031 valid mappings, 41704613 covered cytosines, average coverage: 22.20 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 19:13:33 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 19:16:26 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 19:18:46 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 19:20:59 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 19:23:16 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 19:25:36 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 19:27:49 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 19:30:01 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 19:32:12 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 19:34:19 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 19:36:22 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 19:38:25 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 19:40:18 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 19:42:16 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 19:44:10 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 19:45:58 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 19:47:33 2016 	read 160000000 lines
# [methratio] @Mon Mar 14 19:48:54 2016 	read 170000000 lines
# [methratio] @Mon Mar 14 19:49:57 2016 	read 180000000 lines
# [methratio] @Mon Mar 14 19:50:28 2016 	read 184444368 lines
# [methratio] @Mon Mar 14 19:50:28 2016 	combining CpG methylation from both strands ...
# [methratio] @Mon Mar 14 19:50:44 2016 	writing 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined ...
# [methratio] @Mon Mar 14 19:55:14 2016 	total 52514031 valid mappings, 40840159 covered cytosines, average coverage: 22.70 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4...
# 3165_BRISCOE/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined...
# 
# ========================================================================
# Working on 3581_LYNLEY
# ========================================================================
# Analyzing:
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4.CG
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined
#  3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 19:59:31 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 20:02:30 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 20:04:59 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 20:07:20 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 20:09:45 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 20:12:13 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 20:14:24 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 20:16:44 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 20:19:05 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 20:21:12 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 20:23:26 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 20:25:22 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 20:27:26 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 20:29:27 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 20:31:26 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 20:33:07 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 20:34:33 2016 	read 160000000 lines
# [methratio] @Mon Mar 14 20:35:40 2016 	read 170000000 lines
# [methratio] @Mon Mar 14 20:36:04 2016 	read 173372346 lines
# [methratio] @Mon Mar 14 20:36:04 2016 	writing 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4 ...
# [methratio] @Mon Mar 14 20:40:30 2016 	total 49890822 valid mappings, 39656095 covered cytosines, average coverage: 22.14 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 20:40:31 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 20:43:23 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 20:45:44 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 20:47:58 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 20:50:16 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 20:52:37 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 20:54:42 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 20:56:54 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 20:59:10 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 21:01:12 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 21:03:20 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 21:05:10 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 21:07:08 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 21:09:03 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 21:10:56 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 21:12:32 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 21:13:53 2016 	read 160000000 lines
# [methratio] @Mon Mar 14 21:14:58 2016 	read 170000000 lines
# [methratio] @Mon Mar 14 21:15:21 2016 	read 173372346 lines
# [methratio] @Mon Mar 14 21:15:21 2016 	combining CpG methylation from both strands ...
# [methratio] @Mon Mar 14 21:15:37 2016 	writing 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined ...
# [methratio] @Mon Mar 14 21:19:55 2016 	total 49890822 valid mappings, 38858234 covered cytosines, average coverage: 22.63 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4...
# 3581_LYNLEY/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined...
# 
# ========================================================================
# Working on 3677_MONK
# ========================================================================
# Analyzing:
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam
# Will write output files:
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4.CG
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined
#  3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined.CG
# 
# ------------------------------------------------------------------------
# Running, no -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 21:24:06 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 21:27:00 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 21:29:25 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 21:31:43 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 21:34:04 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 21:36:26 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 21:38:36 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 21:40:53 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 21:43:07 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 21:45:11 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 21:47:23 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 21:49:16 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 21:51:20 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 21:53:20 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 21:55:08 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 21:56:44 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 21:58:03 2016 	read 160000000 lines
# [methratio] @Mon Mar 14 21:59:01 2016 	read 168836540 lines
# [methratio] @Mon Mar 14 21:59:01 2016 	writing 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4 ...
# [methratio] @Mon Mar 14 22:03:33 2016 	total 50337454 valid mappings, 39975402 covered cytosines, average coverage: 22.06 fold.
# 
# ------------------------------------------------------------------------
# Running, yes -g option...
# ------------------------------------------------------------------------
# [methratio] @Mon Mar 14 22:03:34 2016 	loading reference file: /Users/abseq/Documents/H_burtoni_v1.assembly.fa ...
# [methratio] @Mon Mar 14 22:06:28 2016 	read 10000000 lines
# [methratio] @Mon Mar 14 22:08:52 2016 	read 20000000 lines
# [methratio] @Mon Mar 14 22:11:09 2016 	read 30000000 lines
# [methratio] @Mon Mar 14 22:13:30 2016 	read 40000000 lines
# [methratio] @Mon Mar 14 22:15:52 2016 	read 50000000 lines
# [methratio] @Mon Mar 14 22:18:01 2016 	read 60000000 lines
# [methratio] @Mon Mar 14 22:20:16 2016 	read 70000000 lines
# [methratio] @Mon Mar 14 22:22:30 2016 	read 80000000 lines
# [methratio] @Mon Mar 14 22:24:34 2016 	read 90000000 lines
# [methratio] @Mon Mar 14 22:26:45 2016 	read 100000000 lines
# [methratio] @Mon Mar 14 22:28:37 2016 	read 110000000 lines
# [methratio] @Mon Mar 14 22:30:39 2016 	read 120000000 lines
# [methratio] @Mon Mar 14 22:32:38 2016 	read 130000000 lines
# [methratio] @Mon Mar 14 22:34:26 2016 	read 140000000 lines
# [methratio] @Mon Mar 14 22:36:02 2016 	read 150000000 lines
# [methratio] @Mon Mar 14 22:37:20 2016 	read 160000000 lines
# [methratio] @Mon Mar 14 22:38:19 2016 	read 168836540 lines
# [methratio] @Mon Mar 14 22:38:19 2016 	combining CpG methylation from both strands ...
# [methratio] @Mon Mar 14 22:38:35 2016 	writing 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined ...
# [methratio] @Mon Mar 14 22:42:56 2016 	total 50337454 valid mappings, 39184975 covered cytosines, average coverage: 22.54 fold.
# 
# ------------------------------------------------------------------------
# Filtering both output files for CpGs...
# ------------------------------------------------------------------------
# 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4...
# 3677_MONK/aligned_trimmed4-98.adapters.q30.m0_bsmap2.9.bam_methratio_samtools0.1.19-m4-CpGcombined...
# Bio-RDF14:_BS-seq_data abseq$ 

