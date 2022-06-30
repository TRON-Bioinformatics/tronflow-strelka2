#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { STRELKA2; CONCAT_FILES } from './modules/strelka2'
include { MERGE_REPLICATES } from './modules/merge_replicates'

params.help= false
params.input_files = false
params.reference = false
params.intervals = false
params.output = 'output'


def helpMessage() {
    log.info params.help_message
}

if (params.help) {
    helpMessage()
    exit 0
}

if (!params.reference) {
    log.error "--reference is required"
    exit 1
}

if (! params.input_files) {
  exit 1, "--input_files is required!"
}
else {
  Channel
    .fromPath(params.input_files)
    .splitCsv(header: ['name', 'tumor_bam', 'normal_bam'], sep: "\t")
    .map{ row-> tuple(row.name, row.tumor_bam, row.normal_bam) }
    .set { input_files }
}


workflow {
    MERGE_REPLICATES(input_files)
    STRELKA2(MERGE_REPLICATES.out.merged_bams)
    CONCAT_FILES(STRELKA2.out.passed_vcfs)
}
