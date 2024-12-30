from rest_framework import serializers
from .models import Currency_Amount
from decimal import Decimal
class CurrencySerializer(serializers.ModelSerializer):
    amount = serializers.DecimalField(max_digits=15, decimal_places=2, coerce_to_string=False)

    class Meta:
        model = Currency_Amount
        fields = ['id', 'name', 'amount']

    def validate_amount(self, value):
        """Дополнительная валидация для 'amount'"""
        if isinstance(value, str):
            value = Decimal(value)
        return value
from .models import OperationHistory

class OperationHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = OperationHistory
        fields = ['user', 'operation_type', 'currency', 'rate', 'amount', 'timestamp', 'total']