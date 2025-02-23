

process MERGE_REPLICATES {
    tag "$name"
    cpus "${params.cpus}"
    memory "${params.memory}"

    conda (params.enable_conda ? 'conda-forge::libgcc-ng=14.2.0 conda-forge::gsl=2.7 conda-forge::openssl=3.4.0 bioconda::samtools=1.21' : null)

    input:
    tuple val(name), val(tumor), val(normal)

    output:
    tuple val(name), path("${name}.tumor.bam"), path("${name}.tumor.bam.bai"),
        path("${name}.normal.bam"), path("${name}.normal.bam.bai"), emit: merged_bams

    script:
    if (tumor.contains(',')) {
        tumor_inputs = tumor.split(",").join(" ")
        tumor_merge_cmd = "samtools merge ${name}.tumor.bam ${tumor_inputs}"
    }
    else {
        tumor_merge_cmd = "ln -s ${tumor} ${name}.tumor.bam"
    }

    if (normal.contains(',')) {
        normal_inputs = normal.split(",").join(" ")
        normal_merge_cmd = "samtools merge ${name}.normal.bam ${normal_inputs}"
    }
    else {
        normal_merge_cmd = "ln -s ${normal} ${name}.normal.bam"
    }
    """
    ${tumor_merge_cmd}
    samtools index ${name}.tumor.bam

    ${normal_merge_cmd}
    samtools index ${name}.normal.bam
    """
}
