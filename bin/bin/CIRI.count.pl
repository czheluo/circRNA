#!/usr/bin/perl
use warnings;
use strict;

die "perl $0 [sampleA.circRNA.xls] [sampleB.circRNA.xls] ... \n" if @ARGV==0;
my (%hash,@line,$tmp,@sam,$each,$sample,$circ,$count,$k,$id);

open(OUT,">circRNA.count.xls") or die $!;
print OUT "circRNA_ID\t";

foreach $each(@ARGV){
	
	$tmp=(split /\//,$each)[-1];
	$sample=(split /\./,$tmp)[0];
	print OUT "$sample\_count\t";
	push(@sam,$sample);
	open(SAM,"<$each") or die $!;
	while(<SAM>){
		chomp;
		next if (/^circRNA_ID/);
		@line=split /\t/;
		$circ=$line[0];
		$count=$line[4];
		$hash{$circ}{$sample}=$count;
	}
	close SAM;
}
print OUT "\n";

foreach $id(keys %hash){
	print OUT "$id\t";
	foreach $k(@sam){
		if(exists $hash{$id}{$k}){
			print OUT "$hash{$id}{$k}\t";
		}else{
			print OUT "0"."\t";
		}
	}
	print OUT "\n";
}

close OUT;
