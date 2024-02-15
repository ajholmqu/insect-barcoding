# Joining plating data 
setwd("/Users/aholmquist/Documents/insect_barcoding/")
plating <- 
  read.csv("data_sheets/plating.csv") %>%
  filter(catalog != "")

serpa <- 
  read.csv("data_sheets/serpa_metadata.csv") %>%
  filter(X != "") %>%
  select(X, Family:Scientific_Name, Date) %>%
  rename(catalog = X)

p34_test <- read.csv("p34_factorial.csv") %>%
  mutate(concentration = ifelse(concentration < 1, 0, concentration), 
         r_260.280 = ifelse(concentration < 1, 0, r_260.280),
         r_260.230 = ifelse(concentration < 1, 0, r_260.230))

combined <- 
  p34_test %>%
  left_join(plating, by = c("plate", "well"))  %>%
  left_join(serpa, by = "catalog") %>%
  filter(!well == "") %>%
  mutate(treatment = sub("%.*", "%", combined))

combined$nacl <- factor(combined$nacl, 
                        levels = c("1M", "2M", "2.5M"))

lm_df <- 
  read_csv("nacl_test_combined.csv") 
  filter(concentration > 1) %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%y"),
         year = as.integer(format(Date, "%Y"))) %>%
  mutate(concentration = scale(log(concentration)),
         r_260.230 = scale(log(r_260.230)))

# PCR success

# Scaling variables
library(lme4)
mini_lm <- glmer(mini ~ concentration + year + r_260.280 + r_260.230 + order + (1|order),  
                      family = binomial, data = lm_df) 
summary(mini_lm)
mini_lm_narrow <- glmer(mini ~ r_260.230 + concentration + ratio + (1|catalog),  
                 family = binomial, data = combined)

summary(mini_lm_narrow)
full_lm <- glm(mini ~ r_260.280 + r_260.230 + concentration 
               + peg + nacl + ratio,  
               family = binomial, data = combined)

mini_lm_narrowed <- glm(mini ~ r_260.230 + concentration,  
               family = binomial, data = combined)
summary(mini_lm_narrowed)

full_lm_narrowed <- glm(full ~ r_260.230 + concentration,  
                        family = binomial, data = combined)
summary(full_lm_narrowed)

ggplot(combined, aes(x = as.factor(mini), y = concentration)) + 
  geom_boxplot() +
  geom_jitter(alpha = 0.1)

ggplot(combined, aes(x = as.factor(full), y = r_260.230)) + 
  geom_boxplot() +
  geom_jitter(alpha = 0.1)

ggplot(combined, aes(x = as.factor(full), y = r_260.230)) + 
  geom_boxplot() +
  geom_jitter(alpha = 0.1)

ggplot(combined_taxon, aes(x = order)) +
  geom_bar(aes(fill = as.factor(mini)), position = "dodge")

# ANOVA
summary(aov(concentration ~ peg, data = lm_df))
summary(aov(concentration ~ nacl, data = lm_df))
summary(aov(concentration ~ ratio, data = lm_df))

summary(aov(r_260.230 ~ peg, data = lm_df))
summary(aov(r_260.230 ~ nacl, data = lm_df)) # significant
summary(aov(r_260.230 ~ ratio, data = lm_df))

summary(aov(r_260.280 ~ peg, data = lm_df))
summary(aov(r_260.280 ~ nacl, data = lm_df)) # significant
summary(aov(r_260.280 ~ ratio, data = lm_df))

summary(aov(r_260.230 ~ order, data = lm_df))
summary(aov(concentration ~ order, data = lm_df))

ggplot(lm_df, aes(x = order, y = r_260.230)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.2) +
  facet_grid(~nacl)

lm_df %>%
  group_by(order, mini) %>%
  summarise(n())
  ggplot(lm_df, aes(x = order, y = r_260.230)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.2) +
  facet_grid(~nacl)

lm_df %>%
    group_by(order, mini) %>%
    summarise(n = n()) %>%
  ggplot(aes(order, n)) +
  geom_bar(aes(fill = as.factor(mini)), stat = "identity", position = "dodge")
# Values 
combined %>%
  #filter(full == 1) %>%
  group_by(nacl, peg, ratio) %>% 
  summarise(n = n_distinct(catalog), 
            median(r_260.230),
            median(concentration))

# Visualization
lm_df %>%
  ggplot(aes(x = nacl, y = r_260.280)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.1) +
  theme_minimal()

lm_df %>%
  ggplot(aes(x = nacl, y = r_260.230)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.1) +
  theme_minimal()

