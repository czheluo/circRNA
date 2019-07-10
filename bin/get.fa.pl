#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$out,$genes);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"fa:s"=>\$fin,
	"gene:s"=>\$genes,
	"out:s"=>\$out,
			) or &USAGE;
&USAGE unless ($out);
open IN,$fin;
my %seq;
$/ = ">";
while(<IN>){
		chomp;
		next if ($_ eq "" || /^$/);
		my ($chr,$seq) = split(/\n/,$_,2);
		my (undef,$gen,undef)=split/\s+/,$chr,3;
		my (undef,$gene)=split/\=/,$gen;
		$seq{$gene} = $seq;
}
close IN;
$/ = "\n";
open IN,$genes;
open OUT,">",$out;
while(<IN>){
		chomp;
		if (exists $seq{$_}) {
			print Out ">$_\n";
			print Out "$seq{$_}\n";
		}
}
close IN;
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -fa ref.fa -gene gene.list -out gene.fa

Usage:
  Options:
	-fa ref.fa file 
	-gene genes list 
	-out output file name 
  -h         Help

USAGE
        print $usage;
        exit;
}
