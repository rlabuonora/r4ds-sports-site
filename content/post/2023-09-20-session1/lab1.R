library(dplyr)
library(tibble)
library(knitr)
library(kableExtra)


box <- readRDS('./box.rds')
add <- readRDS('./add.rds')

t <- box %>% 
  left_join(add, by="Team")

table <- t %>% 
  group_by(Playoff) %>% 
  summarize(Steals=mean(STL), 
            Points=mean(PTS), 
            Blocks=mean(BLK), 
            Assists=mean(AST), 
            Rebounds=mean(REB))


kable(table, "html") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  cat(., file = "playoff.html")