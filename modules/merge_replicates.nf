

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
    tumor_inputs_list = tumor.split(",").collect { it.trim() }.findAll { it }.unique()
    tumor_prepare_cmds = []
    tumor_prepared_inputs = []
    tumor_inputs_list.eachWithIndex { bam, idx ->
        def preparedBam = "${name}.tumor.input${idx}.prepared.bam"
        tumor_prepare_cmds << "if sambamba view -H \"${bam}\" | grep -E '^@HD' | grep -q 'SO:coordinate'; then ln -s \"${bam}\" \"${preparedBam}\"; else sambamba sort -t ${task.cpus} -o \"${preparedBam}\" \"${bam}\"; fi"
        tumor_prepared_inputs << preparedBam
    }
    if (tumor_prepared_inputs.size() > 1) {
        tumor_merge_cmd = "sambamba merge -t ${task.cpus} ${name}.tumor.bam ${tumor_prepared_inputs.join(' ')}"
    }
    else {
        tumor_merge_cmd = "ln -s ${tumor_prepared_inputs[0]} ${name}.tumor.bam"
    }

    normal_inputs_list = normal.split(",").collect { it.trim() }.findAll { it }.unique()
    normal_prepare_cmds = []
    normal_prepared_inputs = []
    normal_inputs_list.eachWithIndex { bam, idx ->
        def preparedBam = "${name}.normal.input${idx}.prepared.bam"
        normal_prepare_cmds << "if sambamba view -H \"${bam}\" | grep -E '^@HD' | grep -q 'SO:coordinate'; then ln -s \"${bam}\" \"${preparedBam}\"; else sambamba sort -t ${task.cpus} -o \"${preparedBam}\" \"${bam}\"; fi"
        normal_prepared_inputs << preparedBam
    }
    if (normal_prepared_inputs.size() > 1) {
        normal_merge_cmd = "sambamba merge -t ${task.cpus} ${name}.normal.bam ${normal_prepared_inputs.join(' ')}"
    }
    else {
        normal_merge_cmd = "ln -s ${normal_prepared_inputs[0]} ${name}.normal.bam"
    }
    """
    ${tumor_prepare_cmds.join('\n')}
    ${tumor_merge_cmd}
    sambamba index ${name}.tumor.bam

    ${normal_prepare_cmds.join('\n')}
    ${normal_merge_cmd}
    sambamba index ${name}.normal.bam
    """
}
