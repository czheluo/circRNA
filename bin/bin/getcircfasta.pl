#!/usr/bin/perl
use warnings;
use strict;

die "Usage:perl $0 [ref_genome.fa] [ref_genome.gtf] [exon|CDS] [CIRI_combine] [out_CIRI.fasta]
##CIRI_combine example:circ_id circRNA_ID chr circRNA_start circRNA_end circRNA_type strand
" unless (@ARGV==5);

my %hash_fa;
my %hash_gtf;
my (@line_fa,$chr,$seq,@line_gtf,$chr_str,$exon_pos);

local $/=">";
open(FASTA,"<$ARGV[0]")or die $!;
<FASTA>;
while(<FASTA>){
	chomp;
	@line_fa=split /\n/;
	my $one=shift @line_fa;
	$chr=(split /\s/,$one)[0];
	$seq=join("",@line_fa);
	$hash_fa{$chr}=$seq;
}
close FASTA;

local $/="\n";
open(GTF,"<$ARGV[1]")or die $!;
if($ARGV[2] eq "exon"){
	while(<GTF>){
		chomp;
		@line_gtf=split /\t/;
		next if($line_gtf[2]!~/exon/);
		$chr_str=join("",$line_gtf[0],$line_gtf[6]);
		$exon_pos=join("_",$line_gtf[3],$line_gtf[4]);
		if(exists $hash_gtf{$chr_str}){
			$hash_gtf{$chr_str}.=",".$exon_pos;
		}else{
			$hash_gtf{$chr_str}=$exon_pos;
		}
	}
}elsif($ARGV[2] eq "CDS"){
        while(<GTF>){
                chomp;
                @line_gtf=split /\t/;
                next if($line_gtf[2]!~/CDS/);
                $chr_str=join("",$line_gtf[0],$line_gtf[6]);
                $exon_pos=join("_",$line_gtf[3],$line_gtf[4]);
                if(exists $hash_gtf{$chr_str}){
                        $hash_gtf{$chr_str}.=",".$exon_pos;
                }else{
                        $hash_gtf{$chr_str}=$exon_pos;
                }
        }
}else{
	die "please choose CDS or exon or modified the gtf file to adapt this script\n";
}
close GTF;


open(CIRI,"<$ARGV[3]")or die $!;
open(OUT,">$ARGV[4]")or die;
<CIRI>;
while(<CIRI>){
	chomp;
	my @info=split /\t/;
	my $circ=$info[0];
	my $chr_tar=$info[2];
	my $strand=$info[6];
	my $start=$info[3];
	my $end=$info[4];
	my $type=$info[5];
	my %hash_exon=();
	if($type eq "exon"){
		my $chrstr_tar=join("",$chr_tar,$strand);
		if(exists $hash_gtf{$chrstr_tar}){
			my @position=split /,/,$hash_gtf{$chrstr_tar};
			foreach my $p(@position){
				my @pos=split /\_/,$p;
				my $s=$pos[0];
				my $e=$pos[1];
				next if ($start>$e || $end<$s);
				if($start>$s){$s=$start}elsif($end<$e){$e=$end}
				$hash_exon{$s}=substr($hash_fa{$chr_tar},$s-1,$e-$s+1);
			}
		}
		print OUT ">$circ\n";
		if($strand eq "+"){
			foreach my $key (sort {$a<=>$b} keys %hash_exon){
				print OUT "$hash_exon{$key}";
			}
			print OUT "\n";
		}else{
			foreach my $key (sort {$b<=>$a} keys %hash_exon){
				my $seq_rev=reverse $hash_exon{$key};
				$seq_rev=~tr/ATCG/TAGC/;
				print OUT "$seq_rev";
			}
			print OUT "\n";
		}
	}else{
		my $seq_tar=substr($hash_fa{$chr_tar},$start-1,$end-$start+1);
		if($strand eq "+"){
			print OUT ">$circ\n$seq_tar\n";
		}else{
			my $seq_rev=reverse $seq_tar;
			$seq_rev=~tr/ATCG/TAGC/;
			print OUT ">$circ\n$seq_rev\n";
		}
	}
}
close CIRI;
close OUT;
