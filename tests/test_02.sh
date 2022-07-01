#!/bin/bash


source tests/assert.sh
output=output/test2
echo -e "sample1\t"`pwd`"/test_data/TESTX_S1_L001.bam,"`pwd`"/test_data/TESTX_S1_L001.bam\t"`pwd`"/test_data/TESTX_S1_L003.bam,"`pwd`"/test_data/TESTX_S1_L003.bam" > test_data/test_input.txt
nextflow main.nf -profile test,conda --output $output --input_files test_data/test_input.txt

test -s $output/sample1/sample1.strelka2.somatic.vcf.gz || { echo "Missing output VCF!"; exit 1; }
test -s $output/sample1/sample1.strelka2.somatic.vcf.gz.tbi || { echo "Missing output index!"; exit 1; }
