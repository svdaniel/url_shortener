from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse, HttpResponseRedirect

from .models import TwistoURL


def redirect_view(request, slug=None, *args, **kwargs):
    print(args)
    print(kwargs)
    print("slug: {}".format(slug))

    obj = get_object_or_404(TwistoURL, shortened=slug)
    print("URL for slug: {} is: {}".format(slug, obj.url))

    # return HttpResponse("Hello {}".format(obj.url))
    return HttpResponseRedirect(obj.url)

