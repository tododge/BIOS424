#!/bin/bash 
#
#SBATCH --job-name=svim-asm
#SBATCH --partition=normal,hns,dpetrov,owners
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --time=30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

. $HOME/.bashrc
conda activate BIOS424

prefix="2R"
ref="D.melanogaster.fa"
svim_asm_dir="$SCRATCH/BIOS424/lab_two/svim-asm"
bam="$SCRATCH/BIOS424/lab_two/alignments/${prefix}.asm.sorted.bam"
vcf=${svim-asm_dir}/${prefix}.svim-asm.vcf

svim-asm haploid \
        --min_sv_size 50 \
        --min_mapq 20 \
        --sample $prefix \
        ${svim_asm_dir} \
        ${bam} \
        ${ref}
mv ${svim_asm_dir}/variants.vcf ${svim_asm_dir}/${prefix}.svim-asm.vcf