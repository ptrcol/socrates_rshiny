#___________________________________________________________________________
# This file is part of the SOcial Contact RATES (SOCRATES) modelling project
# 
# => R-SHINY USER INTERFACE
#
#  Copyright 2020, SIMID, UNIVERSITY OF ANTWERP & HASSELT UNIVERSITY
#___________________________________________________________________________
# # FYI: To run SOCRATES via Github (latest version!)
# library('shiny')
# runGitHub('socrates_rshiny','lwillem')

# # load all functions and packages
# this is done automatically when running the App

# Define UI for social contact application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel(ui_title,
              windowTitle = paste0('SOCRATES (',version_id,')')),
  
  # Sidebar with controls
  sidebarPanel(
 
    if(bool_is_comix_ui){
      uiOutput("socrates_website_data")
    },
    
    if(bool_is_comix_ui){
      hr()
    },
    
    selectInput(inputId = "country", 
                label = "Country",
                choices = opt_country,
                selectize = ),
    
    # # waves (dynamic, only if wave info is present)
    uiOutput(outputId = 'dynamicWaveInput'),
    
    textInput(inputId="age_breaks_text",
              label="Age breaks (comma delimited)",
              value=opt_age_breaks),
   
    #by default 'all contacts' to prevent warnings/errors, can be extended in "server" script. 
    selectInput("daytype", "Type of day",
                opt_day_type[1]),
    
    conditionalPanel(condition = bool_selectInput_duration,
    selectInput("duration", "Contact duration",
                opt_duration)
    ),
    
    selectInput("touch", "Contact intensity",
                opt_touch),
    
    selectInput("gender", "Gender",
                opt_gender),
    
    tabsetPanel(type = "tabs", id="distancing",
                tabPanel("General",
                         checkboxInput("bool_reciprocal", "Reciprocity",value = TRUE),
                         checkboxInput("bool_weigh_age", "Weigh by age",value = TRUE),
                         checkboxInput("bool_weigh_week", "Weigh by week/weekend",value = TRUE),

                         # SPC (optional)
                         conditionalPanel(
                           condition = 'output.panelStatus',
                           checkboxInput("bool_spc", "Include supplemental professional contacts (SPC)",value = TRUE)),
                         
                         # HH members (optional)
                         conditionalPanel(
                           condition = 'output.panelStatusHome',
                           checkboxInput("bool_hhmember_selection", "Set contacts at 'Home' with non-household members as 'leisure contacts'",value = FALSE)),
                         
                         checkboxInput("bool_location", "Include all locations",value = TRUE),
                         conditionalPanel(
                           condition = "input.bool_location == false",
                           checkboxGroupInput('cnt_location',
                                              label = 'Included locations',
                                              choices = opt_location,
                                              selected = opt_location))
                        ),
                tabPanel("Options", 
                         checkboxInput("bool_age_range", "Age range: sample at random",value = TRUE),
                         checkboxInput("bool_age_missing", "Missing contact age: remove participant",value = FALSE),
                         checkboxInput("bool_matrix_limit", "Specify the max for the contact matrix color scale?",value = FALSE),
                         conditionalPanel(condition = "input.bool_matrix_limit == true",
                                          numericInput(inputId="ui_scale_max",
                                                       label = "Color scale upper limit (≥1)",
                                                       value = NA,
                                                       min   = 1))
                ),
                tabPanel("Distancing", checkboxInput("bool_physical_distancing","Include physical distancing"),
                                       conditionalPanel(
                                         condition = "input.bool_physical_distancing == true",
                                         sliderInput("cnt_reduction_home","Reduce 'home' contacts (%)",min=0,max=100,value=0),
                                         sliderInput("cnt_reduction_work","Reduce 'work' contacts (%)",min=0,max=100,value=0),
                                         sliderInput("cnt_reduction_school","Reduce 'school' contacts (%)",min=0,max=100,value=0),
                                         sliderInput("cnt_reduction_transport","Reduce 'transport' contacts (%)",min=0,max=100,value=0),
                                         sliderInput("cnt_reduction_leisure","Reduce 'lesiure' contacts (%)",min=0,max=100,value=0),
                                         sliderInput("cnt_reduction_otherplace","Reduce 'otherplace' contacts (%)",min=0,max=100,value=0))
                         ),
                tabPanel("Transmission",
                         radioButtons("sel_transmission","Options:",
                                            c("Equal contributions"="equal",
                                              "Relative age factors [0;2]" = "relative",
                                              "Sensitivity and elasticity" = "sensitivity")),
                         conditionalPanel(condition = "input.sel_transmission != 'equal'",
                                          uiOutput("sliders_susceptibility"),
                                          uiOutput("sliders_infectiousness")),
                         conditionalPanel(condition = "input.sel_transmission == 'sensitivity'",
                                          uiOutput("sliders_q"),
                                          hr(),
                                          tags$h3("To calculate relative impact:"),
                                          uiOutput("sliders_delta_p"),
                                          uiOutput("sliders_nrgen"))
                        )
                ),
    
    hr(),
    helpText('DOWNLOAD'),
    downloadButton('download_matrix',"Download matrix (.csv)", style = "width:99%;"),
    downloadButton('download_all',"Download results (.RData)",style = "width:99%;"),
    
    # add version and link to project website
    headerPanel(""),
    uiOutput("project_website"),
    if(!bool_is_comix_ui){
      uiOutput("socrates_website_comix")
    },
    helpText('SOCRATES',version_id)
    
  ),
  
  mainPanel(
    
    # allways show matrix with contact rates
    plotOutput('plot_cnt_matrix',width = "80%", height = "300px"),
    
    # use tabs
    tabsetPanel(type = "tabs",
                id='tabs_results',
                tabPanel("All results", 
                         verbatimTextOutput("social_contact_analysis"),
                         #helpText('Please note that contacts whose ages are given as a range but not exactly will have their age set to the mid-point of the range.')
                         #helpText('Please note that contacts whose ages are not given exactly will have by default their age sampled at random from the given range. If you want to use the midpoint, deselect "Age range: sample at random" [update 2020-10-05].')
                         helpText('The SOCRATES platform has been updated since the publication in BMC Research Notes. See the "Updates" tab for more info.')
                ),
                tabPanel("Matrix per capita", 
                         helpText('This per capita matrix presents the daily contact rate for every individual of an age group with all other individuals in the population.'),
                         plotOutput('plot_cnt_matrix_per_capita',width = "80%", height = "300px")),
                tabPanel("Contact rates", 
                         plotOutput('plot_mean_number_contacts',width = "80%", height = "300px")),
                tabPanel("Transmission dynamics",
                           #helpText('In this section, the next-generation analysis is presented. It includes the next-generation matrix (NGM), the respective sum of columns (k.j) and rows (ki.), the calculation of the reproduction number (R), and the cumulative elasticity for each age group. The relative impact (RI) is shown in the final two figures.'),
                           #hr(),
                           helpText(HTML("In the context of a susceptible-infectious-removed (SIR) model with a discrete age structure, 
                                    the transmission process is described by an <em>n</em> × <em>n</em> next-generation matrix <em>K</em>, where <em>n</em> represents the number of age classes. 
                                    Each entry of this matrix (<em>k<sub>ij</sub></em>) corresponds to the average number of infections caused by an individual in age group <em>j</em> 
                                    in age group <em>i</em> throughout the course of its infection, where <em>i</em>, <em>j</em> = 1, ..., 7.
                                    
                                    Matrix <em>K</em> can be expressed as:
                                    
                                    <br><br>
                                    <div style='text-align: center;'>
                                    <em>K</em> = <em>q</em> * <em>A</em> * <em>M</em><sup>⊺</sup> * <em>H</em>
                                    </div>
                                    <br>
                                                                        
                                    where:
                                    
                                    <ul>
                                    <li>The proportionality factor <em>q</em> accounts for the infectious period and other factors affecting transmission.</li>
                                    <li><em>A</em> and <em>H</em> are diagonal matrices containing entries related to the susceptibility and infectivity for each age group, respectively.</li>
                                    <li><em>M</em><sup>⊺</sup> represents the transposed contact matrix.</li>
                                    </ul>")
                           ), 
                           hr(),
                           tags$h3("Relative incidence"),
                         helpText(HTML('The leading right eigenvector of matrix <em>K</em> is proportional to the expected incidence by age and is independent of the proportionality factor <em>q</em>. The normalized values, which sum to 1, represent the relative incidence, reflecting the risk of infection across different age groups.')),
                         plotOutput('plot_relative_incidence',width = "80%", height = "300px"),
                         hr(),
                         #tags$h3("Parameter summary"),
                         dataTableOutput('table_NGA_parameters'),
                         hr(),
                         conditionalPanel(
                           condition = "input.sel_transmission == 'sensitivity'",
                           tags$h3("Next generation matrix"),
                           helpText('The next generation matrix represents the average number of infections in age group i caused by an individual in group j during their infectious period, given proportionality factor q.'),
                           plotOutput('plot_NGM',width = "80%", height = "300px"),
                           hr(),
                           tags$h3("Sensitivity and elasticity"),
                           helpText(HTML("Matrix <em>K</em> can be used to relate the total number of infections between two consecutive generations. 
                                          Aggregating the columns or rows provides information on the average number of infections per generation either 
                                          caused by age group <em>j</em> (denoted as <em>k<sub>j.</sub></em>) or acquired in age group <em>i</em> 
                                          (denoted as <em>k<sub>.i</sub></em>). Additionally, the dominant eigenvalue of matrix <em>K</em> can be 
                                          interpreted as the reproduction number <em>R</em>, which is indicated by the dashed line. Elasticity 
                                         represents the relative contribution of each age group to the overall reproduction number (<em>R</em>)")
                           ),
                           plotOutput('plot_ELAS',width = "100%", height = "300px"),
                           # helpText('Figure 2: Transmission indicators. Indicator "kj." corresponds to the sum of columns of the NGM and can be interpreted as the average number of infections caused by an 
                           #          individual in age group j during their infectious period. "ki." corresponds to the per-generation total number of infections in age group i caused by a single individual 
                           #          of each age group. Elasticities can be interpreted as the relative contribution of an age group towards overall reproduction number (R), which is presented with the dashed line.'),
                           #helpText('Figure 2: Transmission indicators <em>k<sub>j.</sub></em>, <em>k<sub>.i</sub></em> and the reproduction number R. Elasticity can be interpreted as the relative contribution of an age group towards overall reproduction number (R), which is presented with the dashed line.'),
                           #helpText(HTML('Transmission indicators <em>k<sub>j.</sub></em>, <em>k<sub>.i</sub></em> and the reproduction number (<em>R</em>). Elasticity represents the relative contribution of each age group to the overall reproduction number (<em>R</em>), which is indicated by the dashed line.')),
                           hr(),
                           tags$h3("Relative impact"),
                           helpText(HTML("Changes in susceptibility or infectivity due to factors such as vaccination programs, non-pharmaceutical interventions, or the depletion of susceptibles will lead to 
                                         perturbations in the elements of matrix <em>K</em>, and consequently, in the basic reproduction number (<em>R<sub>0</sub></em>) and relative incidence. The ratio of 
                                         <em>K<sup>update</sup></em> to <em>K<sup>baseline</sup></em> can be interpreted as an approximation of the relative change in the number of infections in the 
                                         <em>m</em><sup>th</sup> generation, given a proportional perturbation (<em>p</em>) in susceptibility or infectivity, assuming no other perturbations to <em>K</em> occurred up to the 
                                         <em>m</em><sup>th</sup> generation.")
                           ),
                           plotOutput('plot_RI_a',width = "80%", height = "300px"),
                           #helpText('The relative number of cases in each age group after the projection time (m) considered, given a proportional perturbation (p) to the susceptibility of the infectee. The comparator is the scenario without any change in susceptibility.'),
                           #hr(),
                           plotOutput('plot_RI_h',width = "80%", height = "300px")#,
                           #helpText('The relative number of cases in each age group after the projection time (m) considered, given a proportional perturbation (p) to the infectivity of the infector. The comparator is the scenario without any change in infectivity.')
                           # tags$h3("Parameter summary 2:"),
                           # dataTableOutput('table_NGA_sens_parameters'),
                           ),
                         conditionalPanel(
                           condition = "input.sel_transmission != 'sensitivity'",
                           tags$h3("More?"),
                           helpText('Enable the sensitivity and elasticity parameters in the left column under "Transmission" to get the next generation matrix and other insights on the transmission dynamics'),
                           )),
                         #),
                tabPanel("Participants", 
                         helpText('Brief summary of participant data:'),
                         dataTableOutput('table_participants')),
                tabPanel("Weights",     
                         uiOutput("project_website_weights"),
                         dataTableOutput('table_weights')),
                tabPanel("Data sets",
                         uiOutput("project_website_data"),
                         div(dataTableOutput("social_contact_data")), style = "font-size:80%"),
                tabPanel("About CoMix",
                        includeMarkdown("doc/doc_comix.md")),
                tabPanel("Updates",
                         includeMarkdown("doc/doc_updates.md"))
        )
  )
))