#!/bin/bash
trimgalore="../trim-galore"
aligned="../STAR"
fused="../STAR-Fusion"
counted="../RSEM"
bigwig="../bigwig"
stargenome="/media/hanjun/Hanjun_Lee_Book/Genome/STAR/hg38.chromosomal.X"
GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"
thread=4
files="10035.1_PDres_v1 10035.2_PDres_v1 358.1_PDres_v2 358.2_PDres_v1 405.2_v1 406.4_v2 T47D_Pdres20_v3"

# Trim-galore
mkdir -p $trimgalore

galore() {
mkdir -p $trimgalore/$2
trim_galore --illumina --paired -j $thread -o $trimgalore/$2 $1/$2_R1.fq.gz $1/$2_R2.fq.gz
}

for file in $files
do
galore "../fastq" "$file"
done

# First-pass STAR
firstpass() {
mkdir -p $aligned/$1.tmp
STAR --runThreadN $thread --genomeDir $stargenome --readFilesIn $trimgalore/$1/$1_R1_val_1.fq.gz $trimgalore/$1/$1_R2_val_2.fq.gz --readFilesCommand zcat --sjdbOverhang 149 --sjdbGTFfile $GENOME/ensembl.v105.hg38.gtf --outFileNamePrefix $aligned/$1.tmp/
mv $aligned/$1.tmp/SJ.out.tab $aligned/sjdb.first/$1.tab
rm -r $aligned/$1.tmp
}

mkdir -p $aligned/sjdb.first $aligned/sjdb.second

for file in $files
do
firstpass "$file"
done

# Second-pass STAR
secondpass() {
mkdir -p $aligned/$1
STAR --runThreadN $thread --genomeDir $stargenome --readFilesIn $trimgalore/$1/$1_R1_val_1.fq.gz $trimgalore/$1/$1_R2_val_2.fq.gz --readFilesCommand zcat --sjdbOverhang 149 --sjdbGTFfile $GENOME/ensembl.v105.hg38.gtf --outFileNamePrefix $aligned/$1/ --sjdbFileChrStartEnd $aligned/sjdb.first/10035.1_PDres_v1.tab $aligned/sjdb.first/10035.2_PDres_v1.tab $aligned/sjdb.first/358.1_PDres_v2.tab $aligned/sjdb.first/358.2_PDres_v1.tab $aligned/sjdb.first/405.2_v1.tab $aligned/sjdb.first/406.4_v2.tab $aligned/sjdb.first/T47D_Pdres20_v3.tab --quantMode TranscriptomeSAM --outSAMtype BAM Unsorted
cp $aligned/$1/SJ.out.tab $aligned/sjdb.second/$1.tab
}

for file in $files
do
secondpass "$file"
done

count() {
rsem-calculate-expression -p $thread --alignments --paired-end $aligned/$1/Aligned.toTranscriptome.out.bam $GENOME/RSEM/hg38.chromosomal.X $counted/$1
}

mkdir -p $counted

for file in $files
do
count "$file"
done

# STAR-Fusion
fusion() {
mkdir -p $fused/$1
STAR-Fusion --left_fq $trimgalore/$1/$1_1_val_1.fq.gz --right_fq $trimgalore/$1/$1_2_val_2.fq.gz --genome_lib_dir $GENOME/STAR-Fusion/GRCh38.gencode.v37.CTAT --output_dir $fused/$1
}

for file in $files
do
samtools sort $aligned/$file/Aligned.out.bam -o $aligned/$file/Aligned.out.sorted.bam
samtools index $aligned/$file/Aligned.out.sorted.bam
fusion "$file"
done

mkdir -p $bigwig

tobigwig() {
bamCoverage -b $aligned/$file/Aligned.out.sorted.bam --normalizeUsing CPM --outFileFormat bigwig --binSize 1 -o $bigwig/$1.CPM.bigWig
}

for file in $files
do
tobigwig "$file"
done
