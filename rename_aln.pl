#!/usr/bin/perl

#Tristan Lefebure,  2008-05-07, Licenced under the GPL

use strict;
use warnings;
use Bio::AlignIO;
use Getopt::Long;

my $list;
my $ext = 'recod';
my $complement;
my $format = 'phylip';
my $nodesc;

GetOptions("list" => \$list,
	  "ext:s" => \$ext,
	  "complement" => \$complement,
	  "format:s" => \$format,
	  "nodesc" => \$nodesc );


if($#ARGV<1) {
	print "Usage: $0 <aln> <translation table>

Will replace a name in an alignment by another name following
a translation table. The translation table should have 
the following format:
old_name	new_name

	Options:
	\t-list, the first input file is a list of files to process
	\t-ext <>, define the extension added to the output, default is recod
	\t-complement, will allow [-_\\d+c] at the end of the taxa names (convenient if with locus ids)
	\t-format <>, gives the input and output format, default is phylip\n";
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

#hash the translation
my %old2new;
open TAB, $ARGV[1];
while (<TAB>) {
	chomp;
	my @col = split /\t/;
	print "Warning: ambiguous renaming of $col[0] (to $col[1] or $old2new{$col[0]})\n" if(exists $old2new{$col[0]} && $old2new{$col[0]} ne $col[1]);
	$old2new{$col[0]} = $col[1];
}


###open the alignment(s)

foreach (@files) {
  chomp;
  my $in  = Bio::AlignIO->new(-file => $_, -format => $format);
  my $out = Bio::AlignIO->new(-file => ">$_.$ext", -format => $format);
  my $aln_in = $in->next_aln();
  my $aln_out = Bio::SimpleAlign->new();

  foreach my $seq ( $aln_in->each_seq() ) {
    #change the names
    my $name = $seq->id;
#       print "$name ", $seq->desc, "\n";
    $seq->desc('') if($nodesc);
    if($complement) {
	my $found = 0;
	foreach my $tax (sort keys %old2new) {
	    if ($name =~ /^$tax[\d_c-]*([\s\t]+.*)*/) {
    # 	  print "$tax => $old2new{$tax}\n";
		$seq->id($old2new{$tax});
		$aln_out->add_seq($seq);
		++$found;
		last;
	    }
	}
	if($found == 0) { $aln_out->add_seq($seq) }
    }
    else {
	if (exists $old2new{$name}) {
	    $seq->id($old2new{$name});
	    $aln_out->add_seq($seq);
	}
	else { $aln_out->add_seq($seq) }
      }
  }
  $aln_out->set_displayname_flat();
  $out->write_aln($aln_out);
}
