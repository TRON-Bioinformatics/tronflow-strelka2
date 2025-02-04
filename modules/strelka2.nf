process STRELKA2 {
    cpus "${params.cpus}"
    memory "${params.memory}"
    tag "${name}"

    conda (params.enable_conda ? 'conda-forge::python=2.7.15 bioconda::strelka=2.9.10=h9ee0642_1' : null)

    input:
    tuple val(name), file(tumor_bam), file(tumor_bai), file(normal_bam), file(normal_bai)

    output:
      tuple val(name), file("somatic.snvs.vcf.gz"),
              file("somatic.snvs.vcf.gz.tbi"),
              file("somatic.indels.vcf.gz"),
              file("somatic.indels.vcf.gz.tbi"), emit: passed_vcfs

    script:
    intervals_option = params.intervals ? "--exome --callRegions ${params.intervals}" : ""

    """
    configureStrelkaSomaticWorkflow.py \
    --tumorBam ${tumor_bam} \
    --normalBam ${normal_bam} \
    --referenceFasta ${params.reference} \
    --runDir ./output \
    ${intervals_option}

    python2 ./output/runWorkflow.py -m local -j $task.cpus

    cp output/results/variants/* .
    """
}

process CONCAT_FILES {
    cpus "${params.cpus}"
    memory "${params.memory}"
    publishDir "${params.output}/${name}", mode: 'copy'
    tag "${name}"

    conda (params.enable_conda ? "conda-forge::libgcc-ng=14.2.0 conda-forge::gsl=2.7 bioconda::bcftools=1.15.1" : null)

    input:
        tuple val(name), file(passed_snvs), file(passed_snvs_idx), file(passed_indels), file(passed_indels_idx)

    output:
        tuple file("${name}.strelka2.somatic.vcf.gz"), file("${name}.strelka2.somatic.vcf.gz.tbi"), emit: passed_vcf

    """
    bcftools concat --allow-overlaps ${passed_indels} ${passed_snvs}  -O z > ${name}.strelka2.somatic.vcf.gz
    tabix -p vcf ${name}.strelka2.somatic.vcf.gz
    """
}
