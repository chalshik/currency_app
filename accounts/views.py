from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User 
from django.contrib.auth import authenticate  
from .serializer import UserSerializer
from django.http import JsonResponse
@api_view(['POST'])
def login_view(request):
    username = request.data.get('username')
    password = request.data.get('password')
    if not username or not password:
        return Response({"error": "Username and password are required."}, status=status.HTTP_400_BAD_REQUEST)
    user = authenticate(username=username, password=password)

    if user is not None:
        return Response({"success": "Login successful!", "username": user.username}, status=status.HTTP_200_OK)
    else:
        return Response({"error": "Invalid username or password."}, status=status.HTTP_401_UNAUTHORIZED)
@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        serializer = UserSerializer(data=request.data)
        
        # Проверка, что данные валидны
        if serializer.is_valid():
            user = serializer.save()  # Сохраняем пользователя в базе
            return Response({
                'message': 'User created successfully!',
                'username': user.username,
                'password': user.password
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

def get_all_users(request):
    """
    Получает всех зарегистрированных пользователей.
    :param request: Запрос пользователя.
    :return: JSON-ответ со списком всех пользователей.
    """
    # Получаем всех пользователей
    users = User.objects.all()

    # Создаем список словарей с данными пользователей
    user_data = []
    for user in users:
        user_data.append({
            "id": user.id,
            "username": user.username,
        })

    return JsonResponse(user_data, safe=False)
