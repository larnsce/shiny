# load packages 1

library(shiny)
library(shinydashboard)
library(dplyr)
library(shinyjs)
library(glue)
library(shinyauthr)

# Load packages 2

#library(shinyjqui)
library(shinydashboardPlus)
#library(shinyAce)
#library(styler)
#library(shinyWidgets)
#library(shinyEffects)
library(ggplot2)

ui <- dashboardPagePlus(md = FALSE,
                        
                        dashboardHeaderPlus(fixed = FALSE,
                                            title = "shinyauthr",
                                            tags$li(class = "dropdown", style = "padding: 8px;",
                                                    shinyauthr::logoutUI("logout")),
                                            tags$li(class = "dropdown", 
                                                    tags$a(icon("github"), 
                                                           href = "https://github.com/paulc91/shinyauthr",
                                                           title = "See the code on github"))
                        ),
                        
                        dashboardSidebar(collapsed = TRUE, 
                                         div(textOutput("welcome"), style = "padding: 20px")
                        ),
                        
                        dashboardBody(
                          shinyjs::useShinyjs(),
                          tags$head(tags$style(".table{margin: 0 auto;}"),
                                    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                                                type="text/javascript"),
                                    includeScript("returnClick.js")
                          ),
                          shinyauthr::loginUI("login"),
                          #uiOutput("user_table"),
                          uiOutput("testUI"),
                          HTML('<div data-iframe-height></div>')
                        )
)