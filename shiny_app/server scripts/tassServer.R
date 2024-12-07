## Server logic for TASS Projection tab ----

###############################################.
## Indicator definitions ----
###############################################.
#Subsetting by domain 

output$tass_tsr <- renderUI({
  
  HTML("To assess if young stands will meet future volume expectations, each YSM tree list is projected in TASS from its latest measurement date to 
rotation, and compared against each spatially matched TSR yield table. TASS3 is run for all YSM ground samples comprising at least 80% 
(by basal area) of PL & SW combined, while TASS2 is run for all other YSM ground samples. No genetic gain estimates are applied, since 
ground based SI estimates are used for all YSM TASS projections.</br>

All YSM TASS projected volumes include the following adjustments: default Operational Adjustment Factors OAF1 (15%) and OAF2 (5%), 
stem rust (DSG, DCS, & DSS) impacts modeled in GRIM & CRIME from samples measured in 2017 or later, plus all remaining forest health 
impacts applied as interim approximations (see previous section). Note that endemic losses from pests and disease are assumed to be part 
of OAF2, so there can be some double-counting with the inclusion of the stem rust modules plus additional interim forest health impacts. 
There may also be some double-counting of non-productive area and stocking gap losses already assumed to be a component of OAF1, as 
these are also captured through the unbiased grid sample design of the YSM program. </br>

The average of all YSM TASS projections (red lines) are compared against the average of all spatially matched TSR yield tables (blue line), 
together with 95% confidence intervals (dashed lines). If the TSR projection overlaps within the 95% confidence interval of the average 
YSM TASS projection, then it is reasonable to assume young stands may meet future timber supply expectations. If not, there may be a 
need to revisit TSR input assumptions or TSR growth expectations.")
  
})


#meanage <- reactive({
#  
#  req(input$SelectCategory, input$SelectVar)
#  input$genearate
#  
#  meanage = ysm_msyt_vdyp_volume %>%
#    filter(CLSTR_ID %in% clstr_id()) %>%
#    summarize(meanage = mean(ref_age_adj)) %>%
#    pull(meanage)
#  
#  return(meanage)
#  
#})
#
#
#volproj <- reactive({
#  
#  req(input$SelectCategory, input$SelectVar)
#  input$genearate
#  
#  risk_vol <- risk_vol()
#  meanage <- meanage()
#  
#  year100_immed <- year100_immed()
#  year100_inc<- year100_inc()
#  year100_comb<- year100_comb()
#  
#  volproj <- tsr_tass_volproj %>%
#    filter(CLSTR_ID %in% clstr_id()) %>%
#    mutate(GMV_adj1 = GMV_adj*(1- year100_immed/100)*
#             (1-max(AGE - meanage, 0)*year100_inc/100*sum(risk_vol[risk_vol$mort_flag==2,]$volperc)),
#           n_si = length(unique(SITE_IDENTIFIER)))
#  
#  volproj1 <- volproj %>%
#    #filter(!is.na(rust)) %>%
#    group_by(rust, AGE) %>%
#    summarize(meanvol_tsr = mean(volTSR, na.rm = T),
#              sd_tsr = sd(volTSR , na.rm = T),
#              meanvol_tass = mean(GMV_adj1, na.rm = T),
#              sd_tass = sd(GMV_adj1 , na.rm = T),
#              n = n()) %>%
#    ungroup() %>%
#    mutate(se_tsr = sd_tsr/sqrt(n),
#           se_tass = sd_tass/sqrt(n),
#           tstat = ifelse(n >1, qt(0.975, n-1), NA),
#           u95_tsr = meanvol_tsr + tstat*se_tsr,
#           l95_tsr = meanvol_tsr - tstat*se_tsr,
#           mai_tsr = meanvol_tsr/AGE,
#           u95_tass = meanvol_tass + tstat*se_tass,
#           l95_tass = meanvol_tass - tstat*se_tass,
#           mai_tass = meanvol_tass/AGE)
#  
#  return(volproj1)
#})
#
#
#projectiontable <- reactive({
#  
#  req(input$SelectCategory, input$SelectVar)
#  input$genearate
#  
#  risk_vol <- risk_vol()
#  meanage <- meanage()
#  
#  year100_immed <- year100_immed()
#  year100_inc<- year100_inc()
#  year100_comb<- year100_comb()
#  
#  projectiontable <- tsr_tass_volproj %>%
#    filter(CLSTR_ID %in% clstr_id(), AGE %in% c(60, 70, 80, 90, 100), rust == "Y") %>%
#    mutate(GMV_adj1 = GMV_adj*(1- year100_immed/100)*
#             (1-max(AGE - meanage, 0)*year100_inc/100*sum(risk_vol[risk_vol$mort_flag==2,]$volperc)),
#           voldiff = volTSR - GMV_adj1) %>%
#    group_by(AGE) %>%
#    summarize(n_samples = n(),
#              meanvol_tsr = round(mean(volTSR, na.rm = T), 0),
#              meanvol_tass = round(mean(GMV_adj1, na.rm = T), 0),
#              meanvoldiff = round(mean(voldiff, na.rm = T), 0),
#              sdvoldiff = sd(voldiff, na.rm = T)) %>%
#    ungroup() %>%
#    mutate(se_voldiff = sdvoldiff/sqrt(n_samples),
#           pval = round(2*pt(abs(meanvoldiff)/se_voldiff, n_samples-1, lower.tail = F), 3),
#           percvoldiff = paste0(round(meanvoldiff/meanvol_tass*100, 0), "%"))
#  
#  return(projectiontable)
#  
#})


output$tass_tsr_netvol <- renderPlot({
  
  volproj <- volproj()
  meanage <- meanage()
  
  volproj1 <- volproj %>%
    arrange(SITE_IDENTIFIER, VISIT_NUMBER, CLSTR_ID, desc(xy), desc(rust)) %>%
    group_by(SITE_IDENTIFIER, AGE) %>%
    slice(1) %>%
    ungroup() %>%
    #filter(!is.na(rust)) %>%
    group_by(AGE) %>%
    summarize(meanvol_tsr = mean(volTSR, na.rm = T),
              sd_tsr = sd(volTSR , na.rm = T),
              meanvol_tass = mean(volTASS_adj, na.rm = T),
              sd_tass = sd(volTASS_adj , na.rm = T),
              n = n()) %>%
    ungroup() %>%
    mutate(se_tsr = sd_tsr/sqrt(n),
           se_tass = sd_tass/sqrt(n),
           tstat = ifelse(n >1, qt(0.975, n-1), NA),
           u95_tsr = meanvol_tsr + tstat*se_tsr,
           l95_tsr = meanvol_tsr - tstat*se_tsr,
           mai_tsr = meanvol_tsr/AGE,
           u95_tass = meanvol_tass + tstat*se_tass,
           l95_tass = meanvol_tass - tstat*se_tass,
           mai_tass = meanvol_tass/AGE)
  
  p <- volproj1 %>%
    ungroup() %>%
    #filter(rust == "Y") %>%
    mutate(l95_tsr = ifelse(l95_tsr < -10, NA, l95_tsr),
           u95_tsr = ifelse(l95_tsr < -10, NA, u95_tsr),
           l95_tass = ifelse(l95_tass < -10, NA, l95_tass),
           u95_tass = ifelse(l95_tass < -10, NA, u95_tass)) %>%
    ggplot() +
    #geom_point(aes(x = AGE, y = meanvol_tsr, col = "deepskyblue"), size = 0) +
    geom_line(aes(x = AGE, y = meanvol_tsr, col = "deepskyblue"), linewidth = 1.1) +
    geom_ribbon(aes(x = AGE, ymin = l95_tsr, ymax = u95_tsr, col = "deepskyblue"), 
                alpha =0, linetype = 2) +
    geom_point(aes(x = AGE, y = meanvol_tass, col = "red"), size = 2) +
    geom_line(aes(x = AGE, y = meanvol_tass, col = "red"), linewidth = 1.1) +
    geom_ribbon(aes(x = AGE, ymin = l95_tass, ymax = u95_tass, col = "red"), 
                alpha =0, linetype = 2)  +
    scale_color_manual(values = c("deepskyblue", "red"), name = NULL, 
                       labels = c("TSR Mean & 95% CI", "YSM (TASS projected) Mean & 95% CI")) +
    scale_y_continuous(expand = c(0, 0)) +
    scale_x_continuous(expand = c(0, 0), breaks=seq(0, 100, 10),
                       limits = c(0, 110)) + 
    labs(x = "Total Age (yrs)", y = "Net merch volume (m3/ha)*",
         caption = "* Net merchantable volume includes all species (deciduous + conifer), but excludes the modeled residual component in YSM TASS projections.
") +
    #theme_bw(base_size = 22) + 
    #theme_bw() + 
    theme(
      axis.line = element_line(colour="darkgray"), 
      #axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
      panel.grid.major.y = element_line(color = 'darkgray'), 
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      rect = element_blank(),
      legend.box.background = element_rect(fill = "white", color = "lightgray"),
      legend.position = c(0.2, 0.9),
      legend.title = element_blank(),
      plot.caption = element_text(hjust=0, size=rel(0.8))
    )  +
    guides(colour = guide_legend(reverse = TRUE))
  
  p
  
})


output$tasstable_flex <- renderUI({
  
  stemrustimpact <- stemrustimpact()
  
  tasstable <- stemrustimpact %>%
    select(AGE, rustimpact) %>%
    flextable %>%
    align(align = "right", part = "body") %>%
    set_header_labels(values = list(Year = "Age", rustimpact = "% Vol")) %>%
    set_caption(as_paragraph(
      as_chunk("Impact of stem rust models included in TASS projections:"))) %>%
    autofit()
  
  return(tasstable %>%
           htmltools_value())   
  
})


output$culmtable_flex <- renderUI({
  
  volproj <- volproj()
  
  volproj1 <- volproj %>%
    arrange(SITE_IDENTIFIER, VISIT_NUMBER, CLSTR_ID, desc(xy), desc(rust)) %>%
    group_by(SITE_IDENTIFIER, AGE) %>%
    slice(1) %>%
    ungroup() %>%
    #filter(!is.na(rust)) %>%
    group_by(AGE) %>%
    summarize(meanvol_tsr = mean(volTSR, na.rm = T),
              sd_tsr = sd(volTSR , na.rm = T),
              meanvol_tass = mean(volTASS_adj, na.rm = T),
              sd_tass = sd(volTASS_adj , na.rm = T),
              n = n()) %>%
    ungroup() %>%
    mutate(se_tsr = sd_tsr/sqrt(n),
           se_tass = sd_tass/sqrt(n),
           tstat = ifelse(n >1, qt(0.975, n-1), NA),
           u95_tsr = meanvol_tsr + tstat*se_tsr,
           l95_tsr = meanvol_tsr - tstat*se_tsr,
           mai_tsr = meanvol_tsr/AGE,
           u95_tass = meanvol_tass + tstat*se_tass,
           l95_tass = meanvol_tass - tstat*se_tass,
           mai_tass = meanvol_tass/AGE)
  
  culmtable <- rbind(
    volproj1 %>% slice(which.max(mai_tass)) %>% select(AGE, mai = mai_tass),
    volproj1 %>% slice(which.max(mai_tsr)) %>% select(AGE, mai = mai_tsr))
  
  culmtable$Proj <- c("YSM (TASS proj)", "TSR")
  
  culmtable <- culmtable %>%
    select(Proj, mai, AGE) %>%
    mutate(mai = round(mai, 2)) %>%
    flextable() %>%
    colformat_num(col_keys = c("mai"), digits = 2) %>% 
    color(i = 1:2, color = c("red", "deepskyblue"), part = "body") %>%
    set_header_labels(Proj = "Culmination", mai = "MAI\n (m3/ha/yr)", AGE = "Age\n (yrs)") %>% 
    align(align ='center', part = 'header')
  
  return(culmtable %>%
           htmltools_value())   
  
})



output$tass_tsr_test <- renderUI({
  
  projectiontable <- projectiontable()
  prjtab_70 <- projectiontable %>% filter(AGE >=70)
  
  max_row = which.max(abs(prjtab_70$meanvoldiff/prjtab_70$meanvol_tass*100))
  
  maxvoldiff = prjtab_70$percvoldiff[max_row]
  ageatmaxvoldiff = prjtab_70$AGE[max_row]
  Significant = ifelse(prjtab_70$pval[max_row] <0.05, "Yes", "No")
  TSRbias1 = ifelse(prjtab_70$meanvoldiff[max_row] < 0, "Conservative", "Optimistic")
  TSRbias2 = ifelse(Significant == "No", "No", TSRbias1)
  
  HTML( paste0("TSR MSYTs are evaluated against YSM TASS projections, using paired t-tests 
of the volume differences (TSR-YSM) projected from 60 & 100 years. 
Highlighted fields (table below) indicate significant differences at alpha = 
0.05. Overall percent differences are computed as (TSR-YSM)/YSM, and the 
age at maximum percent volume difference is identified (table below).", 
               "</br>", "</br>", 
               "<hX><b>Assessment of TSR bias between 70-90 years</b></hX></br>",
               "<ul><li><b><i>Max % vol diff</i></b>",'&emsp;', maxvoldiff, "</li>",
               "<li><b><i>Age @max vol diff</i></b>",'&emsp;', ageatmaxvoldiff, "</li>",
               "<li><b><i>Significant?</b>(when n >= 10)</i>",'&emsp;', 
               ifelse(Significant == "Yes", "<font color='#FF0000'>", ""), 
               Significant, ifelse(Significant == "Yes", "</font>", ""), "</li>",
               "<li><b><i>TSR bias?</i></b>", '&emsp;', TSRbias2, "</li></br></li></ul>"))
               
})



output$tass_tsr_volproj <- renderUI({
  
  projectiontable <- projectiontable()
  
  projectiontable1 <- data.frame(t(projectiontable %>% select(-sdvoldiff, -se_voldiff, -AGE)))
  rownames(projectiontable1) <- c('# YSM samples', "TSR Mean Proj. Vol", "YSM Mean Proj. Vol",
                                  "Mean vol diff", "P-value of vol diff", 
                                  "% vol diff")
  
  colormatrix <- ifelse(projectiontable1[5,] < 0.05, "red", "black")
  
  projectiontable2 <- flextable(projectiontable1 %>% 
              rownames_to_column(" ")) %>% 
    set_header_labels(values = c("Projection age (yrs)", '60', '70', '80', '90', '100'))  %>% 
    color(i = 5, j = 2:6, col = colormatrix, part = "body") %>%
    align(align = "center", part = "all")  %>%
    autofit()
  
  return(projectiontable2 %>%
           htmltools_value())   
  
})



