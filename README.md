# BIOS424
This is a repo that will house the scripts we use in BIOS424 (Structural Variation Minicourse).

The goals of the labs for this class are to walk through generation of long-read sequencing data, calling of structural variants, and analysis of structural variants.

### Computing in BIOS424
In order to keep everything consistent for the computational parts of the labs, we are going to assume everyone will be working on the Sherlock computing cluster.

If you do not have access to Sherlock please let us know and we can try to come up with a workaround.

I've tried to clearly write out all of the commands we will be using for anyone who is not very comfortable with bash or Sherlock.

Additionally, we will be using a conda environment to conveniently hold all of the various programs (and their dependencies) that we will be using. If you do not have conda (and mamba) installed on Sherlock, please do so before class if possible.

Mamba will allow you to download all the packages much faster than conda does.

If you feel competent and wish to install these programs in a different way, we've listed everything out that we are planning on using, so feel free to do so.

---

You can install both conda and mamba through miniforge from here: https://github.com/conda-forge/miniforge

Conda environments with a bunch of packages can take up a fair amount of space. I would recommend installing conda into a personal directory in your `$GROUP_HOME` if possible.

Here are the basic installation commands for linux (Sherlock). See the link for more info:
```
wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3.sh -b -p "${GROUP_HOME}/[personal_dir]/conda" #change [personal_dir] to whatever you use
```
You'll then want to add `conda` and `mamba` to your `$PATH` so that you can run them from wherever. Paste the following into `~/.bash_profile`
```
# add conda to path. Change [personal_dir] to whatever you used on the installation.
if [ -d "${GROUP_HOME}/[personal_dir]/conda" ] ; then
    PATH="${GROUP_HOME}/[personal_dir]/conda/condabin:$PATH"
fi
```
Either `source ~/.bash_profile` or restart your terminal window. Typing `conda` and `mamba` should now give help messages.

Now, we want to all have the same conda environment with all the necessary programs. First, clone this github repo somewhere you can easily access on Sherlock. (I would recommend `$SCRATCH`; it's what all the scripts will assume). Move into the directory and we will now create a new conda environment from the supplied `environment.yml` file. It will probably take a little while (5-10 minutes with mamba) to download everything that's needed. Whenever it finishes, activate the new environment.
```
cd $SCRATCH
git clone https://github.com/jahemker/BIOS424/
cd BIOS424/
mamba env create -n BIOS424 -f environment.yml
conda activate BIOS424
```

## Lab 1 - Long-read sequencing with Oxford Nanopore Technologies (ONT)
In this first lab we will explore an ONT long-read sequencing protocol for Drosophila melanogaster.
We will walk through the each step of the protocol, then we will practice loading nanopore flow cells with a dummy library.
We will look at ONT's sequencing software, Minknow, to see how we can evaluate our sequencing runs.
We will finally end with a foray into computational work, basecalling our sequencing data.

- Input: Sample

- Output: Basecalled reads data from sequencing run.

The protocol we will be following is based off of:

https://elifesciences.org/articles/66405

https://nanoporetech.com/document/genomic-dna-by-ligation-sqk-lsk114?device=PromethION

For basecalling, we will be using Dorado, which is Nanopore's open-source basecaller.

https://github.com/nanoporetech/dorado

## Lab 2 - Genome assembly and long-read + assembly alignment to reference; Structural variant calling
The second lab class will focus on computationally generating our long reads, assembling them into full genomes, aligning to a reference genome, and calling SVs.
We will perform all of our computational work on Sherlock, Stanford's high-performance computing cluster for bioscience labs. In reality, the computational steps can take days to run, so we have already generated all starting, intermediate, and final files.
In lab we will work on learning how to run these programs on Sherlock.

- Input: Basecalled data from sequencing run. Reference genome of species.

- Output: Base-called reads (FASTQ files), genome assemblies (FASTA files), alignments (BAM files), structural variant calls (VCFs)

For detailed steps, refer to the readme in the `lab_two/` folder.

## Lab 3 - Structural variant QC and analysis
In this final lab, we will be looking at our SV calls that we generated in the previous lab. We will manually verify SVs looking at read alignments. We will perform some basic analyses with our VCFs. We will also look for differences between more complex regions of the genome.

- Input: assembly graphs, structural variant calls (VCFs), alignment files (BAM files, mummer files)
- Output: Various plots/analyses

- Programs:
  - JBrowse2 for looking at alignments
  - Bandage for looking at assemblies
  - mummer/R for aligning and visualizing differences genomes
