library(shiny)
library(bs4Dash)
library(summaryBox)

ui <- dashboardPage(
  dark = TRUE,
  header = dashboardHeader(
    title = h3("VizBuzz: Imagemagick Comparison Tool",style = "padding:5px 20px 5px 20px;"),
    # skin = "dark",
    # status = "gray-dark",
    fixed = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = dashboardBody(
    box(
      title = "Inputs",
      width = 12,
      status = "gray-dark",
      closable = FALSE,
      fluidRow(
        "This app uses Imagemagick to compare similarity between two images.",
        br(),
        shiny::markdown(
          "Image code by [@mrcaseb](https://twitter.com/mrcaseb), app by [@_TanHo](https://twitter.com/_TanHo), primarily designed for VizBuzz as hosted by [@nickwan](https://twitter.com/nickwan) on [Twitch](https://twitch.tv/nickwan_datasci).

          Code repo and issues here: <https://github.com/tanho63/vizbuzz_compare>
          "
        )
      ),
      hr(),
      fluidRow(
        column(
          width = 4,
          textInput(
            "original",
            label = "Original Image URL"
          )
        ),
        column(
          width = 4,
          textInput(
            "replication",
            label = "Contestant Image URL"
          )),
        column(width = 4,numericInput("fuzz", label = "Fuzz Factor (0-100)", value = 25, min = 0, max = 100, step = 11))
      ),
      footer = div(style = "text-align:center;",
                   actionButton("run","Run Comparison"))
    ),
    br(),

    uiOutput("summarybox"),
    br(),
    imageOutput("comp_image",width = "100%")
  )
)

server <- function(input, output, session) {

  rv <- reactiveValues()

  observeEvent(input$run,{
    req(input$original)
    req(input$replication)

    showModal(modalDialog("Comparing..."))

    rv$out <- vizbuzz_compare(input$original,input$replication,input$fuzz)
    Sys.sleep(1)
    removeModal()

    if(grepl("https://www.googleapis.com/download/storage/v1/b/kaggle-forum-message-attachments/o/inbox%2F6967664", input$replication)) {
      showModal(modalDialog("Applying Quang penalty..."))
      Sys.sleep(3)
      removeModal()
    }

    if(grepl("https://www.googleapis.com/download/storage/v1/b/kaggle-forum-message-attachments/o/inbox%2F2942617", input$replication)) {
      showModal(modalDialog("Adding Tantastic bonus points..."))
      Sys.sleep(3)
      removeModal()
    }

  })


  output$comp_image <- renderImage({
    req(rv$out)
    x <- magick::image_write(
      rv$out$image_comparison,
      tempfile(fileext = "png"),
      format = "png"
    )
    list(src = x, contentType = "image/png")
  },
  deleteFile = TRUE)


  output$summarybox <- renderUI({
    req(rv$out)
    fluidRow(
      column(
        width = 12,
        # style = "text-align:center;",
        summaryBox3(
          title = "Similarity",
          value = scales::percent(rv$out$similarity, accuracy = 0.1),
          # subtitle = "percentage of resized pixels are similar",
          # fill = TRUE,
          style = "info"
        )
      )
    )
  })

}

shinyApp(ui, server)
