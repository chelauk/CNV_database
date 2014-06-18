use strict;
use warnings;
use List::Util qw( min max );
use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
my $host= 'ensembldb.ensembl.org';
my $user= 'anonymous';
my @line;
my $start;
my $end;
my $chr_start_end;
my $length;
my $chr;
my $bf;
my @gene_list;
# my $gene_type;
my @gene_type_list;
my @zipped;
my $slice;
my $genes;
my $gene_name;
my $gene_type;

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
if($_ =~ /^"/){print $outfh '<!DOCTYPE html>',"\n",
	'<html>',"\n",
	'<head>',"\n",
	'<style>',"\n",
	"table,th,td\n",
	'{',"\n",
	'border:1px solid black;',"\n",
	'border-collapse:collapse;',"\n",
	'}',"\n",
	'</html>',"\n",
	'</head>',"\n",
	'</style>',"\n",
        '<body>',"\n\n",
	'<table style="width:300px">',"\n",
	'<tr>',"\n",
	'<td>',"type",'</td>',
	'<td>',"exons",'</td>',
	'<td>',"chrom:start-end",'</td>',
	'<td>',"length",'</td>',
	'<td>',"BF",'</td>',
	'<td>',"gene list", '</td>',
	'<td>',"gene type", '</td>',
	'<td>',"DGVa_name",'</td>',
	'<td>',"DGVa_start",'</td>',
	'<td>',"DGVa_end",'</td>',
	'<td>',"length",'</td>',"\n";}
else{
	@line=split(/\,/, $_);
	$start=$line[4];
	$end=$line[5];
	$length = $end-$start;
	$chr_start_end = $line[7];
	$chr=$line[6];
	$bf=$line[8];
	$chr=~s/"//g;
## Get the core slice for your region of interest

	$slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $start, $end );


## Get all genes overlapping the slice
	$genes = $slice->get_all_Genes;

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
		my $var_start = $svf->seq_region_start;
		my $var_end = $svf->seq_region_end;
		my $var_length = $svf->length;
		print $outfh '<tr>',"\n",
		'<td>',$line[2],'</td>',
		'<td>',$line[3],'</td>',
		'<td>',$chr_start_end,'</td>',
		'<td>',$length,'</td>',
		'<td>',$bf,'</td>',
		'<td>';
			## Print info about the genes
		while( my $gene = shift @$genes){
			$gene_name = $gene->external_name;
			$gene_type = $gene->biotype;
			print $outfh " ",'<a href="http://www.genecards.org/cgi-bin/carddisp.pl?gene=',$gene_name,'">',$gene_name,'</a>',"\n";
			}
		#'<td>',"@zipped",'</td>',
		#'<td>',"@gene_type_list",'</td>',
		print $outfh '</td>','<td>',	" $gene_type ",	'</td>';
	
	
		print $outfh
		'</td>',
		'<td>','<a href="http://www.ncbi.nlm.nih.gov/dbvar/?term=',$var_name,'">',$var_name,'</a></td>',
		'<td>',$var_start,'</td>',
		'<td>',$var_end,'</td>',
		'<td>',$var_length,'</td>',"\n";
			
			}
		
}
}
}
