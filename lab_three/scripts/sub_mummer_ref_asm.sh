#!/bin/bash
#SBATCH --job-name=mummer
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64GB
#SBATCH -p owners,normal,hns

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <reference.fa> <query_pattern>"
    exit 1
fi

# Assign arguments
REF=$1
QUERY_PATTERN=$2

# Loop over query files matching the pattern
for ASSEM in $(ls ${QUERY_PATTERN}); do
    PREFIX="${ASSEM}_2_${REF}"
    echo "Processing: ${ASSEM}"

    # Run MUMmer commands
    nucmer ${REF} ${ASSEM} --prefix=${PREFIX}
    delta-filter -m ${PREFIX}.delta > ${PREFIX}.delta.m
    show-coords ${PREFIX}.delta.m -T > ${PREFIX}.delta.m.coords
    echo "Results of ${ASSEM} to ${REF} alignment in ${PREFIX}.delta.m.coords"
done
