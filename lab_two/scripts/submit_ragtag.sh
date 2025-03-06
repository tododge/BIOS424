#!/bin/bash 
#
#SBATCH --job-name=ragtag
#SBATCH --partition=normal,hns,dpetrov,owners
#SBATCH --mail-type=BEGIN,END,FAIL

#SBATCH --time=30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

. $HOME/.bashrc
conda activate BIOS424

prefix="2R"
ragtag_dir="$SCRATCH/BIOS424/lab_two/ragtag"
reference="D.melanogaster.fa"
query="$SCRATCH/BIOS424/lab_two/purge/${prefix}.purged.fa"
clean_ragtag="${ragtag_dir}/${prefix}.scaffolded.fasta"

ragtag.py scaffold -t $(nproc) -o ${ragtag_dir} $reference $query
sed 's/_RagTag//g' ${ragtag_dir}/ragtag.scaffold.fasta > tmpfile && mv tmpfile ${clean_ragtag}