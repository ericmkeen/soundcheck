#' Stage settings for SoundCheck app
#'
#' @param analysts desc
#' @param labels desc
#' @param na_default desc
#' @param frequency_min desc
#' @param frequency_max desc
#' @param window_length desc
#' @param frequency_resolution desc
#' @param overlap desc
#' @param timestep_size desc
#' @param dynamic_range desc
#' @param window_type desc
#' @param window_parameter desc
#'
#' @return
#' @export
#'
soundcheck_settings <- function(analysts = c('Ben','Eric','Other'),
                                labels = list(names=c('Target_species', 'Anthropogenic_noise'),
                                              options=list(c('Not present','Present', 'Not sure'),
                                                           c('Not present', 'Present', 'Not sure'))
                                              ),
                                na_default = TRUE,
                                frequency_min = 0,
                                frequency_max = 4000,
                                window_length = 5,
                                frequency_resolution = NULL,
                                overlap = NULL,
                                timestep_size = NULL,
                                dynamic_range = NULL,
                                window_type = NULL,
                                window_parameter = NULL){

  settings <- as.list(environment())

  return(settings)
}
