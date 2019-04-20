#! /usr/bin/perl -w
use strict;
my @files=`ls */*.map.log`;
my ($total,$uniq,$multi,$disc,$exec,$other,$mapped,$per);
print "Samples\tTotal_seq_num\tMapped_seq_num\tMapped_rate\tUniq_map_num\tUniq_rate\tMulti_map_num\tMulti_rate\n";
foreach(@files){
	open (I,"<$_");
	my $sample=($_=~ /(.*)\//)? $1:die;
	while (<I>){
		chomp;
		if (/^(\d+)\s+reads/){
			$total=$1;
		}elsif (/\s+(\d+)\s+\(.*aligned\s+concordantly\s+exactly\s+1\s+time/){
			$uniq=$1;
		}elsif(/\s+(\d+)\s+\(.*aligned\s+concordantly\s+>1\s+time/){
			$multi=$1;
		}elsif(/\s+(\d+)\s+\(.*\s+aligned\s+discordantly\s+1\s+time/){
			$disc=$1;
		}elsif(/\s+(\d+)\s+\(.*\s+aligned\s+exactly\s+1\s+time/){
			$exec=$1;
		}elsif(/\s+(\d+)\s+\(.*\s+aligned\s+>1\s+time/){
			$other=$1;
		}
	}
	$mapped=$uniq*2+$multi*2+$disc*2+$exec+$other;
	my $u=$uniq*2+$disc*2+$exec;
	my $m=$multi*2+$other;
	my $per_u=sprintf("%.2f",$u*50/$total);
	my $per_m=sprintf("%.2f",$m*50/$total);
	$per=sprintf("%.2f",$mapped*50/$total);
	print "$sample\t".($total*2)."\t$mapped\t$per%"."\t$u\t$per_u%\t$m\t$per_m%\n";
	close I;
}
