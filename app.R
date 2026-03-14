library(shiny)
library(dplyr)
library(ggplot2)
library(readr)
library(lubridate)
library(bslib)


# Load data
mars_data <- read_csv("data/mars-weather.csv", show_col_types = FALSE) %>%
  mutate(
    terrestrial_date = as.Date(terrestrial_date)
  )

required_cols <- c(
  "terrestrial_date",
  "month",
  "min_temp",
  "max_temp",
  "pressure"
)

missing_cols <- setdiff(required_cols, names(mars_data))
if (length(missing_cols) > 0) {
  stop(
    paste(
      "Missing required columns in data/mars-weather.csv:",
      paste(missing_cols, collapse = ", ")
    )
  )
}


# Month choices
month_choices <- c("All", sort(unique(mars_data$month)))


# UI
ui <- page_fluid(
  theme = bs_theme(
    version = 5,
    bootswatch = "darkly"
  ),
  
  tags$head(
    tags$style(HTML("
      .app-title {
        text-align: center;
        font-weight: 800;
        font-size: 2.6rem;
        margin-bottom: 0.2rem;
        color: white;
      }

      .app-subtitle {
        text-align: center;
        color: #d9d9d9;
        margin-bottom: 1.5rem;
      }

      .kpi-card {
        background: rgba(255,255,255,0.06);
        border-radius: 14px;
        padding: 18px;
        text-align: center;
        margin-bottom: 16px;
      }

      .kpi-label {
        font-size: 0.95rem;
        color: #d9d9d9;
        margin-bottom: 8px;
      }

      .kpi-value {
        font-size: 1.8rem;
        font-weight: 700;
        color: white;
      }

      .main-bg {
        min-height: 100vh;
        padding: 24px;
        background-image: url('img/mars_bg.png');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
      }

      .plot-card {
        background: rgba(255,255,255,0.05);
        border-radius: 14px;
        padding: 12px;
        margin-bottom: 18px;
      }
    "))
  ),
  
  
  div(
    class = "main-bg",
    
    div(class = "app-title", "MarsCast R"),
    div(
      class = "app-subtitle",
      "A simplified Shiny for R reimplementation of the Mars weather dashboard"
    ),
    
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        
        selectInput(
          inputId = "month",
          label = "Martian Month",
          choices = month_choices,
          selected = "All"
        ),
        
        dateRangeInput(
          inputId = "date_range",
          label = "Terrestrial Date Range",
          start = min(mars_data$terrestrial_date, na.rm = TRUE),
          end = max(mars_data$terrestrial_date, na.rm = TRUE),
          min = min(mars_data$terrestrial_date, na.rm = TRUE),
          max = max(mars_data$terrestrial_date, na.rm = TRUE)
        )
      ),
      
      fillable = TRUE,
      
      layout_columns(
        col_widths = c(6, 6),
        
        div(
          class = "kpi-card",
          div(class = "kpi-label", "Average Minimum Temperature"),
          textOutput("avg_min_temp", container = div, class = "kpi-value")
        ),
        
        div(
          class = "kpi-card",
          div(class = "kpi-label", "Average Maximum Temperature"),
          textOutput("avg_max_temp", container = div, class = "kpi-value")
        )
      ),
      
      div(
        class = "plot-card",
        plotOutput("temp_trend_plot", height = "350px")
      ),
      
      div(
        class = "plot-card",
        plotOutput("pressure_scatter_plot", height = "350px")
      )
    )
  )
)


# Server
server <- function(input, output, session) {
  
  # Reactive filtered dataframe
  filtered_data <- reactive({
    df <- mars_data
    
    if (!is.null(input$month) && input$month != "All") {
      df <- df %>% filter(month == input$month)
    }
    
    if (!is.null(input$date_range) && length(input$date_range) == 2) {
      df <- df %>%
        filter(
          terrestrial_date >= as.Date(input$date_range[1]),
          terrestrial_date <= as.Date(input$date_range[2])
        )
    }
    
    df
  })
  
  # KPI: average minimum temperature
  output$avg_min_temp <- renderText({
    df <- filtered_data()
    
    if (nrow(df) == 0 || all(is.na(df$min_temp))) {
      return("N/A")
    }
    
    paste0(round(mean(df$min_temp, na.rm = TRUE), 2), " °C")
  })
  
  # KPI: average maximum temperature
  output$avg_max_temp <- renderText({
    df <- filtered_data()
    
    if (nrow(df) == 0 || all(is.na(df$max_temp))) {
      return("N/A")
    }
    
    paste0(round(mean(df$max_temp, na.rm = TRUE), 2), " °C")
  })
  
  # Plot 1: temperature trend over time
  output$temp_trend_plot <- renderPlot({
    df <- filtered_data()
    
    validate(
      need(nrow(df) > 0, "No data available for the selected filters.")
    )
    
    df_long_min <- df %>%
      select(terrestrial_date, value = min_temp) %>%
      mutate(type = "Minimum Temperature")
    
    df_long_max <- df %>%
      select(terrestrial_date, value = max_temp) %>%
      mutate(type = "Maximum Temperature")
    
    plot_df <- bind_rows(df_long_min, df_long_max)
    
    ggplot(plot_df, aes(x = terrestrial_date, y = value, color = type)) +
      geom_line(linewidth = 0.8, alpha = 0.9) +
      labs(
        title = "Temperature Trends Over Time",
        x = "Terrestrial Date",
        y = "Temperature (°C)",
        color = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        legend.position = "top"
      )
  })
  
  
  
  

