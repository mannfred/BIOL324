library(caret)
library(here)
library(randomForest)
library(RCurl)
library(tidyverse)

antennaria <- 
  read.csv('media/324_morpho.csv') %>% 
  select(c(4, 6:11)) %>% 
  drop_na()

# random forests
rf <- 
  randomForest(
    antennaria[,-1], 
    ntree=30000, 
    mtry=3, 
    proximity=TRUE, 
    keep.forest=TRUE) 

# distance matrix
distance.matrix <- dist(1 - rf$proximity)

# MDS analysis
mds.analysis <- cmdscale(distance.matrix, eig=TRUE, x.ret=TRUE)
mds.var.per <- round(mds.analysis$eig/sum(mds.analysis$eig)*100, 1)
mds.var.per[1:2]

mds.values <- mds.analysis$points
mds.data <- data.frame(Sample = rownames(mds.values),
                       X = mds.values[,1],
                       Y = mds.values[,2],
                       Status = antennaria$Species)

# MDS plot
mds_plot <- 
  ggplot(
    data = mds.data, 
    aes(x = X, y = Y, label = Sample)) + 
  geom_text(aes(color = Status)) +
  theme_bw() + 
  xlab(paste("MDS1 - ", mds.var.per[1], "%",sep="")) +
  ylab(paste("MDS2 - ", mds.var.per[2], "%",sep="")) +
  ggtitle(" Unsupervised MDS plot using (1 - Random Forest Proximities)") +
  scale_colour_manual(name = "Species", 
                      values = c("#009E73", "#CC79A7"))

mds_plot
