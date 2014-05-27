use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $host= 'ensembldb.ensembl.org';
my $user= 'anonymous';

$registry->load_registry_from_db(
  -host => $host,
  -user => $user
);


open(my $fh, "<:encoding(UTF-8)", "$ARGV[0]")|| die "can't open $ARGV[0]"; 
#open(my $outfh, ">>:encoding(UTF-8)", "$outname") || die "can't open for output";

# Slice adaptor
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );



while (<$fh>){
chomp;
#if($_ =~ /^"/){print $outfh $_,",EnsemblID,gene\n"}
if($_ =~ /^"/){next}
else{
my @line=split(/\,/, $_);
my $start=$line[4];
my $end=$line[5];
my $chr=$line[6];
$chr=~s/"//g;

## Get the core slice for your region of interest

my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $start, $end );

# Fetch the variation feature objects on the Slice
my $svfs = $slice->get_all_StructuralVariationFeatures();

# StructuralVariationFeature objects
#foreach my $svf (@$svfs) {
#	if(($svf->seq_region_start<=$start)&&($svf->seq_region_end>=$end)){
#	print $svf->variation_name, " ", $svf->seq_region_name, ":", $svf->seq_region_start, "-", $svf->seq_region_end, " ", 
#		$svf->var_class, " (SO term: ", $svf->class_SO_term, ")\n";
#			}
#		}
foreach my $svf (@$svfs){
	foreach my $key (keys %$svf){
		print $key,"\n";
			}
		}
	}
}
