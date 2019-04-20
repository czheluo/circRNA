#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$ref,$aln,$queue);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"out:s"=>\$fout,
	"aln:s"=>\$aln,
	"queue:s"=>\$queue,
			) or &USAGE;
&USAGE unless ($fout);
$out=ABSOLUTE_DIR("$fout/04.count");
mkdir $out if (!-d $out);
$fin =ABSOLUTE_DIR("$fout/03.step3/step3.list");
$ref=ABSOLUTE_DIR($ref);
$step||=1;
$stop||=-1;
$queue||="DNA";
if ($step == 1) {
	open In,$fin;
	open SH,">$wsh/04.count.sh";
	print SH "cd $out && perl $Bin/bin/CIRI.count.pl ";
	while (<In>) {
		chomp;
		my ($id,$cri)=split/\s+/,$_;
		print SH "$cri ";
	}
	print SH " && awk '{if(NR==1){print "CIRI_ID\t"$0}else{print "CIRI_circ_"(NR-1)"\t"$0}}'  circRNA.count.xls | cut -f 1,3- | sed 's/_count//g' > new.circRNA.count.xls ";
	print SH " && cut -f1 new.circRNA.count.xls |awk -F'\t' -vOFS='\t' '{if(NR==1){print $0"\tCIRC_ID"}else{print $1,"CIRI_circ_"NR-1}}' >old2newID.xls"
	close In;
	close SH;
	my $job="qsub-slurm.pl  --Queue $queue --Resource mem=30G --CPU 3 $wsh/step3.sh";
	`$job`;
	$step++ if ($step ne $stop);
}
if ($step == 2) {
	open In,$fin;
	open SH,">$wsh/sampleid.sh";
	while (In) {
		chomp;
		my ($id,$cri)=split/\s+/,$_,2;
		print SH "mkdir -p $out/$id && cd $out/$id && perl $Bin/bin/tabletools_add.pl  $out/old2newID.xls -t $cri -n 1 |awk -F'\t' -vOFS='\t' '{print $13,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' >$out/$id.sample.ciri.xls \n";
	}
	close In;
	my $job="qsub-slurm.pl  --Queue $queue --Resource mem=10G $wsh/sampleid.sh";
	`$job`;
	$step++ if ($step ne $stop);
}
if ($step == 3) {
	open In,$aln;
	my %alns;
	while (<In>) {
		chomp;
		my ($id,$mapped,undef)=split/\s+/,$_;
		my ($md,undef)=split/\//,$mapped;
		$alns{$id}=$md;
	}
	close In;
	open IN,"<$out/new.circRNA.count.xls"£»
	open OUT,">$out/cirRNA.srpnm.xls";
	while (<IN>) {
		chomp;
		my @al;
		if ($_ =~ /circRNA_ID/) {
			print OUT "$_\n";
			my ($name,@ids)=split/\s+/,$_,2;
			for (my $i =0;$i <scalar @ids ;$++) {
				$al[i]=$alns{$ids[i]};
			}
		}else{
			my @nids;
			my  ($name,@ids)=split/\s+/,$_,2;
			for (my $i =0;$i <scalar @ids ;$++) {
				$al[i]=$ids[i]*1000000000/$alns{$ids[i]};
				push @nids,join("\t",$l[i])
			}
			print OUT join("\t",$name,split("\t",@nnids)),"\n";
		}
	}
	close IN;
	close OUT;
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
	-int input file name
	-ref inout ref filename
	-out ouput file name 
	-gtf input output file
	-bam bam file dir
	-h         Help

USAGE
        print $usage;
        exit;
}
