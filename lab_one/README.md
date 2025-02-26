# Lab 1
Once we have successfully completed a nanopore sequencing run, we will have to perform super accuracy basecalling on our raw nanopore data. To do this, we will run Dorado on Sherlock's gpu nodes.

First, clone this github repo somewhere you can easily access on Sherlock. (I would recommend `$SCRATCH`; it's what all the scripts will assume).
```
cd $SCRATCH
git clone https://github.com/jahemker/BIOS424/
cd BIOS424/
```

Move into the `lab_one` folder and make a new directory named `dmel1`, which is the name of the sample we will be basecalling. Make another directory in `dmel1` called `pod5`, which is where we will store our data.
```
cd lab_one/
mkdir -p dmel1/pod5
```
Now, we need our raw nanopore data, which comes in a file format called `.pod5`. Copy a sample `.pod5` file from my directory.
```
cp /scratch/users/jahemker/BIOS424/dmel1/pod5/PAY03262_pass_babfcc7c_f5e685fc_431.pod5 dmel1/pod5/
```

You should also be able to see that there is a directory in `lab_one` called `scripts` which holds all of the code for what we will be doing today. Note that all of the scripts are written under the assumption you will be calling them from within the `lab_one` directory, not in the `scripts` directory. You can open the scripts using a text editor like `vim` or `emacs`, or just view them with `less` or `cat`.

We can now submit this job to Sherlock.
```
sbatch scripts/submit_dorado.sh
```
You can check the status of the job on Sherlock.
```
squeue -u $USER
```

You should receive an email when the job has started, as well as when it finishes (either completed or terminated early due to error).

When the job successfully completes, we will have:

