#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$ref,$wsh,$queue,$strand);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"out:s"=>\$fout,
	"wsh:s"=>\$wsh,
	"ref:s"=>\$ref,
	"queue:s"=>\$queue,
			) or &USAGE;
&USAGE unless ($fout);
my $merich =ABSOLUTE_DIR("$fout/07.enrich_mRNA");
mkdir $merich  if (!-d $merich);
mkdir $fout if (!-d $fout);
mkdir $wsh if (!-d $wsh);
$fout=ABSOLUTE_DIR($fout);
$wsh=ABSOLUTE_DIR($wsh);
$step||=1;
$stop||=-1;
$queue||="DNA";
if ($step == 1) {
	my $host=ABSOLUTE_DIR("$merich /host");
	mkdir $host  if (!-d $host);
	open SH,">$wsh/07.host.sh";
	open IN,"<$fout/03.step3/step3.list";
	print SH " cat ";
	while (<IN>) {
		chomp;
		my (undef,$circ)=split/\s+/,$_;
		print SH "$circ ";
	}
	print SH " >$host/circ.all.xls |cut -f 1,10|sort -u >$host/circ_host && ";
	print SH "perl $Bin/bin/tabletools_select.pl -i list -t $host/circ_host -n 1 > $host/circ_host.DE  && ";
	print SH "less $host/circ_host.DE |grep EN |sed 's/,/\n/g'|sort -u |sed 1d > $host/c && less $host/c |cut -f 2 |sort |uniq > $host/target.DE.list ";
	close In;
	close SH;
	my $job="qsub-slurm.pl  --Queue $queue --Resource  $wsh/07.host.sh";
	`$job`;
	$step++ if ($step ne $stop);
}
if ($step == 2) {
	my $enri=ABSOLUTE_DIR("$merich /enrich");
	mkdir $enri  if (!-d $enri);
	open out,">$wsh/07.enrich.sh";
	my $tool="/mnt/ilustre/users/bingxu.liu/workspace/RNA_Pipeline/RNAseq_ToolBox_v1410";
	print out "cd $enri  && $tool enrich $enri  $ref/unigene_GO.list $ref/unigene_pathway.txt out";
	close out;
	my $job="qsub-slurm.pl  --Queue $queue --Resource mem=10G --CPU 2 $wsh/07.enrich.sh";
	`$job`;
	$step++ if ($step ne $stop);
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
