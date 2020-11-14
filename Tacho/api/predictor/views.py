from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.response import Response
from predictor.serializers import PredictorSerializer
from predictor.models import Predictor
from rest_framework.decorators import action
class PredictorViewSet(viewsets.ModelViewSet):
    
    queryset = Predictor.objects.all()
    serializer_class = PredictorSerializer
    @action(detail=False,methods=['post'])
    def predecir(self, request):
        serializer = self.serializer_class(request.data)
        return Response(serializer.data)