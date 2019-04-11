from django.urls import path
from . import views

urlpatterns = [
	path("get/", views.gettest, name = "myapp-gettest"),
	path("post/",views.posttest,name = "myapp-posttest"),
	path("",views.hello , name = 'myapp.hello')
]
