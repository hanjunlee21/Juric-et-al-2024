#!/bin/bash

vep="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredVEP"
GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"

files="MGH10035-1 MGH10035-2 MGH358-1 MGH358-2"

task() {
mkdir -p $vep/$1
for file in $files
do
cat $vep/raw/$file.txt | awk '{if(NR==1 || (($4~/missense_variant/ || $4~/NMD_transcript_variant/ || $4~/frameshift_variant/ || $4~/splice/ || $4~/stop_gained/) && $7=="'$2'")) {print}}' > $vep/$1/$file.$1.txt
printf "$file\n"
done
}

task "RB1" "ENSG00000139687"
task "TP53" "ENSG00000141510"
