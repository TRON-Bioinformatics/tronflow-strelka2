

process MERGE_REPLICATES {
    tag "$name"
    cpus 1
    memory '4g'

    conda (params.enable_conda ? 'conda-forge::libgcc-ng=10.3.0 conda-forge::gsl=2.7 bioconda::samtools=1.15.1' : null)

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