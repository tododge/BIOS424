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

First on Sherlock, pull from github the updated version of this folder.

```
cd $SCRATCH/BIOS424 #or wherever you cloned it last lab.
git pull
```
