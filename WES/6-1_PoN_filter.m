
% /data/rama/labMembers/msl61/dyson/20230108_wxs/run.m

d=[]; d.in=direc('/data/rama/labMembers/msl61/dyson/20230108_wxs/data/1/*.vcf');
d.out = regexprep(d.in,'\.vcf$','.pon_filtered.vcf');
d.indel = grepm('indel',d.in);

pon = 9;        % pon9 = 8334 TCGA FH WXS normals
thresh = 0.2;   % keep positions having < 0.2 percent nonreference reads

for i=1:slength(d),disp(i)
  if exist(d.out{i},'file'), continue; end
  z = load_struct_noheader(d.in{i});
  f = fieldnames(z);
  z.chr = convert_chr(z.col1,'hg19');
  z.pos = str2doubleq(z.col2);
  z = reorder_struct(z,z.chr>=1 & z.chr<=24);  % keep only chr1-22XY
  if ~d.indel(i) % SNVs
    z.pon = summarize_pon(get_pon(z.chr,z.pos,pon));
  else           % indels
    z.pon_left = summarize_pon(get_pon(z.chr,z.pos-1,pon));
    z.pon_center = summarize_pon(get_pon(z.chr,z.pos,pon));
    z.pon_right = summarize_pon(get_pon(z.chr,z.pos+1,pon));
    z.pon = max([z.pon_left z.pon_center z.pon_right],[],2);
  end
  z.pon_keep = (z.pon<thresh);
  z = reorder_struct(z,z.pon_keep);
  z = keep_fields(z,f);
  save_struct_noheader(z,d.out{i});
end