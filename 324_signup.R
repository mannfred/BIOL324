library(tidyverse) #load the tidyverse library

classlist<-
  read.csv("classlist.csv") #import classlist spreadsheet, and name the object "classlist"

head(classlist) #preview the object named "classlist"


#enter your first and last name and organism of study
classlist<-
  classlist %>% 
  mutate(organism = ifelse(
    Student_name == "First name here" & 
      Last_name == "Last name here", 
    "organism", organism)
  ) 

slice(classlist, 55)