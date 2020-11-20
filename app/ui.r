library(shiny)
library(shinydashboard)
library(plotly)
library(shinyBS)
library(shinyWidgets)
library(leaflet)
library(shinycssloaders)
options(scipen=999,enconding = 'UTF-8')

header <- dashboardHeader(title = "AccidentApp")

sidebar <- dashboardSidebar(

  
  sidebarMenu(id = 'sidebarmenu',
              menuItem('Inicio',tabName='inicio',icon = icon("home")),
              menuItem('Datos',tabName='datos',icon = icon("database")),
              #menuItem('Analisis Descriptivo',tabName='descriptivo',icon = icon("chart-bar")),
              menuItem('Segmentacion de Barrios',tabName='clustering',icon = icon("chart-pie")),
              menuItem('Prediccion de Accidentalidad',tabName='predictivo',icon = icon("brain")),
              menuItem('Autores',tabName='autores',icon = icon("address-card"))
  
              )
  )
body <- dashboardBody(
  tabItems(

    tabItem("inicio",
            fluidRow(box(HTML('<iframe width="100%" height="500" src="https://www.youtube.com/embed/49X6QTnhyPM" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),width = 32))
    ),
    tabItem("datos",
            fluidRow(box(h4("Ventana Temporal"),dateInput("fecha_inicio_datos", "Inicio:",startview = "decade",value = '2010-10-10'),dateInput("fecha_fin_datos", "Fin:",startview = "decade"),downloadButton("downloadData", "Descargar"), width = 6   ), box(plotlyOutput("torta_datos")%>%withSpinner(color="blue")) ),
            fluidRow(uiOutput("tabla")%>% withSpinner(color="blue"))
            
    ),
    
    # tabItem("descriptivo",
    #         fluidRow(infoBoxOutput("example_infobox")),
    #         fluidRow()
    #         
    #         
    # ),
    
    tabItem("clustering",
            fluidRow(infoBox(title ="Peligro Bajo",value =2.8,subtitle = "Promedio Accidentes/mes",icon = icon("check"),color = "blue"),
                     infoBox(title = "Peligro Medio",value = 9.4,subtitle ="Promedio Accidentes/mes",icon = icon("exclamation"),color = "yellow"),
                     infoBox(title ="Peligro Alto",value = 46.1,subtitle  = "Promedio Accidentes/mes",icon = icon("radiation"),color = "red")),
            
            fluidRow(box(width = 12,leafletOutput("map_cluster")%>%withSpinner(color="blue")))
    ),
    

    tabItem("predictivo",
            fluidRow(box(h4("Ventana Temporal"),dateInput("fecha_inicio", "Inicio:",startview = "decade"),dateInput("fecha_fin", "Fin:",startview = "decade"),selectInput("ventana", "Resolucion  Temporal:",c("Mes" = "m","Semana" = "s","Dia" = "d")), width = 6   ) ),
            #fluidRow(box(dateInput("fecha_inicio", "Inicio:",startview = "decade"),width=4),box(dateInput("fecha_fin", "Fin:",startview = "decade"),width = 4)),
            #fluidRow(box(selectInput("ventana", "Resolucion  Temporal:",c("Mes" = "m","Semana" = "s","Dia" = "d")),width=4)),
            fluidRow(box(width=12,valueBoxOutput("atropello")%>%withSpinner(color="blue"),valueBoxOutput("caida"),valueBoxOutput("choque"),valueBoxOutput("volcamiento"),valueBoxOutput("otro")))
          
            
    ),
    
    tabItem("autores",
            fluidRow(infoBox(title ="Ana Maria Gaona Gomez","Ingenieria Qumica",subtitle = "amgaonag@unal.edu.co",icon = icon("female"),color = "aqua")),
            fluidRow(infoBox(title ="Andres Orrego Perez","Ingenieria de Sistemas",subtitle = "aorregop@unal.edu.co",icon = icon("user-tie"),color = "red")),
            fluidRow(infoBox(title ="Andres Felipe Vergara","Ingenieria de Sistemas",subtitle = "anfvergarapo@unal.edu.co",icon = icon("user-tie"),color = "navy")),
            fluidRow(infoBox(title ="Jorge Eliecer Miranda Salas","Ingenieria de Sistemas",subtitle = "jemirandas@unal.edu.co",icon = icon("user-tie"),color = "purple"))
            


    )
  
  ),
)


shinyUI(tagList(dashboardPage(header,sidebar,body)))