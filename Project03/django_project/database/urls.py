from django.urls import path
from . import views

urlpatterns = [
	path("saveModel/", views.saveModel, name = "save"),
	path("loadModel/", views.loadModel, name = "load"),
	path("login/", views.login, name = "login"),
	path("signUp/", views.signUp, name = "signup")
] 
