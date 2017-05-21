library(shiny)
library(plotly)
library(ggplot2)
library(shinythemes)
library(shinyBS)

# Shiny does this weird thing where when files are uploaded, it changes
# the name of them. This function fixes that. 
fixUploadedFilesNames <- function(x) {
    if (is.null(x)) return()
    oldNames <- x$datapath
    newNames <- file.path(dirname(x$datapath), x$name)
    file.copy(from = oldNames, to = newNames)
    x$datapath <- newNames
    x
}