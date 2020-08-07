# Lab 6

library(datasets) # attaches the 'datasets' package, which contains a bunch of datasets to explore
iris # typing the name of the dataset (object) will display the contents of the data in the console pane
class(iris) # displays the 'class' of the object 'iris'
summary(iris) # gives various summary statistics on the dataframe 'iris'

install.packages("dplyr","ggplot2")

library(dplyr)
library(ggplot2)

plot(iris)

plot(x=iris$Sepal.Length, y=iris$Petal.Length)

hist(iris$Sepal.Length)
