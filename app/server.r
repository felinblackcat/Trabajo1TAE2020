library(shiny)
library(dplyr)
library(plotly)
library(readxl)
library(lubridate)
#library(shinyalert)
library(shinyWidgets)
library("httr")
library("jsonlite")

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
  
  
  #### PREDICTIVO ####
  base <- "https://jor45458.pythonanywhere.com/Predictor/predecir/"
  get_request <- GET(base)
  datos <- list(
    fecha_inicial = "2014-01-20",
    fecha_final = "2014-02-20",
    #d -> dia; m -> mes; s -> semana
    resoluciontemporal = "d",
    
    #variable constante
    Modelo = "RF"
  )
  res <- POST("https://jor45458.pythonanywhere.com/Predictor/predecir/", body = datos, encode = "json")
  res <- content(res)
  print(res)
  
  
  #get_request_json <- fromJSON(get_request, flatten = TRUE)
  #get_prices_text <- content(get_request, "text")
  
  
  #EXAMPLE INFOBOX
  output$example_infobox <- renderInfoBox({valueBox('Example',100,icon = icon("gavel"),color = "blue")})


})

