#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fout,$ref,$queue,$wsh,$gff);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$ref,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"gff:s"=>\$gff,
	"queue:s"=>$queue,
			) or &USAGE;
&USAGE unless ($fout);
$fout=ABSOLUTE_DIR($fout);
my $out=ABSOLUTE_DIR("$fout/01.step1");
mkdir $out if (!-d $out);
$ref=ABSOLUTE_DIR($ref);
open SH,">$wsh/step1.sh";
print SH "cd $out && bwa index -a bwtsw $ref/ref.fa \n";
print SH "cd $out && hisat2-build  $ref/ref.fa ref_index \n";
print SH "cd $out && gffread -T -o ref_genome.gtf $gff ";
close SH;
my $job="qsub-slurm.pl  --Queue $queue --Resource mem=30G --CPU 3 $wsh/step1.sh";
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
