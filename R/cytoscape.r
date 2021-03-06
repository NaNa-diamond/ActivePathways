#' Prepare files for building an Enrichment Map in Cytoscape
#'
#' This function writes four files that are used to build an network using
#' Cytoscape and the EnrichmentMap app.
#'   The four files written are:
#'   \describe{
#'     \item{pathways.txt}{A list of significant terms and the
#'     associated p-value. Only terms with \code{adjusted.p.val <= significant} are
#'     written to this file}
#'     \item{subgroups.txt}{A matrix indicating whether the significant
#'     pathways are found to be significant when considering only one column from
#'     \code{scores}. A 1 indicates that that term is significant using only that
#'     column to test for enrichment analysis}
#'     \item{pathways.gmt}{A Shortened version of the supplied GMT
#'     file, containing only the terms in pathways.txt}
#'     \item{legend.pdf}{A legend with colours matching contributions
#'     from columns in \code{scores}}
#'   }
#'
#' @param terms a data.table with columns 'term.id', 'term.name', 'adjusted.p.val'
#' @param gmt an abridged GMT object containing only the pathways that were
#' found to be significant
#' @param cytoscape.file.tag user defined file prefix and/or directory to write output files
#' @param col.significance a data.table with a column 'term.id' and a column
#' for each test indicating whether a pathway is signficiant (TRUE) or not
#' (FALSE) when considering only that column. If contribution==TRUE, use
#' col.significance=NULL and this will be skipped
#' @import ggplot2
#'
#' @return None

prepareCytoscape <- function(terms, 
                             gmt, 
                             cytoscape.file.tag, 
                             col.significance) {
  if (!is.null(col.significance)) {
    tests <- unique(unlist(col.significance$evidence))
    rows <- 1:nrow(col.significance)
    
    evidence.columns = do.call(rbind, lapply(col.significance$evidence,
                                             function(x) 0+(tests %in% x)))
    colnames(evidence.columns) = tests
    
    col.significance = cbind(col.significance[,"term.id"], evidence.columns)
    
    # Use pichart
    col.colors <- rainbow(length(tests))
    instruct.str <- paste('piechart:',
                          ' attributelist="', 
                          paste(tests, collapse=','),
                          '" colorlist="', 
                          paste(col.colors, collapse=','), 
                          '" showlabels=FALSE', sep='')
    col.significance[, instruct := instruct.str]
    
    # Writing the Files
    write.table(terms, 
                file=paste0(cytoscape.file.tag, "pathways.txt"), 
                row.names=FALSE, 
                sep="\t", 
                quote=FALSE)
    write.table(col.significance, 
                file=paste0(cytoscape.file.tag, "subgroups.txt"), 
                row.names=FALSE, 
                sep="\t", 
                quote=FALSE)
    write.GMT(gmt, 
              paste0(cytoscape.file.tag, "pathways.gmt"))
    
    # Making a Legend
#    if (requireNamespace("ggplot2", quietly = TRUE)) {
#      require(ggplot2)
      dummy_plot = ggplot(data.frame("tests" = factor(tests, levels = tests),
                                     "value" = 1), aes(tests, fill = tests)) +
        geom_bar() +
        scale_fill_manual(name = "Contribution", values=col.colors)
      pdf(file = NULL) # Suppressing Blank Display Device from ggplot_gtable
      dummy_table = ggplot_gtable(ggplot_build(dummy_plot))
      dev.off()
      legend = dummy_table$grobs[[which(sapply(dummy_table$grobs, function(x) x$name) == "guide-box")]]
      
      # Estimating height & width
      legend_height = ifelse(length(tests) > 20, 
                             5.5, 
                             length(tests)*0.25+1)
      legend_width = ifelse(length(tests) > 20, 
                            ceiling(length(tests)/20)*(max(nchar(tests))*0.05+1), 
                            max(nchar(tests))*0.05+1)
      ggsave(legend,
             device = "pdf",
             filename = paste0(cytoscape.file.tag, "legend.pdf"), 
             height = legend_height, 
             width = legend_width, 
             scale = 1)
#    } else {
#      stop("Package ggplot2 needed for this function to work. Please install it.",
#           call. = FALSE)
#    }
    
    
  } else {
    write.table(terms, 
                file=paste0(cytoscape.file.tag, "pathways.txt"),
                row.names=FALSE, 
                sep="\t", 
                quote=FALSE)
    write.GMT(gmt, 
              paste0(cytoscape.file.tag, "pathways.gmt"))
  }
}



