#!/usr/bin/perl

#Tristan Lefebure, Oct6 2010, Licenced under the GPL

use warnings;
use strict;
use Bio::AlignIO;
use Bio::SeqIO;
use Getopt::Long;

my $list;
# my $ext = '.fasta';
my $informat = 'fasta';
my $outformat = 'phylip';
my $sequencial;

my $mb;

GetOptions (	'l' => \$list,
# 		'ext=s' => \$ext,
		'informat=s' => \$informat,
		'outformat=s' => \$outformat,
		'mb' => \$mb,
		'sequencial' => \$sequencial,
	);


if($#ARGV<0) {
	print "Usage $0 <file to convert>
Options:
\t-l, the file is a list of file to be processed [False]
\t-informat xxx, gives the format of the alignment [fasta]
\t-outformat xxx, gives the format of the alignment [phylip]
\t-mb, removes the show_symbols in the nexus format for MrBayes [False]
\t-sequencial, use the sequencial phylip format instead of the interleaved one\n";
	exit;
}


###file or list of files
my @files;
if($list) {
	open IN, $ARGV[0];
	@files = <IN>;}
else {
	$files[0] = $ARGV[0];
}

###open the alignment(s) print the fasta files

my $symbols = 1;
if($mb) { $symbols = 0 }

foreach (@files) {
	chomp;
	my $in  = Bio::AlignIO->new(-file => $_, -format => $informat);
	my $out;
	if($sequencial) {
	   $out = Bio::AlignIO->new(
		-file => ">$_.$outformat",
		-format => $outformat,
		-show_symbols => $symbols,
		-interleaved => 0,
		-idlength => 20 );
	}
	else {
	    $out = Bio::AlignIO->new(
		-file => ">$_.$outformat",
		-format => $outformat,
		-show_symbols => $symbols,
		-longid => 'true' );
	}

	while ( my $aln = $in->next_aln() ) {
		#foreach seq in the aln, write it in the output
# 		foreach my $seq ( $aln->each_seq() ) {
# 			$out->write_seq($seq);
# 		}
	   $aln->set_displayname_flat();
	   $out->write_aln($aln);
	}
}




