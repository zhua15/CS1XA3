from django.shortcuts import render
from django.http import HttpResponse,JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
from .models import HelperPlatforms, Platforms
import json

def login(request):
   print (request.body)
   myJson = json.loads(request.body)
   username = myJson.get('username','')
   password = myJson.get('password','')
   user = authenticate (request, username = username, password = password)
   if user is not None:
      login(request,user)
      return HttpResponse("Login Success")
   else:
      return HttpResponse("Login Fail")
def signUp(request):
   myJson = json.loads(request.body)
   username = myJson.get("username","")
   password = myJson.get("password","")
   if username != "":
      newuser = User.objects.create_user(username=username,
                                        password=password)
      login(request,newuser)
      return HttpResponse("Success")
   else:
      return HttpResponse("Failure")
def saveModel(request):
   myJson = json.loads(request.body)
   platforms = myJson.get("platforms","")
   if platforms != "":
      newPlatforms = Platforms(json=myJson)
      newPlatforms.save()
      return JsonResponse(platforms)
   return JsonReponse("")

def loadModel (request):
   return JsonResponse("")

# Create your views here.
