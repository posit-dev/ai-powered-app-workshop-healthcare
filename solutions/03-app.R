# Note: Move this file into your main directory before previewing. 
# The filepaths used below will not work if you keep it in the 
# solutions/ directory.

library(shiny)
library(bslib)
library(tidyverse)
library(leaflet)
library(sf)
library(tigris)
library(DT)

# Load data and helpers
georgia_cases <- readRDS("georgia_cases.RDS")
source("helpers.R")
site_levels <- sort(unique(georgia_cases$Site))

ui <- page_sidebar(
  title = "2025 Cancer Incidence Rates in Georgia",
  sidebar = sidebar(
    selectInput(
      "site",
      "Filter by Cancer Site",
      choices  = site_levels,
      selected = site_levels[1]
    )
  ),
  layout_columns(
    col_widths = c(6, 6),
    card(
      full_screen = TRUE,
      card_header("Map"),
      leafletOutput("map", height = "100%")
    ),
    layout_columns(
      col_widths = c(12, 12),
      card(
        card_header("Incidence by Race/Ethnicity"),
        plotOutput("plot", height="150px")
      ),
      card(
        card_header("Data"),
        full_screen = TRUE,
        DTOutput("table")
      )
    )
  )
)

server <- function(input, output, session) {

  filtered <- reactive({
    req(input$site)
    georgia_cases |>
      filter(Site %in% input$site)
  })

  output$map <- renderLeaflet({
    create_incidence_map(filtered(), rate = TRUE)
  })

  output$plot <- renderPlot({
    plot_incidence_by_demographic(filtered(), RE)
  })

  output$table <- renderDT({
    datatable(filtered(), options = list(pageLength = 10, bPaginate = TRUE, dom = 'ltipr'))
  })
}

shinyApp(ui, server)
