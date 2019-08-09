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
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"queue:s"=>\$queue,
			) or &USAGE;
&USAGE unless ($fout);
$queue||="DNA";
mkdir $fout if (!-d $fout);
$fout=ABSOLUTE_DIR($fout);
mkdir $wsh if (!-d $wsh);
$wsh=ABSOLUTE_DIR($wsh);
my $out="$fout/07.host";
mkdir $out if (!-d $out);
open SH,">$wsh/07.host.sh";
print SH "cat $fout/04.count/*.sample.ciri.xls |cut -f 1,11|sort -u > $out/cir_host && ";
print SH "perl $Bin/bin/tabletools_select.pl -i $fout/06.cluster_circ/DE.list -t $out/cir_host -n 1 > $out/cir_host.DE && ";
print SH "less $out/cir_host.DE |sed 1d |cut -f2|grep -v \"n/a\" |sed \'s\/\,\/\\n\/g'|sort|uniq > $out/target.DE.list ";
close SH;
my $job="qsub-slurm.pl  --Queue $queue --Resource mem=60G --CPU 19 $wsh/07.host.sh";
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
