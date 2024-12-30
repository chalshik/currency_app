from django.urls import path
from .views import add_currency,get_all_currencies,get_currency_rate,add_operation_history,get_operations_by_type,get_currency_stats,clear_history_and_stats,get_available_currencies

urlpatterns = [
    path('add_currency/', add_currency, name='add_currency'),
    path('currencies/', get_all_currencies, name='get_all_currencies'),
    path('rate/<str:currency>/', get_currency_rate, name='get_currency_rate'),
    path('add_history/', add_operation_history, name='add_operation_history'),
    path('history/', get_operations_by_type, name='get_operations_by_type'),
    path('stat/', get_currency_stats, name='get_currency_stats'),
    path('clear_data/', clear_history_and_stats, name='clear_data'),
    path('availbale/',get_available_currencies,name='get_availbale_currencies')
]