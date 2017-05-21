source("extRa/startup.R")

function(input, output, session) {
    
    session$onSessionEnded(stopApp)

    rv <- reactiveValues(
        goFile = FALSE,
        filename = NULL,
        computing = FALSE
    )
    
    # Upload a file; handle i/o and render it
    # If it's bigger than 10 peaks, don't proceed
    output$uploadedFileText <- renderText({
        if (is.null(input$uploadedfile)) return(NULL)
        nameObject <- fixUploadedFilesNames(input$uploadedfile)
        rv$filename <- nameObject$datapath
        rv$goFile <- TRUE # can apply other conditions to uploaded file
        paste0("Uploaded file: ", nameObject$name)
    })
    
    # Render boolean variable to determine if we can execute python script
    output$readyToAnalyze <- renderText({
       as.character(rv$goFile & !is.null(input$uploadedfile))
    })
    
    # Render text as to why the analysis can't be run
    # Either because peak file is big or no input
    output$porqueNo <- renderText({
        if(is.null(input$uploadedfile)){
            "Upload file!"
        } else {
            "Something is fishy with the file"
        }
    })
    

    # Toy example; check for "yay.txt"
    observeEvent(input$runPy,{
       rv$computing = TRUE
       system(paste0("python somethingRan.py ", rv$goFile))
    })
    
    checkFn <- reactiveFileReader(500, session, "yay.txt", file.exists)
    
    
    output$outputExist <- renderText({
        if(checkFn()){
            "Done"
        } else if(rv$computing){
            "Computing" 
        } else {
            "Ready"
        }})
    

    # Download output file
    output$downloadData <- downloadHandler(
        filename <- function(){
            "peakchopper.out.png"
        },
        content <- function(file){
            file.copy("gRNA_Score_Distribution.png", file)
        }
    )

    
}

