library(shiny)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(readr)

#babynames <- read_csv("namesbystate.csv", col_types = cols(sex = col_character()))
babynames <- vroom::vroom("namesbystate.csv")
#babynames <- data.table::fread("namesbystate.csv")

inputNames <- sort(unique(pull(babynames, "name")))
inputStates <- sort(unique(pull(babynames, "state")))

ui <- fluidPage(theme = shinythemes::shinytheme("darkly"),
    
    titlePanel("US Naming Trends"),
    
    sidebarLayout(
        sidebarPanel(
            selectizeInput("name", "Name", NULL),
            selectInput("state", "State", inputStates, "NY", TRUE),
            radioButtons("sex", "Sex", c("M", "F", "Both"), "Both")
        ),
        
        mainPanel(
            plotOutput("plot")
        )
    )
)

server <- function(input, output, session) {
    
    updateSelectizeInput(session, "name", choices = inputNames, selected = "Jessie", server = TRUE)
    
    selectedSex <- reactive({
        switch(input$sex, M = "M", F = "F", Both = c("M", "F"))
    })
    
    selectedData <- reactive({
        babynames %>% 
            filter(name==input$name, state %in% input$state, sex %in% selectedSex()) %>%
            group_by(name, year, state) %>%
            summarise(count = sum(n))
    })
    
    output$plot <- renderPlot({
        ggplot(selectedData(), aes(year, count, col = state)) + 
            geom_smooth(span = 0.3) + 
            ggtitle(input$name, input$sex) +
            theme_solarized(light = FALSE) +
            scale_colour_solarized("red")
    })

}

shinyApp(ui = ui, server = server)
