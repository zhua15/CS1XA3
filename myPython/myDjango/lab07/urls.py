from django.urls import path
from . import views

urlpatterns = [
	path("lab7/", views.isCorrect, name = 'lab07-isCorrect'),
]
