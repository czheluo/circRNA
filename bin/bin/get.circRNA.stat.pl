#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);
my @files=glob("$fin/*.xls");
my %chrs;
my %classs;
foreach my $file (@files) {
	my $fln=basename($file);
	my ($name,undef,undef,undef)=split/\./,$fln;
	open In,"<$fin/$fln";
	open Out,">$fout/$name.distribution.xls";
	print Out "num\tchromosome\n";
	open OUT,">$fout/$name.class.xls";
	#print $fln;die;
	while (<In>) {
		chomp;
		next if(/^CIRC_ID/);
		my (undef,undef,$chr,undef,undef,undef,undef,undef,undef,$class,undef)=split/\s+/,$_,11;
		next if($chr !~ "Chr");
		#print $chr,$class;die;
		$chrs{$chr}++;
		$classs{$class}++;
	}
	close In;
	foreach my $value (sort keys %chrs) {
		print Out "$chrs{$value}\t$value\n";
	}
	foreach my $key (sort keys %classs) {
		print OUT "$key\t$classs{$key}\n";
	}
	close Out;
	close OUT;
	#open RCMD, ">$fout/$name.R";
	#print RCMD "library("ggplot2")\n";
	#print RCMD "df<-read.table(file = \"$name.distribution.xls",header = T)\n";
	#print RCMD "\df\$chromosome<-factor(df\$chromosome,levels=c(\"chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chrX"))\n";
	#print RCMD "
	#png(paste(\"$name.chr.distribution", \".png", sep = ""), width = 1000, height = 800)
	#ggplot(data=df, aes(x=chromosome, y=num,fill=chromosome)) +
	#	geom_bar(stat="identity", width=0.5)+xlab("chromosome")+ylab("circRNA_number")
	#dev.off()
	#";
	#close RCMD;
	`perl /mnt/ilustre/centos7users/caixia.tian/Develoment/10.ASprofile/pipe/bin/Highcharts-4.0.4/Highchart.pl -t $name.class.xls -type pie -title "circRNA class" -head 0`;
}

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg: perl $Script -int xls/ -out ./
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
