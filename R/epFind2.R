#' epFind2
#' New all-in-one function to call the major steps of epitopefindr.
#'
#' @param data Biostrings::AAStringset input sequences to search for epitopes, or path to corresponding .fasta file.
#' @param output.dir Directory to which output files should be written.
#' @param verbose Logical to print progress updates.
#' @param pdftk Logical whether or not to merge msa pdfs using staplr and pdftk
#' @param e.thresh Maximum e-value to consider from BLASTp alignments of 'data'.
#' @param g.method Grouping method of alignments. Either 'any' or 'all'. See ?indexGroups
#' @param aln.size Minimum length of alignment to consider from BLASTp alignments of 'data'.
#' @export
# (!) aln size not yet implemented

epFind2 <- function(data = NULL, output.dir = NULL, verbose = TRUE, pdftk = TRUE,
                    e.thresh = 0.01, g.method = "any", aln.size = 7){

  # ----------------------------------------------------------------------------
  # Check parameters

  # throw error if data or output.dir are not defined
  if(is.null(data)){
    stop("Error: epFind2 param 'data' is undefined.")
  }

  if(is.null(output.dir)){
    stop("Error: epFind2 param 'output.dir' is undefined.")
  }

  # read 'data' if input path to .fasta file
  if(class(data)[1] == "character"){
    data <- Biostrings::readAAStringSet(data)
  }

  # setup directories
  temp.dir <- paste0(output.dir,"/intermediate_files/")
  if(!dir.exists(output.dir)){dir.create(output.dir)}
  if(!dir.exists(temp.dir)){dir.create(temp.dir)}

  options(stringsAsFactors = FALSE)
  # ----------------------------------------------------------------------------
  # Prepare sequences

  if(verbose){
    cat("\n", format(Sys.time(), "%R"),
        "Step 1 of 6: Preparing BLAST alignment data from input sequences.",
        "\n")
  }

  fasta1 <- tidyFasta(data)
  f1.path <- paste0(temp.dir,"fasta1.fasta")
  writeFastaAA(fasta1, f1.path)

  blast1 <- selfBLASTaa(f1.path)
  b1.path <- paste0(temp.dir, "blast1.csv")
  data.table::fwrite(blast1, b1.path)

  blast2 <- threshBLAST(blast1, e.thresh)
  b2.path <- paste0(temp.dir, "blast2.csv")
  data.table::fwrite(blast2, b2.path)

  blast3 <- prepareBLAST(blast2, fasta1)
  b3.path <- paste0(temp.dir, "blast3.csv")
  data.table::fwrite(blast3, b3.path)

  # ----------------------------------------------------------------------------
  # Process alignment overlaps

  if(verbose){
    cat("\n", format(Sys.time(), "%R"),
        "Step 2 of 6: Simplifying alignments to minimal number of overlapping intervals.",
        "\n")
  }

  blast4fasta <- pbCycleBLAST(blast3, fasta1)
  blast4 <- blast4fasta[[1]]
  fasta4 <- blast4fasta[[2]]
  b4.path <- paste0(temp.dir, "blast4.csv")
  data.table::fwrite(blast4, b4.path)
  f4.path <- paste0(temp.dir, "fasta4.fasta")
  writeFastaAA(fasta4, f4.path)

  if(verbose){
    cat("\n", format(Sys.time(), "%R"),
        "Step 3 of 6: Trimming interval sequences.", "\n")
  }
  blast5fasta <- trimEpitopes(blast4fasta)
  blast5 <- blast5fasta[[1]]
  fasta5 <- blast5fasta[[2]]
  b5.path <- paste0(temp.dir, "blast5.csv")
  data.table::fwrite(blast5, b5.path)
  f5.path <- paste0(temp.dir, "fasta5.fasta")
  writeFastaAA(fasta5, f5.path)

  if(verbose){
    cat("\n", format(Sys.time(), "%R"),
        "Step 4 of 6: Grouping aligning sequences.", "\n")
  }
  groups <- indexGroups(blast5, fasta5, mode = g.method)
  g.path <- paste0(temp.dir, "groups.csv")
  data.table::fwrite(groups, g.path)

  if(verbose){
    cat("\n", format(Sys.time(), "%R"),
        "Step 5 of 6: Generating multiple sequence alignment logos.", "\n")
  }

  m.path <- paste0(temp.dir, "msa/")
  if(!dir.exists(m.path)){dir.create(m.path)}
  groupMSA(groups, m.path, pdftk)

  if(verbose){
    cat("\n", format(Sys.time(), "%R"),
        "Step 6 of 6: Preparing output files.", "\n")
  }

  if(pdftk){file.copy(paste0(m.path,"msa.pdf"), paste0(output.dir,"/msa.pdf"))}


  msa.cs <- readLines(paste0(m.path,"consensusSequences.txt"))
  o.path <- paste0(output.dir,"/epitopeReport.csv")
  outputTable(blast5, fasta1, groups, msa.cs, o.path)

}