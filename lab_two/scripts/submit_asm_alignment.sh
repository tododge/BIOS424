#!/bin/bash
#
#SBATCH --job-name=asm_alignment
#SBATCH --partition=dpetrov,hns,normal
#SBATCH --mail-type=BEGIN,END,FAIL --mail-user=jahemker@stanford.edu
#
#SBATCH --time=30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

. $HOME/.bashrc
conda activate BIOS424

prefix="2R"
assembly="$SCRATCH/BIOS424/lab_two/${prefix}.fasta"
ref="D.melanogaster.fa"
sam="$SCRATCH/BIOS424/lab_two/alignments/${prefix}.asm.sam"
bam="$SCRATCH/BIOS424/lab_two/alignments/${prefix}.asm.sorted.bam"


minimap2 -a -x asm5 --eqx --cs -t $(nproc) $ref  $assembly > $sam
samtools sort -o $bam $sam
samtools index -b $bam