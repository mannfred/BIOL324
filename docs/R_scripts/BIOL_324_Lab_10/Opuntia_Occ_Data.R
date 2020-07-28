# Welcome to Assignment 5: Phylogeography

# In this R script we'll collect lat-long data for our Opuntia spp.
# In the next script we'll combine this data with the Opuntia phylogeny
# to create a phylogeographic map of Opuntia in North America. 

# Opuntia basilaris (Mojave, Colorado, Utah)
# Opuntia fragilis  ()
# Opuntia humifusa  (Eastern)  
# Opuntia oricola   (Coastal sage and chaparral of S. California)
# Opuntia polyacantha (Great Plains, foothills of Rocky Mtns)

library(here)
library(mapr)
library(spocc)
library(taxize)
library(tidyverse)

# -------------------------
# Get GBIF taxon IDs

# get taxon ID from GBIF
opuntia_ids <- 
  taxize::get_gbifid(
    sci=c('Opuntia basilaris', 'Opuntia fragilis', 
              'Opuntia humifusa', 'Opuntia oricola', 'Opuntia polyacantha'), 
    rank='species')

# get occurence data from GBIF                           
opuntia_metadata <- 
  spocc::occ(ids=opuntia_ids, from='gbif')

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
  full_join(., opuntia_data$`5384100`[, c(1:3, 7, 16, 50, 53)]) %>% 
  full_join(., opuntia_data$`5384095`[, c(1:3, 7, 16, 50, 53)])


# now, search for synonyms and decide which to use

unique(opuntia_combined$scientificName)

opuntia_accepted <- c(
"Opuntia basilaris Engelm. & J.M.Bigelow",
"Opuntia fragilis (Nutt.) Haw.",
"Opuntia humifusa Raf.",
"Opuntia oricola Philbrick",
"Opuntia polyacantha Haw.")

countries <- c("CA", "US", "MX")

# look for misplaced country records
unique(opuntia_combined$country)



# filter out synonyms 
# filter out entries with positive longitude
opuntia_fil<-  
  opuntia_combined %>% 
  dplyr::filter(scientificName == opuntia_accepted) %>% 
  dplyr::filter(longitude < 0)


# map to inspect data quality
mapr::map_ggplot(opuntia_fil[,1:3])


# save combined dataset
saveRDS(opuntia_fil, file=here('Tutorial_5/filtered_gbif_dataset.rds'))


  map(
    database = "worldHires", 
    regions = c("Canada", "USA", "Mexico"),
    xlim = c(-137, -55 ),  
    ylim = c(-10, 100),
    mar = c(0.01, 0.01, 0.01, 0.01),
    asp = 1.3,
    fill = TRUE, 
    col = "gray95")

points(coords, pch = pch, cex = cex.points[2], bg = colors[, 
                                                           2])




  