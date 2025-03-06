# Lab 2

In this lab, we will  walk through a simple genome assembly workflow.

- First, we will assemble our reads into contigs with `hifiasm`. Info [here](https://github.com/chhylp123/hifiasm).
- Second, we will purge haplotype duplications with `purge_dups`. Info [here](https://github.com/dfguan/purge_dups).
- Third, we will scaffold our contigs with `ragtag`. Info [here](https://github.com/malonge/RagTag).

We will additionally call structural variants with two different callers, [Sniffles2](https://github.com/fritzsedlazeck/Sniffles) and [svim-asm](https://github.com/eldariont/svim-asm).

- `Sniffles2` will use our reads aligned to the reference.
- `svim-asm` will use our assembly aligned to the reference. (We may or may not get to using svim-asm, depending on time and how quickly assembly goes, however you should be able to follow the instructions here after the fact and do it yourself, if you want).

### Notes

The reason we can use such a simple assembly workflow is because our sequencing data is ONT R.10.4.1, basecalled with the v5 super accuracy model. With less accurate long reads, you would probably want to do additional steps such as read polishing.

An important piece of a typical workflow we are omitting today is adapter and contamination screening. After we first assemble contigs, we want to make sure that there aren't adapter sequences or sequence from other species (contamination) that has been incorporated into our assembly. I elected not to walkthrough this today as it involves download hundreds of GB of data, and can take a while to run. All the information on this is found [here](https://github.com/ncbi/fcs).

There are a huge number of SV callers we could have chosen to use today. I chose these two because they are relatively popular, they work fast, and they are fairly uncomplicated to use.

---

## Assemblying with hifiasm

First on Sherlock, pull from github the updated version of this folder.

```
cd $SCRATCH/BIOS424 #or wherever you cloned it last lab.
git pull
```
Next, [download this fastq file](https://drive.google.com/file/d/1IkBvaqBol3XBv1x8wT8im7HeYMK-3yWK/view?usp=sharing), which holds the reads for one D. melanogaster chromosome (2R), and upload it to Sherlock.
```
#you may have to change the first part depending on where you downloaded the file to
scp ~/Downloads/2R.fastq.gz [suid]@dtn.sherlock.stanford.edu:$SCRATCH/BIOS424/lab_two/reads
```

We can now go into the `lab_two` folder and submit our hifiasm script to Sherlock. Sherlock will send you an email when your job starts/stops/fails.
```
cd $SCRATCH/BIOS424/lab_two
sbatch scripts/submit_hifiasm.sh #should take about 15 minutes
```

Once the job has finished, you should be able to see a bunch of files in the `assembly/` directory that start with `2R.hifiasm.bp.*`. We are going to focus on the file `2R.hifiasm.bp.p_ctg.gfa`, which is the graph assembly file of the primary contigs. We will first convert this file to a fasta file using an awk command. We can then look at basic stats about our assembly using the tool `gt seqstat`. 

```
cd $SCRATCH/BIOS424/lab_two/assembly/
awk '/^S/{print ">"$2;print $3}' 2R.hifiasm.bp.p_ctg.gfa > 2R.hifiasm.bp.p_ctg.fasta
gt seqstat 2R.hifiasm.bp.p_ctg.fasta
```

(Hopefully) the `gt seqstat` output looks like:
```
# number of contigs:     38
# total contigs length:  38632550
# mean contig size:      1016646.05
# contig size first quartile: 222180
# median contig size:         338280
# contig size third quartile: 555424
# longest contig:             21678417
# shortest contig:            119483
# contigs > 500 nt:           38 (100.00 %)
# contigs > 1K nt:            38 (100.00 %)
# contigs > 10K nt:           38 (100.00 %)
# contigs > 100K nt:          38 (100.00 %)
# contigs > 1M nt:            6 (15.79 %)
# N50                21678417
# L50                1
# N80                498193
# L80                11
```
In the D.melanogaster reference genome, 2R is 25Mb. Somehow, we've picked up an extra 13.5Mb...


## Purging haplodups with purge_dups

Haplotypic dupications are assembly artifacts that can occur in unphased genomes when there is a region of high heterozygosity. The assembler does not recognize the heterozygous region not as different haplotypes of the same region. Instead, it believes that it is two, slightly diverged copies of the same region. Both heterozygous haplotypes are assembled, when in reality the assembler should have chosen only one. hifiasm has a built-in haplodup-purging method, but it can miss things. purge_dups is a program that will scan the genome for these incorrect haplotypic duplications and remove one of the "copies". 

We can purge any potential haplotypic duplications from our hifiasm assembly. 
```
cd $SCRATCH/BIOS424/lab_two
sbatch scripts/submit_purgedups.sh #should take about 5 minutes
```

After the job completes, there will be multiple files in the `purge/` directory. The relevant file for us is `2R.purged.fa`, which is our fasta file without haplodups. We can now check the size of our assembly again.
```
cd $SCRATCH/BIOS424/lab_two
gt seqstat purge/2R.purged.fa
```
(Hopefully) the `gt seqstat` output looks like:
```
# number of contigs:     23
# total contigs length:  31973739
# mean contig size:      1390162.57
# contig size first quartile: 274879
# median contig size:         445479
# contig size third quartile: 652358
# longest contig:             21678417
# shortest contig:            160806
# contigs > 500 nt:           23 (100.00 %)
# contigs > 1K nt:            23 (100.00 %)
# contigs > 10K nt:           23 (100.00 %)
# contigs > 100K nt:          23 (100.00 %)
# contigs > 1M nt:            4 (17.39 %)
# N50                21678417
# L50                1
# N80                652358
# L80                5
```
Now, we've dropped about 7Mb of sequence from erroneous haplodups. There is still a lot more sequence than compared to the reference, but it's possible that we could have assembled a bunch of challenging regions that the reference genome (first assembled in 2014) could not. It's also possible that isolated reads are aligning poorly, and that some of the contigs in our assembly are bogus. Notice how our largest contig is more than 21Mb, which is really excellent.

## Scaffolding contigs with RagTag

We now have a number of contigs. If our data had been high-enough quality, we could have potentially already assembled the full 2R chromosome. However, we can see that our largest contig is still only 21Mb, which is  short of the known chromosome length. Now we will assembly our chromosomes into scaffolds. We don't have any more data to use (like Hi-C), so we have to scaffold against the reference D.melanogaster genome. Unfortunately, this means that our assembly will no longer be truly "de novo", but we were able to assemble large chunks of the chromosome de novo. To scaffold, we will use the program RagTag.

First we have to download the reference D.melanogaster assembly. (You can check its stats the same way we've checked our fasta files. Notice that there are a huge number of contigs. These are all small fragments that are part of the genome, but its unclear where they should be assembled.)
```
wget -O-  https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.58_FB2024_03/fasta/dmel-all-chromosome-r6.58.fasta.gz | gunzip > D.melanogaster.fa.gz
```
Now we can run ragtag
```
cd $SCRATCH/BIOS424/lab_two
sbatch scripts/submit_ragtag.sh # Should take like a minute
```
The ragtag output will be in the `ragtag/` directory. The file we care about is `2R.scaffolded.fasta`. We can check the stats of the scaffolded assembly, and we should find that there are only a few contigs, with one being extremely long. The stats should look like:
```
# number of contigs:     7
# total contigs length:  31975339
# mean contig size:      4567905.57
# contig size first quartile: 1775251
# median contig size:         1864736
# contig size third quartile: 23340296
# longest contig:             23340296
# shortest contig:            652358
# contigs > 500 nt:           7 (100.00 %)
# contigs > 1K nt:            7 (100.00 %)
# contigs > 10K nt:           7 (100.00 %)
# contigs > 100K nt:          7 (100.00 %)
# contigs > 1M nt:            6 (85.71 %)
# N50                23340296
# L50                1
# N80                1864736
# L80                3
```
We were able to combine contigs and add on another 2Mb to our largest contig. We can double check that indeed RagTag aligned this contig to the 2R chromosome by looking at all of the contigs (which are now named by which reference contig they were scaffolded to). `samtools faidx` will create an index file for a fasta, which allows us to easily see contig lengths.
```
cd $SCRATCH/BIOS424/lab_two/ragtag/
samtools faidx 2R.scaffolded.fasta
cut -f-2 2R.scaffolded.fasta.fai | sort -nrk 2
```
This will output the bp length of each contig in `2R.scaffolded.fasta`:
```
2R      23340296
X       1931199
3L      1864736
2L      1775251
ptg000007l_1    1214511
3R      1196988
ptg000028l_1    652358
```
We can clearly see that our longest contig does in fact scaffold to 2R. Notice how we have 6 other smaller contigs that were scaffolded to other chromosomes/contigs in the D. melanogaster reference.

We can now use this assembly of 2R to call structural variants with assembly aligners. It's important to remember that while we have 10 other contigs in our fasta file as well, we know our reads are from 2R. We can further filter the fasta file to only include the sequence of 2R. We will use this fasta file for SV calling in the next part.

```
cd $SCRATCH/BIOS424/lab_two/
samtools faidx ragtag/2R.scaffolded.fasta 2R > 2R.fasta
```

---

## Calling structural variants

To call structural variants, we first need to make the read and assembly alignments. We will use the same set of reads we downloaded earlier as well as the 2R assembly we just made and align them to the same reference genome. We will use the program `minimap2` for both read alignment and assembly alignment. There are separate scripts for each alignment type.
```
cd $SCRATCH/BIOS424/lab_two
sbatch scripts/submit_read_alignment.sh
sbatch scripts/submit_assembly_alignment.sh
```
Our output will be `.bam` files in the `alignments/` directory. I've also included the `.sam` file outputs as well, if you want to look at them, but they won't be used in the rest of the workflow.

### Calling SVs from reads with Sniffles2

We need to give sniffles the bam file with our read alignments, as well as the reference genome we used to make the bam file. There are a bunch of parameters we can set, but we will only explicitly set two of them. First we are going to require a minimum SV length of 50bp, and second we are going to tell sniffles to only look at read alignments that have a minimum mapping quality score of 20.
```
cd $SCRATCH/BIOS424/lab_two
sbatch scripts/submit_sniffles.sh
```
The resulting output, `2R.sniffles2.vcf` can be found in the `sniffles2` directory.

### Calling SVs from assembly with svim-asm

We need to give svim-asm our assembly alignment and the reference assembly. We will set the minimum SV length and minimum mapping quality to be the same as sniffles, 50 and 20, respectively.
```
cd $SCRATCH/BIOS424/lab_two
sbatch scripts/submit_svim-asm.sh
```
The output will be in `svim-asm/`, and we care about the file `2R.svim-asm.vcf`.

Depending on the time at this point, we will either start looking at the vcfs, or we will save that for lab next week. The best tool for parsing VCFs is `bcftools`. Feel free to look it up and see what it can do. 
