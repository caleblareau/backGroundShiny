source("extRa/startup.R")

shinyUI(
    navbarPage(
        HTML("<img src='harvard-logo.png'/>"),
        
tabPanel("Topology",
            fluidPage(
                     pageWithSidebar(
headerPanel( HTML("<h1><b>Identify Features from Topology Data</b></h1>") ),

## Side bar                         
    sidebarPanel(
        radioButtons("loopType",  h4(tags$b("Select Topology Feature")),
                     choices = list("Distal Enhancer" = "de", "Insulated Neighborhood" = "ine")),
        radioButtons("featureSet",  h4(tags$b("Specify Feature Set")), selected = "sg",
                     choices = list("Upload Peaks" = "up", "Select Genes" = "sg", "Upload Gene List" = "ugl")),
        radioButtons("organismAll",  h4(tags$b("Select Organism")),
                     choices = list("Human" = "human"))
        ),

## Main Panel
    mainPanel(
        conditionalPanel('input.featureSet == "sg"',
        selectizeInput("genesSelected", label = h4(tags$b("Select Gene Targets")),
          choices = NULL, multiple = TRUE, selected = NULL)
        ),
        conditionalPanel('input.featureSet == "ugl"',
            fileInput("genesOfInterestUP", label = h4(tags$b("Upload Gene List")))
        ),
        conditionalPanel('input.featureSet == "up"',
            fileInput("bedFeatures", label = h4(tags$b("Upload Bed File")))
        ),
        
         # Options for Distal Enhancer
        conditionalPanel('input.loopType == "de"', 
            selectizeInput("enhancerLoopsHuman", label = h4(tags$b("Select Cell Lines")),
                choices = NULL, multiple = TRUE, selected = NULL),
            uiOutput("showEnhancerLoopDownload")
        ),
        
         # Options for Insulated Neighborhood
        conditionalPanel('input.loopType == "ine"', 
            selectizeInput("insulatedLoopsHuman", label = h4(tags$b("Select Cell Lines")),
                choices = NULL, multiple = TRUE, selected = NULL),
            uiOutput("showInsulatedLoopDownload")
        )
     )
        ))),


# Guide RNA Design Page

        tabPanel("gRNA Design",
                 fluidPage(
                     pageWithSidebar(
headerPanel( HTML("<h1><b>gRNA Design</b></h1>") ),

# Specify UI for gRNA Options
                                                  
## Side bar                         
    sidebarPanel(
        selectInput('xcol', '# of Mismatches', c(1,2,3,4), selected=c(1), selectize = FALSE),
        selectInput('ycol', '# of gRNA Pairs', c(5,6,7,8), selected=c(6), selectize = FALSE),
        fileInput('bedfile', 'Upload Bed File', accept=c('text/csv', 'text/comma-separated-values,text/plain', '.bed')),
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
            actionButton("runPy", "Run gRNA Scoring"), tags$br(), tags$br(),
            conditionalPanel('output.outputExist == "Done"', downloadButton("downloadData", "Download File"))
        )
     )



        ))),
        
    tabPanel("Data Descriptions",
         fluidPage(
             headerPanel( HTML("<h1><b>Topology Data Descriptions</b></h1>") ),
             mainPanel(
                 tags$hr(),
                 dataTableOutput('preloadedDataDescription'),
                 tags$hr(), 
                 width = 12
             )
         )),

                     
        tabPanel("Guide",
            includeMarkdown("www/guide.Rmd")
        ),
        
        ##########
        # FOOTER
        ##########
        
        theme = shinytheme("cosmo"),
        footer = HTML(paste0('<P ALIGN=Center> <A HREF="mailto:caleblareau@g.harvard.edu">peakchopper</A>')),
        collapsible = TRUE, 
        fluid = TRUE,
        windowTitle = "peakchopper"
    )
)
        