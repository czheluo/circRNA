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
	"int:s"=>\$fin,
	"ref:s"=>\$ref,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"queue:s"=>$queue,
			) or &USAGE;
&USAGE unless ($fout);
$fout=ABSOLUTE_DIR($fout);
my $out=ABSOLUTE_DIR("$fout/03.step3");
mkdir $out if (!-d $out);
$ref=ABSOLUTE_DIR($ref);
$fin=ABSOLUTE_DIR("$fout/02.step2/step2.list");
open In,$fin;
open SH,">$wsh/step3.sh";
open LS,">$out/step3.list"
while (<In>) {
	chomp;
	my ($id,$sam)=split/\s+/,$_;
	#my $ciri="/mnt/ilustre/centos7users/meng.luo/Pipeline/RNA/bin/CIRI2.pl";
	my $ciri="/mnt/ilustre/users/rna/newmdt/software/01.bin/CIRI_v2.0.6/CIRI2.pl";
	print SH "mkdir -p $out/$id && cd $out/$id && perl $ciri -I $sam -O $out/$id.ciri -F $ref/ref.fa -A $ref/ref_genome.gtf\n";
	print LS "$id\t$out/$id.ciri\n";
}
close In;
close SH;
close LS;
my $job="qsub-slurm.pl  --Queue $queue --Resource mem=30G --CPU 3 $wsh/step3.sh";
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

	eg: perl -int 
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
