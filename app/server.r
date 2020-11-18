library(shiny)
library(dplyr)
library(plotly)
library(readxl)
library(lubridate)
#library(shinyalert)
library(shinyWidgets)
library("httr")
library("jsonlite")
library(rgdal)
library(leaflet)

###### Desactivar notacion cientifica
options(scipen=999,enconding = 'UTF-8')

#### CONSTANTES ####

FONT = list(family = 'Arial Rounded MT Bold')

GRIS = 'rgb(127, 127, 127)'
AZUL = 'rgb(0, 32, 96)'
AMARILLO = 'rgb(255, 192, 0)'

COLORES = c(GRIS,AZUL,AMARILLO)




####### SERVER #######
shinyServer(function(input, output, session){

  ####### BASES DE DATOS #######  
  
  #Datos Procesados
  datos_procesados <- read_excel("data/datos_procesados.xlsx",sheet=1)
  datos_procesados <- select(datos_procesados,FECHA,BARRIO,CLASE,GRAVEDAD,LONGITUD,LATITUD)
  #Clustering
  clustering <- read_excel("data/clustering.xlsx",sheet=1)


  ######## SALIDA ##########
  
  
  
  #### INICIO ####
  
  
  #### DATOS ####
  
  output$tabla <- renderUI({
      box(width=12,renderDataTable(datos_procesados))
  })
  
  #### DESCRIPTIVO ####
  
  
  #### CLUSTERING ####
  output$map_cluster <- renderLeaflet({
    #dir<-paste(getwd(),"/mapas", sep = "", collapse = NULL)
  
    dir <- "mapas/"
    cc <- readOGR( 
      dsn= dir,
      layer="Barrio_Vereda",
      verbose=TRUE
    )
    
    leaflet(width = "100%")%>% addTiles(attribution = "overlay data© mapsnigeriainitiative 2016")%>% setView(-75.60272578, 6.21901553, 11) %>%  # add the default basemap along with setting the view (lng, lat) and initial zoom 
      addPolygons(data = cc, fill=TRUE, stroke = TRUE, color = "red", popup = paste0("Name:",cc$NOMBRE,"<br>", "Pop:", cc$total))
  })
  
  #### PREDICTIVO ####
  base <- "https://jor45458.pythonanywhere.com/Predictor/predecir/"
  get_request <- GET(base)
  print(get_request)
  #get_request_json <- fromJSON(get_request, flatten = TRUE)
  #get_prices_text <- content(get_request, "text")
  
  print(input$Predecir)
  #EXAMPLE INFOBOX
  output$example_infobox <- renderInfoBox({valueBox('Example',100,icon = icon("gavel"),color = "blue")})


})

