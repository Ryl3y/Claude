from django.contrib import admin
from django.urls import include, path

admin.site.site_header = "TONTINE+ — administration"
admin.site.site_title = "TONTINE+"

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include("comptes.api")),
    path("api/v1/", include("tontines.urls")),
]
