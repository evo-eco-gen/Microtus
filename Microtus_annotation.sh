#!/bin/bash
### ANNOTATE A NEW ASSEMBLY (PARTIALLY PHASED FROM HIFIASM, CCGP GENOME Assembly Pipeline v5)
### Use Liftoff (https://github.com/agshumate/Liftoff)
### Annotate Microtus californicus using three related species (Microtus sp.), and Mus musculus (diverged >20MYA, Upham et al. 2019)
### Polish exon boundaries, look for duplicates, 
### The threshold for divergence of putative paralogues (0.95) is debatable.

### Requirements: Pysam, MMseqs2

### The novel Microtus californicus genome (GCA_028537955.1): 
target="GCA_028537955.1_mMicCal1.0.hap1_genomic.fna"

### Lifotover the Mus musculus annotation with parameters adjusted for higher levels of divergence (minimap2: -asm10):
annotated_Mus_assembly="GCF_000001635.27_GRCm39"

liftoff -g $annotated_Mus_assembly.gff -dir $annotated_Mus_assembly.intermediate -o $target.$annotated_Mus_assembly.gff -mm2_options="-a 0.5 --end-bonus 5 --eqx -N 50 -p 0.5 -c -t12 --cs -x asm10" -exclude_partial -flank 0.1 -p 12 -exclude_partial -polish -copies -sc 0.95 $target $annotated_Mus_assembly.fna

### Identify clusters of putative paralogues:

liftofftools all -mmseqs_params "--threads 12" -r $annotated_Mus_assembly.fna -t $target -rg $annotated_Mus_assembly.gff -tg $target.$annotated_Mus_assembly.gff


### Annotate using the congenerics.
### Analyse the results using LiftoffTools (https://github.com/agshumate/LiftoffTools).

while read annotated_assembly; do
	liftoff -g $annotated_assembly.gff -dir $annotated_assembly.intermediate -o $target.$annotated_assembly.gff -mm2_options="-a 0.5 --end-bonus 5 --eqx -N 50 -p 0.5 -c -t12 --cs -x asm5" -exclude_partial -flank 0.1 -p 12 -exclude_partial -polish -copies -sc 0.95 $target $annotated_assembly.fna
	mv unmapped_features.txt $target.$annotated_assembly.unmapped_features.txt
	liftofftools all -mmseqs_params "--threads 12" -r $annotated_assembly.fna -t $target -rg $annotated_assembly.gff -tg $target.$annotated_assembly.gff
	mv liftofftools_output $target.$annotated_assembly.liftofftools_output
done < annotated_assemblies.txt

