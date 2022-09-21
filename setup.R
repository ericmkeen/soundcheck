# Super quick load (no install)
library(devtools) ; document() ; load_all()

# Quick install
#library(devtools) ; remove.packages(hyfer) ; document() ; install() ; library(soundcheck)

# Full load and check
#library(devtools) ; document() ; load_all() ; check() ; install() ; library(soundcheck)

# Create package environment

#library(devtools)
getwd()
#setwd('../')
getwd()
#create_package('/Users/erickeen/repos/shipstrike')

# Import packages
library(usethis)
if(FALSE){
  use_package('magrittr')
  use_package('dplyr')
  use_package('readr')
  use_package('stringr')
  use_package('lubridate')
  use_package('usethis')
  use_package('devtools')
  use_package('shiny')
  use_package('shinyjs')
  use_package('shinydashboard')
  use_package('shinythemes')
  use_package('rintrojs')
  use_package('DT')
  use_package('wesanderson')
}
use_pipe()
#### Try it out


# Install soundcheck
library(devtools)
devtools::install_github('ericmkeen/soundcheck')
library(soundcheck)

# Before using your own data, confirm the package works on your machine by using our demo data:
# Download the `wav` folder in this repo, unzip it, and place it in your working directory.

# Now prepare settings
settings <- soundcheck_settings()
settings
# If you do not wish to use defaults, modify this call using the documentation (`?soundcheck_settings`)

# Launch the app
soundcheck_app(settings)
# For details and step-by-step instructions, see `?soundcheck_app`

#document()

# Bubble net feeding call (40 seconds) =========================================
# good for demo 1

settings <-
  soundcheck_settings(
    frequency_min = 200,
    frequency_max = 900,
    window_length = 206, #512,
    frequency_resolution = 4,
    overlap = 0.2, #3,
    dynamic_range = 40,
    window_type = "hamming"
  )

soundcheck_app(settings)


# Human voice ======================================================
# demos 2 (4 sec), 3 (10 sec), and 4 (20 sec)

settings <-
  soundcheck_settings(
    frequency_min = 100,
    frequency_max = 3500,
    window_length = 100,
    frequency_resolution = 4,
    overlap = 0.2,
    dynamic_range = 40,
    window_type = "hamming"
  )

soundcheck_app(settings, wav_start = 2)

# Fin whale =========================================================
# demos 5 (2 mins)

settings <-
  soundcheck_settings(
    frequency_min = 0,
    frequency_max = 300,
    window_length = 206,
    frequency_resolution = 1,
    overlap = 0.5,
    dynamic_range = 40,
    window_type = "hamming"
  )

soundcheck_app(settings, wav_start = 5)

# Killer whales ======================================================
# demo 6 (53 sec)

settings <-
  soundcheck_settings(
    frequency_min = 1000,
    frequency_max = 6000,
    window_length = 100,
    frequency_resolution = 2,
    overlap = 0.9,
    dynamic_range = 40,
    window_type = "hamming"
  )

soundcheck_app(settings, wav_start = 6)

# Reviewing large files ==============================================
# demo 7

settings <-
  soundcheck_settings(
    frequency_min = 100,
    frequency_max = 6000,
    window_length = 100,
    frequency_resolution = 1,
    overlap = 1,
    dynamic_range = 40,
    window_type = "hamming"
  )

soundcheck_app(settings, wav_start = 7)

