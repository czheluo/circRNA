#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($ref,$aln,$out,$wsh,$stop,$step,$queue,$fq,$wsh,$gff);
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$ref,
	"gff:s"=>\$gff,
	"out:s"=>\$out,
	"aln:s"=>\$aln,
	"queue:s"=>\$queue,
	"fqlist:s"=>\$fq,
	"wsh:s"=>\$wsh,
	"step:s"=>\$step,
	"stop:s"=>\$stop,
			) or &USAGE;
&USAGE unless ($ref and $out);
########################################################
mkdir $out if (!-d $out);
$out=ABSOLUTE_DIR($out);
$wsh=ABSOLUTE_DIR("$out/work_sh");
mkdir $wsh if (!-d $wsh);
$ref=ABSOLUTE_DIR($ref);
$gff=ABSOLUTE_DIR($gff);
$step||=1;
$stop||=-1;
$queue||="DNA";
if ($step == 1) {
	print Log "########################################\n";
	print Log "hisat-mapping\n"; 
	my $time = time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/hisat.pl -fqlist $fq -ref $ref  -out $out/01.hisat-mapping -wsh $wsh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 2) {
	print Log "########################################\n";
	print Log "step2\n";
	my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step2.pl  -out $out -ref $ref -fq $fq -wsh $wsh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}

if ($step == 3) {
	print Log "########################################\n";
	print Log "step3\n";
	my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step3.pl -ref $ref -out $out -wsh $wsh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 4) {
	print Log "########################################\n";
	print Log "express\n";
	my $time=time();
	print Log "########################################\n";
	#my $fa=ABSOLUTE_DIR("$out/03.split/fasta.list");
	my $job="perl $Bin/bin/count.pl -out $out -aln $aln -wsh $wsh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 5) {
	print Log "########################################\n";
	print Log "diffexp circRNA\n";
	my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/diffexp_circ.pl -out $out  -wsh $wsh -queue $queue";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}

if ($step == 6) {
	print Log "########################################\n";
	print Log "cluster circRNA\n";
	my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/cluster_circ.pl -out $out  -wsh $wsh -queue $queue";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 7) {
	print Log "########################################\n";
	print Log "enrich circRNA\n";
	my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/enrich_circRNA.pl -out $out -ref $ref -wsh $wsh -queue $queue";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}

#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=ABSOLUTE_DIR($pavfile);
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
		warn "Warning! just for existing file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:		$Script
Version:	$version
Description:	
Usage:
 -ref		<file>	input ref dir
 -group <file> input group.list file 
	-gff  <file> the original gff file download from the website 
  -aln		<file>	hisat mapping stats result file ("aln_stats.txt")
  -out		<dir>	output dir
  -fqlist	<file>	afther qc list file 
  -queue	<str>   the current nodes (default "DNA")
  -wsh		<str>  the work shell dir (default "work_sh")
  -step		<num>	pipeline control, 1-13
  -stop		<num>	pipeline control, 1-13
  -h		Help
USAGE
        print $usage;
        exit;
}
