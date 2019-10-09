#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;

my $format = 'fasta';
my $N = 'N';
my $questionm;


GetOptions( "format=s" => \$format, 'questionm' => \$questionm );

my $usage = <<EOM;
Usage: $0 <infile> <outfile>
Transform any ambiguity code into N
Options:
	-format <>, default [$format]
	-questionm, uses ? instead of N
EOM

if($#ARGV<1) {
	print $usage;
	exit;
}

$N = '?' if $questionm;

my $seqin = Bio::SeqIO->new( -file => $ARGV[0], -format => $format );
my $seqout = Bio::SeqIO->new( -file => ">$ARGV[1]", -format => $format );

while (my $seq = $seqin->next_seq ) {
	my $str = $seq->seq;
	$str =~ s/[BD-FH-SU-Z\?]/$N/gi;
	$seq->seq($str);
	$seqout->write_seq($seq);
}

