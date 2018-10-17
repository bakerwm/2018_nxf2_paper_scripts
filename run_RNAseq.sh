
# Author: Ming Wang
# Email: wangming@ibp.ac.cn
# Date: 2018-10-16
# License: MIT License

# The following codes were designed to generate high quality plots for
# publication.


# The following script was tested on Ubuntu 18.04 server

# !!! important
path_to_project="dNxf2_project"
path_to_genome=""
path_to_rawdata="${path_to_project}/data/rawdata"
path_to_cleandata="${path_to_project}/data/cleandata"
path_to_hipipe="${path_to_project}/src/hipipe"


# prepare your working directory
mkdir ${path_to_project} ${path_to_rawdata} ${path_to_cleandata} ${path_to_hipipe}

# clone this repository to your project directory
cd ${path_to_project}/src
git clone https://github.com/bakerwm/2018_nxf2_paper_scripts.git  

# clone Python scripts for this publication
git clone https://github.com/bakerwm/hipipe
# add hipipe directory to your PATH
# add the following line to your "~/.bashrc" file.
export PATH="$HOME/work/wmlib/hipipe:$PATH"

cd ../.. # back to main project directory

# download rawdata from GEO with the following accession number
# GEO accession number: GSE********
# convert .sra files to FASTQ format
#
# download Panx_het and Panx_mut RNA-seq datasets with the following accession number:
# GEO accession number: GSE71371
# 
# GSM1833180	CG9754_het_rep1_RNAseq
# GSM1833182	CG9754_het_rep2_RNAseq
# GSM1833181	CG9754_mutant_rep1_RNAseq
# GSM1833183	CG9754_mutant_rep2_RNAseq

# The following files are expected with directory: data/rawdata/
#
# ├── RNAseq_attp2_rep1.fq.gz
# ├── RNAseq_attp2_rep2.fq.gz
# ├── RNAseq_dNxf2_KD_rep1.fq.gz
# ├── RNAseq_dNxf2_KD_rep2.fq.gz
# ├── RNAseq_dNxf2_mut_rep1.fq.gz
# ├── RNAseq_dNxf2_mut_rep2.fq.gz
# ├── RNAseq_CG9754_het_rep1.fq.gz
# ├── RNAseq_CG9754_het_rep2.fq.gz
# ├── RNAseq_CG9754_mut_rep1.fq.gz
# ├── RNAseq_CG9754_mut_rep2.fq.gz
# ├── RNAseq_W1118_rep1.fq.gz
# └── RNAseq_W1118_rep2.fq.gz

# 1. Quality control
hipipe-trim.py -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -i data/rawdata/RNAseq_*.fq.gz -o data/cleandata/ -m 20 --threads 8 --cut-after-trim 6,-6

# 2. Alignment and DE analysis
$path_to_hipipe/hipipe-rnaseq.py -g dm3 -p 8 -s 2 --aligner star --align-to-rRNA --bin-size 1 \
    --gtf $path_to_genome/dm3/Drosophila_melanogaster.BDGP5.75.gtf \
    -x $path_to_genome/dm3/dm3_transposon/STAR_index \
    -o $path_to_results/RNAseq_W1118_vs_dNxf2_mut \
    -A W1118 -B dNxf2_mut \
    -a data/cleandata/RNAseq_W1118_rep1.fq.gz data/cleandata/RNAseq_W1118_rep2.fq.gz \
    -b data/cleandata/RNAseq_dNxf2_mut_rep1.fq.gz data/cleandata/RNAseq_dNxf2_mut_rep2.fq.gz

$path_to_hipipe/hipipe-rnaseq.py -g dm3 -p 8 -s 2 --aligner star --align-to-rRNA --bin-size 1 \
    --gtf $path_to_genome/dm3/Drosophila_melanogaster.BDGP5.75.gtf \
    -x $path_to_genome/dm3/dm3_transposon/STAR_index \
    -o results/RNAseq_attp2_vs_dNxf2_KD \
    -A attp2 -B dNxf2_KD \
    -a data/cleandata/RNAseq_attp2_rep1.fq.gz data/cleandata/RNAseq_attp2_rep2.fq.gz \
    -b data/cleandata/RNAseq_dNxf2_KD_rep1.fq.gz data/cleandata/RNAseq_dNxf2_KD_rep2.fq.gz

$path_to_hipipe/hipipe-rnaseq.py -g dm3 -p 8 -s 2 --aligner star --align-to-rRNA --bin-size 1 \
    --gtf $path_to_genome/dm3/Drosophila_melanogaster.BDGP5.75.gtf \
    -x $path_to_genome/dm3/dm3_transposon/STAR_index \
    -o results/RNAseq_Panx_het_vs_Panx_mut \
    -A Panx_het -B Panx_mut \
    -a data/cleandata/RNAseq_Panx_het_rep1.fq.gz data/cleandata/RNAseq_Panx_mut_rep2.fq.gz \
    -b data/cleandata/RNAseq_Panx_mut_rep1.fq.gz data/cleandata/RNAseq_Panx_mut_rep2.fq.gz

# the structure of each sub-directory organized like this

# results/RNAseq_W1118_vs_dNxf2_mut
# ├── bigWig
# ├── count
# ├── de_analysis
# ├── genome_mapping
# ├── report
# ├── src
# └── transposon_analysis

# The differentially expressed analysis of canonical transposon elements stored in results/RNAseq_W1118_vs_dNxf2_mut/transposon_analysis/report/

