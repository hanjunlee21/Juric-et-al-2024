#!/bin/bash

vcf="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredVCF"
bed="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/bed/"

files="MGH358-1 MGH358-2 MGH10035-1 MGH10035-2"

mkdir -p $vcf/snvs $vcf/indels $vcf/merged

for file in $files
do
cat $vcf/header.snvs.vcf $vcf/filtered/$file.snvs.pon_filtered.vcf | bedtools intersect -a - -b $bed/TruSeq_Exome_TargetedRegions_v1.2_hg19.ncbi.bed | cat $vcf/header.snvs.vcf - > $vcf/snvs/$file.snvs.pon_filtered.vcf
cat $vcf/header.indels.vcf $vcf/filtered/$file.indels.pon_filtered.vcf | bedtools intersect -a - -b $bed/TruSeq_Exome_TargetedRegions_v1.2_hg19.ncbi.bed | cat $vcf/header.indels.vcf - > $vcf/indels/$file.indels.pon_filtered.vcf
bgzip $vcf/snvs/$file.snvs.pon_filtered.vcf && tabix -p vcf $vcf/snvs/$file.snvs.pon_filtered.vcf.gz
bgzip $vcf/indels/$file.indels.pon_filtered.vcf && tabix -p vcf $vcf/indels/$file.indels.pon_filtered.vcf.gz
zcat $vcf/snvs/$file.snvs.pon_filtered.vcf.gz > $vcf/snvs/$file.snvs.pon_filtered.vcf
zcat $vcf/indels/$file.indels.pon_filtered.vcf.gz > $vcf/indels/$file.indels.pon_filtered.vcf
printf "$file\n"
done

for file in $files
do
bcftools merge $vcf/snvs/$file.snvs.pon_filtered.vcf.gz $vcf/indels/$file.indels.pon_filtered.vcf.gz -o $vcf/merged/$file.pon_filtered.vcf.gz -O z
tabix -p vcf $vcf/merged/$file.pon_filtered.vcf.gz

gunzip -c $vcf/merged/$file.pon_filtered.vcf.gz > $vcf/merged/$file.pon_filtered.vcf

printf "$file\n"
done

