from django.db import models

class Platform (models.Model):
	json = models.CharField(max_length = 3000)
