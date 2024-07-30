#!/bin/bash

# A function to fetch assembly details from Genbank using Entrez.
fetch_assembly_details() {
    local genus=$1
    esearch -db assembly -query "$genus[Organism]" |
    efetch -format docsum |
    xtract -pattern DocumentSummary -element AssemblyAccession SpeciesName AssemblyName SubmitterOrganization \
        -block Stat -if "@category" -equals "total_length" \
        -or "@category" -equals "scaffold_count" \
        -or "@category" -equals "scaffold_n50" -or "@category" -equals "scaffold_l50" \
        -or "@category" -equals "total_gap_length" -or "@category" -equals "max_scaffold_length" \
        -element Stat \
        -block Stat -if "@category" -equals "contig_n50" -element Stat \
        -element FtpPath_GenBank BioProjectAccn \
        -block Biosource -element Isolate \
        -block PropertyList -element BiologicalProperties \
        -block PropertyList -element Assembly-Method \
        -block PropertyList -element Sequencing-Technology |
    awk -F '\t' 'BEGIN {OFS="\t"; print "Accession", "Species", "Assembly Name", "Submitter", "N Scaffolds", "Chromosomal",  "Scaffold N50", "Scaffold L50", "N (bp)", "Length (bp)", "Contig N50", "Assembly name"}
    {print}' > "${genus}_assembly_details.tsv"
}

# Fetch details for each genus for the purpose of summarising rhe state of genome asemblies of rodents in the genus Microtus.
fetch_assembly_details "Microtus"
fetch_assembly_details "Alexandromys"

# echo "Data has been saved to Microtus_assembly_details.tsv and Alexandromys_assembly_details.tsv"