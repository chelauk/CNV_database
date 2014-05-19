#!/usr/bin/env python

# to create and save database as csv
import csv
# create usage message

import argparse

# author of argparse
__author__ = 'nixCraft'


# all the arguments necessary for make_cnv_database

parser = argparse.ArgumentParser(description='CNV_database_maker by chela james')
parser.add_argument('-i','--input', help='File annotated by ExomeDepth, gene and dgv',required=True)
parser.add_argument('-d','--database', help='database',required=False)
parser.add_argument('-o','--output', help='output file name',required=True)
parser.add_argument('-s','--sample', help='sample name',required=True)

args = parser.parse_args()

### display entered values #


print ("Input file: %s" % args.input )
print ("Database file: %s" args.database)
print ("Output file: %s"  args.output)
print ("Sample name: %s" args.sample)

sample=args.sample

database_dictionary = {}


# If there is a current database open the database and make a database dictionary using the csvreader
# The key will be the gene.

if args.database:
	for key, val in csv.reader(open(args.database)):
    		database_dictionary[key] = val 



# open the input

input = open(args.input, 'r')

input_lines = input.readlines()

# parse the input csv

for line in input_lines:
	if not line.startswith("\"star"):
		line_without_return = line.strip("\n")
                line_columns = line_without_return.split(",")

# create dictionary whereby the key is the gene and the sample as the value
# if the database already has the gene, it concatenates the sample name to the db


		if  database_dictionary.has_key(line_columns[13]):
			current_value = database_dictionary[line_columns[13]]
			
			database_dictionary[line_columns[13]] = current_value + " " + sample
		else:
			database_dictionary[line_columns[13]] = sample


# write gene_tally.csv

file = csv.writer(open("gene_tally.csv", "w"))
for key, val in database_dictionary.items():
	file.writerow([key, val])
