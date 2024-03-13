# individual pages in the wizard
page1 <- tagList(
  titlePanel("Design criteria"),
  checkboxInput('obj_checkbox_D', 'D', value = TRUE),
  checkboxInput('obj_checkbox_A', 'A', value = FALSE),
  checkboxInput('obj_checkbox_BMD', 'BMD', value = TRUE)

)
page2 <- tagList(
  titlePanel('Select model'),
  selectInput(
    inputId = 'model_selector',
    label = NULL,
    choices = c('4 parameter log-logistic'),
    selected = '4 parameter log-logistic'
  ),
  uiOutput('model_formula_display_page2')
)
page3 <- tagList(
  titlePanel('Choose model parameters'),
  uiOutput('model_formula_display_page3'),
  uiOutput('example_theta'),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        'theta1',
        'Theta 1',
        value = 0.084950,
        step = 0.1
      ),
      numericInput(
        'theta2',
        'Theta 2',
        -11.093067,
        step = 0.1
      ),
      numericInput(
        'theta3',
        'Theta 3',
        12.157339,
        step = 0.1
      ),
      numericInput(
        'theta4',
        'Theta 4',
        0.913343,
        step = 0.1
      ),
      numericInput(
        'dose_limit',
        'Dose limit',
        20,
        min = 0.01,
        step = 0.5
      )
    ),
    mainPanel(
      plotOutput('dose_response_plot_page3')
    )
  ),


)
page4 = tagList(
  titlePanel('Algorithm options'),
  selectInput(
    'method',
    'Method',
    choices = c('compound', 'pareto'),
    selected = 'pareto'
  ),
  numericInput(
    'design_pts',
    'Dose levels (sample size for exact designs)',
    value = 3,
    min = 1,
    max = 100
  ),
  numericInput(
    'swarm',
    'Swarm size',
    100,
    min = 1,
    max = 10000
  ),
  numericInput(
    'maxIter',
    'Maximum iterations',
    500,
    max = 10000,
    min = 1
  ),
  checkboxInput(
    'exact',
    'Exact design',
    value = F
  )

)
page5 = tagList(
  titlePanel('Verify and find design'),
  sidebarLayout(
    sidebarPanel(
      htmlOutput('verify_choices')
    ),
    mainPanel(
      plotOutput('dose_response_plot_page4')
    )
  )
)
