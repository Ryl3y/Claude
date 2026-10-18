from django.urls import path
from rest_framework.routers import SimpleRouter

from . import views

router = SimpleRouter()
router.register("tontines", views.TontineViewSet, basename="tontine")

urlpatterns = router.urls + [
    path("invitations/<str:code>/accepter/", views.accepter_invitation, name="invitation-accepter"),
    path("tours/<int:pk>/cotisations/", views.cotisations_du_tour, name="tour-cotisations"),
    path("tours/<int:pk>/remise/", views.remise_du_tour, name="tour-remise"),
    path("cotisations/<int:pk>/paiements/", views.payer_cotisation, name="cotisation-paiements"),
    path("webhooks/mobile-money/<str:fournisseur>/", views.webhook_mobile_money, name="webhook-mobile-money"),
]
