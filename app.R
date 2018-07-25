#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(ggthemes)
ks <- read.csv("ks-projects-201801.csv", stringsAsFactors = FALSE)
ks_clean <- na.omit(ks) # there are 3797 NA values in the data set all in the usd.pledged column 
# change launch date and deadline to 
ks_clean$deadline <- as.Date(ks_clean$deadline)
ks_clean$launched <- as.Date(ks_clean$launched)

# Define UI for application that draws a histogram
ui <-
  navbarPage("Navigation",
             tabPanel("Home",
                      # App title ----
                      titlePanel("A Study of Kickstarter Projects"),
                      # Sidebar layout with input and output definitions ----
                      sidebarLayout(
                        
                        # Sidebar panel for short explanation
                        sidebarPanel(
                          
                          print("In this app, we will be looking at a set of kickstarter projects and analyze what variables (like time and category) affect their success")
                          
                          
                        ), # end of sidebar layout
                        
                        # Main panel for displaying outputs ----
                        mainPanel(
                          
                          # Output: Histogram ----
                          plotOutput(outputId = "distPlot")
                          
                        ) # end of mainPanel
                      ) # end of sidebarLayout
             ), # end of Tab panel 1
             tabPanel("Time Sensitive",# App title ----
                      titlePanel("Time Dependent Success"),
                      # Sidebar layout with input and output definitions ----
                      sidebarLayout(
                        
                        # Sidebar panel for inputs ----
                        sidebarPanel(
                          
                          # Input: Text input for different category
                          selectInput(inputId = "inCat", label = "Input Category: ", 
                                      choices = c("Art","Comics","Crafts","Dance","Design","Fashion","Film & Video","Food","Games","Journalism","Music","Photography","Publishing","Technology","Theater"),
                                      selected = "Art", multiple = FALSE,
                                      selectize = TRUE, width = NULL, size = NULL),
                          # Input: Slider for the plot dimensions ----
                          sliderInput(inputId = "xmaxtime", label = "Max x Dimension ", min = 0, 
                                      max = 100, value = 50),
                          sliderInput(inputId = "ymaxtime", label = "Max y Dimension ", min = 0, 
                                      max = 40000, value = 100)
                          
                        ), # end of sidebar layout
                        
                        # Main panel for displaying outputs ----
                        mainPanel(
                          
                          # Output: Histogram ----
                          plotOutput(outputId = "timePlot")
                          
                        ) # end of mainPanel
                      ) # end of sidebarLayout
             ), # end of Tab panel 2
             tabPanel("Category Success",
                      titlePanel = "State of the Projects for Each Category",
                      sidebarLayout(
                        
                        # Sidebar panel for inputs ----
                        sidebarPanel(
                          
                          # Input: Text input for different category
                          selectInput(inputId = "inCat2", label = "Input Category: ", 
                                      choices = c("Art","Comics","Crafts","Dance","Design","Fashion","Film & Video","Food","Games","Journalism","Music","Photography","Publishing","Technology","Theater"),
                                      selected = "Art", multiple = FALSE,
                                      selectize = TRUE, width = NULL, size = NULL)
                        ),
                        mainPanel(
                          plotOutput(outputId = "statusPlot2"),
                          plotOutput(outputId = "statusPlot"),
                          plotOutput(outputId = "statusPlot3"),
                          width = 12
                        ) # end main panel
                      ) # end sidebar layout
             ), # end of Tab Panel 3
             tabPanel("Popularity",
                      titlePanel = "Popularity of Different Kickstarter Categories",
                      mainPanel(
                        plotOutput(outputId = "popPlot"),
                        width = 12
                      )
                      ) # end of tab panel 4
  ) # end of navbar page

# Define server logic required 
server <- function(input, output) {
  
  output$distPlot <- renderPlot({
    # histogram of projects per main category
    ks_cat <- ks_clean %>% 
      group_by(main_category) %>%
      summarise(count = n())
    g_cat <- ggplot(ks_cat, aes(x = main_category, y= count)) 
    g_cat + geom_col(fill = "coral", colour = "coral") +
      labs(title="Projects per Category", x = "Category", y = "Count") 
  })
  
  output$timePlot <- renderPlot({
    ks_TvsGoal <- ks_clean %>%
      group_by(main_category) %>%
      filter(main_category == input$inCat) %>%
      transmute(ID,
                timediff = deadline-launched,
                percent = usd_pledged_real/usd_goal_real) %>%
      arrange(timediff)
    g_TvsGoal <- ggplot(ks_TvsGoal,aes(timediff,percent))
    g_TvsGoal + geom_point() + coord_cartesian(xlim = c(0,input$xmaxtime), ylim = c(0,input$ymaxtime)) +
      scale_x_continuous() +
      labs(title = "Money collected v. Open Time of Project", x = "Time Difference (days)", y = "Percentage of Goal Raised")
  })
  
  output$statusPlot <- renderPlot({
    ks_complete <- ks_clean %>%
      group_by(main_category,state) %>%
      summarise(ct = n()) %>%
      mutate(freq = ct/sum(ct))
    g_complete <- ggplot(ks_complete, aes(x = main_category, y = freq, fill = state)) +
      labs(title= "Project Success per Category", x = "Main Category", y = "Percentage")
      g_complete + geom_bar(position = "stack", stat = "identity") + scale_fill_brewer(palette = "Spectral")
  })
  
  output$statusPlot2 <- renderPlot({
    ks_complete_2 <- ks_clean %>%
      group_by(main_category,state) %>%
      summarise(ct = n()) %>%
      mutate(freq = ct/sum(ct)) %>%
      filter(main_category == input$inCat2)
    g_complete_2 <- ggplot(ks_complete_2, aes(x = state, y= freq, fill = state)) 
    g_complete_2 + geom_bar(stat = "identity") +
      labs(title= paste("Project Success per Category for ",input$inCat2), x = "State", y = "Percentage") +
      scale_fill_brewer(palette = "Spectral")
  })
  
  output$statusPlot3 <- renderPlot({
    g_complete_3 <- ggplot(ks_complete, aes(x = main_category,y=ct,fill = state)) +
      labs(title= "State of Each Category", x = "Main Category", y = "Project number (count)")
      g_complete_3 + geom_bar(position = "dodge",stat = "identity") + scale_fill_brewer(palette = "Spectral")
  })
  
  output$popPlot <- renderPlot({
    ks_popularity <- ks_clean %>%
      group_by(main_category) %>%
      summarise(bkrs = sum(backers))
    g_pop <- ggplot(ks_popularity, aes(x = main_category, y = bkrs))
    g_pop + geom_col(fill = "coral", colour = "coral") +
      labs(title="Backers per Category", x = "Category", y = "Backers")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

