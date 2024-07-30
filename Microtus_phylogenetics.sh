MICROTUS PHYLOGENY
#####
# Downlaod the paired end, minmum 4x coverage Illumina samples
while IFS= read -r line
do
    fastq-dl --accession "$line" --group-by-sample
done < Microtus.txt

#####
# Map to 500 OMA Orthology Groups with Read2Tree:
while IFS= read -r line
do
	read2tree --standalone_path /media/data1/kozakk/Microtus/paired_reads/rodents_marker_genes --output_path /media/data1/kozakk/Microtus/paired_reads/output --threads 12 --reads "$line"_1.fastq.gz "$line"_2.fastq.gz
done < Microtus_prefixes.txt

read2tree --threads 12 --standalone_path /media/data1/kozakk/Microtus/paired_reads/rodents_marker_genes --output_path /media/data1/kozakk/Microtus/paired_reads/output_highqual --merge_all_mappings

#####
# Change supermatrix taxon names in R
library(ape)
current_names <- rownames(supermatrix)
new_names <- current_names  # Initialize new_names with current names

for (i in 1:length(current_names)) {
  match_index <- which(name_table$alphanumeric == current_names[i])
  if (length(match_index) > 0) {
    new_names[i] <- name_table$sample_name[match_index]
  }
}

# Apply the new names
rownames(supermatrix) <- new_names

# Verify the change
print(rownames(supermatrix))

comparison <- data.frame(Old = current_names, New = rownames(supermatrix))
print(comparison)

#####
# Split the supermatrix into individual gene alignments:
python AMAS.py split \
 -f fasta -d dna -i supermatrix_interleaved_gaps.fas -u fasta -l concat_merge_dna.group_boundaries

#####
# Remove taxa with excess missing data:
for FILE in *out.fas; do
	./missing.sh $FILE $FILE.gappy_removed.fas $FILE.removed_gappy_samples.txt
done


#Compute the Multispecies Coalescent weighted ASTRAL phylogeny:
/media/kozakk/120TB/bin/ASTER-Linux/bin/wastral -t 20 -o wastral1 --mode 1 --root Mus_musculus --mapping species_assignments_2.txt -r 20 -s 20 


# Compute the Supermatrix tree:
iqtree -s supermatrix.32.fas -p concat_merge_dna.group_boundaries.raxml.txt -m MFP+MERGE -B 1000 --sampling GENE -T AUTO -ntmax 18

