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
library(lubridate)
knitr::opts_chunk$set(echo = TRUE)
library('BBmisc')
library(viridis)  # paletas de colores

###### Desactivar notacion cientifica
options(scipen=999,enconding = 'UTF-8')

#### CONSTANTES ####

FONT = list(family = 'Arial Rounded MT Bold')

GRIS = 'rgb(127, 127, 127)'
AZUL = 'rgb(0, 32, 96)'
AMARILLO = 'rgb(255, 192, 0)'

COLORES = c(GRIS,AZUL,AMARILLO)


mapa_barrios <- function(){
  dir<-paste(getwd(),"./mapas/mapa_barrios_usado", sep = "", collapse = NULL)
  print(dir)
  
  barriosShape <- readOGR( 
    dsn= dir,
    layer="Barrio_Vereda",
    verbose=TRUE
  )
  
  barriosShape$numerica <- as.numeric(barriosShape$CLUSTER)
  
  # Variable categorica
  barriosShape$categorica <- case_when(barriosShape$numerica == 1 ~ "peligro moderado", barriosShape$numerica == 0 ~ "peligro bajo", barriosShape$numerica == 2 ~ "peligro alto", barriosShape$numerica == 3 ~ "no agrupado")
  
  palnumeric <- colorNumeric("viridis", c(0,3))
  palnumeric <- colorNumeric(c("aliceblue","brown4"), 0:2)
  
  popup <- paste0("<style> div.leaflet-popup-content {width:auto !important;}</style>","<b>", "Nombre del barrio: ", "</b>", as.character(barriosShape$NOMBRE), 
                  "<br>", "<b>", "Capital: ", "</b>", as.character("hola"), "<br>", 
                  "<b>", "Area: ", "</b>", "dsa", "<br>", "<b>", 
                  "Num. Aleatorio ", "</b>", "specify_decimal", "<br>", "<b>", 
                  "Grupo al que pertenece: ", "</b>", as.character(barriosShape$categorica), "<br>",
                  "<table>", "<tr>",
                  "<th>","tipo","</th>",
                  "<th>","atropello","</th>",
                  "<th>","caida ocupante","</th>",
                  "<th>","choque","</th>",
                  "<th>","otro","</th>",
                  "<th>","volcamiento","</th>",
                  "</tr>",
                  "<th>","promedio","</th>",
                  "<td>","cantidadatropello","</td>",
                  "<td>","cantidad caida ocupante","</td>",
                  "<td>","cant choque","</td>",
                  "<td>","cant otro","</td>",
                  "<td>","cant volca","</td>",
                  "</tr>",
                  
                  
                  "</table>",
                  "<table>", "<tr>",
                  "<th>","tipo","</th>",
                  "<th>","atropello","</th>",
                  "<th>","caida ocupante","</th>",
                  "<th>","choque","</th>",
                  "<th>","otro","</th>",
                  "<th>","volcamiento","</th>",
                  "</tr>",
                  "<th>","promedio","</th>",
                  "<td>","cantidadatropello","</td>",
                  "<td>","cantidad caida ocupante","</td>",
                  "<td>","cant choque","</td>",
                  "<td>","cant otro","</td>",
                  "<td>","cant volca","</td>",
                  "</tr>",
                  
                  
                  "</table>"
                  
  )
  
  leaflet(barriosShape) %>%
    # Opcion para anadir imagenes o mapas de fondo (tiles)
    setView(-75.60272578, 6.21901553, 11) %>%
    # Funcion para agregar poligonos
    addPolygons(color = "#444444" ,
                weight = 1, 
                smoothFactor = 0.5,
                opacity = 1.0,
                fillOpacity = 0.5,
                fillColor = case_when(barriosShape$numerica != 3 ~palnumeric(barriosShape$numerica)),    # Color de llenado
                highlightOptions = highlightOptions(color = "white", weight = 2,
                                                    bringToFront = TRUE), #highlight cuando pasas el cursor
                label = ~barriosShape$NOMBRE ,                                  # etiqueta cuando pasas el cursor
                labelOptions = labelOptions(direction = "auto"),
                popup = popup)%>%addTiles(attribution = "overlay data mapsnigeriainitiative 2016")
}


















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

  output$map_cluster <- renderLeaflet({mapa_barrios()})
  #EXAMPLE INFOBOX
  output$example_infobox <- renderInfoBox({valueBox('Example',100,icon = icon("gavel"),color = "blue")})
  
  
  
  
  #### PREDICTIVO ####
  base <- "https://jor45458.pythonanywhere.com/Predictor/predecir/"
  
  data <- data.frame()
  reactivo = reactive({
    
    get_request <- GET(base)
    datos <- list(
      fecha_inicial = input$fecha_inicio,
      fecha_final = input$fecha_fin,
      #d -> dia; m -> mes; s -> semana
      resoluciontemporal = input$resolucion_temporal,
      
      #variable constante
      Modelo = "RF"
    )
    res <- POST("https://jor45458.pythonanywhere.com/Predictor/predecir/", body = datos, encode = "json")
    res <- content(res)
    data = data.frame(res)
    #print(head(data))
    #print(res)
    data
    
    
    
    
  })

  
  output$atropello = renderInfoBox({valueBox('Atropello',data$Resultado$Atropello,icon = icon("gavel"),color = "blue")})

  
  



})

