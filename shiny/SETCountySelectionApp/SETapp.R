# v0.1

# This is a Shiny app web application. You can run the application by clicking
# the "Run App" button above.
# Use the dashboard guide for building nice shiny UI https://rstudio.github.io/shinydashboard/structure.html







# library(shiny)
# library(shinythemes)
# library(shinycssloaders)
library(shinydashboard)
library(rintrojs)
library(reactable)
library(shiny)
library(data.table)
library(SETR)

# Load Data ---------------------------------------------------------------
dt_app <- SETR::Cancer_rates_dt

Cancers_dt <- t(unique(dt_app$Cancer))
colnames(Cancers_dt) <- Cancers_dt

Demographics_dt <- t(unique(dt_app$Demographic))
colnames(Demographics_dt) <- Demographics_dt

Sex_dt <- t(unique(dt_app$Sex))
colnames(Sex_dt) <- Sex_dt

states <- unique(dt_app$State)
states <- c("All States",states)

States_dt <- t(unique(states))
colnames(States_dt) <- States_dt

measures_dt <- t(c("Average Annual Count","Age-Adjusted Incidence Rate - cases per 100,000"))
colnames(measures_dt) <- measures_dt
# Shiny UI ----------------------------------------------------------------



ui <- dashboardPage(skin = "blue",

                    dashboardHeader(title = "SET County Selection App"),
                    dashboardSidebar(width =350,
                                     sidebarMenu(
                                       introjsUI(),
                                       menuItem(text = "Guide",tabName = "browse", icon = icon("folder-open"),
                                                shiny::actionButton(inputId = "help",
                                                                    label = "Press for instructions",
                                                                    width = "160px")
                                       ),
                                       menuItem(text = "Parameters",tabName = "browse", icon = icon("folder-open"),
                                                varSelectInput(inputId = "state",
                                                               multiple = FALSE,
                                                               label = "State",
                                                               data = States_dt,
                                                               width = "400px"),
                                                varSelectInput(inputId = "dem",
                                                               multiple = FALSE,
                                                               label = "Demographic",
                                                               data = Demographics_dt,
                                                               width = "400px"),
                                                varSelectInput(inputId = "sex",
                                                                label = "Sex",
                                                                multiple = FALSE,
                                                                data =Sex_dt,
                                                                #selected = "All",
                                                                width = "400px"),
                                                varSelectInput(inputId = "cancer",
                                                               label = "Cancer",
                                                               multiple = FALSE,
                                                               width = "400px",
                                                               data =Cancers_dt),
                                                varSelectInput(inputId = "var",
                                                               multiple = FALSE,
                                                               label = "Ranking Variable",
                                                               data = measures_dt,
                                                               width = "400px"),
                                                shiny::textAreaInput(inputId = "num_rows",
                                                                     value = 10,
                                                                     width = "160px",
                                                                     height = "35px",
                                                                     label = "Number of Results"),
                                                shiny::actionButton(inputId = "run",
                                                                    label = "Run",
                                                                    width = "160px")
                                       )
                                     )
                                     ),
                    dashboardBody(
                      fluidRow(
                        #leafletOutput("mymap",width = 800, height = 800),
                        #shiny::textOutput("err_msg_map"),
                        tabBox(width = 12,
                               title = "",
                               id = "Data_tab",
                               tabPanel("Data",
                                        fluidRow(
                                          shiny::textOutput("err_msg"),
                                          reactableOutput("table")
                                        )
                               )
                        )
                      )
                    )

)

server <- function(input, output, session) {
  steps <- reactive(
    data.frame(
      element=c("Parameters", "Number of Results", "Run"),
      intro=c(
        "Please use the Parameters tab to specify the demographic, sex and cancer you are intrested in",
        "Specify the number of results you want to observe using the *Number of Results* text box",
        "Click the *Run* button to run the analysis and view the results"
        )
      #position=c("right", "right", "bottom")
    )
  )

  observeEvent(input$help,
               introjs(session,
                       options = list(steps=steps(),
                                      "nextLabel"="Next",
                                      "prevLabel"="Previous",
                                      "skipLabel"="Skip"
                       )
                       #events = list("oncomplete"=I('alert("Done")'))
               )
  )


  # Make the map
  observeEvent(input$run, {
      Dem <- paste(input$dem)
      Canc <- paste(input$cancer)
      Sx <- paste(input$sex)
      rows <- as.character(paste(input$num_rows))
      St <- paste(input$state)
      v <- paste(input$var)
      i <-   which(colnames(dt_app) == v)
      ## Error messages for Female and Male only cancers

    if(St == "All States") {
      dt_out <<- dt_app[Demographic == Dem & Cancer == Canc & Sex == Sx]
      dt_out <<- dt_out[order(dt_out[,i,with = FALSE], decreasing = TRUE)][1:rows,]

    } else{
      dt_out <<- dt_app[State == St & Demographic == Dem & Cancer == Canc & Sex == Sx]
      dt_out <<- dt_out[order(dt_out[,i,with = FALSE], decreasing = TRUE)][1:rows,]

    }
    dt_out <<- dt_out[,-c(6:8)]


    if(Sx == "Female" & Canc %in% c("Prostate") |
       Sx == "Male" & Canc %in% c("Breast","Ovary")){
      output$err_msg <- renderText(paste("Please enter correct Sex and Cancer combination"))

    }

    output$table <- renderReactable({
      reactable(dt_out)
    })

    # counties <- get_urbn_map(map = input$map_type, sf = TRUE)
    # dt_labels <- get_urbn_labels(map = input$map_type)

  })


}


shiny::shinyApp(ui,server)

