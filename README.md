# soundcheck
Efficiently annotate a batch of sound files using a Shiny-based spectrogram app

### Install remotely from `GitHub`:
```
library(devtools)
devtools::install_github('ericmkeen/soundcheck')
library(soundcheck)
```
### Try it out

1. Before using your own data, confirm the package works on your machine by using our demo data:
Download the `wav` folder in this repo, unzip it, and place it in your working directory.
It contains four demo files, each of decreasing length (~45 seconds long to ~4 seconds; 44.1 kHz sample rate).

2. Prepare settings for your work session:  

```
settings <- soundcheck_settings()
```

This command will load the default settings (see `?soundcheck_settings` for details). 

3. Launch the app:  

```
soundcheck_app(settings)
```

4. Read detailed instructions for use in `?soundcheck_app`.  


