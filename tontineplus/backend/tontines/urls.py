from django.urls import path
from rest_framework.routers import SimpleRouter

from . import views

router = SimpleRouter()
router.register("tontines", views.TontineViewSet, basename="tontine")

urlpatterns = router.urls + [
    path("invitations/<str:code>/accepter/", views.accepter_invitation, name="invitation-accepter"),
    path("tours/<int:pk>/cotisations/", views.cotisations_du_tour, name="tour-cotisations"),
    path("tours/<int:pk>/remise/", views.remise_du_tour, name="tour-remise"),
    path("tours/<int:pk>/tirage/", views.tirage_du_tour, name="tour-tirage"),
    path("tours/<int:pk>/designations/", views.proposer_designation, name="tour-designation"),
    path("designations/<int:pk>/vote/", views.voter_designation, name="designation-vote"),
    path("cotisations/<int:pk>/paiements/", views.payer_cotisation, name="cotisation-paiements"),
    path("paiements/<int:pk>/", views.detail_paiement, name="paiement-detail"),
    path("penalites/<int:pk>/payer/", views.encaisser_penalite, name="penalite-payer"),
    path("webhooks/mtn-momo/", views.callback_mtn, name="callback-mtn"),
    path("webhooks/mobile-money/<str:fournisseur>/", views.webhook_mobile_money, name="webhook-mobile-money"),
]
