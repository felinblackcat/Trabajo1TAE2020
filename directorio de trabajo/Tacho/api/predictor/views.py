from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.response import Response
from predictor.serializers import PredictorSerializer
from predictor.models import Predictor
from rest_framework.decorators import action
import joblib
from datetime import datetime,timedelta,date
import dateutil.relativedelta
import numpy as np
import pandas as pd
import os
import calendar
import math


ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

#BOSQUES
bosque_dia = joblib.load(ROOT_DIR+'/modelos/arbol_dia.pkl')
bosque_mes = joblib.load(ROOT_DIR+'/modelos/arbol_mes.pkl') 
bosque_semana = joblib.load(ROOT_DIR+'/modelos/arbol_semana.pkl') 

#carga de datas
fechas_especiales = pd.read_excel(ROOT_DIR+"/data/fechas_especiales.xlsx")
clustering = pd.read_excel(ROOT_DIR+"/data/clustering.xlsx")


def week_of_month(tgtdate):
    anio_inicio = datetime.strptime('2014/01/01', '%Y/%m/%d')    
    return math.ceil(((tgtdate - anio_inicio).days-4) /7)

def know_special(anio,dia,mes,fecha_especiales):
    especial = 0    
    variable = fecha_especiales[fecha_especiales['MES']==int(mes)]
    variable = variable[fecha_especiales['DIA']==int(dia)]
    print(variable)
    if(len(variable)==1):
        especial = 1
    return(especial)

def PrepararData(data,fechas_especiales):
    if(data['resoluciontemporal']=='d'):       
        inicial = datetime.strptime(data['fecha_inicial'].replace('-','/'), '%Y/%m/%d')
        final = datetime.strptime(data['fecha_final'].replace('-','/'), '%Y/%m/%d')
        rango = final-inicial
        #formatox = ['Barrio_encoder','DIA','MES','Año','Especial']
        
        Matrix= []
        
        
            #dia mes anio especial cluster semana
        for i in range(0,rango.days+1):        
            fecha = inicial+timedelta(days=i)
            cluster1 = 0
            cluster2 = 1
            cluster3 = 2
            dia = fecha.day
            dia_semana = fecha.weekday()
            mes = fecha.month
            anio = fecha.year
            especial = know_special(anio,dia,mes,fechas_especiales)
            semana = week_of_month(fecha)                
            Matrix.append([float(dia_semana),float(mes),float(anio),float(especial),float(semana),cluster1,cluster2,cluster3])
            
        marray = pd.DataFrame(Matrix)
        resultado = pd.DataFrame(bosque_dia.predict(marray.values))
        
        resultado_front = {
        
                           'Resultado':{ 
                                       'Atropello':round(resultado[0].sum(),0),
                                       'CaidaOcupante':round(resultado[1].sum(),0),
                                       'Choque':round(resultado[2].sum(),0),
                                       'Otro':round(resultado[3].sum(),0),
                                       'volcamiento':round(resultado[4].sum(),0),
                                       },
                           'Modelo':{
                               'nombre':'Random Forest',
                               'ImportanciaVariables':{
                                   'Barrio peligro bajo':0.81,
                                   'DIA_SEMANA':0.09,
                                   'ESPECIAL':0.04,
                                   'Barrio peligro moderado':0.02,
                                   'Barrio peligro Alto':0.02,
                                   'MES':0.01,
                                   'SEMANA':0.01,
                                   'ANIO': 0.0,
                                   },
                               'Errores':{   
                                           'error_validacion': 11.350853964079027,
                                           'erro_prueba': 11.098365715779519,
                                        }
                                    }
                           }
    elif(data['resoluciontemporal']=='m'):   
        
        inicial = datetime.strptime(data['fecha_inicial'].replace('-','/'), '%Y/%m/%d')
        final = datetime.strptime(data['fecha_final'].replace('-','/'), '%Y/%m/%d')
        rango = (final.year - inicial.year) * 12 + (final.month - inicial.month)
        #formatox = ['Barrio_encoder','DIA','MES','Año','Especial']
        print(rango)
        Matrix= []       
        
        #dia mes anio especial cluster semana
        for i in range(0,rango+1):        
            fecha = inicial - dateutil.relativedelta.relativedelta(months=1) 
            cluster1 = 0
            cluster2 = 1
            cluster3 = 2                       
            mes = fecha.month
            anio = fecha.year                            
            Matrix.append([float(mes),float(anio),cluster1,cluster2,cluster3])
            
        marray = pd.DataFrame(Matrix)
        resultado = pd.DataFrame(bosque_mes.predict(marray.values))
        
        resultado_front = {
        
                           'Resultado':{ 
                                       'Atropello':round(resultado[0].sum(),0),
                                       'CaidaOcupante':round(resultado[1].sum(),0),
                                       'Choque':round(resultado[2].sum(),0),
                                       'Otro':round(resultado[3].sum(),0),
                                       'volcamiento':round(resultado[4].sum(),0),
                                       },
                           'Modelo':{
                               'nombre':'Random Forest',
                               'ImportanciaVariables':{
                                   'Barrio peligro bajo':0.93,
                                   'DIA_SEMANA':0.09,
                                   'ESPECIAL':0.04,
                                   'Barrio peligro moderado':0.05,
                                   'Barrio peligro Alto':0.02,
                                   'MES':0.0,                                   
                                   'ANIO': 0.0,
                                   },
                               'Errores':{  
                                           'error_validacion': 1199.1679222686375,
                                           'erro_prueba': 1243.219178929076,
                                        }
                                    }
                           }
    elif(data['resoluciontemporal']=='s'):       
        inicial = datetime.strptime(data['fecha_inicial'].replace('-','/'), '%Y/%m/%d')
        final = datetime.strptime(data['fecha_final'].replace('-','/'), '%Y/%m/%d')
        rango = final-inicial
        #formatox = ['Barrio_encoder','DIA','MES','Año','Especial']
        
        Matrix= []
        
        
            #dia mes anio especial cluster semana
        for i in range(0,rango.days+1):        
            fecha = inicial+timedelta(days=i)
            cluster1 = 0
            cluster2 = 1
            cluster3 = 2
            dia = fecha.day
            dia_semana = fecha.weekday()
            mes = fecha.month
            anio = fecha.year
            especial = know_special(anio,dia,mes,fechas_especiales)
            semana = week_of_month(fecha)                
            Matrix.append([float(anio),cluster1,cluster2,cluster3,float(semana)])
            
        marray = pd.DataFrame(Matrix)
        marray = marray.drop_duplicates([4])
        resultado = pd.DataFrame(bosque_semana.predict(marray.values))
        
        resultado_front = {
        
                           'Resultado':{ 
                                        
                                       'Atropello':round(resultado[0].sum(),0),
                                       'CaidaOcupante':round(resultado[1].sum(),0),
                                       'Choque':round(resultado[2].sum(),0),
                                       'Otro':round(resultado[3].sum(),0),
                                       'volcamiento':round(resultado[4].sum(),0),
                                       },
                           'Modelo':{
                               'nombre':'Random Forest',
                               'ImportanciaVariables':{
                                   'Barrio peligro bajo':0.95,
                                   'DIA_SEMANA':0.09,
                                   'ESPECIAL':0.04,
                                   'Barrio peligro moderado':0.02,
                                   'Barrio peligro Alto':0.02,                                   
                                   'SEMANA':0.01,
                                   'ANIO': 0.0,
                                   },                                  
                                   
                               'Errores':{   
                                           'error_validacion': 325.29153465889914,
                                           'erro_prueba': 293.12953247210106,
                                        } 
                                    }
                           }
    return(resultado_front)

    
class PredictorViewSet(viewsets.ModelViewSet):    
    queryset = Predictor.objects.all()
    serializer_class = PredictorSerializer    
    
    @action(detail=False,methods=['post'])
    def predecir(self, request):      
        serializer = PredictorSerializer(data=request.data)      
        
        #Validaciones
        if(serializer.is_valid()): 
            modeloLearning = serializer.data['Modelo']
            if(modeloLearning=='SVM'):                
                return Response({'Mensage':'svm'})
            elif(modeloLearning=='RF'):
                respuesta = PrepararData(serializer.data,fechas_especiales)
                return Response(respuesta)
        else:
            return Response({'Errors':serializer.errors})