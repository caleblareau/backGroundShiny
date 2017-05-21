source("extRa/startup.R")

shinyUI(
    navbarPage(
        HTML("<img src='harvard-logo.png'/>"),


        tabPanel("Base Tab",
                 fluidPage(
                     pageWithSidebar(
headerPanel( HTML("<h1><b>Upload Text File</b></h1>") ),

## Side bar                         
    sidebarPanel(
        selectInput('xval', 'Randint', c(1,2,3,4), selected=c(1), selectize = FALSE),
        fileInput('uploadedfile', 'Upload File', accept=c('text/csv', 'text/comma-separated-values,text/plain', '.txt', '.tsv')),
        verbatimTextOutput("uploadedFileText")
    ),

## Main Panel
    mainPanel(
        tags$h3("Ready for analysis:"),
        verbatimTextOutput("readyToAnalyze"),
        conditionalPanel('output.readyToAnalyze == "FALSE"', verbatimTextOutput("porqueNo")),
        dataTableOutput('table'),
        conditionalPanel('output.readyToAnalyze == "TRUE"', 
            verbatimTextOutput("outputExist"),
            actionButton("runPy", "Run Python Script"), tags$br(), tags$br(),
            conditionalPanel('output.outputExist == "Done"', downloadButton("downloadData", "Download File"))
        )
     )
        ))),


        
        ##########
        # FOOTER
        ##########
        
        theme = shinytheme("cosmo"),
        footer = HTML(paste0('<P ALIGN=Center> <A HREF="mailto:caleblareau@g.harvard.edu">bgs</A>')),
        collapsible = TRUE, 
        fluid = TRUE,
        windowTitle = "backGroundShiny"
    )
)
        