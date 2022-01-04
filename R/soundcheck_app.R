soundcheck_app <- function(settings,
                           wav_folder = 'wav',
                           labels_file = 'labels.csv',
                           verbose = TRUE){

  if(FALSE){ # code for debugging -- not run!
    wav_folder = 'wav'
    labels_file = 'labels.csv'
    verbose = TRUE

    # Test it
    settings2 <- soundcheck_settings(
      labels = list(names=c('Target_species',
                            'Anthropogenic_noise',
                            'Third_thing',
                            'Fourth_thing'),
                    options=list(c('Not present','Present', 'Not sure'),
                                 c('Not present', 'Present', 'Not sure'),
                                 c('Who cares','Whatever','Why me'),
                                 c('Seriously','Infinite jest'))))

    soundcheck_app(settings = settings2,
                   wav_folder = 'wav',
                   labels_file = 'labels.csv')

  }

  ##############################################################################
  # Process settings

  ok2launch <- TRUE

  settings

  # Prepare list of WAV files
  (wavs <- dir(wav_folder, all.files=FALSE))
  (wavs <- wavs[grep('wav',wavs)])
  (wavs <- paste0(wav_folder,'/',wavs))
  if(length(wavs)==0){
    stop('No WAV files found! Stopping here.\n  Double check your working directory / `wav_folder` argument, then try again.')
  }

  # Make sure the labels file is a CSV
  if(length(grep('csv',labels_file))==0){
    stop('Wait! The labels file you specified is not a CSV.\n  Stopping here!\n  Provide a full filename for a CSV file.')
  }

  # Save the list of analysts as its own object
  analysts <- settings$analysts
  if(settings$na_default){(analysts <- c("N/A",analysts))}

  # Save the list of label categories/options as its own object
  (cats <- settings$labels)
  if(settings$na_default){
    cats$options <- lapply(cats$options,function(x){c("N/A",x)})
  }

  # Create vector of columns expected in the labels file
  (result_columns <- tolower(c('wav',
                       gsub(' ','_',cats$names),
                       'analyst','datetime','comment')))

  # If the labels file already exists, make sure it has the right number of columns
  if(file.exists(labels_file)){
    if(file.size(labels_file) > 1){
      df <- read.csv(labels_file)
      if(nrow(df)>0){
        if(length(names(df)) != length(result_columns)){
          stop('Wait! Labels file is non-empty but has a different number of labels columns.\n  Stopping here!\n  Reconcile your settings with your existing labels file, or provide a name to a different/new label .csv')
        }
      }
    }
  }

  if(!file.exists(labels_file)){
    file.create(labels_file)

    # Add column names
    cat(paste(result_columns,collapse=','),
        file=labels_file,
        sep='\n',
        append=TRUE)
  }

  if(TRUE){
    ##############################################################################
    ##############################################################################
    ##############################################################################
    # UI

    ui <- shiny::shinyUI(
      tagList( #needed for shinyjs
        shinyjs::useShinyjs(),  # Include shinyjs
        rintrojs::introjsUI(),   # Required to enable introjs scripts
        shiny::navbarPage(id = "intabset", #needed for landing page
                          title = 'Soundcheck',
                          windowTitle = "Soundcheck", #title for browser tab
                          theme = shinythemes::shinytheme("cerulean"), #Theme of the app (blue navbar)
                          collapsible = TRUE #tab panels collapse into menu in small screens
        ),
        shiny::mainPanel(width = 10, style="margin-left:4%; margin-right:4%",
                         ##############################################################################
                         ##############################################################################

                         shiny::fluidRow(column(3,selectInput('analyst','Select analyst',
                                                              choices=analysts, selected = analysts[1])),
                                         column(3,selectInput('filter','Filter file list?',
                                                              choices=c('All','Not yet labeled','Already labeled'), selected='All',width='95%')),
                                         column(2,textOutput('files_counted')),
                                         column(2,textOutput('files_labeled')),
                                         column(2,textOutput('files_staged'))),
                         shiny::br(),
                         shiny::fluidRow(column(1),column(11,textOutput('current_filename'))),
                         shiny::uiOutput('spectrogram_row'),
                         shiny::fluidRow(column(1), column(11,helpText('Double-click anywhere on spectrogram to play sound from that point; double-click again to stop.'))),
                         shiny::br(),
                         shiny::fluidRow(shiny::uiOutput('labels_row')),
                         shiny::fluidRow(column(12,shiny::textInput('comment','Comment? (optional):',width='100%'))),
                         shiny::fluidRow(column(5,actionButton('save_next',h4('Save & Next'),width='100%')),
                                         column(2,actionButton('skip',h5('Skip'),width='100%')),
                                         column(2,actionButton('back',h5('Back'),width='100%')),
                                         column(3,uiOutput('manual_select'))),
                         shiny::uiOutput('previous_label_row'),
                         shiny::hr(),
                         shiny::fluidRow(column(4,shiny::sliderInput('speed','Playback speed', min=0.1,max=10,value=1,step=.1,width='95%')),
                                         column(4,'ff sensitivity'),
                                         column(4,'fft resolution')),
                         shiny::br(),
                         shiny::fluidRow(column(3,'freq min'),
                                         column(3,'freq max'),
                                         column(3,'window length'),
                                         column(3,'timestamp size')),
                         shiny::hr(),
                         shiny::fluidRow(column(12,DT::dataTableOutput('df'))),
                         shiny::br()

                         ##############################################################################
                         ##############################################################################
        ),
        div(style = "margin-bottom: 30px;"), # this adds breathing space between content and footer
        tags$footer(column(6, "© Eric Keen and Ben Hendricks"),
                    style = "
   position:fixed;
   text-align:center;
   left: 0;
   bottom:0;
   width:100%;
   z-index:1000;
   height:30px; /* Height of the footer */
   color: white;
   padding: 10px;
   background-color: #1995dc"
        )
      )
    )

    ##############################################################################
    ##############################################################################
    ##############################################################################
    # Server

    server <- function(input, output, session) {

      # Reactive values ==========================================================

      rv <- reactiveValues()
      rv$wav_files <- wavs # list of viable wav files
      rv$wav_file <- NULL # wav_file selected
      rv$wav <- NULL # wav object
      rv$i <- 1 # index of selected wav file
      rv$play <- NULL
      rv$df <- read.csv(labels_file,stringsAsFactors=FALSE)
      rv$df_trigger <- 0

      # File navigation ========================================================

      # WAV file options
      observe({
        df <- rv$df
        filter_op <- input$filter
        #print(filter_op)

        wavs_raw <- wavs
        #print(wavs_raw)

        if(filter_op == 'Already labeled'){
          if(nrow(df)>0){
            keeps <- which(wavs_raw %in% df$wav)
            if(length(keeps)>0){
              wavs_raw <- wavs_raw[keeps]
            }else{
              wavs_raw <- c()
            }
          }
        }

        if(filter_op == 'Not yet labeled'){
          if(nrow(df)>0){
            keeps <- which(! wavs_raw %in% df$wav)
            if(length(keeps)>0){
              wavs_raw <- wavs_raw[keeps]
            }else{
              wavs_raw <- c()
            }
          }
        }

        if(length(wavs_raw) > 0){
          rv$wav_files <- wavs_raw
        }else{
          showModal(modalDialog(title="No more sounds to label!",
                                "(According to your filter settings). Showing you all the files in your WAV folder...",
                                size="m",easyClose=TRUE))
          rv$wav_files <- wavs
          isolate({updateSelectInput(session,'filter',selected='All')})
        }

        # Update index if needed
        if(rv$i > length(rv$wav_files)){rv$i <- length(rv$wav_files)}
        rv$wav_file <- rv$wav_files[rv$i]

        #print(rv$wav_files)
      })

      output$manual_select <- renderUI({
        selectInput('manual_select',
                    'Manually select a file:',
                    choices = rv$wav_files,
                    selected = rv$wav_files[which(rv$wav_files %in% rv$wav_file)],
                    width='100%')
      })

      observeEvent(input$manual_select,{
        rv$i <- which(rv$wav_files %in% input$manual_select)
      })

      # Index of wav file selected
      observeEvent(rv$i,{
        isolate({
          i <- rv$i
          wav_files <- rv$wav_files
          rv$wav_file <- wav_files[i]
          #print(rv$wav_file)

          # Update selectInputs each time you navigate
          lapply(1:length(cats$names),
                 function(x){
                   isolate({updateSelectInput(session,
                                              paste0('cat_',cats$names[x]),
                                              selected=cats$options[[x]][1])})
                 }
          )
          isolate({updateTextInput(session, 'comment',value='')})

          # Turn off playback, if a sound is playing
          if(!is.null(rv$play)){rv$play <- audio::pause(rv$play) ; rv$play <- NULL}
        })
      })

      observeEvent(input$save_next,{
        isolate({
          if(input$analyst == 'N/A'){
            showModal(modalDialog(title="Select an analyst name first!",
                                  "Silly goose!",
                                  size="m",easyClose=TRUE))
          }else{
            # Gather labels for the output line
            inputs <- reactiveValuesToList(input) # get list of all inouts
            catinputs <- grep('cat_',names(inputs)) # indices for inputs pertaining to labels
            df_labels <- c() # concatenate these labels into a character vector
            for(i in catinputs){
              df_labels <- c(df_labels, inputs[[i]])
            }

            if(any(df_labels == 'N/A')){
              showModal(modalDialog(title="You have to make a decision for each label!",
                                    "Are you a pelican, or a pelican't???",
                                    size="m",easyClose=TRUE))
            }else{
              df_labels <- paste(df_labels,collapse=',') # collapse this vector, sep by comma
              #print(df_labels)

              # Prepare output to save
              df_line <- paste(c(rv$wav_file,
                                 df_labels,
                                 input$analyst,
                                 as.character(Sys.time()),
                                 gsub(',',';',input$comment)),
                               collapse=',')
              #print(df_line)

              # Write output to labels_file
              cat(df_line, file=labels_file, sep='\n', append=TRUE)

              # Re-read the labels_file
              rv$df <- read.csv(labels_file,stringsAsFactors=FALSE)

              # Navigate
              if(input$filter == 'All'){
                rv$i <- ifelse(rv$i == length(rv$wav_files), 1, rv$i+1)
              }
            }
          }
        })
      })

      observeEvent(input$skip,{
        isolate({
          if(rv$i == length(rv$wav_files)){
            showModal(modalDialog(title="You have reached the end of the file set!",
                                "Bringing you back to the first file...",
                                size="m",easyClose=TRUE))
          }
          rv$i <- ifelse(rv$i == length(rv$wav_files), 1, rv$i+1)
        })
      })

      observeEvent(input$back,{
        isolate({
          rv$i <- ifelse(rv$i == 1, length(rv$wav_files), rv$i-1)
        })
      })

      # Spectrogram ============================================================

      output$spectrogram_row <- shiny::renderUI({
        wav_file <- rv$wav_file
        (ok_test <- !is.null(wav_file))
        if(ok_test){(ok_test <- file.exists(wav_file))}
        if(ok_test){
          # Read in wav file
          lw <- audio::load.wave(wav_file)
          wav_duration <- length(lw) / (2*lw$rate)
          #wav_duration <- 15

          if(wav_duration > 30){
            fluidRow(column(12,
                            plotOutput("spectrogram", height="200px",
                                       dblclick = "dbl")))
          }else{
            secs <- 1:30
            cols <- seq(3,10,length=length(secs))
            fft_col <- ceiling(cols[which.min(abs(wav_duration - secs))]) ; fft_col
            side_col <- floor((12 - fft_col) / 2) ; side_col
            fft_col <- 12 - 2*side_col ; fft_col
            if(side_col < 1){side_col <- 1}
            if(fft_col > 10){fft_col <- 10}

            fluidRow(column(side_col),
                     column(fft_col,
                            plotOutput("spectrogram", height="200px",
                                       dblclick = "dbl")),
                     column(side_col))
          }
        }
      })

      output$spectrogram <- renderPlot({
        wav_file <- rv$wav_file
        #wav_file <- 'demo.wav'
        (ok_test <- !is.null(wav_file))
        if(ok_test){(ok_test <- file.exists(wav_file))}
        if(ok_test){
          # Read in wav file
          wav <- tuneR::readWave(filename=wav_file)

          # Handle settings
          ylim <- c(200,900)

          # Display spectrogram
          par(mfrow=c(1,1), mar=c(4.2,4.2,.1,.5))
          Spectrogram( Audio=wav,
                       SamplingFrequency=NULL,
                       WindowLength = 350,
                       FrequencyResolution = 4,
                       TimeStepSize = .25*350,
                       nTimeSteps = NULL,
                       Preemphasis = TRUE,
                       DynamicRange = 40,
                       Omit0Frequency = FALSE,
                       WindowType = "hamming",
                       WindowParameter = NULL,
                       plot = TRUE,
                       PlotFast = TRUE,
                       add = FALSE,
                       col = NULL,
                       xlim = NULL,
                       ylim = ylim,
                       xlab = "Time (ms)",
                       ylab = "Frequency (Hz)")
        }
      })


      # Playback =================================================================

      observeEvent(input$dbl,{
        isolate({
          if(is.null(rv$play)){
             if(!is.null(rv$wav_file)){

              # Load wav file for playback
              wav_file <- rv$wav_file
              #wav_file <- 'wav/demo-4.wav'
              lw <- audio::load.wave(wav_file)

              # Get sample rate
              sr <- lw$rate * 2
              sr

              # Determine start position based on double click
              x <- input$dbl$x
              (ms_start <- (x/1000)*sr) # start position in milleseconds
              # Subset wav object according to start position
              lw_sub <- lw[ms_start:min(c(length(lw), ms_start + (10*sr)))]

              # Adjust sample rate based on playback speed
              playback_speed <- input$speed
              sr_playback <- sr*playback_speed

              # Playback
              rv$play <- audio::play(lw_sub, rate = sr_playback)

              #pause(playback)
              print(input$dbl)
            }
          }else{
            rv$play <- audio::pause(rv$play)
            rv$play <- NULL
          }
        })
      })

      # Dynamic UI outputs =======================================================

      output$files_counted <- renderText({HTML(paste0(length(wavs),' file(s) in /',wav_folder))})

      output$files_staged <- renderText({HTML(paste0(length(rv$wav_files),' file(s) staged for labeling.'))})

      output$files_labeled <- renderText({
        if(nrow(rv$df)>0){
          HTML(paste0(length(unique(rv$df$wav)),' file(s) already labeled.'))
        }else{
          HTML(paste0('No labels yet!'))
        }
      })

      output$current_filename <- renderText({ rv$wav_file})

      output$labels_row <- shiny::renderUI({
        colwidth <- floor(12 / length(cats$names))
        lapply(1:length(cats$names),
               function(x){
                 shiny::column(colwidth,shiny::selectInput(paste0('cat_',cats$names[x]),
                             label=cats$names[x],
                             choices=cats$options[[x]],
                             selectize=FALSE,
                             size=length(cats$options[[x]])))
               })
      })

      output$previous_label_row <- shiny::renderUI({
        shiny::fluidRow(column(12,'previous_label_row'))
      })

      output$df <- DT::renderDataTable(rv$df %>% dplyr::arrange(desc(datetime)))
    }

    ##############################################################################
    ##############################################################################
    ##############################################################################
    # Run app
    shiny::shinyApp(ui = ui, server = server)
  }
}
