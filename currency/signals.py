# signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import OperationHistory, CurrencyStats

@receiver(post_save, sender=OperationHistory)
def update_currency_stats(sender, instance, created, **kwargs):
    """
    Обработчик сигнала, который обновляет статистику валют при добавлении новой записи.
    """
    if created:
        # Вызовем обновление статистики для всех валют
        CurrencyStats.update_stats()
