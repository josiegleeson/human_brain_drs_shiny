

ui <- dashboardPage(
    dashboardHeader(title = "Gleeson et al. 2024"),
    # tabs
    dashboardSidebar(
        sidebarMenu(
            menuItem("Welcome", tabName = "welcome", icon = icon("house")),
            menuItem("Explore data", tabName = "explore_polya", icon = icon("magnifying-glass")),
            menuItem("IsoVis", tabName = "dl_data", icon = icon("eye"))
        )
    ),
    # body
    dashboardBody(
        # Add custom CSS to remove borders
        tags$head(
            tags$style(HTML("
                .box {
                    border: none !important;
                    box-shadow: none !important;
                }
            "))
        ),
        tabItems(
            
            tabItem(tabName = "welcome",
                    fluidRow(
                        column(12,
                            div(class = "box box-primary", style = "padding-right: 5%; padding-left: 5%; font-size:110%", 
                            div(class = "box-body", shiny::includeMarkdown("welcome-page-text.md")),
                            img(src = "images/Fig1.png", width = "100%"),
                            br(),
                            br(),
                            h5("For questions or to report issues please contact: josie.gleeson@unimelb.edu.au"),
                            br(),
                       )
                )
            )),
            
            tabItem(
                tabName = "explore_polya",
                fluidRow(
                    # Dropdown for genes
                    box(
                        width = 12,
                        h3("Select a gene:"), 
                        selectInput(
                            inputId = "gene_name",
                            label = "",
                            choices = NULL # Populated dynamically
                        ),
                        h5(actionLink("show_instructions", "More information")),
                        conditionalPanel(
                            condition = "input.show_instructions % 2 == 1",
                            p("All genes in the data are initially available for selection."),
                            p("Ticking the checkboxes below filters the gene list, so that only genes with isoforms matching the selected criteria are now available to select."),
                            p("All isoforms within the selected gene are displayed in the tables below, even if only some isoforms meet the filtering criteria."),
                            p("Brain regions: prefrontal cortex = PFC, caudate nucleus = CN, cerebellum = CB.")
                        ),
                        br(),
                        h5(strong("Differential expression filters:")),
                        checkboxInput(
                            inputId = "filter_up_PFC",
                            label = "Isoforms with increased expression in PFC",
                            value = FALSE
                        ),
                        checkboxInput(
                            inputId = "filter_up_CN",
                            label = "Isoforms with increased expression in CN",
                            value = FALSE
                        ),
                        checkboxInput(
                            inputId = "filter_up_CB",
                            label = "Isoforms with increased expression in CB",
                            value = FALSE
                        ),
                        h5(strong("Differential modification (DM) filters:")),
                        checkboxInput(
                            inputId = "filter_DM_within",
                            label = "Isoforms with DM within a brain region",
                            value = FALSE
                        ),
                        checkboxInput(
                            inputId = "filter_DM_between",
                            label = "Isoforms with DM between brain regions",
                            value = FALSE
                        ),
                        h5(strong("PolyA filters:")),
                        checkboxInput(
                            inputId = "filter_dynamic",
                            label = "Isoforms with dynamic polyA lengths (top 250 isoforms per brain region with the largest polyA length interquartile range (IQR))",
                            value = FALSE
                        ),
                        checkboxInput(
                            inputId = "filter_diff",
                            label = "Isoforms with differential polyA lengths between brain regions",
                            value = FALSE
                        )
                    )
                    
                ),
                fluidRow(
                    box(
                        width = 12,
                        h3("Differential expression data per brain region:"),
                        tableOutput("dei_table"),
                        h3("M6A data per brain region:"),
                        tableOutput("m6a_table"),
                        h3("PolyA tail data per brain region:"),
                        tableOutput("polya_table")
                    )
                )
            ),
            
            tabItem(tabName = "dl_data",
                    fluidRow(
                        box(width = 12,
                               h3("Visualisation with IsoVis:"),
                               h5("Download the zip file below, unzip the files and upload these files into IsoVis. This contains m6A modification data summarised to genomic positions."),
                               downloadButton(outputId = "download_data", label = "Download"),
                               br(),
                               br(),
                            h5(actionLink("show_isovis_steps", "Instructions for using IsoVis")),
                            conditionalPanel(
                                condition = "input.show_isovis_steps % 2 == 1",
                                p("Step 1: Click 'Upload data'. For the 'Stack data' upload 'gencode.v31.filtered.gtf'. For the 'Heatmap data' upload 'transcript_counts.csv'."),
                                p("Step 2: Check the box 'Show m6A sites data upload options'."),
                                p("Step 3: For the 'm6A sites data' upload 'genomic_m6a_positions.bed'. For the 'm6A modification level data' upload 'genomic_m6a_rates_updated.csv'. Then click 'Apply'."),
                                p("Step 4: Type a gene to view and press enter."),
                                p("Step 5: Click 'Stack options' and select 'm6A sites' from the drop-down menu.")
                            )
                        ),
                        box(width = 12,
                            tags$iframe(src = "https://isomix.org/isovis/", 
                                        width = "100%", 
                                        height = "800px",
                                        style = "border:none;"))
                    ))
            
        )
    ),
    skin = "blue" 
)
