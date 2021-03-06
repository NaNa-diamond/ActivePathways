% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/activePathways.r
\name{activePathways}
\alias{activePathways}
\title{activePathways}
\usage{
activePathways(
  scores,
  gmt,
  background = makeBackground(gmt),
  geneset.filter = c(5, 1000),
  cutoff = 0.1,
  significant = 0.05,
  merge.method = c("Brown", "Fisher"),
  correction.method = c("holm", "fdr", "hochberg", "hommel", "bonferroni", "BH", "BY",
    "none"),
  cytoscape.file.tag = NA
)
}
\arguments{
\item{scores}{A numerical matrix of p-values where each row is a gene and
each column is a test. Rownames should be the genes and colnames the names
of the tests. All values must be 0<=p<=1 with missing values removed or
converted to 1}

\item{gmt}{A GMT object to be used for enrichment analysis. If a filename, a
GMT object will be read from the file}

\item{background}{A character vector of gene names to be used as a
statistical background. By default, the background is all genes that appear
in \code{gmt}}

\item{geneset.filter}{A numeric vector of length two giving the lower and 
upper limits for the size of the annotated geneset to pathways in gmt.
Pathways with a geneset shorter than \code{geneset.filter[1]} or longer
than \code{geneset.filter[2]} will be removed. Set either value to NA to
to not enforce a minimum or maximum value, or set \code{geneset.filter} to 
\code{NULL} to skip filtering}

\item{cutoff}{A maximum p-value for a gene to be used for enrichment analysis.
Any genes with \code{adjusted.p.val > significant} will be discarded before testing}

\item{significant}{A number in [0,1] denoting the maximum p-value for a
pathway to be considered significantly enriched.}

\item{merge.method}{Method to merge p-values. See section Merging p Values}

\item{correction.method}{Method to correct p-values. See
\code{\link[stats]{p.adjust}} for details}

\item{cytoscape.file.tag}{the directory and/or file prefix to which the output files
 for generating enrichment maps should be written. 
If NA, files will not be written.}
}
\value{
A data.table of terms containing the following columns:
  \describe{
    \item{term.id}{The id of the term}
    \item{term.name}{The full name of the term}
    \item{adjusted.p.val}{The associated p-value, adjusted for multiple testing}
    \item{term.size}{The number of genes annotated to the term}
    \item{overlap}{A character vector of the genes that overlap between the
    term and the query}
    \item{evidence}{Columns of \code{scores} that contributed individually to 
         enrichment of the pathway. Each column is evaluated separately for 
         enrichments and added to the evidence field if the pathway is found.}
  }
}
\description{
activePathways
}
\section{Merging p Values}{

In order to obtain a single score for each gene, the p-values in \code{scores}
are merged row-wise. The two methods are:
\describe{
 \item{Fisher}{Fisher's method assumes p-values are uniformly
 distributed and performs a chi-squared test on the statistic sum(-2 log(p)).
 This method is most appropriate when the columns in \code{scores} are
 independent.}
 \item{Brown}{Brown's method extends Fisher's method by accounting for the
 covariance in the columns of \code{scores}. It is more appropriate when the
 tests of significance used to create the columns in \code{scores} are not
 necessarily independent.}
}
}

\section{Cytoscape}{

  activePathways will write four files that can be used to build a network using Cytoscape and the
  EnrichmentMap and enhancedGraphics apps. The four files written are:
  \describe{
    \item{pathways.txt}{A list of significant terms and the
    associated p-value. Only terms with \code{adjusted.p.val <= significant} are
    written to this file}
    \item{subgroups.txt}{A matrix indicating whether the significant
    pathways are found to be significant when considering only one column from
    \code{scores}. A 1 indicates that that term is significant using only that
    column to test for enrichment analysis}
    \item{pathways.gmt}{A Shortened version of the supplied gmt
    file, containing only the terms in pathways.txt}
    \item{legend.pdf}{A legend with colours matching contributions
    from columns in \code{scores}}
  }

  How to use: Create an enrichment map in Cytoscape with the file of terms
  (pathways.txt) and the shortened gmt file
  (pathways.gmt). Upload (File > import > table > file) the
  subgroups file (subgroups.txt) as a table. Under the 'style'
  panel, set image/Chart1 to use the column `instruct` and the passthrough
  mapping type. Use legend.pdf as a reference in final figure.
}

\examples{
\dontrun{
    dat <- as.matrix(read.table('path/to/data.txt', header=TRUE, row.names='Gene'))
    dat[is.na(dat)] <- 1
    activePathways(dat, 'path/to/gmt.gmt', cytoscape.file.tag="results")
}

}
