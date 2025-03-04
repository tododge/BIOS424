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

Once the job has finished, you should be able to see a bunch of files in the `assembly/` directory that start with `2L.hifiasm.bp.*`. We are going to focus on the file `2L.hifiasm.bp.p_ctg.gfa`, which is the graph assembly file of the primary contigs. We will first convert this file to a fasta file using an awk command. We can then look at basic stats about our assembly using the tool `gt seqstat`. 

```
cd $SCRATCH/BIOS424/lab_two/assembly/
awk '/^S/{print ">"$2;print $3}' 2L.hifiasm.bp.p_ctg.gfa > 2L.hifiasm.bp.p_ctg.fasta
gt seqstat assembly/2L.hifiasm.bp.p_ctg.fasta
```

(Hopefully) the `gt seqstat` output looks like:
```
# number of contigs:     42
# total contigs length:  34972702
# mean contig size:      832683.38
# contig size first quartile: 130618
# median contig size:         193803
# contig size third quartile: 469105
# longest contig:             15568587
# shortest contig:            84909
# contigs > 500 nt:           42 (100.00 %)
# contigs > 1K nt:            42 (100.00 %)
# contigs > 10K nt:           42 (100.00 %)
# contigs > 100K nt:          38 (90.48 %)
# contigs > 1M nt:            4 (9.52 %)
# N50                6008429
# L50                2
# N80                563548
# L80                7
```
In the D.melanogaster reference genome, 2L is 23.5Mbp. Somehow, we've picked up an extra 11.5Mb...


## Purging haplodups with purge_dups

Haplotypic dupications are assembly artifacts that can occur in unphased genomes when there is a region of high heterozygosity. The assembler does not recognize the heterozygous region not as different haplotypes of the same region. Instead, it believes that it is two, slightly diverged copies of the same region. Both heterozygous haplotypes are assembled, when in reality the assembler should have chosen only one. hifiasm has a built-in haplodup-purging method, but it can miss things. purge_dups is a program that will scan the genome for these incorrect haplotypic duplications and remove one of the "copies". 

We can purge any potential haplotypic duplications from our hifiasm assembly. 
```
cd $SCRATCH/BIOS424/lab_two
sbatch --mail-user=[your@email.com] scripts/submit_purgedups.sh
```

After the job completes, there will be multiple files in the `purge/` directory. The relevant file for us is `2L.purged.fa`, which is our fasta file without haplodups. We can now check the size of our assembly again.
```
cd $SCRATCH/BIOS424/lab_two
gt seqstat purge/2L.purged.fa
```
(Hopefully) the `gt seqstat` output looks like:
```
# number of contigs:     25
# total contigs length:  27447083
# mean contig size:      1097883.32
# contig size first quartile: 124935
# median contig size:         193511
# contig size third quartile: 294027
# longest contig:             15568587
# shortest contig:            84909
# contigs > 500 nt:           25 (100.00 %)
# contigs > 1K nt:            25 (100.00 %)
# contigs > 10K nt:           25 (100.00 %)
# contigs > 100K nt:          21 (84.00 %)
# contigs > 1M nt:            3 (12.00 %)
# N50                15568587
# L50                1
# N80                2747760
# L80                3
```
Now, we've dropped about 7.5Mb of sequence from erroneous haplodups. There is still 4Mb more sequence than compared to the reference, but it's possible that we could have assembled a bunch of challenging regions that the reference genome (first assembled in 2014) could not.

## Scaffolding contigs with RagTag

We now have a number of contigs. If our data had been high-enough quality, we could have potentially already assembled the full 2L chromosome. However, we can see that our largest contig is still only 15Mb, which is well short of the known chromosome length. Now we will assembly our chromosomes into scaffolds. We don't have any more data to use (like Hi-C), so we have to scaffold against the reference D.melanogaster genome. Unfortunately, this means that our assembly will no longer be truly "de novo", but we were able to assemble large chunks of the chromosome de novo. To scaffold, we will use the program RagTag.

First we have to download the reference D.melanogaster assembly. (You can check its stats the same way we've checked our fasta files. Notice that there are a huge number of contigs. These are all small fragments that are part of the genome, but its unclear where they should be assembled.)
```
wget -O D.melanogaster.fa https://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.58_FB2024_03/fasta/dmel-all-chromosome-r6.58.fasta.gz
```
Now we can run ragtag
```
cd $SCRATCH/BIOS424/lab_two
sbatch --mail-user=[your@email.com] scripts/submit_ragtag.sh
```
The ragtag output will be in the `ragtag/` directory. The file we care about is `2L.scaffolded.fasta`. We can check the stats of the scaffolded assembly, and we should find that there are only a few contigs, with one being extremely long. The stats should look like:
```
# number of contigs:     11
# total contigs length:  27448483
# mean contig size:      2495316.64
# contig size first quartile: 193563
# median contig size:         470274
# contig size third quartile: 728259
# longest contig:             23922314
# shortest contig:            84909
# contigs > 500 nt:           11 (100.00 %)
# contigs > 1K nt:            11 (100.00 %)
# contigs > 10K nt:           11 (100.00 %)
# contigs > 100K nt:          9 (81.82 %)
# contigs > 1M nt:            1 (9.09 %)
# N50                23922314
# L50                1
# N80                23922314
# L80                1
```
Our longest contig is 23.9Mb long, about .5MB longer than the reference 2L chromosome. We can double check that indeed RagTag aligned this contig to the 2L chromosome by looking at all of the contigs (which are now named by which reference contig they were scaffolded to). `samtools faidx` will create an index file for a fasta, which allows us to easily see contig lengths.
```
cd $SCRATCH/BIOS424/lab_two/ragtag/
samtools faidx 2L.scaffolded.fasta
cut -f-2 2L.scaffolded.fasta.fai | sort -nrk 2
```
This will output the bp length of each contig in `2L.scaffolded.fasta`:
```
2L	23922314
3L	728259
2R	719145
3R	551615
ptg000033l_1	470274
X	426731
ptg000001l_1	193563
ptg000024l_1	136059
3Cen_mapped_Scaffold_36_D1605	124935
211000022280470	90679
211000022278845	84909
```
We can clearly see that our longest contig does in fact scaffold to 2L. Notice how we have 10 other smaller contigs that were scaffolded to other chromosomes/contigs in the D. melanogaster reference.

We can now use this assembly of 2L to call structural variants with assembly aligners. It's important to remember that while we have 10 other contigs in our fasta file as well, we know our reads are from 2L. We can further filter the fasta file to only include the sequence of 2L. We will use this fasta file for SV calling in the next part.

```
cd $SCRATCH/BIOS424/lab_two/
samtools faidx ragtag/2L.scaffolded.fasta 2L > 2L.fasta
```

---

## Calling structural variants from read alignments with Sniffles2

