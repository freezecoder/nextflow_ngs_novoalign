#!/usr/bin/env nextflow
 
params.genome=null
params.reads=null
   
if (!params.reads || !params.genome){
    exit 1, "Parameters '--reads' and '--genome'   are required to run the pipeline"
}


println params.platform
println params.sampleparams.sampleid

/*
 * Defines pipeline parameters in order to specify the refence genomes
 * and read pairs by using the command line options


/*
 * The reference genome file
 */
genome_file = file(params.genome)
  
/*
 * Creates the `read_pairs` channel that emits for each read-pair a tuple containing
 * three elements: the pair ID, the first read-pair file and the second read-pair file
 */
Channel
    .fromFilePairs( params.reads )                                             
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }  
    .set { read_pairs }
  
/*


* Step 1. Builds the genome index required by the mapping process
 */
process buildNovoIndex {
    container = "mydockerimagename"
    
    input:
    file genome from genome_file
      
    output:
    file 'genome.index*' into genome_index
        
    """
    novoindex genome.index ${genome} 
    """
}
/*
 * Step 2. Maps each read-pair by using Novoalign 
 */

if ( params.aligner.name == "novoalign" ) {
println "Aligning with Novoalign"
process novoalign {
    container = "mydockerimagename"
    
    tag "$pair_id"
    publishDir "${params.outdir}/alignment", mode: 'copy', overwrite: true

    //output:
    //set val(sample), file("${sample}_novoalign.sam") into raw_aln_sam

    input:
    file genome from genome_file
    file index from genome_index
    set pair_id, file(reads) from read_pairs
   
  
    output:
    set pair_id,file("${pair_id}_novoalign.bam") into bam_files
    set pair_id ,file("${pair_id}_novoalign.log.txt") into align_log
    
    """
        novoalign -d genome.index -f ${reads} -oSAM -H --hlimit 7  2> ${pair_id}_novoalign.log.txt |samtools view -bS -  > ${pair_id}_novoalign.bam
    """
}

}

/*
 * Step 2. Sorts alignment files
 */

process novosort {
    container = "mydockerimagename"
    
    tag "pair_id"
     publishDir "${params.outdir}/alignment", mode: 'copy', overwrite: true
    
    input:
        set pair_id, file(bam_file) from bam_files

    output:
        set pair_id, file("${pair_id}.bam") into sorted_bam
        set pair_id, file("${pair_id}.novosort.log.txt") into novosort_log

    """ 
        novosort -i ${bam_file} -o ${pair_id}.bam 2> ${pair_id}.novosort.log.txt
    """
}

/*
 * Step 3. Call Variants using samtools mpileup
*/


process samtoolsVarCall {
    tag "$pair_id"
    container = "myimagename2"
    
    publishDir "${params.outdir}/varcalls", mode: 'copy', overwrite: true
     
    input:
    set pair_id, bam_file from sorted_bam
    file genome from genome_file
      
    output:
    set pair_id, file("${pair_id}.raw.vcf") into raw_vcf
  
    """
        samtools mpileup -q 2 -d 3000  -ugf ${genome} ${bam_file} 2> sam.err | bcftools call -vmO v -o ${pair_id}.raw.vcf
    """
}



