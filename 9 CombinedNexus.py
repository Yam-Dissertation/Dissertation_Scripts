import os
from Bio import AlignIO
from Bio.Nexus import Nexus
from Bio.Alphabet import generic_dna

os.chdir('/mnt/c/Users/joshu/OneDrive - The Royal Botanic Gardens, Kew/BIOL0019/TestZone')


def combined_nexus(wd, fasta1, fasta2):
	os.chdir(wd)

	record1 = AlignIO.parse(fasta1, "fasta", alphabet = generic_dna)
	record2 = AlignIO.parse(fasta2, "fasta", alphabet = generic_dna)

	Output1 = fasta1.split(".")[0]+".nex"
	Output2 = fasta2.split(".")[0]+".nex"

	count1 = AlignIO.write(record1, Output1, "nexus")
	count2 = AlignIO.write(record2, Output2, "nexus")

	file_list = [Output1, Output2]
	nexi = [(fname, Nexus.Nexus(fname)) for fname in file_list]

	combined = Nexus.combine(nexi)
	combinedprefix = fasta1.split(".")[0]+fasta2.split(".")[0]
	combined.write_nexus_data(filename=open(combinedprefix + ".nex", "w"))

	with open(combinedprefix + ".nex", "r") as NEX:
		lines = NEX.readlines()
		lines = [line.rstrip() for line in lines]

		smaller = [i for i, s in enumerate(lines, 1) if "matrix" in s]
		larger = [i for i, s in enumerate(lines, 1) if "begin sets" in s]
		smaller = smaller[0]
		larger = larger[0] - 4
		data_lines = lines[smaller:larger]

		ids = []
		alignments = []
		for data in data_lines:
			ids.append(str.split(data)[0])
			alignments.append(str.split(data)[1])

		new_seqs = []
		for sequence in alignments:
			leading = len(sequence) - len(sequence.lstrip("?").lstrip("-"))
			trailing = len(sequence) - len(sequence.rstrip("?").rstrip("-"))
			new_seq = ("?" * leading) + sequence[leading:len(sequence)-trailing] + ("?" * trailing)
			new_seqs.append(new_seq)

		for id2 in range(0, len(ids)):
			if len(ids[id2]) == 3:
				ids[id2] += "  "
			elif len(ids[id2]) == 4:
				ids[id2] += " "

		codelines = ["begin PAUP;", "log file=" + combinedprefix + ".log;", "hompart partition=combined nreps=100 / start=stepwise addseq=random nreps=10 savereps=no randomize=addseq rstatus=yes hold=1 swap=tbr multrees=yes nchuck=10 chuckscore=10;", "log stop;", "end;"]

		# We've got new.seqs and we've got ids
		new_data_lines = []
		for line_num in range(0, len(new_seqs)):
			new_data_lines.append(ids[line_num] + new_seqs[line_num])

		# Final document should read lines[0:smaller] + new_data_lines + lines[larger:len(lines)-1]
		document = lines[0:smaller] + new_data_lines + lines[larger:len(lines)] + codelines
	NEX.close()

	fout = open(combinedprefix + "CODE.nex", "w")
	for element in document:
		fout.write(element + "\n")
	fout.close()

combined_nexus(wd = '/mnt/c/Users/joshu/OneDrive - The Royal Botanic Gardens, Kew/BIOL0019/TestZone', fasta1 = "261TRIMAL.fasta", fasta2 = "262TRIMAL.fasta")
