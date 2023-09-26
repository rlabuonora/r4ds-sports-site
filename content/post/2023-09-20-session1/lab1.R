library(dplyr)
library(tibble)
library(knitr)
library(kableExtra)


box <- readRDS('./box.rds')
add <- readRDS('./add.rds')

df <- left_join(box, add, by="Team")

df_grouped <- group_by(df, Playoff)

tbl <- summarize(df_grouped,
            Steals=mean(STL), 
            Points=mean(PTS), 
            Blocks=mean(BLK), 
            Assists=mean(AST), 
            Rebounds=mean(REB))


simple_table <- kable(tbl, "html")
styled_table <- kable_styling(simple_table, bootstrap_options = c("striped", "hover"))
cat(styled_table, file = "playoff.html")
