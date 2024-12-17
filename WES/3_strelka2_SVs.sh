#!/bin/bash

outdir="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/bam"
variant="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredMutation"

files="MGH358-1 MGH358-2 MGH10035-1 MGH10035-2"
extension="fq.gz"
GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"

mkdir -p $variant

docker start muTect1

for file in $files
do
mkdir -p $variant/${file}
/home/hanjun/Strelka2/bin/configureStrelkaSomaticWorkflow.py --normalBam $outdir/${file}.readGroup.bam --tumorBam $outdir/${file}-resistant.readGroup.bam --referenceFasta $GENOME/Homo_sapiens_assembly19.fasta --runDir $variant/${file} --exome
$variant/$file/runWorkflow.py -m local -j 8
done
