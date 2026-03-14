library(shiny)
library(dplyr)
library(ggplot2)
library(readr)

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

latest_date <- max(mars_data$terrestrial_date, na.rm = TRUE)
latest_row <- mars_data %>%
  filter(terrestrial_date == latest_date) %>%
  slice(1)

latest_martian_month <- latest_row$month[[1]]

month_values <- sort(unique(mars_data$month))

if (is.numeric(month_values)) {
  month_choices <- c("All", paste("Month", month_values))
  latest_month_label <- paste("Month", latest_martian_month)
} else {
  month_choices <- c("All", as.character(month_values))
  latest_month_label <- as.character(latest_martian_month)
}

normalize_month_col <- function(x) {
  if (is.numeric(x)) {
    paste("Month", x)
  } else {
    as.character(x)
  }
}

# UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      html, body {
        margin: 0;
        padding: 0;
        min-height: 100%;
        font-family: Arial, Helvetica, sans-serif;
        background: #000;
      }

      .main-bg {
        min-height: 100vh;
        padding: 20px 24px 36px 24px;
        background-image: url('mars_bg.png');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
      }

      .title-main {
        text-align: center;
        color: #FFFFFF;
        font-size: 4rem;
        font-weight: 900;
        margin: 0;
        letter-spacing: 1px;
        text-shadow: 0 2px 12px rgba(0,0,0,0.9), 0 0 40px rgba(220,80,20,0.7);
      }

      .subtitle-main {
        text-align: center;
        color: rgba(255,205,160,0.95);
        font-weight: 400;
        font-size: 1.15rem;
        margin: 2px 0 14px 0;
        text-shadow: 0 1px 8px rgba(0,0,0,0.8);
        letter-spacing: 0.3px;
      }

      .top-rule {
        border: none;
        height: 1px;
        background: linear-gradient(to right, transparent, rgba(210,85,30,0.7), transparent);
        border-radius: 999px;
        margin: 10px auto 18px auto;
        max-width: 1200px;
      }

      .filter-card {
        background-color: rgba(18,5,5,0.78);
        box-shadow: 0px 8px 24px rgba(0,0,0,0.55);
        border-radius: 20px;
        padding: 12px 14px;
        border: 1px solid rgba(210,85,30,0.45);
        backdrop-filter: blur(6px);
        min-height: 108px;
        margin-bottom: 16px;
        overflow: visible !important;
      }

      .filter-title {
        text-align: center;
        color: #FFAD70;
        font-weight: 700;
        font-size: 0.92rem;
        margin: 0 0 10px 0;
        text-transform: uppercase;
        letter-spacing: 0.8px;
      }

      .filter-inner {
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .filter-inner .form-group {
        width: 100%;
        max-width: 420px;
        margin-bottom: 0 !important;
      }

      .filter-inner select.form-control {
        text-align-last: center;
        -moz-text-align-last: center;
        min-height: 44px;
        border-radius: 10px !important;
      }

      .date-wrap {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 44px;
      }

      .date-wrap .form-group {
        margin-bottom: 0 !important;
        width: 100%;
      }

      .date-wrap .input-daterange {
        display: flex;
        justify-content: center;
      }

      .date-wrap input {
        text-align: center;
      }

      .kpi-card {
        background-color: rgba(10,2,2,0.85);
        box-shadow: 0px 8px 24px rgba(0,0,0,0.55);
        border-radius: 36px;
        padding: 14px 12px;
        min-height: 104px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        border: 1px solid rgba(210,85,30,0.5);
        backdrop-filter: blur(6px);
        margin-bottom: 16px;
      }

      .kpi-label {
        color: #FFAD70;
        font-weight: 600;
        font-size: 0.82em;
        text-align: center;
        margin: 0 0 6px 0;
        letter-spacing: 0.6px;
        text-transform: uppercase;
      }

      .kpi-value {
        color: #FFE8D0;
        font-weight: 700;
        font-size: 1.55rem;
        line-height: 1.1;
        text-align: center;
        margin: 0;
        text-shadow: 0 1px 6px rgba(0,0,0,0.6);
      }

      .chart-shell {
        margin-top: 10px;
        background-color: rgba(10,2,2,0.60);
        box-shadow: 0px 10px 22px rgba(0,0,0,0.4);
        border-radius: 28px;
        padding: 18px;
        border: 1px solid rgba(210,85,30,0.35);
        backdrop-filter: blur(4px);
      }

      .plot-card {
        background-color: rgba(14,4,4,0.82);
        box-shadow: 0px 8px 24px rgba(0,0,0,0.55);
        border-radius: 18px;
        padding: 12px;
        border: 1px solid rgba(210,85,30,0.4);
        backdrop-filter: blur(6px);
        margin-bottom: 18px;
      }

      .shiny-date-input .input-group-addon,
      .input-daterange .input-group-addon {
        background-color: #f8f8f8 !important;
        color: #333 !important;
      }
    "))
  ),

  div(
    class = "main-bg",

    h1("MarsCast", class = "title-main"),
    div("Weather Patterns from The Red Planet", class = "subtitle-main"),
    hr(class = "top-rule"),

    fluidRow(
      column(
        6,
        div(
          class = "filter-card",
          div("Martian Month", class = "filter-title"),
          div(
            class = "filter-inner",
            selectInput(
              "month",
              NULL,
              choices = month_choices,
              selected = latest_month_label,
              selectize = FALSE
            )
          )
        )
      ),
      column(
        6,
        div(
          class = "filter-card",
          div("Terrestrial Date", class = "filter-title"),
          div(
            class = "date-wrap",
            dateRangeInput(
              "date_range",
              NULL,
              start = min(mars_data$terrestrial_date, na.rm = TRUE),
              end = max(mars_data$terrestrial_date, na.rm = TRUE),
              min = min(mars_data$terrestrial_date, na.rm = TRUE),
              max = max(mars_data$terrestrial_date, na.rm = TRUE)
            )
          )
        )
      )
    ),

    fluidRow(
      column(
        6,
        div(
          class = "kpi-card",
          div("Avg Min Temperature", class = "kpi-label"),
          div(class = "kpi-value", textOutput("avg_min_temp"))
        )
      ),
      column(
        6,
        div(
          class = "kpi-card",
          div("Avg Max Temperature", class = "kpi-label"),
          div(class = "kpi-value", textOutput("avg_max_temp"))
        )
      )
    ),

    div(
      class = "chart-shell",
      fluidRow(
        column(
          12,
          div(class = "plot-card", plotOutput("temp_trend_plot", height = "360px"))
        )
      ),
      fluidRow(
        column(
          12,
          div(class = "plot-card", plotOutput("pressure_scatter_plot", height = "360px"))
        )
      )
    )
  )
)


# Server
server <- function(input, output, session) {

  filtered_data <- reactive({
    df <- mars_data %>%
      mutate(month_label = normalize_month_col(month))

    if (!is.null(input$month) && input$month != "All") {
      df <- df %>% filter(month_label == input$month)
    }

    if (!is.null(input$date_range) && length(input$date_range) == 2) {
      start <- as.Date(input$date_range[1])
      end <- as.Date(input$date_range[2])

      df <- df %>%
        filter(
          terrestrial_date >= start,
          terrestrial_date <= end
        )
    }

    df
  })

  series_data <- reactive({
    filtered_data() %>%
      group_by(terrestrial_date) %>%
      summarise(
        min_temp = mean(min_temp, na.rm = TRUE),
        max_temp = mean(max_temp, na.rm = TRUE),
        .groups = "drop"
      )
  })

  output$avg_min_temp <- renderText({
    df <- filtered_data()

    if (nrow(df) == 0 || all(is.na(df$min_temp))) {
      return("N/A")
    }

    paste0(round(mean(df$min_temp, na.rm = TRUE), 2), " °C")
  })

  output$avg_max_temp <- renderText({
    df <- filtered_data()

    if (nrow(df) == 0 || all(is.na(df$max_temp))) {
      return("N/A")
    }

    paste0(round(mean(df$max_temp, na.rm = TRUE), 2), " °C")
  })

  output$temp_trend_plot <- renderPlot({
    df <- series_data()

    validate(
      need(nrow(df) > 0, "No data available for the selected filters.")
    )

    plot_df <- bind_rows(
      df %>%
        select(terrestrial_date, value = min_temp) %>%
        mutate(type = "Minimum Temperature"),
      df %>%
        select(terrestrial_date, value = max_temp) %>%
        mutate(type = "Maximum Temperature")
    )

    ggplot(plot_df, aes(x = terrestrial_date, y = value, color = type)) +
      geom_line(linewidth = 1) +
      scale_color_manual(values = c(
        "Minimum Temperature" = "#FFAD70",
        "Maximum Temperature" = "#C1440E"
      )) +
      labs(
        title = "Temperature Trends Over Time",
        x = "Terrestrial Date",
        y = "Temperature (°C)",
        color = NULL
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        legend.position = "top"
      )
  })

  output$pressure_scatter_plot <- renderPlot({
    df <- filtered_data()

    validate(
      need(nrow(df) > 0, "No data available for the selected filters.")
    )

    ggplot(df, aes(x = pressure, y = max_temp)) +
      geom_point(color = "#C1440E", size = 2.2, alpha = 0.8) +
      labs(
        title = "Air Pressure vs Maximum Temperature",
        x = "Air Pressure (Pa)",
        y = "Maximum Temperature (°C)"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold")
      )
  })
}

shinyApp(ui = ui, server = server)