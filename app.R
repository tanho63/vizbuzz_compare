library(shiny)
library(bs4Dash)

ui <- dashboardPage(
  dark = TRUE,
  header = dashboardHeader(
    title = h3("VizBuzz: Imagemagick Comparison Tool"),
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
        "Image code by @mrcaseb, app by @_TanHo, primarily designed for VizBuzz as hosted by @nickwan."
      ),
      hr(),
      fluidRow(
        column(
          width = 4,
          textInput(
            "original",
            label = "Original Image URL"
            # ,value = "https://cdn.discordapp.com/attachments/944672779826003968/953446500556484638/MonthlySeaIceExtent_PolicyViz-1140x700.png"
            )
          ),
        column(
          width = 4,
          textInput(
            "replication",
            label = "Contestant Image URL"
            # ,value = "https://cdn.discordapp.com/attachments/944672779826003968/953456772780281896/plot_zoom_png.png"
            )),
        column(width = 4,numericInput("fuzz", label = "Fuzz Factor (0-100)", value = 10, min = 0, max = 100, step = 11))
      ),
      footer = div(style = "text-align:center;",
                   actionButton("run","Run Comparison"))
      ),
    uiOutput("comparison")
  )
)

server <- function(input, output, session) {

  rv <- reactiveValues()

  observeEvent(input$run,{
    req(input$original)
    req(input$replication)

    rv$out <- vizbuzz_compare(input$original,input$replication,input$fuzz)

  })

  output$comp_image <- renderImage({
    req(rv$out)
    x <- rv$out$image_comparison |>
      magick::image_write(
        tempfile(fileext = "png"),
        format = "png"
      )
    list(src = x, contentType = "image/png")
  },
  deleteFile = TRUE)

  output$comparison <- renderUI({
    req(rv$out)
    box(
      title = glue::glue("Comparison"),
      width = 12,
      em(rv$out$sim_string),
      br(),
      imageOutput("comp_image",width = '100%',height = "auto")
    )
  })

}

shinyApp(ui, server)
