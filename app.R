#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(metaheuristicOpt)
library(nsga2R)


# load wizard code
source('R/wizard.R')
source('R/pages.R')

# load my library for finding optimal designs
# source all R files in nlodm directory
directory <- "R/nlodm"

# List all files with the .R extension in the directory
r_files <- list.files(directory, pattern = "\\.R$", full.names = TRUE)
# Source each .R file
for (file in r_files) {
  source(file)
}


ui <- fluidPage(
  wizardUI(
    id = "wizard",
    pages = list(page1, page2, page3, page4, page5),
    doneButton = actionButton("done", "Find design!")
  )
)
server <- function(input, output, session) {
  wizardServer("wizard", 5)

  # dose response plot
  dose_response_plot = reactive({
    theta = c(input$theta1, input$theta2, input$theta3, input$theta4)
    plot_response(input$model_selector, theta, input$dose_limit, log_dose=F)
  })

  # reactive objects for result
  results = reactiveValues(pareto_data = NULL)

  # find design button
  observeEvent(input$done, {

    # browser()
    selected_obj = c(input$obj_checkbox_D, input$obj_checkbox_A, input$obj_checkbox_BMD)
    grad = grad_selector(input$model_selector)
    grad_funs = list(grad, grad, grad)[selected_obj]
    obj_funs = list(obj.D, obj.A, obj.c_e)[selected_obj]
    theta = c(input$theta1, input$theta2, input$theta3, input$theta4)
    thetas = list(theta, theta, theta)[selected_obj]
    bmd_grad = get_bmd_grad(input$model_selector, 'added')
    params = list(c(), c(), bmd_grad(0.1, theta))[selected_obj]


    # switch between single and multi-objective
    if (sum(selected_obj) == 1) {

    }
    else if (sum(selected_obj) > 1) {
      # call main function
      result = multi_obj(
        grad_funs,
        obj_funs,
        thetas,
        params,
        type = input$method,
        bound = input$dose_limit,
        pts = input$design_pts,
        swarm = input$swarm,
        maxiter = 50,
        verbose = T,
        exact = input$exact
      )

      # process results
      results$pareto_data = extract_front(result, input$exact)


      showModal(modalDialog(
        title = 'Results',
        fluidRow(
          plotOutput("results_plot")
        ),
        h3('Pareto optimal designs'),
        fluidRow(
          tableOutput("results_table")
        ),

        modalButton("Done"),
        footer = NULL))
    }
    else if (sum(selected_obj) == 0) {
      showModal(modalDialog(
        title = 'Results',
        "Please select at least 1 objective function.",

        modalButton("Done"),
        footer = NULL))
    }


  })

  # Render the data table in modal
  output$results_table <- renderTable({
    results$pareto_data
  })

  # Render the plot in modal
  output$results_plot <- renderPlot({
    selected_obj = c(input$obj_checkbox_D, input$obj_checkbox_A, input$obj_checkbox_BMD)
    if (!is.null(results$pareto_data) &
        sum(selected_obj) == 2) {
      plot_pareto2d(results$pareto_data, c("D", 'A', "BMD")[selected_obj])
    }
  })

  output$model_formula_display_page2 = renderUI({
    p(withMathJax(model_display(input$model_selector)))
  })

  output$model_formula_display_page3 = renderUI({
    p(withMathJax(model_display(input$model_selector)))
  })

  output$example_theta = renderUI({
    p(withMathJax(display_example_param(input$model_selector)))
  })

  output$dose_response_plot_page3 = renderPlot({
    dose_response_plot()
  })

  output$dose_response_plot_page4 = renderPlot({
    dose_response_plot()
  })

  output$verify_choices = renderUI({
      HTML(paste(
        'D objective:',
        input$obj_checkbox_D,
        '<br>A objective:',
        input$obj_checkbox_A,
        '<br>BMD objective:',
        input$obj_checkbox_BMD,
        '<br>Model:',
        input$model_selector,
        '<br>theta 1:',
        input$theta1,
        '<br>theta 2:',
        input$theta2,
        '<br>theta 3:',
        input$theta3,
        '<br>theta 4:',
        input$theta4,
        '<br>Dose limit:',
        input$dose_limit,
        '<br>Method:',
        input$method,
        '<br>Dose levels:',
        input$design_pts,
        '<br>Swarm size:',
        input$swarm,
        '<br>Maximum iterations:',
        input$maxIter,
        '<br>Exact design:',
        input$exact
      ))
  })
}


# Run the application
shinyApp(ui = ui, server = server)
