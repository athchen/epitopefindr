% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pbCycleBLAST.R
\name{pbCycleBLAST}
\alias{pbCycleBLAST}
\title{pbCycleBLAST
Initialize a txtProgressBar object with which to call cycleBLAST.}
\usage{
pbCycleBLAST(blast, fasta, ncycles = "max")
}
\arguments{
\item{blast}{BLAST alignment table to process.}

\item{fasta}{Fasta file of peptide sequences to process.}

\item{ncycles}{Number of cycles of cycleBLAST to perform.}
}
\description{
pbCycleBLAST
Initialize a txtProgressBar object with which to call cycleBLAST.
}
