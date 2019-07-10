#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$method,$wsh,$queue,$rep,$qvalue);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"rep:s"=>\$rep,
	"method:s"=>\$method,
	"qvalue:s"=>\$qvalue,
	"queue:s"=>\$queue,
			) or &USAGE;
&USAGE unless ($fout);
$qvalue||=0.005;
$method||="edgr";
$rep||="yes";
mkdir $fout if (!-d $fout);
mkdir $wsh if (!-d $wsh);
$fout=ABSOLUTE_DIR($fout);
$wsh=ABSOLUTE_DIR($wsh);
my $difc ="$fout/05.diffexp_circ";
mkdir $difc  if (!-d $difc);
open Out,">$wsh/05.circ_diffexp.sh";
if ($method eq "edgr") {
	my $tool="/mnt/ilustre/users/bingxu.liu/workspace/RNA_Pipeline/RNAseq_ToolBox_v1410";
	print Out "cp $fout/04.count/{cirRNA.srpnm.xls,new.circRNA.count.xls} $difc && cd $difc && $tool edgeR -groupfile $fout/group.list -count new.circRNA.count.xls -fpkm cirRNA.srpnm.xls \n";
	close Out;
}elsif ($method eq "DESeq" && $rep eq "no") {
	my $Degseq="/mnt/ilustre/users//yuntao.guo/research/dif_exp/DESeq/run_DEGseq_DE.pl";
	print Out "cp $fout/04.count/{cirRNA.srpnm.xls,new.circRNA.count.xls} $difc && cd $difc && perl $Degseq -fpkm cirRNA.srpnm.xls -count new.circRNA.count.xls -qvalue $qvalue \n";
	close Out;
}elsif ($method eq "DESeq" && $rep eq "yes") {
	my $Degseq="/mnt/ilustre/users//yuntao.guo/research/dif_exp/DESeq/run_DEGseq_for_rep_DE.pl";
	print Out "cp $fout/04.count/{cirRNA.srpnm.xls,new.circRNA.count.xls} $difc && cd $difc && perl $Degseq -group $fout/group.list -tpm cirRNA.srpnm.xls -count new.circRNA.count.xls -qvalue $qvalue \n";
	close Out;
}

#my $job="qsub-slurm.pl  --Queue $queue --Resource mem=10G --CPU 4 $wsh/05.circ_diffexp.sh";
#`$job`;

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
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"rep:s"=>\$rep,
	"method:s"=>\$method, 
	"qvalue:s"=>\$qvalue,
	"queue:s"=>\$queue,
	-h         Help

USAGE
        print $usage;
        exit;
}
