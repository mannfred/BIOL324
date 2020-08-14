# Welcome to Assignment 5: Phylogeography

# Only needs to be run the first time
# install.packages(
#   c('phytools', 'mapdata'), 
#   dependencies = TRUE)

# Opuntia basilaris (Mojave, Colorado, Utah)
# Opuntia fragilis  ()
# Opuntia humifusa  (Eastern)  
# Opuntia polyacantha (Great Plains, foothills of Rocky Mtns)
# Opuntia stricta (Gulf Coast and Caribbean)

library(here)
library(mapdata)
library(phytools)
library(tidyverse)
library(viridis)

# ---------------------------
# import data

# import Opuntia consensus tree from last tutorial
con_tree_rooted <- readRDS(file = here('Tutorial_4_Phylogenetics/rooted_tree.rds'))

# import filtered GBIF data from last tutorial
opuntia_fil <- readRDS(file=here('Tutorial_5_Phylogeography/filtered_gbif_dataset.rds')) 

# shorten names and replace spaces with underscores (for phytools)
opuntia_fil <-
 opuntia_fil %>% 
 mutate(short_names = case_when(
   name == "Opuntia basilaris Engelm. & J.M.Bigelow" ~ "O_basilaris",
   name == "Opuntia fragilis (Nutt.) Haw." ~ "O_fragilis",
   name == "Opuntia humifusa Raf." ~ "O_humifusa",
   name == "Opuntia oricola Philbrick" ~ "O_oricola",
   name == "Opuntia polyacantha Haw." ~ "O_polyacantha"
 ))

# format latlong data for phylo.to.map()
latlong <- 
  opuntia_fil %>% 
  select(c(3,2)) %>% # reverse long-lat to lat-long
  as.matrix()

# re-assign species names to rows
rownames(latlong) <- opuntia_fil$short_names

# removes rows with NAs
latlong <- na.omit(latlong)

# rename tip labels to match latlong
con_tree_rooted$tip.label <- unique(opuntia_fil$short_names)

# ----------------
# mapping


colours <- 
  setNames(c('#999999', '#E69F00', '#56B4E9', '#009E73', '#F0E442'),
           con_tree_rooted$tip.label)

                    
for(i in 1:Ntip(con_tree_rooted)){
  spr<-latlong[which(rownames(latlong)==con_tree_rooted$tip.label[i]),]
  mcp<-if(i==1) spr[chull(spr),] else rbind(mcp,spr[chull(spr),])
}
                                     
                    
# create phylogeographic map
obj <- 
  phylo.to.map(
    con_tree_rooted, 
    latlong, 
    regions = c("Canada", "USA", "Mexico"),
    database = "worldHires",
    xlim = c(-135, -55 ),  
    ylim = c(10, 45),
    asp = 4,
    lwd = 1,
    plot = FALSE)

  
plot(
  obj, 
  direction = "rightwards", 
  colors = sapply(colours, make.transparent, 0.4),
  pts = FALSE,
  cex.points = c(0,0),
  lwd = c(3,1),
  asp = 1.3,
  ftype ="i")

for(i in 1:Ntip(con_tree_rooted)){
  ii<-which(rownames(mcp)==con_tree_rooted$tip.label[i])
  polygon(mcp[ii,2:1],col=make.transparent(colours[con_tree_rooted$tip.label[i]],0.8),
          border="darkgrey")
}
