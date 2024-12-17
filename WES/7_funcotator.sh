#!/bin/bash

GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"

vcf="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredVCF"
maf="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredMAF"

files1="MGH358-1 MGH358-2"
files2="MGH10035-1 MGH10035-2"

mkdir -p $maf

task() {
printf "$1\n"
$HOME/gatk-*.*.*.*/./gatk Funcotator -R $GENOME/Homo_sapiens_assembly19.fasta -V $vcf/merged/$1.vcf -O $maf/$1.maf --output-file-format MAF --data-sources-path $GENOME/funcotator/dataSources.v1.7.20200521s/ --ref-version hg19
}

for file in $files1
do
task "$file" &
done
printf "running...\n"
wait
for file in $files2
do
task "$file" &
done
printf "running...\n"
wait

printf "completed!\n"
