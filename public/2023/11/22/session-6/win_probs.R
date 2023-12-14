library(espnscrapeR)
library(dplyr)

# esto para un left join!
win_prob <- get_espn_win_prob(game_id = "401030956")
home_teams <- get_nfl_teams() %>% 
  select(team_name=team_name, home_team_id=team_id)
away_teams <- get_nfl_teams() %>% 
  select(away_team_name=team_name, away_team_id=team_id)

win_probs <- win_prob %>% 
  left_join(home_teams) %>% 
  left_join(away_teams)

win_probs %>% colnames
library(ggplot2)
ggplot(win_probs, aes(row_id, home_win_percentage)) +
  geom_line()

saveRDS(win_probs, '../r4ds-sports/content/post/2023-12-14-session-7/win_probs.rds')
