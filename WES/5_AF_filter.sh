#!/bin/bash

variant="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredMutation"
vcf="/media/hanjun/Hanjun_Lee_Book/Lawrence/BRCA/WES/palbociclib/acquiredVCF"

files="MGH358-1 MGH358-2 MGH10035-1 MGH10035-2"

mkdir -p $vcf

for file in $files
do
# snvs from MuTect1
bcftools filter -Ov -o $vcf/$file.snvs.tmp -i 'FA>0.25' $variant/$file.MuTect1.vcf
cat $vcf/$file.snvs.tmp | grep "^[^#;]" | grep PASS > $vcf/$file.snvs.vcf
rm $vcf/$file.snvs.tmp
# indels from Strelka2
zcat $variant/$file/results/variants/somatic.indels.vcf.gz | grep "^[^#;]" | grep -v SNV | grep PASS > $vcf/$file.indels.vcf
bgzip $vcf/$file.snvs.vcf && tabix -p vcf $vcf/$file.snvs.vcf.gz
bgzip $vcf/$file.indels.vcf && tabix -p vcf $vcf/$file.indels.vcf.gz
printf "$file\n"
done
