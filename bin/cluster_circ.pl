#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$ref,$wsh,$queue);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"queue:s"=>\$queue,
	"ref:s"=>\$ref,
			) or &USAGE;
&USAGE unless ($fout);
my $clu =ABSOLUTE_DIR("$fout/06.cluster_circ");
mkdir $clu if (!-d $clu);
mkdir $wsh if (!-d $wsh);
$fout=ABSOLUTE_DIR($fout);
$wsh=ABSOLUTE_DIR($wsh);
open In,"<$fout/01.hisat_mapping/bam.list";
open out,">$wsh/06.cluster.sh";
my $cluster="/mnt/ilustre/users/bingxu.liu/workspace/RNA_Pipeline/RNAseq_ToolBox_v1410 cluster";
open SH,">$wsh/06.cluster.sh";
print SH "cat $fout/06.cluster_circ/replicates_exp/*.DE.list >$fout/06.cluster_circ/list && sort $fout/06.cluster_circ/list >$fout/06.cluster_circ/DE.list && ";
print SH "perl $Bin/bin/get.matrix.pl -l $fout/06.cluster_circ/DE.list -t $fout/04.count/cirRNA.srpnm.xls -o $fout/06.cluster_circ/DE.matrix && ";
print SH "cp $Bin/bin/heatmap.r $fout/06.cluster_circ && cd $fout/06.cluster_circ && $cluster $fout/06.cluster_circ/DE.matrix -type n heatmap" 
close SH;
my $job="qsub-slurm.pl  --Queue $queue --Resource mem=10G  $wsh/06.cluster.sh";
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

	eg: perl -int filename -out filename 
	

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
