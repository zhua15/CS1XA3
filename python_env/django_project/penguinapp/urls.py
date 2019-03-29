from django.urls import path
from . import views

urlpatterns = [
    path('', views.penguin_view , name='penguinapp'),
    path('addpenguin/', views.add_penguin, name = 'addpenguin'),
    path('getpenguin/', views.get_penguin, name = 'addpenguin'), 
]
