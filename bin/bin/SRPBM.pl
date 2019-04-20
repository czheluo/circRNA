#!/usr/bin/perl -w
use strict;
@ARGV==4 || die "
	# Usage:   perl $0 [trimPairFq.list] [map_stat.xls] [sample_name] [sample_CIRI_result]
	# contact: yuntao.guo\@majorbio.com
	# updata:  2017-4-29

";

#read clean fq list
my %clean_fq;
open LIST,"<$ARGV[0]";
map{
	chomp;
	my @line=split /\t/;
	$clean_fq{$line[0]}{"R1"}=$line[2];
	$clean_fq{$line[0]}{"R2"}=$line[3];
}<LIST>;
close LIST;

#read map_stat.xls
my %map;
open MAP,"<$ARGV[1]";
<MAP>;
map{
        chomp;
        my @line=split /\t/;
        $map{$line[0]}=$line[2];
}<MAP>;
close MAP;
my $library_size=$map{$ARGV[2]};

#stat length
my $fq_R1=$clean_fq{$ARGV[2]}{"R1"};
my $fq_R2=$clean_fq{$ARGV[2]}{"R2"};
my %len;
my $id;

open FQ1,"<$fq_R1" || die "can't open $fq_R1\n";
while (<FQ1>){
	chomp;
	if ($.%4 ==1){
		$_=~/@(\S+)/;
		$id=$1;
	}elsif ($.%4 ==2){
		$len{$id}{"R1"}=length ($_);
	}
}
close FQ1;

open FQ2,"<$fq_R2" || die "can't open $fq_R2\n";
while (<FQ2>){
        chomp;
        if ($.%4 ==1){
                $_=~/@(\S+)/;
                $id=$1;
        }elsif ($.%4 ==2){
                $len{$id}{"R2"}=length ($_);
        }
}
close FQ2;

#stat SRPBM
open CIRI,"<$ARGV[3]";
open COUNT,">$ARGV[2].count.xls";
open SRPBM,">$ARGV[2].srpbm.xls";
print COUNT "CircRNA_ID\tCounts\n";
print SRPBM "CircRNA_ID\tSrpbm\n";
<CIRI>;
while (<CIRI>){
	chomp;
	my @line=split /\t/;
	my @reads=split /,/,$line[-1];
#	pop @reads;
	print COUNT "$line[0]\t".(2*scalar (@reads))."\n";
	print SRPBM "$line[0]\t".stat_srpbm(\@reads,\%len)."\n";
}
close CIRI;
close COUNT;
close SRPBM;

sub stat_srpbm {
	my $re=shift;
	my $le=shift;
	my $sum_srpbm=0;
	foreach my $r(@{$re}){
		my $len_R1=$le->{$r}->{"R1"};
		my $len_R2=$le->{$r}->{"R2"};
		$sum_srpbm+=1000000000/($library_size*$len_R1);
		$sum_srpbm+=1000000000/($library_size*$len_R2);
	}
	return $sum_srpbm;
}
