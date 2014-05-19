#!/usr/bin/perl

use strict;
my $label;
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';

my $outname="$ARGV[0]".".ann";
open(my $fh, "<:encoding(UTF-8)", "$ARGV[0]")|| die "can't open $ARGV[0]"; 
open(my $outfh, ">>:encoding(UTF-8)", "$outname") || die "can't open for output";

## Load the databases into the registry
$registry->load_registry_from_db( -host => 'ensembldb.ensembl.org', -user => 'anonymous' );

## Get the slice adaptor for human
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );

while (<$fh>){
chomp;
if($_ =~ /^"/){print $outfh $_,",EnsemblID,gene\n"}
else{
my @line=split(/\,/, $_);
my $start=$line[4];
my $end=$line[5];
my $chr=$line[6];
$chr=~s/"//g;

## Get the slice for your region of interest

my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $start, $end );

## Get all genes overlapping the slice
my $genes = $slice->get_all_Genes;

## Print info about the genes
while( my $gene = shift @$genes){
## use commas as array separator
$"=",";
  print $outfh
    "@line","\,",
    $gene->stable_id, "\,",
    $gene->external_name,",",
    $gene->biotype,"\n"
}
}
}
