from django.db import models
from django.contrib.auth.models import User

class PlatformsManager(models.Manager):
   def create_user_info(self,username,password,json):
      user = User.objects.create_user(username = username, password = password)
      userPlatforms = self.create(user = user,json = json)
      return userPlatforms

class Platforms(models.Model):
   json = models.CharField(max_length = 3000, default = "")
   user = models.OneToOneField(User,on_delete = models.CASCADE,primary_key = True)
   objects = PlatformsManager()

# Create your models here.

