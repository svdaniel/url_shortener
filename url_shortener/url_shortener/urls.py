from django.contrib import admin
from django.urls import path
from django.conf.urls import url

from app_url_shortener.views import redirect_view

urlpatterns = [
    path('admin/', admin.site.urls),
    url('^(?P<slug>[\w-]+)/$', redirect_view),
    # url('^view/$', redirect_view),

]

