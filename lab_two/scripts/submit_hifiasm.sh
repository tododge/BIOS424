#!/bin/bash
#
#SBATCH --job-name=hifiasm
#SBATCH --partition=normal,hns,dpetrov,owners
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G

reads="$SCRATCH/BIOS424/lab_two/reads/2L.fastq.gz"
out_dir="$SCRATCH/BIOS424/lab_two/assembly/2L.hifiasm"
hifiasm -o ${out_dir} \
        -t $(nproc) \
        --ont \
        ${reads}
