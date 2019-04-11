from django.db import models
class ProgramManager(models.Manager):
	def create_lang(self, name, paradigm, is_oo):
		lang = self.create(name = name, paradigm = paradigm, is_oo = is_oo)
		return lang
class ProgrammingLanguage(models.Model):
  PARADIGM_CHOICES = (
      ("FUNCTIONAL","Functional"),
      ("IMPERATIVE","Imperative"),
  )

  name = models.CharField(max_length=30,primary_key=True)
  paradigm = models.CharField(max_length=10, choices=PARADIGM_CHOICES, default="IMPERATIVE")
  is_oo = models.BooleanField()
  objects = ProgramManager()
from django.db import models
from django.contrib.auth.models import User
class UserInfoManager (models.Manager):
    def create_user_info(self, username, password, info)
        user = User.objects.create_user(username = username, password = password)
        userinfo = self.create(user = user, info = info)
        return userinfo
class UserInfo (models.Model):
    user = models.OneToOneField(User, on_delete = models.CASCADE, primary_key = True)
    info = models.CharField(max_length = 30)
    objects = UserInfoManager()
