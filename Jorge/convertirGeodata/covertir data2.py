# -*- coding: utf-8 -*-
"""
Created on Wed Nov 18 21:06:00 2020

@author: quipo
"""
import pandas as pd
data_clustering =  pd.read_excel("../../Andres/cluster/clustering.xlsx")
data_completo=pd.read_csv('../../Tacho/TrabajoTAE/DatosBrutoCorregidos.csv',sep=',',encoding='utf8')
data_completo = data_completo.apply(lambda x: x.str.strip() if(x.dtype == "str") else x)
geodata=pd.read_csv('geoDataframe_temporal.csv',sep=';',encoding='utf8')
geodata = geodata.apply(lambda x: x.str.strip() if(x.dtype == "str") else x)
caracterizacion=pd.read_excel("caracterizacion.xlsx")
caracterizacion['CLUSTER']=caracterizacion['cluster']
caracterizacion=caracterizacion.drop('cluster',axis=1)
#nombre de las columnas con las sumas
#nombre_columnasTipo=['SUMA_atropello', 'SUMA_caidaocupante','SUMA_choque','SUMA_otro','SUMA_volcamiento','SUMA_incendio','SUMA_choque y atropello']
#dataEnc.columns = nombre_columnasTipo
#dataEnc = dataEnc.reset_index()

dumis=pd.get_dummies(data_completo,columns=['CLASE'])
dumis=dumis.groupby(['BARRIO','DIA']).agg({'CLASE_atropello':'mean','CLASE_caida ocupante':'mean','CLASE_choque':'mean','CLASE_otro':'mean','CLASE_volcamiento':'mean'})
#nombre de las columnas con las sumas
nombre_columnasTipo=['atropello', 'caidaocupante','choque','otro','volcamiento']
dumis.columns = nombre_columnasTipo
dumis = dumis.reset_index()
dumis=dumis.groupby(['BARRIO']).mean().reset_index()
dumis =dumis.drop('DIA',axis=1)
dumis=dumis.fillna(0)
geodata=pd.merge(geodata, dumis,  how='left', left_on=['NOMBRE'], right_on = ['BARRIO'])
geodata=pd.merge(geodata, caracterizacion,  how='left', left_on=['CLUSTER'], right_on = ['CLUSTER'])

print(geodata.columns)
geodata.to_csv('geoDataframe_definitivo.csv',sep=';',encoding='utf8',index=False)
