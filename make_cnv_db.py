#!/usr/bin/env python
# regex
import re

# to create and save database as csv
import csv
# create usage message

import argparse

__author__ = 'nixCraft'

parser = argparse.ArgumentParser(description='CNV_database_maker by chela james')
parser.add_argument('-i','--input', help='File annotated by ExomeDepth, gene and dgv',required=True)
parser.add_argument('-d','--database', help='database',required=False)
parser.add_argument('-o','--output', help='output file name',required=True)
parser.add_argument('-s','--sample', help='sample name',required=True)

args = parser.parse_args()

### display entered values #


print ("Input file: %s" % args.input )
print ("Output file: %s" % args.output)

sample=args.sample

database_dictionary = {}

if args.database:
	for key, val in csv.reader(open(args.database)):
    		database_dictionary[key] = val 


input = open(args.input, 'r')

input_lines = input.readlines()




for line in input_lines:
	if not line.startswith("\"star"):
		line_without_return = line.strip("\n")
                line_columns = line_without_return.split(",")
# create dictionary whereby the key is the gene and the sample as the value
		if  database_dictionary.has_key(line_columns[13]):
			current_value = database_dictionary[line_columns[13]]
			
			database_dictionary[line_columns[13]] = current_value + " " + sample
		else:
			database_dictionary[line_columns[13]] = sample



file = csv.writer(open("gene_tally.csv", "w"))
for key, val in database_dictionary.items():
	file.writerow([key, val])
