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
docker exec muTect1 java -Xmx4g -jar muTect-1.1.7.jar -T MuTect --unsafe -R $GENOME/Homo_sapiens_assembly19.fasta -I:normal $outdir/${file}.readGroup.bam -I:tumor $outdir/${file}-resistant.readGroup.bam -o $variant/${file}.call_stats.txt -vcf $variant/${file}.MuTect1.vcf
grep -v REJECT $variant/${file}.call_stats.txt > $variant/${file}.call_stats.keep.txt
done
