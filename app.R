library(shiny)
library(semantic.dashboard)
library(shiny.semantic)
library(DT)
library(purrr)
library(shinyjs)


options(shiny.maxRequestSize = 30*1024^2)

#serve images
addResourcePath("assets", "assets")

preprocess_results <- function(data,...){
  purrr::map_dfr(data, as.data.frame)
}

# register with shiny
#shiny::registerInputHandler("ml5.class", preprocess_results)

#ml5js dependency
dependency_ml5 <- htmltools::htmlDependency(
  name = "ml5",
  version = "0.4.3",
  src = c(href = "https://unpkg.com/ml5@0.4.3/dist/"),
  script = "ml5.min.js"
)




ui <- dashboardPage(
  dashboardHeader(color = "olive"),
  dashboardSidebar(sidebarMenu(
    menuItem(tabName = "claasify",text = "Image Classification", icon = icon("image")),
    menuItem(tabName = "detect", text = "Object Detection", icon = icon("object")),
    menuItem(tabName = "pose", text = "Pose Estimation", icon = icon("object"))
  )),
  
  dashboardBody(
    dependency_ml5,
    tags$head(
      tags$script(src = "assets/classify.js")
    ),
    box(
      title = "Inputs", status = "primary", solidHeader = TRUE,
      collapsible = TRUE, width = 4,
      selectInput(inputId = "imselect", label = "select an image", choices = c("flamingo", "lorikeet","cat","dog","panda")),
      br(),
      br(),
      fileInput(inputId = "imChose", label = "Upload Image", accept = c(".jpg"))
      
    ),
    
    box(
      title = "Inputs", status = "warning", solidHeader = TRUE,
      h4("Image Classication using pretrained Mobilenet", style="text-align: center;"), br(),br(),
      # tags$canvas(
      #   width="255", height = "255", id = "imarea", style="border: 1px solid red; display: block; margin: 0 auto; background: #c1c1c1;"
      # ),
      uiOutput("birdDisplay"),
      
      br(),
      br(),
      button("classify", "Classify", style = "display: block; margin: 0 auto;")
      
    ),
    br(),
    DTOutput("results")
  )
)


server = function(input, output, session) {
  
  base64 <- reactive({
    inFile <- input$imChose
    if(!is.null(inFile)){
      dataURI(file = inFile$datapath, mime = "image/jpeg")
    }
  })
  
  
  output$birdDisplay <- renderUI({
    
    if(!is.null(base64())){
      tags$img(src = base64(),width = "100%", id = "bird", style ="display: block; margin: 0 auto;")
    }
    path <- sprintf("assets/%s.jpg", input$imselect)
    tags$img(src = path, id = "bird", style ="display: block; margin: 0 auto;")
  })
  
  
  
  
  #We thus observe the button so that when clicked,
  #a message is sent to the front-end, via the WebSocket.
  observeEvent(input$classify, {
    session$sendCustomMessage("classify", list())
  })

  output$results <- renderDT({
    datatable(input$classification)
  })
}



shinyApp(ui, server)
