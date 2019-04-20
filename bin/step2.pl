#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$ref,$queue,$wsh);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"fq:s"=>\$fin,
	"ref:s"=>\$ref,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"queue:s"=>$queue,
			) or &USAGE;
&USAGE unless ($fout);
$fout=ABSOLUTE_DIR($fout);
mkdir $fout if (!-d $fout);
my $out=ABSOLUTE_DIR("$fout/02.step2");
mkdir $out if (!-d $out);
#$fin=ABSOLUTE_DIR("$fout/../01.hisat-mapping/hisat.list");
open In,$fin;
open SH,">$wsh/step2.sh";
open LS,">$out/step2.list";
while (<In>) {
	chomp;
	my ($id,undef,$fq1,$fq2)=split/\s+/,$_;
	print SH "mkdir --p $out/$id && cd $out/$id && bwa mem -T 19 $fout/01.step1/ $fq1 $fq2 1\>$out/$id/aln-pe.sam 2\>$out/$id/aln-pe.log\n";
	print LS "$id\t$out/$id/aln-pe.sam\n";
}
close In;
close SH;
close LS;
my $job="qsub-slurm.pl  --Queue $queue --Resource mem=100G --CPU 19 $wsh/step2.sh";
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
	"help|?" =>\&USAGE,
	"fqlist:s"=>\$fin,
	"out:s"=>\$fout,
	"ref:s"=>\$ref,
	"wsh:s"=>\$wsh,
	"strand:s"=>\$strand,
	"queue:s"=>\$queue,
	-h         Help

USAGE
        print $usage;
        exit;
}
