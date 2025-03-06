#!/bin/bash 
#
#SBATCH --job-name=sniffles
#SBATCH --partition=normal,hns,dpetrov,owners
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --time=30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

. $HOME/.bashrc
conda activate BIOS424

prefix="2R"
reads="$SCRATCH/BIOS424/lab_two/reads/${prefix}.fastq.gz"
ref="D.melanogaster.fa"
sniffles_dir=$SCRATCH/BIOS424/lab_two/sniffles2
bam="$SCRATCH/BIOS424/lab_two/alignments/${prefix}.reads.sorted.bam"
vcf=${sniffles_dir}/${prefix}.sniffles2.vcf

sniffles -i ${bam} \
        --reference ${ref} \
        --minsupport auto \
        --minsvlen 50 \
        --threads $(nproc) \
        --allow-overwrite \
        --output-rnames \
        --mapq 20 \
        -v $vcf