from django.shortcuts import render
from django.http import HttpResponse,JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
from .justPlatforms import Platform
import json

def login(request):
   myJson = json.loads(request.body.decode("utf-8"))

def signUp(request):
   myJson = json.loads(request.body.decode("utf-8"))

#def saveModel(request):
#   myJson = json.loads(request.body.decode("utf-8""))
#   platforms = myJson.get("platforms","")
#   if platforms != "":
#      newPlatforms = Platforms(json=myJson)
#      newPlatforms.save()
#      return JsonResponse(platforms)
#   return JsonReponse("")
#
#def loadModel (request):
#   return JsonResponse("")

# Create your views here.
