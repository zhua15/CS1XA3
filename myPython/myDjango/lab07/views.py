from django.shortcuts import render
from django.http import HttpResponse

def isCorrect(request):
	d = request.POST
	user = d.get("user", "")
	password = d.get("password", "")
	passagain = d.get ("passwordagain","")
	if user == "Jimmy" and password == "Hendrix" and passagain == "Hendrix":
		return HttpResponse("Cool")
	return HttpResponse("Bad User Name")
