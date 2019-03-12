from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

def hello_world(request):
    html = "<html><body>Hello World</body></html>"
    print ("hajfdnshjfsh")
    return HttpResponse(html)

urlpatterns = [
    path('e/zhua15/' , include('helloworldapp.urls')) ,
]
