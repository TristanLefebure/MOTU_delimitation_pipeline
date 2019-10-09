#! /usr/bin/perl

#3Fev2010
#Tristan Lefebure

#this script abbreviate seq name following the e3s format so that they fit into
# 9 letter codes. 4 letters for the species names are used, 3 for the station, the remaining
# are digits that are incremented
# if 2 species have the same abbreviation, the 4th letters is skipped to the 5th, 3th, ...,
# until the name is unambiguous
# the same is done for the station (weel the species-station)


use strict;
use warnings;

if($#ARGV<1) {
    print "Usage: $0 <list of ids> <output table>\n";
    exit;
}


open IN, $ARGV[0];
my @ids = <IN>;
chomp @ids;

open OUT, ">$ARGV[1]";
my %name;
my %spAbbrev;
my %staAbbrev;
my %spSta;


foreach my $i (@ids){
	chomp $i;
	my $shortName;
	if($i eq 'Ref') { $shortName = $i }
	else {
		my $seqinfo = parse_formatv3($i);
		my $ind = $seqinfo->{ind};
		my $station = $seqinfo->{loc};
		my $date = $seqinfo->{date};
		my $sp = $seqinfo->{head};

		#remove the working tag
		$sp =~ s/^W_//i;

		#remove []
		$sp =~ s/\[//g;
		$sp =~ s/\]//g;

		#if several capital letter in the species name, only keep the first and last one
		$sp =~ s/^([A-Z])[A-Z]*([A-Z])/$1$2/;


		#take the first letters that will be used, but 1
		my $spShort = substr $sp, 0, 3;
		my $staShort =  substr $station, 0, 2;
		
		my $nInd = 1;
# 		my $nSp = '';
# # 		my $nSt = '';


		#find the species abbreviated name
		my $nsp4 = 4;
		my $sp4Letter = substr $sp, $nsp4 -1, 1;
		my $maxnsp = length($sp);

# 		print "$sp : $nsp4 : $spShort $sp4Letter\n";
		while(exists $spAbbrev{$spShort.$sp4Letter} && $spAbbrev{$spShort.$sp4Letter} ne $sp && $nsp4 <= $maxnsp) {
			++$nsp4;
			$sp4Letter = substr $sp, $nsp4 -1, 1;
# 			print "   iterating $spShort $sp4Letter\n";
		}
		my $spShortFinal = $spShort.$sp4Letter;
		$spAbbrev{$spShortFinal} = $sp;


		#find the station abbreviated name
		my $nsta3 = 3;
		my $sta3Letter = substr $station, $nsta3 -1, 1;
		my $maxsta = length($station);

		while(exists $staAbbrev{$spShortFinal.$staShort.$sta3Letter} && $staAbbrev{$spShortFinal.$staShort.$sta3Letter} ne $sp.$station && $nsta3 <= $maxsta) {
			++$nsta3;
			$sta3Letter = substr $station, $nsta3 -1, 1;
# 			print "$sp $station  iterating $staShort $sta3Letter\n";
		}
		my $staShortFinal = $staShort.$sta3Letter;
		$staAbbrev{$spShortFinal.$staShortFinal} = $sp.$station;


		my $spstation = $sp.$station;
		if(exists $spSta{$spShortFinal.$staShortFinal} && $spSta{$spShortFinal.$staShortFinal} ne $spstation) {
			print "The following start of abbreviated names for species and station are identical:
	$spSta{$spShortFinal.$staShortFinal}
	$spstation\n";
		}
		else {
			$spSta{$spShortFinal.$staShortFinal} = $spstation;
		}

		while(exists $name{$spShortFinal.$staShortFinal.$nInd}) { ++$nInd };
		$shortName = $spShortFinal.$staShortFinal.$nInd;
	}

	$name{$shortName} = 1;
# 	print "$i --> $shortName\n";
	print OUT "$i\t$shortName\n";

	if(length($shortName) > 10) {
		print "Problem: $shortName is too long!\n"
	}
}



sub parse_formatv3 {
    my ($name) = @_;
    $name =~ /^(.+)\|(\w+)_(\d+)_(\w+)_(\w+)\|(.*)$/;
    my $head = $1;
    my $loc = $2;
    my $date = $3;
    my $ind = $4;
    my $first_yas = $5;
    my $tail = $6;
    my @yas;
    @yas = search_yas_in_tail($tail) unless (!defined $tail);
    push @yas, $first_yas;
    my $hash;
    $hash = {
	head => $head,
	loc => $loc,
	date => $date,
	ind => $ind,
	tail => $tail,
	original => $name,
	format => 'v3',
	firstyas => $first_yas,
	yas => \@yas,
    };
    return $hash;
}


sub search_yas_in_tail {
    my ($tail) = @_;
    my @yas;
    while($tail =~  /([YC][A-Z]{2}\d+)_/g) {
	push @yas, $1;
    }
    return(@yas);
}

