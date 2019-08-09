#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$queue,$wsh);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"fq:s"=>\$fin,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"queue:s"=>\$queue,
			) or &USAGE;
&USAGE unless ($fout);
$fin=ABSOLUTE_DIR($fin);
$queue||="DNA";
mkdir $fout if (!-d $fout);
$fout=ABSOLUTE_DIR($fout);
mkdir $wsh if (!-d $wsh);
$wsh=ABSOLUTE_DIR($wsh);
my $out="$fout/02.bwa";
mkdir $out if (!-d $out);
open In,$fin;
open SH,">$wsh/step2.sh";
open LS,">$out/step2.list";
while (<In>) {
	chomp;
	my ($id,$fq1,$fq2)=split/\s+/,$_;
	print SH "mkdir --p $out/$id && cd $out/$id && bwa mem -T 19 $fout/01.ref/ref.fa $fq1 $fq2 1\>$out/$id/aln-pe.sam 2\>$out/$id/aln-pe.log\n";
	print LS "$id\t$out/$id/aln-pe.sam\n";
}
close In;
close SH;
close LS;
my $job="qsub-slurm.pl  --Queue $queue --Resource mem=60G --CPU 19 $wsh/step2.sh";
`$job`;
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
	eg: perl ste

Usage:
  Options:
	"fq:s"=>\$fin,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"queue:s"=>\$queue,
	-h         Help

USAGE
        print $usage;
        exit;
}
