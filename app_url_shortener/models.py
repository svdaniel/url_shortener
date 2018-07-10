from django.db import models
from .functions import generate_short_url


class TwistoURL(models.Model):
    url = models.CharField(max_length=250, unique=True)
    shortened = models.CharField(max_length=80, null=False, blank=True, unique=True)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if self.shortened is None or self.shortened == "":
            self.shortened = generate_short_url()
        super(TwistoURL, self).save(*args, **kwargs)
        print("saved")

    def __str__(self):
        return str(self.url)

