library(tidyverse)
setwd("/Users/aholmquist/Documents/github/insect-barcoding")
pcr_success <- read.csv("data/pcr.csv") 

pcr_cleaned <- 
  pcr_success %>% 
  # Didn't need these columns
  select(-X, -evaporated, -primers) %>%
  mutate(primer_pair = paste0(primer_f, "_", primer_r), # Created clean primer pair
         band = case_when( # Standardized band calls
           band == "Y" ~ "y",
           band == "y" ~ "y",
           TRUE ~ "n"),
         thermocycler = case_when( # Standardized thermocyclers
           grepl("2", thermocycler) ~ "#2",
           grepl("3", thermocycler) ~ "#3",
           grepl("4", thermocycler) ~ "#4",
           grepl("5", thermocycler) ~ "#5",
           grepl("6", thermocycler) ~ "#6",
           TRUE ~ "?"
         ),
         date = as.Date(date, "%m/%d/%Y")) %>% # Fixed data formating to allow ordering by date
  group_by(plate) %>%
  arrange(date) %>%
  mutate(replicate = paste0(plate, "_pcr.v", as.numeric(factor(date)))) %>% # Create replicate column for unique PCR
  ungroup() 

# I like things a certain way so re-ordered columns this way!
order <- c("catalog", "well", "plate", "letter", "number",
           "primer_f", "primer_r", "primer_pair", "replicate",   
           "date", "thermocycler", "band", "flag", "notes")

pcr_cleaned <-
  pcr_cleaned %>%
  # Used select and the order list to re-order
  select(all_of(order)) %>%
  # Didn't want fly test on there
  filter(!plate %in% c("Fly 1", "Fly 2")) %>%
  # Below three lines were for a subset of columns that were true duplicates (same band called)
  dplyr::group_by(catalog, well, plate, letter, number, primer_f, primer_r, 
                  replicate, date, thermocycler,
                  flag, notes, primer_pair, band) %>%
  filter(row_number() == 1) %>%
  ungroup()

# This is the step to pivot long to wide
pcr_pivot <- 
  pcr_cleaned %>%
  # Pivoting on one column, so need to remove these unique identifiers 
  select(-primer_f, -primer_r) %>%
  # We didn't need all those primers anymore so selected only relevant 
  filter(primer_pair %in% c("LCO_HCO", "LCO_CFMRb", "fwhF2_fwhR2", "fwhF2_HCO", "AJHFwd1_dR")) %>%
  # Pivot function - column from which you will get your new columns, and the column with the values
  pivot_wider(names_from = primer_pair, values_from = band)

# Write the CSV
write.csv(pcr_pivot, "pcr_pivot.csv", row.names = F)

