from django.http import HttpResponse,JsonResponse
from . import models
import json

def penguin_view (request):
	allpenguins = Penguin.objects.all()
	print(allpenguins)
	return HttpResponse("that's a lot of penguins")

def add_penguin (request):
	penguindata = json.loads(request.body)
	penguinname = penguindata.get("name","")
	penguinbeak = penguindata.get("hasbeak",True)

	if name != "":
		penguin = Penguin(name = penguinname, hasbeak = penguinbeak)
		penguin.save()

	return HttpResponse('success')

def get_penguin (request):
	penguin = Penguin.objects.first()
	return JsonReponse({ "name": penguin.name, "hasbeak": penguin.hasbeak})
