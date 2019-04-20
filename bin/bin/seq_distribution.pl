#! /usr/bin/perl -w
use strict;
use Getopt::Long;
my %opts;
my $VERSION="1.0";
GetOptions( \%opts,"i=s","t=s","o=s","b=s","s=s","e=s","h!");
my $usage = <<"USAGE";
       Descript: Used for seq length stat and plot
       Version : $VERSION
       Contact : yuntao.guo\@majorbio.com
       Modify  : 2017-5-26
       Usage   : $0 [options]
       Options :
                -i*            file            input sequence
                -t*            file            type: fa/fq/list is support
                -o             string          outprefix, default: length
                -b             num             step to draw, default : 500
		-s             num             start point to draw, default : 1
		-e	       num	       end point to draw, default : longest seq lenth
                -h                             display this usage information
     
       "*" --> must be given Argument      
####fa
>id1
ATCGATGCATGCATCGATGCATGCATCGATGCATGC
......
###fq
\@header
ATCGATGCATGCATCGATGCATGCATCGATGCATGC
+
FKFFFFFFFFFFFFFFFFFFFFFFKKKKKKKKKKKK
......
###list (one seq per line)
ATCGATGCATGCATCGATGCATGCATCGATGCATGC
ATCGATGCATGCATCGATGCATGCATCGATGCATGC
......
USAGE

die $usage if ( !( $opts{i} && $opts{t} ) || $opts{h} );
die "File format -t $opts{t} are not support, please choose fa/fq/list" if (($opts{t} ne 'fa') && ($opts{t} ne 'fq') && ($opts{t} ne 'list'));
$opts{o}=$opts{o}? $opts{o} : "length";
$opts{b}=$opts{b}? $opts{b} : 500;
$opts{s}=$opts{s}? $opts{s} : 1;

#main
my %len_seq;
if ($opts{t} eq 'fa'){
	%len_seq = %{read_fa ($opts{i})};
}elsif ($opts{t} eq 'fq'){
	%len_seq = %{reaf_fq ($opts{i})};
}elsif ($opts{t} eq 'list'){
	%len_seq = %{reaf_list ($opts{i})};
}

my $max = (sort {$b <=> $a} (keys %len_seq))[0];
$max = $opts{e}? $opts{e} : $max;
my %parsed_length = %{parse_step (\%len_seq, $opts{s}, $max, $opts{b})};
barplot (\%parsed_length, $opts{o});

#sub
sub read_fa{
	my $file=shift;
	my %len;
	my $seq = '';
	open FA,"<$file" || die "can't open file $file\n";
	while (<FA>){
		chomp;
		if (/^>/){
			if ($seq ne ''){
				$len{length($seq)}+=1;
			}
			$seq='';
		}else{
			$seq.=$_;
		}
	}
	$len{length($seq)}+=1;
	close FA;
	return (\%len);
}

sub read_fq {
	my $file=shift;
	my $c=0;
	my %len;
	open FQ,"<$file" || die "can't open file $file\n";
	while (<FQ>){
		$c++;
		if ($c==2){
			chomp;
			$len{length($_)}+=1;
		}elsif ($c==4){
			$c=0;
		}
	}
	close FQ;
	return (\%len);
}

sub read_list {
	my $file=shift;
	my %len;
	open L,"<$file" || die "can't open file $opts{i}\n";
	map {
		chomp;
		$len{length($_)}+=1;
	}<L>;
	close L;
	return (\%len);
}

sub parse_step {
	my $h=shift;
	my %len=%{$h};
	my $start=shift;
	my $end=shift;
	my $step=shift;
	my %sum;
	my %parsed_len;
	my $i;
	for ($i=$start;$i<=$end;$i+=$step){
		for my $l(keys %len){
			if ($l >= $i and $l <($i+$step)){
				$sum{$i}+=$len{$l};
			}
		}
	}
	for my $l(keys %len){
                        if ($l >= $i ){
                                $sum{$i}+=$len{$l};
                        }
         }
	my $c=0;
	my $tmp;
	for my $m (sort {$a<=>$b} keys %sum){
		$c++;
		$parsed_len{$c} = "$m~".($m+$step-1)."\t$sum{$m}";
		$tmp = "\t$sum{$m}";
	}
	$parsed_len{$c} = "$i~$tmp";
	return (\%parsed_len);
}

sub barplot {
	my $h=shift;
	my %len=%{$h};
	my $outprefix=shift;
	open XLS, ">$outprefix.xls";
	print XLS "Length\tNumber\n";
	for my $key (sort {$a <=> $b} keys %len){
		print XLS $len{$key}."\n";
	}
	close XLS;
	open RL,">cmd.r";
	print RL "
library(ggplot2)
a<-read.table(\"$outprefix.xls\",header=T)
a\$Length<-factor(a\$Length,levels=a\$Length)
add<-max(a\$Number)/100
theme_set(theme_bw())
pdf(\"$outprefix.pdf\",width=16,height=9)
par(mar=c(3,2,2,1))
ggplot(data=a,aes(x=Length,y=Number,fill=Number))+theme(axis.text.x=element_text(size=8,angle=45,hjust=1),plot.title = element_text(hjust=0.5))+ ggtitle(\"Length distribution\")+annotate(\"text\",x=a\$Length,y= a\$Number+add,parse=T,label=a\$Number,size=3) +geom_bar(stat=\"identity\")
dev.off()
";
	close RL;
	system ("Rscript cmd.r");
}
