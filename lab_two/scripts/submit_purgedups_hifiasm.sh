#!/bin/bash 
#
#SBATCH --job-name=purgedups
#SBATCH --partition=normal,hns,dpetrov,owners
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

. /home/users/jahemker/.bashrc
conda activate BIOS424

prefix="2L"
draft="$SCRATCH/BIOS424/lab_two/assembly/${prefix}.hifiasm.bp.p_ctg.fasta"
reads="$SCRATCH/BIOS424/lab_two/reads/${prefix}.fastq.gz"
purge_dir="$SCRATCH/BIOS424/lab_two/purge"
paf="${purge_dir}/${prefix}.paf"

#Align the reads to the draft assembly
minimap2 -x map-ont -t $(nproc) ${draft} ${reads} > ${paf}

#Get read depths across draft assembly
pbcstat -O ${purge_dir} ${paf}

#Calculate coverage cutoffs
calcuts ${purge_dir}/PB.stat > ${purge_dir}/${prefix}.cutoffs

#Split the fasta file by "N's" (gaps)
split_fa ${draft} > ${purge_dir}/${prefix}.fasta.split

#Map the split fasta file to itself
minimap2 -xasm5 -t $(nproc) -DP ${purge_dir}/${prefix}.fasta.split \
        ${purge_dir}/${prefix}.fasta.split > ${purge_dir}/${prefix}.fasta.split.paf

#Purge the haplotigs and overlaps from the assembly
purge_dups -2 -T ${purge_dir}/${prefix}.cutoffs \
        -c ${purge_dir}/PB.base.cov ${purge_dir}/${prefix}.fasta.split.paf > \
        ${purge_dir}/${prefix}.dups.bed 2> ${purge_dir}/${prefix}.purge_dups.log 

#Get the new sequences after purging
get_seqs -e ${purge_dir}/${prefix}.dups.bed ${draft}

#rename the output file
mv purged.fa ${purge_dir}/${prefix}.purged.fa 