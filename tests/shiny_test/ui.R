## Run via shiny::runApp("./tests/shiny_test", port=4624)

library(shiny)
library(DT)

# The object can be passed to runApp()
shinyUI(fluidPage(
  titlePanel("searchConsoleR Shiny Demo"),
  sidebarLayout(
    sidebarPanel(
      googleAuthR::loginOutput("loginButton"),
      selectInput("website_select", label = "Select Website",
                  choices = NULL),
      actionButton("submit", "Get Search Console Data"),
      br(),
      p("Demo for the searchConsoleR R package."),
      a("See source code on Github", href="https://github.com/MarkEdmondson1234/searchConsoleR"),
      helpText("Note this app is not multi-user yet!  E.g. if someone else authenticates their Google account when you are using it, you will lose API access.  ")
    ),
    mainPanel(
      textOutput("debug"),
      textOutput("selected_url", container = h2),
      tabsetPanel(
        tabPanel(title = "Search Analytics",
                 fluidRow(
                   h3("Data Range Select"),
                   column(3,
                          dateRangeInput("date_range", "Select Dates",
                                         start = Sys.Date() - 90,
                                         end = Sys.Date() - 3),
                          br()
                          
                   ),
                   column(3,
                          selectInput("type", label = "Search Type",
                                      choices = c("Web" = "web",
                                                  "Image" = "image",
                                                  "Video" = "video")),
                          br()
                   ),
                   column(3,
                          selectInput("metrics", label ="Plot Metrics",
                                      choices = c("Clicks" = "clicks",
                                                  "Impressions" = "impressions",
                                                  "CTR" = "ctr",
                                                  "Avg. Postion" = "position")),
                          br()
                   )
                   
                 ),
                 fluidRow(
                   h3("Data Filter Select"),
                   column(3,
                          selectInput("filter_dim", label ="Filter By",
                                      choices = c("No filter" = "none",
                                                  "Query" = "query",
                                                  "Page" = "page",
                                                  "Country" = "country",
                                                  "Device" = "device")),
                          br()
                   ),
                   column(3,
                          selectInput("filter_op", label = "Filter Type",
                                      choices = c("Contains" = "~~",
                                                  "Equals" = "==",
                                                  "Does Not Contain" = "!~",
                                                  "Does Not Equal" = "!=")
                          ),
                          br()
                   ),
                   column(3,
                          textInput("filter_ex", label = "Filter On"),
                          br()
                   )
                 ),
                 fluidRow(
                   h3("Trend"),
                   plotOutput("plot_analytics"),
                   br()
                 ),
                 fluidRow(
                   h3("Breakdown"),
                   selectInput("dims", label ="Dimension Breakdown",
                               choices = c("Query" = "query",
                                           "Page" = "page",
                                           "Country" = "country",
                                           "Device" = "device"),
                               multiple = TRUE,
                               selected = "query"),
                   DT::dataTableOutput("sa_breakdown"),
                   helpText("Click on a row to see its trend."),
                   h4("Breakdown Trend"),
                   plotOutput("breakdown_plot"),
                   br()
                 )
        ),
        tabPanel(title = "Crawl Errors",
                 selectInput("errors", 
                             "Error Type",
                             choices = c("Not Found" = "notFound",
                                         "Soft 404" = "soft404",
                                         "Auth Permissions" = "authPermissions",
                                         "Many To One Redirect" = "manyToOneRedirect",
                                         "Not Followed" = "notFollowed",
                                         "Roboted" = "roboted",
                                         "Server Error" = "serverError")),
                 selectInput("platform",
                             "Googlebot User Agent",
                             choices = c("Web" = "web",
                                         "SmartPhone" = "smartphoneOnly",
                                         "Mobile" = "mobile")
                 ),
                 h3("Error Trend"),
                 plotOutput("crawl_errors"),
                 h3('Sample Errors'),
                 DT::dataTableOutput("crawl_error_samples"),
                 h4('Error Details for URL selected above'),
                 DT::dataTableOutput("error_detail")
                 
        ),
        tabPanel(title = "Sitemaps",
                 DT::dataTableOutput("websites"),
                 br()
        )
      ),
      br()
      
    ) ## mainPanel
  ) ##sidebarLayout
)
)
