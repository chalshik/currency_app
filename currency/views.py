from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .serializer import CurrencySerializer, OperationHistorySerializer
from .models import Currency_Amount
from .models import OperationHistory
from django.core import serializers
from rest_framework import status
from rest_framework.permissions import IsAuthenticated


@api_view(['POST'])
def add_currency(request):
    if request.method == 'POST':
        data = request.data
        currency_name = data.get('name')
        new_amount = data.get('amount')

        if not currency_name or not new_amount:
            return Response({"error": "Currency name and amount are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            new_amount = Decimal(new_amount)
        except (ValueError, TypeError):
            return Response({"error": "Invalid amount value"}, status=status.HTTP_400_BAD_REQUEST)

        if currency_name == 'KGS':
            currency, created = Currency_Amount.objects.update_or_create(
                name=currency_name,
                defaults={'amount': new_amount}  # Обновляем стоимость для KGS
            )
        else:
            currency = Currency_Amount.objects.filter(name=currency_name).first()

            if currency:
                currency.amount += new_amount
                currency.save()  # Сохраняем изменения
                created = False
            else:
                currency = Currency_Amount.objects.create(
                    name=currency_name,
                    amount=new_amount
                )
                created = True

        if created:
            return Response({
                'message': 'Currency added successfully!',
                'currency': CurrencySerializer(currency).data
            }, status=status.HTTP_201_CREATED)
        else:
            return Response({
                'message': 'Currency updated successfully!',
                'currency': CurrencySerializer(currency).data
            }, status=status.HTTP_200_OK)
@api_view(['GET'])
def get_all_currencies(request):
    currencies = Currency_Amount.objects.all()
    
    serializer = CurrencySerializer(currencies, many=True)
    
    return Response(serializer.data, status=status.HTTP_200_OK)
from django.http import JsonResponse
import requests
BEARER_TOKEN = "vSS6RudrQrIZLqJt1e6TRdwMYhCAYcSpkvcY1uhA68a894dc"
BASE_URL = "https://data.fx.kg/api/v1/current"
STATIC_ORGANIZATION = "ОАО \"Оптима Банк\""
def get_currency_rate(request, currency):
    headers = {
        "Authorization": f"Bearer {BEARER_TOKEN}"
    }
    response = requests.get(BASE_URL, headers=headers)

    if response.status_code == 200:
        data = response.json()
        for organization in data:
            if organization["official_title"] == STATIC_ORGANIZATION:
                for rate in organization["rates"]:
                    if rate["type"] == "regular":  # Выбираем только тип regular
                        buy_key = f"buy_{currency.lower()}"
                        sell_key = f"sell_{currency.lower()}"
                        if buy_key in rate and sell_key in rate:
                            return JsonResponse({
                                "buy": rate[buy_key],
                                "sell": rate[sell_key]
                            })
        return JsonResponse({"error": "Currency or organization not found."}, status=404)
    
    else:
        return JsonResponse({"error": f"API Error: {response.status_code}, {response.text}"}, status=500)
from decimal import Decimal

def get_available_currencies(request):
    headers = {
        "Authorization": f"Bearer {BEARER_TOKEN}"
    }
    
    try:
        response = requests.get(BASE_URL, headers=headers)

        if response.status_code == 200:
            data = response.json()
            available_currencies = set()

            for organization in data:
                if "official_title" in organization and organization["official_title"] == STATIC_ORGANIZATION:
                    if "rates" in organization:
                        for rate in organization["rates"]:
                            if "type" in rate and rate["type"] == "regular":  # Choose regular type only
                                for key in rate.keys():
                                    if key.startswith("buy_"):
                                        currency_name = key[4:].upper()  # Extract currency name
                                        available_currencies.add(currency_name)
                                    if key.startswith("sell_"):
                                        currency_name = key[5:].upper()  # Extract currency name
                                        available_currencies.add(currency_name)

            currency_to_remove = request.GET.get('currency', '').upper()
            if currency_to_remove in available_currencies:
                available_currencies.remove(currency_to_remove)

            return JsonResponse({"available_currencies": list(available_currencies)})

        else:
            return JsonResponse({"error": f"API Error: {response.status_code}, {response.text}"}, status=500)

    except requests.exceptions.RequestException as e:
        return JsonResponse({"error": f"Request failed: {str(e)}"}, status=500)
@api_view(['POST'])
def add_operation_history(request):
    if request.method == 'POST':
        serializer = OperationHistorySerializer(data=request.data)
        
        if serializer.is_valid():
            operation_type = serializer.validated_data['operation_type']
            currency = serializer.validated_data['currency']
            amount = serializer.validated_data['amount']
            rate = serializer.validated_data['rate']

            if operation_type == 'buy':
                som_currency = Currency_Amount.objects.get(name='KGS')  # Получаем сомы
                total_cost = rate * amount
                if som_currency.amount < total_cost:
                    return Response({"error": "Not enough KGS to complete the purchase."}, status=status.HTTP_400_BAD_REQUEST)

                currency_amount, created = Currency_Amount.objects.get_or_create(name=currency)
                currency_amount.amount += amount  # Добавляем количество купленной валюты
                currency_amount.save()

                som_currency.amount -= total_cost
                som_currency.save()
                operation_history = serializer.save()

            elif operation_type == 'sell':
                currency_amount = Currency_Amount.objects.get(name=currency)
                if currency_amount.amount < amount:
                    return Response({"error": f"Not enough {currency} to complete the sale."}, status=status.HTTP_400_BAD_REQUEST)
                currency_amount.amount -= amount
                currency_amount.save()
                som_currency = Currency_Amount.objects.get(name='KGS')
                total_sale = rate * amount
                som_currency.amount += total_sale
                som_currency.save()
                operation_history = serializer.save()

            return Response({
                'message': 'Operation completed successfully!',
                'operation': OperationHistorySerializer(operation_history).data
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
def get_operations_by_type(request):
    operation_type = request.GET.get('operation_type')
    if operation_type:
        operations = OperationHistory.objects.filter(operation_type__iexact=operation_type)
    else:
        operations = OperationHistory.objects.all()
    operations_data = [
        {
            "user": operation.user.username,
            "operation_type": operation.operation_type,
            "currency": operation.currency,
            "rate": str(operation.rate),
            "amount": str(operation.amount),
            "timestamp": operation.timestamp.isoformat(),
            "total": str(operation.total)
        }
        for operation in operations
    ]
    return JsonResponse(operations_data, safe=False)
from .models import CurrencyStats

def get_currency_stats(request):
    stats = CurrencyStats.objects.all()
    stats_data = [
        {
            "currency": stat.currency,
            "total_buy": str(stat.total_buy),
            "total_sell": str(stat.total_sell),
            "average_buy": str(stat.average_buy),
            "average_sell": str(stat.average_sell),
            "profit": str(stat.profit)
        }
        for stat in stats
    ]

    return JsonResponse(stats_data, safe=False)

@api_view(['POST'])
  # Это обеспечит, что только аутентифицированные пользователи могут делать запросы
def clear_history_and_stats(request):
    # Ваш код
    OperationHistory.objects.all().delete()
    CurrencyStats.objects.all().delete()
    Currency_Amount.objects.update(amount=0)
    return JsonResponse({"message": "История и статистика успешно удалены."})