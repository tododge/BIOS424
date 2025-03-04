# Lab 2

In this lab, we will  walk through a simple genome assembly workflow.

- First, we will assemble our reads into contigs with `hifiasm`. Info [here](https://github.com/chhylp123/hifiasm).
- Second, we will purge haplotype duplications with `purge_dups`. Info [here](https://github.com/dfguan/purge_dups).
- Third, we will scaffold our contigs with `ragtag`. Info [here](https://github.com/malonge/RagTag).

We will additionally call structural variants with two different callers, [Sniffles2](https://github.com/fritzsedlazeck/Sniffles) and [svim-asm](https://github.com/eldariont/svim-asm).

- `Sniffles2` will use our reads aligned to the reference.
- `svim-asm` will use our assembly aligned to the reference. (We may or may not get to using svim-asm, depending on time and how quickly assembly goes, however you should be able to follow the instructions here after the fact and do it yourself, if you want).

### Note

The reason we can use such a simple assembly workflow is because our sequencing data is ONT R.10.4.1, basecalled with the v5 super accuracy model. With less accurate long reads, you would probably want to do additional steps such as read polishing.

An important piece of a typical workflow we are omitting today is adapter and contamination screening. After we first assemble contigs, we want to make sure that there aren't adapter sequences or sequence from other species (contamination) that has been incorporated into our assembly. I elected not to walkthrough this today as it involves download hundreds of GB of data, and can take a while to run. All the information on this is found [here](https://github.com/ncbi/fcs).

There are a huge number of SV callers we could have chosen to use today. I chose these two because they are relatively popular, they work fast, and they are fairly uncomplicated to use.

---

### Assemblying with hifiasm

First on Sherlock, pull from github the updated version of this folder.

```
cd $SCRATCH/BIOS424 #or wherever you cloned it last lab.
git pull
```
Next, [download this fastq file](https://drive.google.com/file/d/1LIipMBVFH-UM6RJXn4VOfVPrlHVsk365/view?usp=drive_link), which holds the reads for one D. melanogaster chromosome (2L), and upload it to Sherlock.
```
#you may have to change the first part depending on where you downloaded the file to
scp ~/Downloads/2L.fastq.gz [suid]@dtn.sherlock.stanford.edu:$SCRATCH/BIOS424/lab_two/reads
```

We can now go into the `lab_two` folder and submit our hifiasm script to Sherlock. The `--mail-user` option will allow Sherlock to send you an email when your job starts/stops/fails.
```
cd $SCRATCH/BIOS424/lab_two
sbatch --mail-user=[your@email.com] scripts/submit_hifiasm.sh
```

Once the job has finished, you should be able to see a bunch of files in the `assembly/` directory that start with `2L.hifiasm.bp.*`. We are going to focus on the file `2L.hifiasm.bp.p_ctg.gfa`, which is the graph assembly file of the primary contigs. We will first convert this file to a fasta file using the simple command `awk '/^S/{print ">"$2;print $3}' 2L.hifiasm.bp.p_ctg.gfa > 2L.hifiasm.bp.p_ctg.fasta`. 

### Purging haplodups with purge_dups

Haplotypic dupications are assembly artifacts that can occur in unphased genomes when there is a region of high heterozygosity. The assembler does not recognize the heterozygous region not as different haplotypes of the same region. Instead, it believes that it is two, slightly diverged copies of the same region. Both heterozygous haplotypes are assembled, when in reality the assembler should have chosen only one. purge_dups is a program that will scan the genome for these incorrect haplotypic duplications and remove one of the "copies".
