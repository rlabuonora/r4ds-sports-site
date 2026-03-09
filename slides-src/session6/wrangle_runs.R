library(trackeR)
library(dplyr)
library(tidyr)

run <- runs[[1]] %>% as.data.frame

run <- run %>% 
  mutate(time=index(runs[[1]])) %>% 
  relocate(time) %>%   
  as_tibble() %>% 
  select(time, heart_rate)

saveRDS(run, '../run.rds')

## 
library(ggplot2)

run %>% 
  ggplot(aes(x=time, y=heart_rate)) +
  geom_line() +
  theme_minimal()+
  labs(x='Time', y="Heart Rate (BPM)")
