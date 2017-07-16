#
# A small demo app for the shinydrawr function
#
# devtools::install_github("nstrayer/shinysense")

library(shiny)
library(shinysense)
library(tidyverse)

ui <- fluidPage(
    shinydrawrUI(id = "outbreak_stats")
)

server <- function(input, output) {
    
    random_data <- tibble(
        time = 1:30, 
        metric = time*sin(time/6) + rnorm(30)
    )
 
    # call drawr module
    draw_chart <- callModule(
        module = shinydrawr, 
        id = "outbreak_stats",
        data = random_data, 
        draw_start = 15, 
        x_key = "time", 
        y_key = "metric", 
        y_max = 20)
}

shinyApp(ui, server)