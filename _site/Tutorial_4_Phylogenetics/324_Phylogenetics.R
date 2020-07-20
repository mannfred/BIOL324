# Welcome to Lab 2: Creating Phylogenetic Trees in R
# First, we'll install the necessary packages: 

# Only needs to be run the first time
# install.packages(
#   c('ape', ), 
#   dependencies = TRUE)

# Genbank was searched using 
# "Opuntia oricola"[Organism] AND matk[Gene Name]
# to collect accession numbers

# load packages once they are installed 
library(ape)
library(here)
library(msa)
library(seqinr)
library(tidyverse)

# -------------------------
# Collect matK and rbcL partial CDS from:
#
# Majure LC, Puente R, Griffith MP, Judd WS, Soltis PS and Soltis, DE. (2012)
# Phylogeny of Opuntia s.s. (Cactaceae): Clade delineation,
# geographic origins, and reticulate evolution.
# American Journal of Botany 99(5): 847-864.
#
#
# Opuntia basilaris (Mojave, Colorado, Utah)
# Opuntia fragilis  ()
# Opuntia humifusa  (Eastern)  
# Opuntia oricola   (Coastal sage and chaparral of S. California)
# Opuntia polyacantha (Great Plains, foothills of Rocky Mtns)
# Miqueliopuntia miquelii (Outgroup, native to Brazil)

# build data frame
# accession numbers found by searching GenBank
species <- c('O. basilaris', 'O. fragilis', 'O. humifusa',  'O. oricola', 'O. polyacantha') # 'M. miquelii')
matK_acc <- c('JF786750.1', 'JF786786.1', 'JF786791.1', 'JF786812.1', 'JF786823.1') # 'JF786725.1')
rbcL_acc <- c('JF787189.1', 'JF787223.1', 'JF787227.1', 'JF787249.1', 'JF787259.1') # 'JF787164.1')

df <- data.frame(species, matK_acc, rbcL_acc)



# ------------------------
# Gene: maturase K 

# call GenBank
matK <- 
  read.GenBank(
    df$matK_acc,
    species.names = FALSE,
    as.character = TRUE) %>% 
  lapply(., paste0,collapse="") %>%  # remove spaces
  lapply(., str_to_upper) # capitalize 

# replace Accession IDs with names
names(matK) <- df$species

# save
saveRDS(matK, file=here('Tutorial_4_Phylogenetics/matK.rds'))



# ------------------------
# Gene: ribulose-1,5-biphosphate carboxylase large subunit 

# call GenBank
rbcL <- 
  read.GenBank(
    df$rbcL_acc,
    species.names = FALSE,
    as.character = TRUE) %>% 
  lapply(., paste0,collapse="") %>%  # remove spaces
  lapply(., str_to_upper) # capitalize 

# replace Accession IDs with names
names(rbcL) <- df$species

# save
saveRDS(rbcL, file=here('Tutorial_4_Phylogenetics/rbcL.rds'))


# ---------------------------
# multiple sequence alignment

# read in data
matK <- readRDS(file=here('Tutorial_4_Phylogenetics/matK.rds'))
rbcL <- readRDS(file=here('Tutorial_4_Phylogenetics/rbcL.rds'))

# matK alignment
matK_alignment <- 
  msa(unlist(matK),
      type ='dna', 
      method ='ClustalW',
      verbose = TRUE)

# inspect alignment
print(matK_alignment, show='complete')


# rbcL alignment
rbcL_alignment <- 
  msa(unlist(rbcL),
      type ='dna', 
      method ='ClustalW',
      verbose = TRUE)

# inspect alignment
print(rbcL_alignment, show='complete')



# -------------------------------------
# concatenate (merge) aligned sequences


# convert alignment object into seqinr object
matK_r <- msaConvert(matK_alignment, type="seqinr::alignment")
rbcL_r <- msaConvert(rbcL_alignment, type="seqinr::alignment")

# concatenate (merge) sequences
conseq <- mapply(paste0, matK_r$seq, rbcL_r$seq)
names(conseq) <- df$species

# re-align
con_alignment <-
  msa(unlist(conseq),
      type ='dna', 
      method ='ClustalW',
      verbose = TRUE)

# inspect 
print(con_alignment, show='complete')

# convert alignment object into seqinr object
con_r <- msaConvert(con_alignment, type="seqinr::alignment")




# -------------------------
# construct phylogenies


# create distance matrices
matK_dist <- dist.alignment(matK_r)
rbcL_dist <- dist.alignment(rbcL_r)
con_dist <- dist.alignment(con_r)


# neighbour joining trees
matK_tree <- nj(matK_dist)
rbcL_tree <- nj(rbcL_dist)
con_tree <- nj(con_dist)

# plot trees
plot(matK_tree, main ='matK tree')
plot(rbcL_tree, main = 'rbcL tree')
plot(con_tree, main = 'Consensus tree (matK + rbcL)') 

# root concatenated sequences tree
con_tree_rooted <- root(con_tree, outgroup = "O. polyacantha", resolve.root = TRUE)

# plot rooted tree
plot(con_tree_rooted, main = 'rooted consensus tree')

# save consensus tree
saveRDS(con_tree_rooted, file=here('Tutorial_3/rooted_tree.rds'))

