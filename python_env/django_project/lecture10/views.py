from django.shortcuts import render
from django.http import HttpResponse
import json
from django.contrib.auth.models import User
from django.contrib.auth import authenticate,login

def session_incr(request):
  """increments a counter held in the current session"""

  i = request.session.get('counter',0)
  request.session['counter'] = i+1

  return HttpResponse('')

def session_get(request):
  """returns counter held by current session"""

  counter = request.session.get('counter',0)
  return HttpResponse("Counter = " + str(counter))

def add_user(request):
    json_req = json.loads(request.body)
    uname = json_req.get('username', '')
    passw = json_req.get('pass', '')
    if uname != "":
        user = User.create_user(username = uname,
     	 		         password = passw)
        return HttpResponse("success")
    else:
        return HttpResponse("invalid username")

def login_user(request):
    json_req = json.loads(request.body)
    uname = json_req.get("username", "")
    passw = json_req.get("password", "")
    user = authenticate(request,username = uname, password = passw)
    if user is not None:
        login(request,user)
        HttpResponse("Valid User")
    else:
        HttpResponse("Invalid User")
def userinfo(request):
    user = request.user
    if user.is_authenticated:
        HttpResponse("Hello" + user.first_name)
    else:
        HttpResponse("Go away")
