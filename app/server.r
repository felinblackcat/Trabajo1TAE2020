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
#library('BBmisc')
#library(viridis)  # paletas de colores
set.seed(19990)

###### Desactivar notacion cientifica
#options(scipen=999,enconding = 'UTF-8')

#### CONSTANTES ####

FONT = list(family = 'Arial Rounded MT Bold')

GRIS = 'rgb(127, 127, 127)'
AZUL = 'rgb(0, 32, 96)'
AMARILLO = 'rgb(255, 192, 0)'

COLORES = c(GRIS,AZUL,AMARILLO)

mapa_barrios <- function(){
  
  dir<-paste("./mapas/mapa_barrios_usado", sep = "", collapse = NULL)
  print(dir)
  
  barriosShape <- readOGR( 
    dsn= dir,
    layer="Barrio_Vereda",
    verbose=TRUE
  )
  
  geoData<-read.csv("mapas/geoDataframe_definitivo.csv",sep =';')
  
  barriosShape@data<-geoData
  
  barriosShape$numerica <- as.numeric(barriosShape@data$CLUSTER)
  
  palnumeric <- colorNumeric("viridis", barriosShape$numerica)
  
  #palnumeric <- colorNumeric(c("aliceblue","brown4"), 0:2)
  palfac <- colorFactor("RdBu",barriosShape$numerica)
  
  # Variable categorica
  barriosShape$categorica <- case_when(barriosShape$numerica == 3 ~ "no agrupado", barriosShape$numerica == 1 ~ "peligro bajo", barriosShape$numerica == 0 ~ "peligro medio", barriosShape$numerica == 2 ~ "peligro alto")
  sdaojdosjadoa<-barriosShape$categorica
  
  popup <- paste0("<style> div.leaflet-popup-content {width:auto !important;}</style>",
                  "<b>","Nombre del barrio: ", "</b>", as.character(barriosShape$NOMBRE), 
                  "<br><b>Grupo al que pertenece: ", "</b>", as.character(barriosShape$categorica), "<br>",
                  "<table>", "<tr>",
                  "<th>","TIPO","</th>",
                  "<th>","ATROPELLO","</th>",
                  "<th>","CAIDA OCUPANTE","</th>",
                  "<th>","CHOQUE","</th>",
                  "<th>","OTRO","</th>",
                  "<th>","VOLCAMIENTO","</th>",
                  "</tr>",
                  "<th>","PROMEDIO/DIA","</th>",
                  "<td>",round(as.numeric(barriosShape$atropello),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$caidaocupante),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$choque),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$otro),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$volcamiento),2),"</td>",
                  "</tr>",
                  "</table>",
                  "<br>",
                  "<table>", "<tr>",
                  "<th>","ACCIDENTES","</th>",
                  "<th>","MUERTOS","</th>",
                  "<th>","HERIDOS","</th>",
                  "<th>","SOLO_DANOS","</th>",
                  
                  "</tr>",
                  "<th>","PROMEDIO/MES","</th>",
                  "<td>",round(as.numeric(barriosShape$ACCIDENTES),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$MUERTO),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$HERIDO),2),"</td>",
                  "<td>",round(as.numeric(barriosShape$SOLO_DANOS),2),"</td>",
                  
                  "</tr>",
                  "</table>"
                  
                  
  )
  
  leaflet(barriosShape) %>%
    # Opcion para anadir imagenes o mapas de fondo (tiles)
    setView(-75.60272578, 6.21901553, 12) %>%
    # Funcion para agregar poligonos
    addPolygons(color = "#444444" ,
                weight = 1, 
                smoothFactor = 0.5,
                opacity = 1.0,
                fillOpacity = 0.5,
                fillColor = ~palnumeric(barriosShape$numerica),    # Color de llenado
                highlightOptions = highlightOptions(color = "white", weight = 2,
                                                    bringToFront = TRUE), #highlight cuando pasas el cursor
                label = ~barriosShape$NOMBRE ,                                  # etiqueta cuando pasas el cursor
                labelOptions = labelOptions(direction = "auto"),
                popup = popup)%>%addTiles(attribution = "overlay data mapsnigeriainitiative 2016")%>% 
    addLegend(position = "bottomleft", pal = palfac, values = ~barriosShape$categorica, 
              title = "Clasificacion de barrio")
  
}







prediccion <- function(fecha_inicio,fecha_fin,ventana){

  get_request <- GET("https://jor45458.pythonanywhere.com/Predictor/predecir/")
  datos <- list(
    fecha_inicial = fecha_inicio,
    fecha_final = fecha_fin,
    #d -> dia; m -> mes; s -> semana
    resoluciontemporal = ventana,
    
    #variable constante
    Modelo = "RF"
  )
  res <- POST("https://jor45458.pythonanywhere.com/Predictor/predecir/", body = datos, encode = "json")
  res <- content(res)
  data = data.frame(res)
  #print(head(data))
  data

}











####### SERVER #######
shinyServer(function(input, output, session){

  ####### BASES DE DATOS #######  
  
  #Datos Procesados
  datos_procesados <- reactive({
    data <- read.csv("./data/datos_procesados.csv",sep = ",")
    data <- select(data,FECHA,BARRIO,CLASE,GRAVEDAD,LONGITUD,LATITUD)
    data <- filter(data,FECHA >= input$fecha_inicio_datos)
    data <- filter(data,FECHA<= input$fecha_fin_datos)
    data
  })
  #Clustering
  clustering <- read.csv("./data/clustering.csv",sep=";")

  
  
  data_prediccion <- reactive({
    prediccion(input$fecha_inicio,input$fecha_fin,input$ventana)
    
  })
  

  ######## SALIDA ##########
  
  
  
  #### INICIO ####
  
  
  #### DATOS ####
  
  
  output$torta_datos <- renderPlotly({plot_ly(
    datos_procesados(),labels=as.character(datos_procesados()$CLASE),type="pie"
    
    
  )%>%
    layout(title='Proporcion de Accidentes por'
    )})
  
  output$tabla <- renderUI({
      box(width=12,renderDataTable(datos_procesados()))
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = 'Descarga.csv',
    content = function(file) {
      write.csv(datos_procesados(), file, row.names = FALSE)
    }
  )
  
  #### DESCRIPTIVO ####
  
  
  #### CLUSTERING ####


  
  output$map_cluster <- renderLeaflet({mapa_barrios()})


  
  
  
  
  #### PREDICTIVO ####
  
  
  # 
  # output$atropello = renderValueBox({
  #   data <- prediccion(input$fecha_inicio,input$fecha_fin,input$ventana)
  #   print(head(data))
  #   valueBox('Atropello',data$Resultado.Atropello,icon = icon("gavel"),color = "blue")
  #   
  #   
  #   })

  atropello <- reactive({
    

    valueBox('Atropellos',data_prediccion()$Resultado.Atropello,icon = icon("gavel"),color = "red")
    

  })
  
  output$atropello <- renderValueBox({atropello()})
  
  
  

  output$caida = renderValueBox({
    
    valueBox('Caidas Ocupante',data_prediccion()$Resultado.CaidaOcupante,icon = icon("gavel"),color = "blue")
    
    
  })
  output$choque = renderValueBox({
    
    valueBox('Choques',data_prediccion()$Resultado.Choque,icon = icon("gavel"),color = "yellow")
    
    
  })
  output$otro = renderValueBox({
    
    valueBox('Otros',data_prediccion()$Resultado.Otro,icon = icon("gavel"),color = "aqua")
    
    
  })
  output$volcamiento = renderValueBox({
    
    valueBox('Volcamientos',data_prediccion()$Resultado.volcamiento,icon = icon("gavel"),color = "green")
    
    
  })
  

  
  



})

