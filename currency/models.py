
from django.db import models
from decimal import Decimal
class Currency_Amount(models.Model):
    name = models.CharField(max_length=50, unique=True)  # Название валюты, например, USD, EUR
    amount = models.DecimalField(max_digits=15, decimal_places=2, default=Decimal('0.00'))  # Количество валюты или стоимость

    def __str__(self):
        return f"{self.name} - {self.amount}"

from django.contrib.auth.models import User

class OperationHistory(models.Model):
    OPERATION_TYPES = [
        ('buy', 'Buy'),
        ('sell', 'Sell'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Пользователь, который выполнил операцию
    operation_type = models.CharField(max_length=4, choices=OPERATION_TYPES)  # Тип операции (покупка или продажа)
    currency = models.CharField(max_length=3)  # Код валюты (например, usd, eur)
    rate = models.DecimalField(max_digits=10, decimal_places=4)  # Стоимость курса (например, 74.25)
    amount = models.DecimalField(max_digits=10, decimal_places=2)  # Количество валюты
    timestamp = models.DateTimeField(auto_now_add=True)  # Время операции
    total = models.DecimalField(max_digits=20, decimal_places=2, editable=False)  # Общее (стоимость * количество)

    def save(self, *args, **kwargs):
        """Перед сохранением вычисляем общее значение"""
        self.total = self.rate * self.amount
        super().save(*args, **kwargs)  # Вызываем метод save родительского класса

    def __str__(self):
        return f"{self.operation_type.capitalize()} {self.amount} {self.currency} at {self.rate} per unit"

import logging

logger = logging.getLogger(__name__)
class CurrencyStats(models.Model):
    currency = models.CharField(max_length=3)
    total_buy = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_sell = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    average_buy = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    average_sell = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    profit = models.DecimalField(max_digits=10, decimal_places=2, null=True, default=None)

    @staticmethod
    def update_stats():
        # Получаем все уникальные валюты
        currencies = OperationHistory.objects.values('currency').distinct()

        for currency in currencies:
            currency_code = currency['currency']

            # Получаем все операции для этой валюты
            operations = OperationHistory.objects.filter(currency=currency_code)

            # Считаем общие суммы для покупки и продажи
            total_buy = sum(op.total for op in operations if op.operation_type == 'buy')
            total_sell = sum(op.total for op in operations if op.operation_type == 'sell')
            total_buy_rate = sum(op.rate for op in operations if op.operation_type == 'buy')
            total_sell_rate = sum(op.rate for op in operations if op.operation_type == 'sell')

            # Считаем количество покупок и продаж
            total_buy_count = operations.filter(operation_type='buy').count()
            total_sell_count = operations.filter(operation_type='sell').count()

            # Вычисляем среднее количество покупок и продаж
            average_buy = total_buy_rate / total_buy_count if total_buy_count else 0
            average_sell = total_sell_rate / total_sell_count if total_sell_count else 0

            # Считаем общие объемы покупок и продаж
            total_sell_amount = sum(op.amount for op in operations if op.operation_type == 'sell')
            total_buy_amount = sum(op.amount for op in operations if op.operation_type == 'buy')

            # Проверка: если покупок не было, а продажи есть
            if total_buy_amount == 0 and total_sell_amount > 0:
                logger.warning(f"Currency {currency_code}: No purchase data available, but sales exist.")
                profit = None  # Или 0, если нужно
            else:
                # Применяем формулу для расчета прибыли
                profit = (average_sell - average_buy) * total_sell_amount if total_sell_amount else 0

            # Сохраняем или обновляем статистику
            CurrencyStats.objects.update_or_create(
                currency=currency_code,
                defaults={
                    'total_buy': total_buy,
                    'total_sell': total_sell,
                    'average_buy': average_buy,
                    'average_sell': average_sell,
                    'profit': profit,
                }
            )

