# Generated by Django 2.2 on 2019-04-09 21:20

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('database', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='platforms',
            old_name='savenum',
            new_name='num',
        ),
    ]
