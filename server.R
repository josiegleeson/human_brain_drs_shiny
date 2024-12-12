


server <- function(input, output, session) {
  
  # load the data
  all <- readRDS("data/general.rds")
  polyA_data <- readRDS("data/polya.rds")
  m6A_data <- readRDS("data/m6a.rds")
  dei_data <- readRDS("data/dei.rds")
  
  # update drop-down choices based on checkbox
  observe({
    # begin filter with all gene names
    filtered_genes <- unique(all$gene_name)
    
    # filter dei_data
    if (input$filter_up_PFC || input$filter_up_CN || input$filter_up_CB) {
      dei_data_filtered <- dei_data
      if (input$filter_up_PFC) {
        dei_data_filtered <- dei_data_filtered %>% filter(up_in_PFC == TRUE)
      }
      if (input$filter_up_CN) {
        dei_data_filtered <- dei_data_filtered %>% filter(up_in_CN == TRUE)
      }
      if (input$filter_up_CB) {
        dei_data_filtered <- dei_data_filtered %>% filter(up_in_CB == TRUE)
      }
      # reduce filtered_genes to the intersection with m6A results
      filtered_genes <- intersect(filtered_genes, unique(dei_data_filtered$gene_name))
    }
    
    # filter m6A_data
    if (input$filter_DM_within || input$filter_DM_between) {
      m6A_data_filtered <- m6A_data
      if (input$filter_DM_within) {
        m6A_data_filtered <- m6A_data_filtered %>% filter(DM_within == TRUE)
      }
      if (input$filter_DM_between) {
        m6A_data_filtered <- m6A_data_filtered %>% filter(DM_between == TRUE)
      }
      # reduce filtered_genes to the intersection with m6A results
      filtered_genes <- intersect(filtered_genes, unique(m6A_data_filtered$gene_name))
    }
    
    # filter polyA_data
    if (input$filter_dynamic || input$filter_diff) {
      polyA_data_filtered <- polyA_data
      if (input$filter_dynamic) {
        polyA_data_filtered <- polyA_data_filtered %>% filter(dynamic == TRUE)
      }
      if (input$filter_diff) {
        polyA_data_filtered <- polyA_data_filtered %>% filter(differential_polyA_between_brain_regions == TRUE)
      }
      # reduce filtered_genes to the intersection with polyA results
      filtered_genes <- intersect(filtered_genes, unique(polyA_data_filtered$gene_name))
    }
    
    # handle case where no filters are active
    if (length(filtered_genes) == 0) {
      filtered_genes <- unique(all$gene_name)
    }
    
    # update the gene_name drop-down
    updateSelectInput(
      session,
      inputId = "gene_name",
      choices = filtered_genes
    )
  })
  
  
  # filter and display data based on selected transcript_id
  output$dei_table <- renderTable({
    req(input$gene_name) # ensure input is selected
    
    # filter the data
    filtered_dei_data <- subset(dei_data, gene_name == input$gene_name)
    
    # select relevant columns to display
    display_dei_data <- data.frame(isoform = filtered_dei_data$transcript_id,
                                   up_in_PFC = filtered_dei_data$up_in_PFC,
                                   up_in_CN = filtered_dei_data$up_in_CN,
                                   up_in_CB = filtered_dei_data$up_in_CB)
    
    # return the filtered data
    display_dei_data
  })
  
  # filter and display data based on selected transcript_id
  output$m6a_table <- renderTable({
    req(input$gene_name) # ensure input is selected
    
    # filter the data
    filtered_m6a_data <- subset(m6A_data, gene_name == input$gene_name)
    
    # select relevant columns to display
    display_m6a_data <- data.frame(isoform = filtered_m6a_data$transcript_id,
                               brain_region = filtered_m6a_data$brain_region,
                               number_sites = filtered_m6a_data$number_sites,
                               DM_within = filtered_m6a_data$DM_within,
                               DM_between = filtered_m6a_data$DM_between)
    
    
    # return the filtered data
    display_m6a_data
  })
  
  # filter and display data based on selected transcript_id
  output$polya_table <- renderTable({
    
    req(input$gene_name) # ensure input is selected
    
    # filter the data
    filtered_polya_data <- subset(polyA_data, gene_name == input$gene_name)
    
    # select columns to display
    display_polya_data <- data.frame(isoform = filtered_polya_data$transcript_id,
                                     brain_region = filtered_polya_data$brain_region,
                                     median_polyA_length = filtered_polya_data$median_polya_length,
                                     polyA_IQR = filtered_polya_data$polya_iqr,
                                     dynamic = filtered_polya_data$dynamic,
                                     differential = filtered_polya_data$differential_polyA_between_brain_regions)
    
    
    # return filtered data
    display_polya_data
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      "isovis_files.zip"
    },
    content = function(file) {
      # Replace this path with the actual location of 'data/result.zip' on your server
      file.copy("data/m6a_files_isovis.zip", file)
    }
  )
  
}