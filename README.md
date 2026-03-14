# MarsCast 🪐

MarsCast is an individual **Shiny for R** reimplementation of our original Mars weather dashboard project.  
It explores historical Martian weather data collected by NASA's *Curiosity Rover* and provides an interactive interface for filtering and visualizing temperature and pressure patterns on Mars.

## Deployed App

- Deployed Dashboard: 

---

## Overview

This repository contains a simplified Mars weather dashboard built in **Shiny for R**.  
The app is based on the original group project, which was implemented in **Shiny for Python**, but this version was rebuilt individually in R to practice reactive programming and dashboard development in a different language.

The dashboard supports interactive filtering and updates key outputs automatically based on user selections.

## Features

This app includes:

- **Martian month filtering** to explore weather patterns for a selected month
- **Terrestrial date range filtering** to focus on a specific observation window
- **Reactive KPI outputs** for:
  - average minimum temperature
  - average maximum temperature
- **Temperature trend visualization** over time
- **Scatter plot** showing the relationship between air pressure and maximum temperature

## Data Description

### Dataset

The dataset contains weather observations from **Sol 1 (August 7, 2012 on Earth)** to **Sol 1895 (February 27, 2018 on Earth)**, measured directly on the surface of Mars.

### Source

- Collected by the **Rover Environmental Monitoring Station (REMS)**
- On-board the **Curiosity Rover**
- Publicly released by:
  - NASA’s Mars Science Laboratory
  - Centro de Astrobiología (CSIC-INTA)

More information about the source data is available here:  
<https://github.com/the-pudding/data/tree/master/mars-weather>

## Tools & Technologies

This project uses:

- **R**
- **Shiny** for interactive dashboard development
- **dplyr** for data wrangling
- **ggplot2** for plotting
- **readr** for reading the dataset

## Project Structure

```text
├── README.md
├── app.R
├── data/
│   └── mars-weather.csv
└── www/
    └── mars_bg.png
```

## Getting Started

### Prerequisites

Make sure you have R installed on your machine.

1. Clone the repository

```bash
git clone https://github.com/zainnofal/MarsCast-R.git
cd MarsCast-R
```

2. Install required packages

Open R and run:

```R
install.packages(c("shiny", "dplyr", "ggplot2", "readr"))
```

3. Run the application
From the repository root, run:

```R
shiny::runApp()
```

## App

Specifically, this app includes:

- Inputs: Martian month selector, terrestrial date range selector
- Reactive calculation: filtered Mars weather dataframe
- Outputs: average minimum temperature KPI, average maximum temperature KPI, temperature trends plot, air pressure vs maximum temperature scatter plot

## Acknowledgements

- NASA’s Mars Science Laboratory
- Centro de Astrobiología (CSIC-INTA)
- The Curiosity Rover team

Their work makes planetary-scale data science possible.

## License

This project is released under an open-source license. See [LICENSE](LICENSE) for details.