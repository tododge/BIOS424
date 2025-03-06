#!/bin/bash
#
#SBATCH --job-name=read_alignment
#SBATCH --partition=dpetrov,hns,normal
#SBATCH --mail-type=BEGIN,END,FAIL
#
#SBATCH --time=30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

. $HOME/.bashrc
conda activate BIOS424

prefix="2R"
reads="$SCRATCH/BIOS424/lab_two/reads/${prefix}.fastq.gz"
ref="D.melanogaster.fa"
sam="$SCRATCH/BIOS424/lab_two/alignments/${prefix}.reads.sam"
bam="$SCRATCH/BIOS424/lab_two/alignments/${prefix}.reads.sorted.bam"


minimap2 -a -x map-ont -t $(nproc) $ref  $reads > $sam
samtools sort -o $bam $sam
samtools index -b $bam
