# Simple Nextflow NGS pipeline using Novoalign-Novosort on Docker


Description
============

A quickstart on using novoalign and novosort in a computational pipeline to align and call variants.


Set up
------

This is intended to run on a linux or mac machine and assumes familiarity with unix.

* Install Nextflow
* Install docker
* Clone this repository

Edit main.nf and change the docker imagenames in the "container" section


Docker
-------------------

Build a docker image with novoalign and novosort and your license file. Also add samtools and bcftools to this docker image.
You can obtain a Novoalign license at http://www.novocraft.com/buy

Running
----------

```sh}

nextflow run -resume main.nf  --genome testdata/yeast_genome.fa  --reads "testdata/*{1,2}.fastq.gz"


```

Using S3 Storage
------------------

```{sh}

nextflow run main.nf --genome $LOCALPATH/testdata/yeast_genome.fa  --reads "s3://bucketname/inputs/*{1,2}.fastq.gz" --outdir s3://bucketname/results00000133

```


For Cloud storage use s3 paths but the pipeline will run locally

```{sh}

nextflow run  main.nf --genome "s3://bucketname/inputs/yeast_genome.fa"  --reads "s3://bucketname/inputs/*{1,2}.fastq.gz" --outdir s3://bucketname/batchjob0000001 -w s3://nx001/tmp0000011

```



Results
----------

See the results folder for outputs, including trace logs and workflow report






