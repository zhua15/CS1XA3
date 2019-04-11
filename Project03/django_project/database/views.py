from django.shortcuts import render
from django.http import HttpResponse,JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
from .justPlatforms import Platform
import json

def saveModel(request):
   myJson = json.loads("hello i am json")
   print ("myJson:",myJson)
   platforms = myJson.get("platforms","")
   if platforms != "":
      newPlatforms = Platforms(json=myJson)
      newPlatforms.save()
      return JsonResponse(platforms)
   return JsonReponse("")

def loadModel (request):
   return JsonResponse("")

# Create your views here.
