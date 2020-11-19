library(shiny)
library(shinydashboard)
library(plotly)
library(shinyBS)
library(shinyWidgets)
library(leaflet)
options(scipen=999,enconding = 'UTF-8')

header <- dashboardHeader(title = "AccidentApp")

sidebar <- dashboardSidebar(

  
  sidebarMenu(id = 'sidebarmenu',
              menuItem('Inicio',tabName='inicio',icon = icon("home")),
              menuItem('Datos',tabName='datos',icon = icon("database")),
              menuItem('Analisis Descriptivo',tabName='descriptivo',icon = icon("chart-bar")),
              menuItem('Segmentacion de Barrios',tabName='clustering',icon = icon("chart-pie")),
              menuItem('Prediccion de Accidentalidad',tabName='predictivo',icon = icon("brain"))
  
              )
  )
body <- dashboardBody(
  tabItems(
    tabItem("clustering",
            #fluidRow(infoBoxOutput("cluster_1"),infoBox("cluster_2"),infoBox("Cluster_3")),
            fluidRow(leafletOutput("map_cluster"))
            ),
    
    
    tabItem("inicio",
            fluidRow(
              navbarPage("AccidentApp V0.1",
                         tabPanel("Video",
                                      box(HTML('<iframe width="100%" height="500" src="https://www.youtube.com/embed/49X6QTnhyPM" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),width = 32)
                                   ),
                         tabPanel("Desarrolladores",
                                  verbatimTextOutput("Desarroladores")
                         )
                    )
            )
    ),
    tabItem("datos",
            fluidRow(uiOutput("tabla"))
            
    ),
    tabItem("descriptivo",
            fluidRow(infoBoxOutput("example_infobox")),
            fluidRow()
            
            
    ),
    tabItem("predictivo",
            fluidRow(box(h4("Ventana Temporal"))),
            fluidRow(box(dateInput("fecha_inicio", "Inicio:",startview = "decade"),width=4),box(dateInput("fecha_fin", "Fin:",startview = "decade"),width = 4)),
            fluidRow(box(selectInput("resolucion_temporal", "Resoluciontemporal:",c("Dia" = "d","Mes" = "m","Semana" = "s")),width=4)),
            fluidRow(infoBoxOutput("atropello"))
           
            
    )
  
  ),
)


shinyUI(tagList(dashboardPage(header,sidebar,body)))