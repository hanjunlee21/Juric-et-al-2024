#!/bin/bash

GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"

vcf="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredVCF"
maf="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredMAF"
bed="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/bed/"

files="MGH358-1 MGH358-2 MGH10035-1 MGH10035-2"

mkdir -p $maf/mutsig2cv

for file in $files
do

cat $maf/$file.maf | grep "^[^#;]" | awk -F '\t' '{if(NR>1) {printf "%s\t%s\t%s\t'$file'\t%s\t%s\t%s\t%s\n",$5,$6,$1,$11,$13,$9,$10}}' > $maf/mutsig2cv/$file.tmp

cat $vcf/../header.maf $maf/mutsig2cv/$file.tmp > $maf/mutsig2cv/$file.maf
printf "$file\n"
done

cat $vcf/../header.maf $maf/mutsig2cv/MGH358-1.tmp $maf/mutsig2cv/MGH358-2.tmp $maf/mutsig2cv/MGH10035-1.tmp $maf/mutsig2cv/MGH10035-2.tmp  > $maf/mutsig2cv/cohort.maf
rm $maf/mutsig2cv/MGH358-1.tmp $maf/mutsig2cv/MGH358-2.tmp $maf/mutsig2cv/MGH10035-1.tmp $maf/mutsig2cv/MGH10035-2.tmp
