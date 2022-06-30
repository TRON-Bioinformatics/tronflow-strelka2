process STRELKA2 {
    cpus "${params.cpus}"
    memory "${params.memory}"
    tag "${name}"

    conda (params.enable_conda ? 'conda-forge::python=2.7.15 bioconda::strelka=2.9.10' : null)

    input:
    tuple val(name), file(tumor_bam), file(tumor_bai), file(normal_bam), file(normal_bai)

    output:
      tuple val(name), file("somatic.snvs.vcf.gz"),
              file("somatic.snvs.vcf.gz.tbi"),
              file("somatic.indels.vcf.gz"),
              file("somatic.indels.vcf.gz.tbi"), emit: passed_vcfs

    script:
    """
    configureStrelkaSomaticWorkflow.py \
    --tumorBam ${tumor_bam} \
    --normalBam ${normal_bam} \
    --referenceFasta ${params.reference} \
    --runDir ./output \
    --exome

    python2 ./output/runWorkflow.py -m local -j $task.cpus

    cp output/results/variants/* .
    """
}

process CONCAT_FILES {
    cpus 1
    memory '4g'
    publishDir "${params.output}/${name}", mode: 'copy'
    tag "${name}"

    conda (params.enable_conda ? "bioconda::bcftools=1.15.1" : null)

    input:
        tuple val(name), file(passed_snvs), file(passed_snvs_idx), file(passed_indels), file(passed_indels_idx)

    output:
        tuple file("${name}.passed.somatic.vcf"), emit: passed_vcf

    """
    bcftools concat --allow-overlaps ${passed_indels} ${passed_snvs} > ${name}.passed.somatic.vcf
  	"""
}
