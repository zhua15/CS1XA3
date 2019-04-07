from django.urls import path
from . import views

urlpatterns = [
    path ('incr/', views.session_incr , name='func'),
    path ("get/", views.session_get, name = "func2"),
    path ("adduser/", views.add_user, name = "user"),
    path ("login/", views.login_user, name = "none"),
    path ("info/", views.userinfo, name = "info")
]
