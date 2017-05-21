source("extRa/startup.R")
source("extRa/processTopology.R")

function(input, output, session) {
    
    session$onSessionEnded(stopApp)
    
    # Set up dataframe for data description tab
    dDF <- read.table("https://raw.githubusercontent.com/aryeelab/dnalandscaper_tracks/master/peakchopper_tracks.txt", header = FALSE, sep = ",")
    colnames(dDF) <- c("Track",	"Organism",	"Type", "PMID",	"Description")
    dDF$PMID <- paste0('<a href="http://www.ncbi.nlm.nih.gov/pubmed/', dDF$PMID, '" target="_blank">', dDF$PMID, '</a>')
    output$preloadedDataDescription <- renderDataTable({dDF}, escape = FALSE)
    
    rv <- reactiveValues(
        bedfile = FALSE,
        peaks = NULL,
        smallFile = FALSE,
        computing = FALSE,
        
        # Topology Reactive Variables
        humanGenes = g.geneList,
        deData = g.deLoopData,
        ilData = g.ilLoopData
    )
    
    # Upload a bed file; handle i/o and render it
    # If it's bigger than 10 peaks, don't proceed
    output$uploadedFileText <- renderText({
        if (is.null(input$bedfile)) return(NULL)
        nameObject <- fixUploadedFilesNames(input$bedfile)
        rv$bedfile <- nameObject$datapath
        rv$peaks <- read.table(rv$bedfile , header = FALSE)
        rv$smallFile = (dim(rv$peaks)[1] < 10)
        paste0("Uploaded .bed file: ", nameObject$name)
    })
    
    # Render boolean variable to determine if we can execute python script
    output$readyToAnalyze <- renderText({
       as.character(rv$smallFile & !is.null(input$bedfile))
    })
    
    # Render text as to why the analysis can't be run
    # Either because peak file is big or no input
    output$porqueNo <- renderText({
        if(is.null(input$bedfile)){
            "Specify .bed file!"
        } else {
            ".bed file too big; maximum number of peaks allowed is 10!"  
        }
    })
    
    output$table <- renderDataTable(rv$peaks)
    
    # Execute Python Code
    
    observeEvent(input$runPy,{
        rv$computing = TRUE
        system(paste0("python peakchop.py -bed ", rv$bedfile, " -genome hg19.2bit"))
    })
    
    # Check for the file every half second
    checkFn <- reactiveFileReader(500, session, "gRNA_Score_Distribution.png", file.exists)
    
    # Toy example
    # observeEvent(input$runPy,{
    #    rv$computing = TRUE
    #    system(paste0("python somethingRan.py ", rv$bedfile))
    # })
    # checkFn <- reactiveFileReader(500, session, "yay.txt", file.exists)
    
    
    output$outputExist <- renderText({
        if(checkFn()){
            "Done"
        } else if(rv$computing){
            "Computing" 
        } else {
            "Ready"
        }})
    

    # Download Data; Replace with like a .zip of the file outputs eventually...
    output$downloadData <- downloadHandler(
        filename <- function(){
            "peakchopper.out.png"
        },
        content <- function(file){
            file.copy("gRNA_Score_Distribution.png", file)
        }
    )

    
### Topology Panel
    observe({
        updateSelectizeInput(session, "genesSelected", choices = g.geneList, server = TRUE)
        updateSelectizeInput(session, "enhancerLoopsHuman", choices = rv$deData, server = TRUE)
        updateSelectizeInput(session, "insulatedLoopsHuman", choices = rv$ilData, server = TRUE)
    })
    
    observe({
      if(input$featureSet == "sg"){
          rv$humanGenes <- input$genesSelected
      } else if(input$featureSet == "upl" & !is.null(input$genesOfInterestUP)){
          rv$humanGenes <- read.table(input$genesOfInterestUP, header = FALSE)[,1]
      }
    })
    
    # Download Stuff
    output$showEnhancerLoopDownload = renderUI({
        if(length(input$enhancerLoopsHuman) > 0 & length(rv$humanGenes) > 0) {
            downloadButton("downloadEnhancerRegions", "Download Enhancer Regions")
        }
    })
    
    output$downloadEnhancerRegions <- downloadHandler(
        filename = function() { paste0('peakchopper-distalEnhancers', Sys.Date(), '.bed') },
        content = function(file) {
            write.table(getDistalEnhancers(input$genesSelected, input$enhancerLoopsHuman),
                        file, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
        }
    )
    
    output$showInsulatedLoopDownload = renderUI({
        if(length(input$enhancerLoopsHuman) > 0 & length(rv$humanGenes) > 0) {
            downloadButton("downloadInsulatedRegions", "Download Insulated Loop Regions")
        }
    })
    
    output$downloadEnhancerRegions <- downloadHandler(
        filename = function() { paste0('peakchopper-insulatedLoops', Sys.Date(), '.bed') },
        content = function(file) {
            write.table(getDistalEnhancers(input$genesSelected, input$enhancerLoopsHuman),
                        file, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
        }
    )
    
    
}

