# Welcome to Lab 5: Mapping with RGBIF

# Opuntia basilaris (Mojave, Colorado, Utah)
# Opuntia fragilis  ()
# Opuntia humifusa  (Eastern)  
# Opuntia polyacantha (Great Plains, foothills of Rocky Mtns)
# Opuntia stricta (Gulf Coast and Caribbean)

library(here)
library(mapr)
library(mapdata)
library(spocc)
library(taxize)
library(tidyverse)

# -------------------------
# Get GBIF taxon IDs

# get taxon ID from GBIF
opuntia_ids <- 
  taxize::get_gbifid(
    sci=c('Opuntia basilaris', 
          'Opuntia fragilis', 
          'Opuntia humifusa', 
          'Opuntia polyacantha', 
          'Opuntia stricta'), 
    rank='species')

# get occurence data from GBIF                           
opuntia_metadata <- 
  spocc::occ(ids=opuntia_ids, from='gbif', limit=1000)

# save metadata for quick import later..
saveRDS(opuntia_metadata, file=here('Tutorial_5/opuntia_occ_data.rds'))

# import
opuntia_metadata <- readRDS(file=here('Tutorial_5_Phylogeography/opuntia_occ_data.rds'))
        
# discard unnecessary metadata and preserve occurence data
# NOTE: the '$' symbol subsets your data. To narrow in 
# on the occurence data, insert the taxon ID from 'group1_ids' 
# into the end of the subset string 
opuntia_data <- opuntia_metadata$gbif$data


# -------------------------------------
#  look for (and discard) synonyms for each species

# first, let's combine the separate data.frames into one
# join data (columns 1, 2, 3, 7, 16, 53)

opuntia_combined <-
  full_join(   opuntia_data$`5384070`[, c(1:3, 7, 16, 50, 53)], opuntia_data$`5384113`[, c(1:3, 7, 16, 53)]) %>% 
  full_join(., opuntia_data$`5384047`[, c(1:3, 7, 16, 50, 53)]) %>% 
  full_join(., opuntia_data$`5384095`[, c(1:3, 7, 16, 50, 53)]) %>% 
  full_join(., opuntia_data$`5384075`[, c(1:3, 7, 16, 50, 53)])


# now, search for synonyms and decide which to use

unique(opuntia_combined$scientificName)

opuntia_accepted <- c(
"Opuntia basilaris Engelm. & J.M.Bigelow",
"Opuntia fragilis (Nutt.) Haw.",
"Opuntia humifusa Raf.",
"Opuntia polyacantha Haw.",
"Opuntia stricta (Haw.) Haw.")


# filter out synonyms 
# filter out entries with positive longitude
opuntia_fil<-  
  opuntia_combined %>% 
  filter(scientificName == opuntia_accepted) %>% 
  filter(longitude < 0)

# pick some colours
mycolors <- c( "#E69F00", "#56B4E9",  "#F0E442", "#D55E00", "#CC79A7")

# map to inspect data quality
mapr::map_ggplot(opuntia_fil[,1:3], color = mycolors) + 
      coord_fixed(xlim = c(-135, -55 ),  ylim = c(10, 90)) 

# save combined dataset
saveRDS(opuntia_fil, file=here('Tutorial_5/filtered_gbif_dataset.rds'))


 





  