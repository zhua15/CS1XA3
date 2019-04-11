from django.shortcuts import render
from django.http import HttpResponse

def hello(req):
	return HttpResponse("Hello World")
def gettest(request):
	d = request.GET
	name  = d.get("name","")
	age = d.get("age","")

	return HttpResponse("Hello " + name + "ur " + age +  " old")
def posttest(request):
	keys = request.POST
	name = keys.get("name","")
	age = keys.get("age","")
	
	return HttpResponse("Hello " + name + "ur " + age + " old")
# Create your views here.
