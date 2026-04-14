

process MERGE_REPLICATES {
    tag "$name"
    cpus "${params.cpus}"
    memory "${params.memory}"

    conda (params.enable_conda ? "bioconda::sambamba=${params.sambamba_version}" : null)

    input:
    tuple val(name), val(tumor), val(normal)

    output:
    tuple val(name), path("${name}.tumor.bam"), path("${name}.tumor.bam.bai"),
        path("${name}.normal.bam"), path("${name}.normal.bam.bai"), emit: merged_bams

    script:
    if (tumor.contains(',')) {
        tumor_inputs = tumor.split(",").join(" ")
        tumor_merge_cmd = "sambamba merge -t ${task.cpus} ${name}.tumor.bam ${tumor_inputs}"
    }
    else {
        tumor_merge_cmd = "ln -s ${tumor} ${name}.tumor.bam"
    }

    if (normal.contains(',')) {
        normal_inputs = normal.split(",").join(" ")
        normal_merge_cmd = "sambamba merge -t ${task.cpus} ${name}.normal.bam ${normal_inputs}"
    }
    else {
        normal_merge_cmd = "ln -s ${normal} ${name}.normal.bam"
    }
    """
    ${tumor_merge_cmd}
    sambamba index ${name}.tumor.bam

    ${normal_merge_cmd}
    sambamba index ${name}.normal.bam
    """
}
