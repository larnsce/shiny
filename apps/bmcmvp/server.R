####### trial with odbc and config

library(DBI)
library(odbc)
#library(config)
library(ggplot2)
library(tidyverse)

# get information from config.yml
dw <- config::get("datawarehouse")

# connect to database
con <- dbConnect(odbc::odbc(),
                     Driver = dw$driver,
                     Database = dw$database, 
                     UID = dw$uid,
                     PWD = dw$pwd,
                     Server = dw$server,
                     Port = dw$port
)

# get mtcars dataframe
bmcmvp <- tbl(con, "random_tibble")

bmcmvp_sum <- bmcmvp %>% 
  group_by(id) %>% 
  summarise(
    n = n(),
    min = round(min(value, na.rm = T), 4),
    mean = round(mean(value, na.rm = T), 4),
    sd = round(sd(value, na.rm = T), 4),
    max = round(max(value, na.rm = T), 4)
  ) %>% 
  collect()

dbDisconnect(conn = con)

# in your app code, read in the user base rds file
user_base <- readRDS("user_base.rds")


server <- function(input, output, session) {
  
  credentials <- callModule(shinyauthr::login, "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password,
                            sodium_hashed = TRUE,
                            log_out = reactive(logout_init()))
  
  logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
  
  observe({
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  output$user_table <- renderUI({
    # only show pre-login
    if(credentials()$user_auth) return(NULL)
    
    tagList(
      tags$p("test the different outputs from the sample logins below 
             as well as an invalid login attempt.", class = "text-center"),
      
      renderTable({user_base[, -3]})
      )
  })
  
  user_info <- reactive({credentials()$info})
  
  user_data <- reactive({
    req(credentials()$user_auth)
    
    if (user_info()$permissions == "admin") {
      bmcmvp_sum
    } else if (user_info()$permissions == "standard") {
      filter(bmcmvp_sum, id == "c")
    }
    
  })
  
  output$welcome <- renderText({
    req(credentials()$user_auth)
    
    glue("Welcome {user_info()$name}")
  })
  
  output$testUI <- renderUI({
    req(credentials()$user_auth)
    
    fluidRow(
      column(
        width = 12,
        tags$h2(glue("Your permission level is: {user_info()$permissions}. 
                     Your data is: {ifelse(user_info()$permissions == 'admin', 'Starwars', 'Storms')}.")),
        box(width = NULL, status = "primary",
            #title = ifelse(user_info()$permissions == 'admin', "Starwars Data", "Storms Data"),
            title = case_when(user_info()$permissions == 'admin' ~ "Starwars Data", TRUE ~ "Storms Data"),
            DT::renderDT(user_data(), options = list(scrollX = TRUE))
            #renderPlot(
            #  ggplot(user_data(), aes(x = factor(cyl), y = mpg, group = cyl)) +
            #    geom_boxplot()
            #  )
            )
        )
  )
    
  })
  
}