### Create filtered edgelists to be fed to CytoScape

source("../../load.R", chdir=T)

write.filtered.edgelist <- function(infile, outfile, min.common, 
                                    # change the column name to distinguish sources
                                    src.prefix, src.suffix,
                                    cyto.mode=F)
  {
  filt.links <<- read.filtered.edgelist(infile=infile, 
                                        min.common=min.common,
                                        min.exposure=MIN.EXPOSURE,
                                        discard.langs=DISCARD.LANGS,
                                        weighted.graph=T)
  
  # CytoScape mode: format is for updating the edge attrbutes in CytoScape
  # without having to start the network from scratch
  if (cyto.mode==T) {
    row.names(filt.links) <- with(filt.links, paste0(src.name, " (pp) ", tgt.name))
    filt.links$src.name <- NULL
    filt.links$tgt.name <- NULL
  }
    
  # add before column name so CytoScape can distinguish values for different sources
  colnames(filt.links) <- paste0(src.prefix, colnames(filt.links), src.suffix) 
  
  # The row.names column is written but has no title
  write.table(filt.links, file=outfile,
              quote=F, sep="\t", row.names=T, col.names=NA)
  
}

# Used to prevent conflicts with previously loaded attributes
# e.g., add ".new"
ALL.SUFFIX <- ".new"

write.filtered.edgelist(TWIT.STD.LANGLANG, "twit_links_filtered.tsv", 
                        MIN.COMMON.USERS, src.prefix="t", src.suffix=ALL.SUFFIX)
write.filtered.edgelist(WIKI.STD.LANGLANG, "wiki_links_filtered.tsv", 
                        MIN.COMMON.USERS, src.prefix="w", src.suffix=ALL.SUFFIX)
write.filtered.edgelist(BOOKS.STD.LANGLANG, "book_links_filtered.tsv", 
                        MIN.COMMON.TRANS, src.prefix="b", src.suffix=ALL.SUFFIX)

# For CytoScape's "Import edge attributes"
write.filtered.edgelist(TWIT.STD.LANGLANG, "twit_edge_attribs_cyto.tsv", 
                        MIN.COMMON.USERS, src.prefix="t", src.suffix=ALL.SUFFIX,
                        cyto.mode=T)
write.filtered.edgelist(WIKI.STD.LANGLANG, "wiki_edge_attribs_cyto.tsv", 
                        MIN.COMMON.USERS, src.prefix="w", src.suffix=ALL.SUFFIX,
                        cyto.mode=T)
write.filtered.edgelist(BOOKS.STD.LANGLANG, "book_edge_attribs_cyto.tsv", 
                        MIN.COMMON.TRANS, src.prefix="b", src.suffix=ALL.SUFFIX,
                        cyto.mode=T)
