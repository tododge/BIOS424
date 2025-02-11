# BIOS424
This is a repo that will house the scripts we use in BIOS424 (Structural Variation Minicourse).

The goals of the labs for this class are to walk through generation of long-read sequencing data, annotation and calling of structural variants, and analysis of structural variants.

## Lab 1 - Long-read sequencing with Oxford Nanopore Technologies (ONT)
In this first lab we will explore an ONT long-read sequencing protocol for Drosophila melanogaster.
We will walk through the each step of the protocol, then we will practice loading nanopore flow cells with a dummy library.
We will end by looking at ONT's sequencing software, Minknow, to see how we can evaluate our sequencing runs.

- Input: Sample

- Output: Raw basecalling data from sequencing run.

The protocol we will be following is based off of:

https://elifesciences.org/articles/66405

https://nanoporetech.com/document/genomic-dna-by-ligation-sqk-lsk114?device=PromethION

## Lab 2 - Genome assembly and long-read + assembly alignment to reference; Structural variant calling
The second lab class will focus on computationally generating our long reads, assembling them into full genomes, aligning to a reference genome, and calling SVs.
We will perform all of our computational work on Sherlock, Stanford's high-performance computing cluster for bioscience labs. In reality, the computational steps can take days to run, so we have already generated all starting, intermediate, and final files.
In lab we will work on learning how to run these programs on Sherlock.

- Input: Raw basecalling data from sequencing run. Reference genome of species.

- Output: Base-called reads (FASTQ files), genome assemblies (FASTA files), alignments (BAM files), structural variant calls (VCFs)

Todo for James:
- Make a singularity image that holds all of the necessary programs and dependencies
- For basecalling:
  - Dorado
- For genome assembly:
  - Flye
  - purgedups
  - medaka
  - Foreign Contamination Adapters + Screen
  - RagTag
  - RepeatModeler + RepeatMasker
  - QC Tools
- For alignment:
  - Minimap2
  - samtools
- For SV Calling:
  - sniffles2
  - cuteSV
  - svim-asm
  - Jasmine
  - bcftools

## Lab 3 - Structural variant QC and analysis
In this final lab, we will be looking at our SV calls that we generated in the previous lab. We will manually verify SVs looking at read alignments. We will perform some basic analyses with our VCFs.

- Input: structural variant calls (VCFs), alignment files (BAM files)
- Output: Various plots/analyses

- Programs:
  - JBrowse2 for looking at alignments
  - R?
