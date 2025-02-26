#! /bin/bash
#
#SBATCH --job-name=Dorado
#SBATCH --time=4:00:00
#SBATCH --partition=gpu,owners
#SBATCH --mail-type=BEGIN,FAIL,END --mail-user=%u@stanford.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --constraint="GPU_GEN:VLT|GPU_GEN:AMP"
#SBATCH --gres="gpu:4"

# Activate the conda environment
. $HOME/.bashrc
conda activate BIOS424

#Set up variables to directories
species="dmel1"
speciespath="$SCRATCH/BIOS424/${species}/"
fastq="$SCRATCH/BIOS424/${species}/${species}.dorado.fastq.gz"

# Prepare basecalling directory by downloading model if it doesn't exist
# Will check that model exists before downloading
# Notice that the model is for R10 pore chemistry and is the Super accuracy model (sup)
model="dna_r10.4.1_e8.2_400bps_sup@v5.0.0"
dorado download --model $model --directory "$SCRATCH/BIOS424/lab_one"

# Run basecalling
# Owners gpu nodes can be interrupted, so if it was interrupted, resume
# from previous spot.
if [ -f ${species}.bam ]; then 
    mv ${species}.bam ${species}.old.bam
    dorado basecaller --min-qscore 10 --recursive \
        --resume-from ${species}.old.bam \
        ${model} ${speciespath}/ \
        > ${species}.bam
else
    dorado basecaller --min-qscore 10 --recursive \
        ${model} ${speciespath}/ \
        > ${species}.bam
fi 

if [ -f ${species}.old.bam ]; then
    rm ${species}.old.bam
fi

# Convert the bam file output to a fastq file
samtools bam2fq -@ $(nproc) ${species}.bam | pigz -p $(nproc) > ${fastq}
rm ${species}.bam

# There may be duplicated reads in the fasta file, and downstream stuff
# expects each read to have a unique name, so we just clean the file of dups
# and then compress it so that it takes up less space.
seqkit rmdup -n ${fastq} > ${fastq::-9}.clean.fastq
gzip ${fastq::-9}.clean.fastq
rm ${fastq}
