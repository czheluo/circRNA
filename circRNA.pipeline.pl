#!/usr/bin/env perl
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
my ($ref,$gff,$fqlist,$method,$outdir,$dsh,$queue,$step,$stop,$qvalue,$compare,$species,$group);
GetOptions(
	"help|?" =>\&USAGE,
	"ref:s"=>\$ref,
	"gff:s"=>\$gff,
	"fqlist:s"=>\$fqlist,
	"method:s"=>\$method,
	"compare:s"=>\$compare,
	"group:s"=>\$group,
	"outdir:s"=>\$outdir,
	"dsh:s"=>\$dsh,
	"queue:s"=>\$queue,
	"qvalue"=>\$qvalue,
	"step:s"=>\$step,
	"stop:s"=>\$stop
	"species:s">\$species,
			) or &USAGE;
&USAGE unless ($ref and $gff and $fqlist and $method and $compare and $group and $species);
##############################################################
mkdir $outdir if (!-d $outdir);
$outdir=ABSOLUTE_DIR($outdir);
mkdir "$outdir/work_sh" if (!-d "$outdir/work_sh");
$ref=ABSOLUTE_DIR($ref);
$gff=ABSOLUTE_DIR($gff);
$group=ABSOLUTE_DIR($group);
$compare=ABSOLUTE_DIR($compare);
$fqlist=ABSOLUTE_DIR($fqlist);
$method||="all";
$queue||="DNA";
$qvalue||=0.05;
$step||=1;
$stop||=-1;
open Log,">$outdir/work_sh/circle.$BEGIN_TIME.log";
if ($step == 1){
	print Log "########################################\n";
	print Log "fastq qc\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step01.fastq-qc.pl -fqlist $fqlist -outdir $outdir/01.fastq-qc -dsh $outdir/work_sh -queue $queue";
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
	print Log "ref index\n"; my $time=time();
	print Log "########################################\n";
	my $job = "perl $Bin/bin/step02.reference.pl -ref $ref -gff $gff -out $outdir/02.reference -method $method -queue $queue -dsh $outdir/work_sh\n";
	print Log "$job\n";
	`$job`;
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 3) {
	print Log "########################################\n";
	print Log "align\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step03.align.pl -fqlist $outdir/01.fastq-qc/fastq.list -ref $ref -gtf $gff -method $method -outdir $outdir/03.align -queue $queue -dsh $outdir/work_sh";
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
	print Log "circle RNA\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step04.circleRNA.pl -queue $queue -fqlist $fqlist -ref $ref -gff $gff -method $method -alignfile $outdir/03.align/bam.list -outdir $outdir/04.circleRNA -queue $queue -dsh $outdir/work_sh";
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
	print Log "circle RNA express\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step05.express.pl -bedfile $outdir/04.circleRNA/predict_output.list -outdir $outdir/05.express -queue $queue -dsh $outdir/work_sh";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}	
if ($step == 6) {
	print Log "########################################\n";
	print Log "circle RNA diffexpress\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step06.diffexpress.pl -express $outdir/05.express/express_countList -compare $compare -grouplist $group -out $outdir/06.diffexpress -dsh $outdir/work_sh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 7) {
	print Log "########################################\n";
	print Log "circle RNA AS\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step07.AS.pl -bedfile $outdir/04.circleRNA/predict_output.list -ref $ref -gff $gff -outdir $outdir/07.AS -dsh $outdir/work_sh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 8) {
	print Log "########################################\n";
	print Log "circle RNA diff\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step08.diffexpress.pl -out $outdir/08.diffexp_circ -dsh $outdir/work_sh -queue $queue -qvalue $qvalue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}

if ($step == 9) {
	print Log "########################################\n";
	print Log "circle RNA cluster\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step09.cluster.pl -out $outdir/09.cluster_circ -dsh $outdir/work_sh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}

if ($step == 10) {
	print Log "########################################\n";
	print Log "host gene\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step09.cluster.pl -out $outdir -dsh $outdir/work_sh -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}

if ($step == 11) {
	print Log "########################################\n";
	print Log "enrich\n"; my $time=time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/step11.enrich.pl -out $outdir -dsh $outdir/work_sh -species $species -queue $queue";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
close Log;
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
Contact:        meng.luo\@majorbio.com
Script:		$Script

Description:	
Usage:

	-ref	<file>	input ref files
	-gff	<file>	input gff files
	-fqlist	<file>	fastq list file
	-method	<string> align method, bwa,STAR,bowtie and TopHat-Fusion, default "all"
			 ## bwa && CIRI2 |  bowtie && find_circ  | STAR && CIRCexplorer  | TopHat-Fusion && CIRCexplorer ##
	-compare different express compare group
	-group	sample group
	-outdir	<dir>	output dir
	-step	<num>	pipeline start control,default=1
	-stop	<num>	pipeline control,default=-1
	-dsh	<str>	process record file output pathway
	-queue	<word>	job partition
	-species <str> required  Animals \or Plants
	-h			Help

USAGE
        print $usage;
        exit;
}
