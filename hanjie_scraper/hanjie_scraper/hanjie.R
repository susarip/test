library(dplyr)
library(ggplot2)
library(ggthemes)

### Cleaning Data ###
hanjie <- read.csv("/Users/susmithasaripalli/Documents/GitHub/test1/hanjie_scraper/hanjie_scraper/hanjie.csv",
               header = TRUE,
               sep = ",",
               stringsAsFactors = FALSE)
hanjie$difficulty <- as.numeric(gsub("/10","",hanjie$difficulty))
hanjie <- hanjie %>%
  mutate(size = sizeRow*sizeCol)

