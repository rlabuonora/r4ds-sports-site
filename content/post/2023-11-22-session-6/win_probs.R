library(espnscrapeR)
library(dplyr)

schedule_18 <- espnscrapeR::get_nfl_schedule(season='2018')
game_data <- schedule_18 %>% 
  filter(game_id=="401030956")

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

runs_long %>% 
  filter(name %in% c("heart_rate")) %>% 
  filter(idx<13) %>% 
  ggplot(aes(date, value)) + 
  geom_line(color="blue") +
  #geom_area(alpha=0.6, fill="blue") +
  ggplot2::labs(title="Heart Rate during training sessions",
                subtitle="",
                x="",
                y="BPM") + 
  facet_wrap(~idx
             , 
             scales = "free"
             ) + 
  theme_minimal()

