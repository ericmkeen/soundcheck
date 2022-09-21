# `soundcheck`
Efficiently annotate a batch of sound files using a Shiny-based spectrogram app.

### Install remotely from `GitHub`:
```
library(devtools)
devtools::install_github('ericmkeen/soundcheck')
library(soundcheck)
```
### Try it out

1. Before using your own data, confirm the package works on your machine by using our demo data: download the `wav` folder from this repo, unzip it, place it in your working directory, and make sure its name is precisely `wav`. It contains seven demo files, each of decreasing length (~45 seconds long to ~4 seconds; 44.1 kHz sample rate).

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

### Settings demo

Each `.wav` demo file represents a different use case. Here we provide recommended settings for each. 

#### Demo 1: Bubble net feeding calls

This sound file (44.1 kHz stereo, 16 bits per sample, 40 sec) contains tonal humpback whale calls occurring between 400 and 600 Hz. 

```
settings <-
  soundcheck_settings(
    frequency_min = 200,
    frequency_max = 900,
    window_length = 206, 
    frequency_resolution = 4,
    overlap = 0.2, #3,
    dynamic_range = 40,
    window_type = "hamming"
  )

soundcheck_app(settings)
```

#### Demos 2 - 4: Human voice

These files of a male human voice are 4s, 10s, and 20s in duration. All are 44.1 kHz stereo at 16 bits per sample.

```
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
```

#### Demo 5: Fin whale song

Fin whales have very-low frequency songs (18 - 60 Hz) that typically require increased playback speeds to hear. This file is 64 kHz, mono, 16 bits per sample, and 54 sec. 

```
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
```

#### Demo 6: Orca calls 

Killer whales produce tonal calls in the approximate range of 500 Hz to 8 kHz, as well as broadband echolocation clicks and higher-frequency whistles. This file is 64 kHz, mono, 16 bits per sample, and 53 sec.

```
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
```

#### Demo 7: Passive acoustic monitoring 

This is a 5-minute file of passive acoustic monitoring, featuring orca calls (64 kHz, mono, 16 bits per sample).  

```
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
```

### Customizing the app

The `Soundcheck` app was designed to have customizable features. The `soundcheck_settings()` function can be used not only to define default spectrogram display settings, but also to customize/add/remove label categories.   

The defaults for `soundcheck_settings()` will create an app with only two label categories: `"Target_species"` and `"Anthropogenic_noise"`. These labels are defined in the function's input `labels` as a named list, like so: 

```
settings <-
  soundcheck_settings(
    labels = list(Target_species = c('Not present','Present', 'Not sure'),
                  Anthropogenic_noise = c('Not present','Present', 'Not sure')
                  )
  )
```

But you can define whatever labels you want using the `labels` input. For example, say you want to process sound files by noting whether humans, dogs, and/or cats are present in the recordings. To do so, you can prepare settings like this: 

```
settings <-
  soundcheck_settings(
    labels = list(Humans = c('Not present','Present', 'Not sure'),
                  Dogs = c('Constant barking','Low-confidence woofs', 'Not sure'),
                  Cats = c('Everywhere!', 'Lurking in the shadows', 'Not sure')
                 )
  )
```

Each label category you define will become the name of a column in your `labesl.csv` file. 
The app layout typically handles up to five label categories well without getting two scrunched. 

