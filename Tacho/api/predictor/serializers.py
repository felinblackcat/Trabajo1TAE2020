from rest_framework import serializers
from predictor.models import Predictor

class PredictorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Predictor
        fields = '__all__'