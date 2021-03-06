# epitopefindr: Minimal Overlaps from BLAST Alignments 





|  |  |
| --- | --- |
| Version:  | 1.1.13 |
| Date: | February 17, 2019 |
| Concept: | Ben Larman, Brandon Sie, Daniel Monaco  |
| Author: | Brandon Sie  (contact: brandonsie at gmail)   |

# Pipeline Overview: 
The purpose of this package is to describe the alignments among a set of peptide sequences by reporting the overlaps of each peptide's alignments to other peptides in the set. One can imagine inputting a list of peptides enriched by immunoprecipitation (e.g. by [PhIP-seq](https://www.nature.com/articles/s41596-018-0025-6)) to identify corresponding epitopes. 

`epitopefindr` takes a .fasta file listing peptide sequences of interest and calls BLASTp from within R to identify alignments among these peptides. Each peptide's alignments to other peptides are then simplified to the minimal number of "non overlapping" intervals* of the index peptide that represent all alignments to other peptides reported by BLAST. (*By default, each interval must be at least 7 amino acids long, and two intervals are considered NOT overlapping if they share 6 or fewer amino acids). After the minimal overlaps are identified for each peptide, these overlaps are gathered into aligning groups based on the initial BLAST. For each group, a multiple sequence alignment logo (motif) is generated to represent the collective sequence. Additionally, a spreadsheet is written to list the final trimmed amino acid sequences and some metadata. 

![workflow](https://raw.githubusercontent.com/brandonsie/brandonsie.github.io/master/docs/EpitopeFindRWorkflow2.png)


# Setup:
1. Install [R (version 3.5+)](https://www.r-project.org/).  
2. Install [BLAST+ (version 2.7.1+)](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download).  
3. Install [pdftk (version 2.02+)](https://www.pdflabs.com/tools/pdftk-server/). _(Optional; only used to combine individual sequence alignment logo pdfs into a single file.)_  
4. In R console, execute: 
``` r  

# Install Bioconductor packages
if (!requireNamespace("BiocManager")) install.packages("BiocManager")
BiocManager::install(c("Biostrings", "EBImage", "IRanges", "msa", "S4Vectors"))

# Install Github packages
if(!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("mhahsler/rBLAST")  
devtools::install_github("brandonsie/epitopefindr")

# Load & attach
library(epitopefindr)
```
----------------------------------------------------------------------
# Guide

1. Prepare an `AAStringSet` object of peptides (identifier + sequence) as described in the [Biostrings documentation](http://web.mit.edu/~r/current/arch/i386_linux26/lib/R/library/Biostrings/html/XStringSet-class.html) OR prepare a fasta file with equivalent information.
2. For now, try calling `epFind2(<AAStringSet or path to .fasta file>, <path to directory to write output files>)` to run a typical epitopefindr pipeline. A make-style implementation is an upcoming development goal.  

A brief summary of the functions called by `epFind2`:
  * `pbCycleBLAST` cycles through each input peptide to find the overlap of its alignment with other peptides from the input. Nested within a call to `pbCycleBLAST` are calls to `epitopeBLAST`, `indexEpitopes`. 
  * `trimEpitopes` performs a second pass through the identified sequences to tidy alignments.
  * `indexGroups` collects trimmed sequences into aligning groups
  * `groupMSA` creates a multiple sequence alignment motif logo for each group
  * `outputTable` creates a spreadsheet summarizing identified sequences and epitope groups

