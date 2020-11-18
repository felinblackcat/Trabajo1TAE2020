library(shiny)
library(shinydashboard)
library(plotly)
library(shinyBS)
library(shinyWidgets)
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
            fluidRow(div(id="div-example",infoBoxOutput("example-infobox")))
            ),
    tabItem("inicio",
            fluidRow(),
                     
    ),
    tabItem("datos",
            fluidRow(uiOutput("tabla"))
            
            
    ),
    tabItem("descriptivo",
            fluidRow(),
            
    ),
    tabItem("predictivo",
            fluidRow(box(h4("Ventana Temporal"))),
            fluidRow(box(dateInput("fecha_inicio", "Inicio:",startview = "decade"),width=4),box(dateInput("fecha_fin", "Fin:",startview = "decade"),width = 4)),
            fluidRow(box(selectInput("Resoluciontemporal", "Resoluciontemporal:",c("Dia" = "d","Mes" = "m","Semana" = "s")),width=4)),
            fluidRow(box(submitButton("Predecir", icon("refresh")),width=4)),
            
    )

                     
  
    
    
   

  )
)


shinyUI(tagList(dashboardPage(header,sidebar,body)))