from django.urls import path
from .views import login_view,register_user,get_all_users

urlpatterns = [
    path('login/', login_view, name='login'),
    path('register/', register_user, name='register_user'),
    path('users/', get_all_users, name='get_all_users'),
]