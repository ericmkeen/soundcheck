# Super quick load (no install)
library(devtools) ; document() ; load_all()

# Quick install
#library(devtools) ; remove.packages(hyfer) ; document() ; install() ; library(soundcheck)

# Full load and check
#library(devtools) ; document() ; load_all() ; check() ; install() ; library(soundcheck)

# Create package environment

#library(devtools)
#setwd('../')
#getwd()
#create_package('/Users/erickeen/repos/soundcheck')

# Import packages
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

#### Try it out


# Install soundcheck
library(devtools)
devtools::install_github('ericmkeen/soundcheck', force=TRUE, quiet=TRUE)
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











