# EpitopeFinder (R package name: epitopefindr)
## Minimal Overlaps from BLAST Alignments 
Version: 1.1.01  
Date: January 1, 2019  
Concept: Ben Larman, Brandon Sie, Daniel Monaco  
Author: Brandon Sie  (contact: brandonsie at gmail)  

# Pipeline Overview: 
The purpose of this package is to describe the alignments among a set of peptide sequences by reporting the overlaps of each peptide's alignments to other peptides in the set. One can imagine inputting a list of peptides enriched by immunoprecipitation to identify corresponding epitopes. 

`epitopefindr` takes a .fasta file listing peptide sequences of interest and calls BLASTp from within R to identify alignments among these peptides. Each peptide's alignments to other peptides are then simplified to the minimal number of "non overlapping" intervals* of the index peptide that represent all alignments to other peptides reported by BLAST. (*By default, each interval must be at least 7 amino acids long, and two intervals are considered NOT overlapping if they share 6 or fewer amino acids). After the minimal overlaps are identified for each peptide, these overlaps are gathered into aligning groups based on the initial BLAST. For each group, a multiple sequence alignment logo (motif) is generated to represent the collective sequence. Additionally, a spreadsheet is written to list the final trimmed amino acid sequences and some metadata. 

![workflow](https://brandonsie.github.io/docs/EpitopeFindRWorkflow.png)

# Setup:
1. Install [R (version 3.4.2+)](https://www.r-project.org/).  
2. Install [BLAST+ (version 2.7.1+)](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).
3. In R console, execute `devtools::install_github("brandonsie/epitopefindr")`, then `library(epitopefindr)`

----------------------------------------------------------------------
# Guide

* An implementation with Richfitz's [remake](https://github.com/richfitz/remake) is a planned upcoming development aim.

1. Prepare an `AAStringSet` object of peptides as described in the [Biostrings documentation](http://web.mit.edu/~r/current/arch/i386_linux26/lib/R/library/Biostrings/html/XStringSet-class.html).
2. `pbCycleBLAST` cycles through each input peptide to find the overlap of its alignment with other peptides from the input. Nested within a call to `pbCycleBLAST` are calls to `epitopeBLAST`, `indexEpitopes`. 
3. `trimEpitopes` performs a second pass through the identified sequences to tidy alignments.
4. `indexGroups` collects trimmed sequences into aligning groups
5. `groupMSA` creates a multiple sequence alignment motif logo for each group
6. `outputTable` creates a spreadsheet summarizing identified sequences and epitope groups
