# Simple Nextflow NGS pipeline using Novoalign-Novosort on Docker


Description
============

A quickstart on using novoalign and novosort in a computational pipeline to align and call variants.


Set up
------

This is intended to run on a linux or mac machine and assumes familiarity with unix.

* Install Nextflow
* Install docker


Edit main.nf and change the docker imagenames in the "container" section


Docker
-------------------

Build a docker image with novoalign and novosort and your license file. Also add samtools and bcftools to this docker image.
You can obtain a Novoalign license at http://www.novocraft.com/buy

Running
----------

'''{sh}

nextflow run -resume main.nf  --genome testdata/yeast_genome.fa  --reads "testdata/*{1,2}.fastq.gz" 
N E X T F L O W  ~  version 0.27.4
Launching `mapsimple.groovy` [evil_austin] - revision: 530dce4056
illumina
sample123
[warm up] executor > local
Aligning with Novoalign
[51/a0341e] Cached process > buildNovoIndex
[be/c13bcb] Cached process > novoalign (yeast_R)
[ea/d2efcd] Cached process > novosort (pair_id)
[29/562757] Cached process > samtoolsVarCall (yeast_R)

'''


Results
----------

See the results folder for outputs, including trace logs and workflow report






