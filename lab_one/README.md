# Lab 1
Once we have successfully completed a nanopore sequencing run, we will have to perform super accuracy basecalling on our raw nanopore data. To do this, we will run Dorado on Sherlock's gpu nodes.

Move into the `lab_one` folder and make a new directory named `dmel1`, which is the name of the sample we will be basecalling. Make another directory in `dmel1` called `pod5`, which is where we will store our data.
```
cd lab_one/
mkdir -p dmel1/pod5
```
Now, we need our raw nanopore data, which comes in a file format called `.pod5`. [Download this sample `.pod5` file](https://drive.google.com/file/d/1XydwR_ljegH58smLO5rG2jU5h9e6NjPa/view?usp=drive_link) and then upload it to the data directory we just made in the BIOS424 directory.

```
#you may have to change the first part depending on where you downloaded the file to
scp ~/Downloads/dmel1_raw.pod5 [suid]@dtn.sherlock.stanford.edu:$SCRATCH/BIOS424/lab_one/dmel1/pod5
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

