from django.db import models
from django.contrib.auth.models import User

class HelperPlatforms(models.Manager):
   def create (self,json):
      user = User.objects.create_user(json = json)
      return user

class Platforms(models.Model):
   json = models.CharField(max_length = 3000, default = "")
   user = models.ForeignKey(User,on_delete = models.CASCADE)
   num = models.IntegerField(primary_key = True)
   objects = HelperPlatforms()
# Create your models here.
