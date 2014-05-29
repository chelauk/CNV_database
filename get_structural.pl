use strict;
use warnings;
use List::Util qw( min max );
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $host= 'ensembldb.ensembl.org';
my $user= 'anonymous';

$registry->load_registry_from_db(
  -host => $host,
  -user => $user
);


my $outname = $ARGV[1];
open(my $fh, "<:encoding(UTF-8)", "$ARGV[0]")|| die "can't open $ARGV[0]"; 
open(my $outfh, ">>:encoding(UTF-8)", "$outname") || die "can't open for output";

# Slice adaptor
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );



while (<$fh>){
chomp;
if($_ =~ /^"/){print $outfh $_,",","DGVa_start",",","DGVa_end",",","length",",","DGVa\n",'<br />'}
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
# create arrays to contain your starts and ends

my @starts_and_ends;

# StructuralVariationFeature objects
foreach my $svf (@$svfs) {
	my $svf_start = $svf->seq_region_start;
	my $svf_end = $svf->seq_region_end;

# if the structural variant has a start equal or before our start and and end equal or after our end:
	if(($svf_start<=$start)&&($svf_end>=$end)){
# stick the start and end values in to an array
	push(@starts_and_ends,$svf_start);
	push(@starts_and_ends,$svf_end);
	}


}
# now we should have an array of pairs of length values
# how to keep the smallest pair
while (scalar @starts_and_ends > 2){
#print scalar @starts_and_ends,"\n";
if (($starts_and_ends[1]-$starts_and_ends[0])>$starts_and_ends[3]-$starts_and_ends[2]){
splice @starts_and_ends, 0, 2;
}
else{
splice @starts_and_ends, 2, 2;
}
}

foreach my $svf (@$svfs) {
if (($starts_and_ends[0] == $svf->seq_region_start) && ($starts_and_ends[1] == $svf->seq_region_end)){
	my $var_name = $svf->variation_name;
	my $start = $svf->seq_region_start;
	my $end = $svf->seq_region_end;
	my $length = $svf->length;
	print $outfh	$_,",",$start,",",$end,",",$length,",",'<a href="http://www.ncbi.nlm.nih.gov/dbvar/?term=',$var_name,'">',$var_name,'</a><br />',"\n";
			}
}

}
}
