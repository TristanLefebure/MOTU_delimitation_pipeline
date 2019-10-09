#! /usr/bin/perl -w

#Tristan Lefebure, 2008-04-30 

use warnings;
use strict;
use Bio::SeqIO;

if($#ARGV<2) {
	print "Usage $0 <input> <format> <output>\n";
	exit
}

my $in  = Bio::SeqIO->new(-file => "<$ARGV[0]", -format => $ARGV[1]);
open OUT, ">$ARGV[2]";

while ( my $seq = $in->next_seq() ) {
# 	foreach my $seq ( $aln->each_seq() ) {
		my $id = $seq->id();
# 		my $common_name = seq->species;
		print OUT "$id\n";
# 	}
}
