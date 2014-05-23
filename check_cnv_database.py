#!/usr/bin/env python 

# allows the use of regex
import re

# create usage message

import argparse

__author__ = 'nixCraft'
 
parser = argparse.ArgumentParser(description='CNVchecker by chela james')
parser.add_argument('-d','--database', help='CNV database file name',required=True)
parser.add_argument('-i','--input', help='File annotated by ExomeDepth',required=True)
parser.add_argument('-o','--output', help='output file name',required=True)
args = parser.parse_args()


## show values ##
print ("Database file: %s" % args.database )
print ("Input file: %s" % args.input )
print ("Output file: %s" % args.output)




database_file = open(args.database, 'r')
	


db_lines = database_file.readlines()

db_dict = {}	
for line in db_lines:
	if not line.startswith("variantaccession"):
		db_locations = line.strip("\n")
		db_positions = db_locations.split("\t")
		accession = db_positions[0]
		
# create dictionary whereby the key consists of the second third and fourth positions and the value is the name of the dgv variant
		db_dict[ db_positions[1], db_positions[2], db_positions[3] ] = db_positions[0]
	

	
	

database_file.close()

output_file = open(args.output, 'w')

output_file.write('"start.p","end.p","type","nexons","start","end","chromosome","id","BF","reads.expected","reads.observed","reads.ratio","EnsemblID","gene","type","in dgv","dgv name","dgv freq"\n')

test_file = open(args.input,'r')
lines = test_file.readlines()


def find_key(chrom, start, end):
	for k, v in db_dict.iteritems():
		db_start = int(k[1])
		db_end = int(k[2])
		if chrom == k[0] and start >= db_start and end <= db_end:
			return db_dict[k]
		


for location in lines:
	
	if not 'start' in location:
    		location = location.strip("\n")
        	location = location.replace('"','')
        	location = location.replace('chr','')
        	pos=location.split(',')
        	test_positions = re.split('\-|:',pos[7])
	
		chrom = test_positions[0]
		#print chrom
		start = int(test_positions[1])
		#print start
		end = int(test_positions[2])
		#print end
	
	
		dgv_var_name = find_key( chrom, start , end )
	
		if dgv_var_name == None:
			not_in_dgv=location + ",not in dgv,NA\n"
			output_file.write( not_in_dgv )
		else:
			in_dgv=location + ",present in dgv," + dgv_var_name+ "\n"
			output_file.write( in_dgv )
		
