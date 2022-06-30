#!/bin/bash


source tests/assert.sh
output=output/test1
echo -e "sample1\t"`pwd`"/test_data/TESTX_S1_L001.bam\t"`pwd`"/test_data/TESTX_S1_L003.bam" > test_data/test_input.txt
nextflow main.nf -profile test,conda --output $output --input_files test_data/test_input.txt

test -s $output/sample1/sample1.passed.somatic.vcf || { echo "Missing output VCF!"; exit 1; }
