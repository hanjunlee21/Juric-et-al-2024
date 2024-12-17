#!/bin/bash

indir="../fastq"
outdir="../bam"
trimgalore="../trim_galore"

files="MGH358-1 MGH358-1-resistant MGH358-2 MGH358-2-resistant MGH10035-1 MGH10035-1-resistant MGH10035-2 MGH10035-2-resistant"
extension="fq.gz"
GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"


mkdir -p $outdir $bwdir $trimgalore

for file in $files
do
trim_galore --illumina --fastqc --paired -j 8 -o $trimgalore/$file $indir/${file}_R1.$extension $indir/${file}_R2.$extension
done

for file in $files
do
bwa mem -t 8 $GENOME/Homo_sapiens_assembly19.fasta $trimgalore/${file}/${file}_R1_val_1.$extension $trimgalore/${file}/${file}_R2_val_2.$extension | samtools sort -@ 8 -o $outdir/$file.sorted.bam -
samtools index -@ 8 $outdir/$file.sorted.bam
sambamba sort -p -t 8 -o $outdir/$file.sambamba.bam $outdir/$file.sorted.bam
sambamba markdup -p -r -t 8 $outdir/$file.sambamba.bam $outdir/$file.markedDuplicates.bam
sambamba index -p -t 8 $outdir/$file.markedDuplicates.bam
echo $file
done

for file in $files
do
sambamba view -F "not (duplicate) and [NM] <= 2 and mapping_quality >= 30" -f bam -t 8 -o $outdir/$file.bam $outdir/$file.markedDuplicates.bam
sambamba index -p -t 8 $outdir/$file.bam
done
