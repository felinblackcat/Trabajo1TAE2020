# -*- coding: utf-8 -*-
"""
Created on Tue Nov 17 23:03:32 2020

@author: quipo
"""

import pandas as pd
import numpy as np
import re
from unidecode import unidecode

def diccionario_quitar_tildes(col):
  return {col: {'á': 'a', 'Á': 'A','é': 'e', 'É': 'E','í': 'i', 'Í': 'I','ó': 'o', 'Ó': 'O','ú': 'u', 'Ú': 'U'}}

data_completo=pd.read_csv('../../datos_proscesados.csv',sep=',',encoding='utf8')
data_completo = data_completo.apply(lambda x: x.str.strip() if(x.dtype == "str") else x)

data_clustering =  pd.read_excel("../../Andres/cluster/clustering.xlsx")
data_clustering=data_clustering[['BARRIO','cluster']]
data_clustering = data_clustering.apply(lambda x: x.str.strip() if(x.dtype == "str") else x)

data=pd.read_csv('geoDataframe_cluster.csv',sep=';',encoding='utf8')
data = data.apply(lambda x: x.str.strip() if(x.dtype == "str") else x)

print(data.columns)
data =data.drop('CLUSTER',axis=1)


joindata = pd.merge(data,data_clustering, how='left', left_on=['NOMBRE'], right_on = ['BARRIO']) 
joindata=joindata.rename(columns={'cluster':'CLUSTER'})
joindata['CLUSTER'] = joindata['CLUSTER'].fillna(3)
joindata=joindata.drop('BARRIO',axis=1)
#print(data['NOMBRE'])
barrios=data_completo['BARRIO']
barrios_geo=data['NOMBRE']

barrios=barrios.drop_duplicates()
barrios_geo=barrios_geo.drop_duplicates()
barrios=pd.DataFrame(barrios)
barrios['ESTA']=0
print(barrios)
data['NOMBRE_MIN']=data['NOMBRE']
#data['NOMBRE_MIN']=data['NOMBRE_MIN'].apply(lambda x: str(unidecode(x)))

data=data.replace(diccionario_quitar_tildes('NOMBRE_MIN'), regex=True)
data['NOMBRE_MIN']=data['NOMBRE_MIN'].str.lower()



#barrios.to_csv('barrios.csv',sep=',',encoding='utf8',index=False)
#data.drop_duplicates(subset='...')
"""
for index, value  in barrios.items():
    data.loc[data.NOMBRE_MIN ==  f'{value}', 'ESTA']=1
 """   
    
for index, value  in barrios_geo.items():
    barrios.loc[barrios.BARRIO==  f'{value}', 'ESTA']=1
    
print(barrios[barrios['ESTA']==0])
barrios.to_csv('barrios.csv',sep=';',encoding='utf8',index=False)
    
    
data['NOMBRE']=data['NOMBRE_MIN']
data=data.drop('NOMBRE_MIN',axis=1)
data=data[['OBJECTID', 'CODIGO','NOMBRE',
           'SUBTIPO_BA', 'NOMBRE_COM', 'SHAPEAREA', 'SHAPELEN']]
#print(data.columns)
#data.to_csv('geoDataframe_funciona.csv',sep=',',encoding='utf8',index=False)
joindata['CLUSTER_CORREGIDO']=3
joindata.loc[joindata.CLUSTER ==  0, 'CLUSTER_CORREGIDO']=1
joindata.loc[joindata.CLUSTER ==  1, 'CLUSTER_CORREGIDO']=0
joindata.loc[joindata.CLUSTER ==  2, 'CLUSTER_CORREGIDO']=2

joindata['CLUSTER']=joindata['CLUSTER_CORREGIDO']
joindata=joindata.drop('CLUSTER_CORREGIDO',axis=1)





joindata.to_csv('geoDataframe_temporal.csv',sep=';',encoding='utf8',index=False)

#data_completo.to_csv('datos_proscesados.csv', encoding='utf-8')


