# packages
library(tidyverse)
library(glue)
library(lubridate)


# ------------------------------
# Variable   Columns   Type
# ------------------------------
# ID            1-11   Character
# YEAR         12-15   Integer
# MONTH        16-17   Integer
# ELEMENT      18-21   Character
# VALUE1       22-26   Integer
# MFLAG1       27-27   Character
# QFLAG1       28-28   Character
# SFLAG1       29-29   Character
# VALUE2       30-34   Integer
# MFLAG2       35-35   Character
# QFLAG2       36-36   Character
# SFLAG2       37-37   Character
#   .           .          .
#   .           .          .
#   .           .          .
# VALUE31    262-266   Integer
# MFLAG31    267-267   Character
# QFLAG31    268-268   Character
# SFLAG31    269-269   Character
# ------------------------------

# read_table("data/ghcnd_all/ASN00008255.dly")
# read_tsv("data/ghcnd_all/ASN00008255.dly")

# first, let's create the arguments to pass in the fwf_widths()
widths <- c(11, 4, 2, 4, rep(c(5,1,1,1), 31))
# let´s check
length(widths)
sum(widths) # matches with SFLAG31 269

# create the quadruplets
# create a function for the quadruplets
quadruplets <- function(x){
c(glue("VALUE{x}"),glue("MFLAG{x}"),glue("QFLAG{x}"),glue("SFLAG{x}")) 
}
# checking
quadruplets(23)
# use purrr
map(1:31, quadruplets) %>% unlist()

# put the quadruplets with the other headers
# headers
headers <- c("ID", "YEAR", "MONTH", "ELEMENT", map(1:31, quadruplets) %>% unlist()) # nolint

# create a vector with the files that we are interested in
dly_files <- list.files("data/ghcnd_all", full.names = T)


# parse thee data based on fixed widths
df <- read_fwf(dly_files, 
        fwf_widths(widths, headers), 
        na = c("NA", "-9999"), 
        col_types = cols(.default = col_character()),
        col_select = c(ID, YEAR, MONTH, ELEMENT, starts_with("VALUE"))) %>%
    rename_all(tolower) %>%
    filter(element == "PRCP") %>%
    select(-element) %>%
    # remove dates with NA (february)
    drop_na() %>% 
    pivot_longer(cols = starts_with("value"), names_to = "day", values_to = "prcp") %>%
    mutate(day = str_replace(day, "value", ""),
    date = ymd(glue("{year}-{month}-{day}")),
    prcp = as.numeric(prcp)/100) # prcp now in cm (before = tenths of mm)


limits <- as.Date(c("1950-10-15", "1960-10-15"))

df %>% ggplot(aes(x = date, y = prcp)) +
geom_bar(stat = "identity") +
scale_x_date(limits = limits) +
  xlab("Time") + ylab("Precipitation (cm)") +
  ggtitle("Daily Total Precipitation") 
