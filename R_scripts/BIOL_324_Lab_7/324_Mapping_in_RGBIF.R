# Welcome to Assignment 1: Mapping Species Distributions
# First, we'll install the necessary packages: 

# Only needs to be run the first time
# install.packages(
#   c('mapr', 'rgbif', 'spocc', 'taxize', 'tidyverse'), 
#   dependencies = TRUE)


# load packages once they are installed 
library(mapr)
library(rgbif)
library(spocc)
library(taxize)
library(tidyverse)



# -------------------------
# Group 1 (Opuntia humifusa)

# get taxon ID from GBIF
group1_ids <- 
  taxize::get_gbifid(sci=c('Opuntia humifusa'), rank='species')

# get occurence data from GBIF                           
group1_metadata <- 
  spocc::occ(ids=group1_ids, from='gbif')

# inspect metadata to find elements that we can discard


# discard unnecessary metadata and preserve occurence data
# NOTE: the '$' symbol subsets your data. To narrow in 
# on the occurence data, insert the taxon ID from 'group1_ids' 
# into the end of the subset string 
group1_simple <- group1_metadata$gbif$data$`5384047`

# look for species synonyms
unique(group1_simple$scientificName)

# look for misplaced country records
unique(group1_simple$country)

# filter out synonyms 
# filter out countries
# also, narrow in on records that are 'human observations'

group1_fil<-  
  group1_data %>% 
  filter(scientificName== 'Opuntia humifusa Raf.' & 
           basisOfRecord == "HUMAN_OBSERVATION" &
           country == c('Canada', 'United States of America')) %>%
  select(1:3)


# -------------------------
# Group 2 (Opuntia fragillis)

# get taxon ID from GBIF
# inspect and type "1" to select "Accepted" taxonomic name
group2_ids <- 
  get_gbifid(sciname=c('Opuntia fragilis'), rank='species')


# get occurence data from GBIF                           
group2_metadata <- 
  occ(ids=group2_ids, from='gbif')

# inspect metadata to find elements that we can discard
head(group2_metadata)

# discard unnecessary metadata and preserve occurence data
# NOTE: the '$' symbol subsets your data. To narrow in 
# on the occurence data, insert the taxon ID from 'group2_ids' 
# into the end of the subset string.
# this ID will be a different ID than Opuntia humifusa
group2_data <- group2_metadata$gbif$data$`5384113`

# look for species synonyms
unique(group2_data$scientificName)

# look for misplaced country records
unique(group2_data$country)

# filter out synonyms 
# filter out countries
# also, narrow in on records that are 'human observations'
group2_fil<-  
  group2_data %>% 
  filter(scientificName== 'Opuntia fragilis (Nutt.) Haw.' & 
           basisOfRecord == "HUMAN_OBSERVATION" &
           country == c('Canada', 'United States of America')) %>%
  select(1:3)



# ----------------
# combine datasets

combined_data<-
  full_join(group1_fil, group2_fil)

# ----------------
# map 

map_ggplot(combined_data) + 
  coord_fixed(xlim = c(-135, -55 ),  ylim = c(10, 90))
