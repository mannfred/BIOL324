# Welcome to Assignment 3: 
# Species Delimitation using Morphometrics and Machine Learning
# First, we'll install the necessary packages: 

# Only needs to be run the first time
# install.packages(
#   c('caret', 'randomForest'), 
#   dependencies = TRUE)


# load packages once they are installed 
library(caret)
library(here)
library(randomForest)
library(tidyverse)


# --------------------------
# import morphometric data, saving it as 'columbine_data'
columbine_data <- read.csv(here("R_scripts/BIOL_324_Lab_8/Columbine_data.csv"))

# random number generator
set.seed(22)



# ------------------------------------
# run the function randomForest() on our morphometric data.
# ntree tells us how many decision trees to build
# mtry is the amount of variables that will be tested at each node of the tree 
# proximity=TRUE so that the data saves a proximity matrix

rf <- 
  randomForest(
    columbine_data[,-1], 
    ntree=30000, 
    mtry=3, 
    proximity=TRUE, 
    keep.forest=TRUE) 

# inspect your random forest
rf


# -----------------------------
# Multi-Dimensional Scaling (MDS)


# dist() makes a distance matrix from 1-proximity matrix 
# it is saved as distance.matrix
distance.matrix <- dist(1-rf$proximity)

# cmdscale() stands for classical multi-dimensional scale 
mds.analysis <- cmdscale(distance.matrix, eig=TRUE, x.ret=TRUE)

# calculate the percentage of variation in the distance matrix that X and Y axes account for 
mds.var.per <- round(mds.analysis$eig/sum(mds.analysis$eig)*100, 1)

# format the data so that we can plot it 
mds.values <- mds.analysis$points
mds.data <- data.frame(Sample = rownames(mds.values),
                       X = mds.values[,1],
                       Y = mds.values[,2],
                       Status = columbine_data$species.label)


# ---------------------------------
# plotting

# create MDS plot object with ggplot() function
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
                      breaks = c("flavescens", "formosa"), 
                      labels = c(expression(italic("A. flavescens")), 
                                 expression(italic("A. formosa"))),
                      values = c("#009E73", "#CC79A7"))


# show plot
# the MDS plot shows the distribution of your samples in 'shape space'
# The X axis shows the greatest amount of variation in shape
# The Y axis accounts for the second greatest amount of variation in shape
mds_plot




# Below is the code that details what we would do if there was NA in the data 

# data.imputed<-rfImpute(species ~., data = columbine_data, iter=6)
# If this had to be done on this data set then we would use data.imputed when running randomForest 
# species ~. is telling the program that we want species to be predicted instead of other data columns
# iter specifies how many random forests should build to estimate the missing values, 4-6 should be enough 
# You can try more but once the value does not improve there is no point in using more 
# Once this runs the Out-Of-Bag error rate will be shown (OOB). If they are getting smaller the estimates are improving. 


