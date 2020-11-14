from django.db import models

# Create your models here.
class Predictor(models.Model):
    choiceResolucion =[
        ('d','Dia'),
        ('m','Mes'),
        ('s','Semana')    
    ]
    fecha_inicial = models.DateField()
    fecha_final = models.DateField()
    resoluciontemporal = models.CharField(max_length=100,choices=choiceResolucion)