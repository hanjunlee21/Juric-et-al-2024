#!/bin/bash

bam="../palbociclib/bam"
coverage="../palbociclib/coverage"

files="MGH358-1 MGH358-1-resistant MGH358-2 MGH358-2-resistant MGH10035-1 MGH10035-1-resistant MGH10035-2 MGH10035-2-resistant"
kits="Agilent_SureSelect_Human_All_Exon_v7"

GENOME="/media/hanjun/Hanjun_Lee_Book/Genome"

preprocessing() {
printf "preprocseeing: ${1}\n"
cnvkit.py access ${GENOME}/Homo_sapiens_assembly19.fasta -o ${GENOME}/Homo_sapiens_assembly19.CNVkit.access.bed
cnvkit.py target ${GENOME}/capture_region/${1}.bed --annotate ${GENOME}/Homo_sapiens_assembly19.refFlat.txt --split -o ${GENOME}/capture_region/${1}.target.bed
cnvkit.py antitarget ${GENOME}/capture_region/${1}.target.bed --access ${GENOME}/Homo_sapiens_assembly19.CNVkit.access.bed -o ${GENOME}/capture_region/${1}.antitarget.bed
cnvkit.py reference -o ${coverage}/Homo_sapiens_assembly19.cnn -f ${GENOME}/Homo_sapiens_assembly19.fasta -t ${GENOME}/capture_region/${1}.target.bed -a ${GENOME}/capture_region/${1}.antitarget.bed
}

mkdir -p ${coverage}

for kit in ${kits}
do
preprocessing "${kit}"
done

cnv() {
printf "cnv: ${1}\n"
cnvkit.py coverage ${bam}/${1}.readGroup.bam ${GENOME}/capture_region/${2}.target.bed -o ${coverage}/${1}.targetcoverage.cnn
cnvkit.py coverage ${bam}/${1}.readGroup.bam ${GENOME}/capture_region/${2}.antitarget.bed -o ${coverage}/${1}.antitargetcoverage.cnn
cnvkit.py fix ${coverage}/${1}.targetcoverage.cnn ${coverage}/${1}.antitargetcoverage.cnn ${coverage}/Homo_sapiens_assembly19.cnn -o ${coverage}/${1}.cnr
cnvkit.py segment ${coverage}/${1}.cnr -o ${coverage}/${1}.cns
cnvkit.py call ${coverage}/${1}.cns -o ${coverage}/${1}.call.cns
}

for file in ${files}
do
cnv "${file}" "${kits}"
done

