source("extRa/startup.R")

function(input, output, session) {
    
    session$onSessionEnded(stopApp)

    rv <- reactiveValues(
        goFile = FALSE,
        filename = NULL,
        computing = FALSE
    )
    
    # Upload a file; handle i/o and render it; possibly fail based on condition
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
       system(paste0("python runSomething.py ", rv$filename, " ", input$xval))
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
            "yay.txt"
        },
        content <- function(file){
            file.copy("yay.txt", file)
        }
    )

    
}

