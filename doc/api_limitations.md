# Ограничения и лимиты Gladia API

Этот документ содержит информацию о существующих ограничениях при работе с Gladia API, а также рекомендации по их обходу.

## Основные лимиты

### Бесплатный тариф

| Параметр | Ограничение |
|----------|-------------|
| Количество одновременных сессий | 1 |
| Месячный лимит запросов | Ограничен |
| Длительность аудио | До 2 часов |
| Размер файла | До 100 МБ |

### Платные тарифы

На платных тарифах ограничения значительно выше. Точные лимиты можно увидеть на [странице тарифов Gladia](https://app.gladia.io/pricing).

## Ограничения транскрипции в реальном времени

### Максимальное количество сессий

В бесплатном тарифе Gladia API разрешена только **одна** активная сессия транскрипции в реальном времени. При попытке создать вторую сессию вы получите ошибку:

```
GladiaApiException: Maximum number of concurrent sessions reached. Your Free Trial plan allows only up to 1 sessions. Please visit https://app.gladia.io/ to upgrade your plan. (Status: 429)
```

#### Решение проблемы

1. **Явное закрытие сессий**

   Убедитесь, что вы корректно закрываете сессию после использования:

   ```dart
   // Закрытие WebSocket
   socket.close();
   
   // Закрытие сессии на сервере
   await dio.delete('v2/live/$sessionId');
   ```

2. **Сброс всех активных сессий**

   Если возникает ошибка с превышением лимита, можно сбросить все активные сессии:

   ```dart
   final dio = Dio()
     ..options.baseUrl = 'https://api.gladia.io/'
     ..options.headers = {
       'x-gladia-key': apiKey,
       'Content-Type': 'application/json',
     };
   
   await dio.delete('v2/live/reset');
   ```

3. **Автоматический сброс при старте приложения**

   Рекомендуется добавить автоматический сброс сессий при запуске приложения:

   ```dart
   Future<void> resetActiveSessions() async {
     try {
       // Отправка запроса на сброс всех активных сессий
       await dio.delete('v2/live/reset');
       print('Активные сессии сброшены');
     } catch (e) {
       print('Ошибка при сбросе сессий: $e');
     }
   }
   ```

### Длительность неактивности

Если в течение определенного времени (обычно 30-60 секунд) сессия не получает аудио данных, она может быть автоматически закрыта сервером.

#### Решение

1. **Отправка пинг-сигналов**

   При паузах в записи отправляйте пустые аудио-фреймы или специальные пинг-сообщения для поддержания соединения.

2. **Переподключение при разрыве**

   Реализуйте логику автоматического переподключения при обнаружении разрыва соединения.

### Форматы аудио

Не все форматы аудио одинаково хорошо поддерживаются API. Наилучшие результаты дают:

- WAV/PCM (16-bit, 16kHz, моно)
- RAW PCM (без заголовков)

#### Решение проблем с форматом аудио

1. **Используйте рекомендуемые параметры**

   ```dart
   await audioRecorder.start(
     RecordConfig(
       encoder: AudioEncoder.wav,
       bitRate: 256000,
       sampleRate: 16000,
       numChannels: 1,
     ),
     path: tempFilePath,
   );
   ```

2. **Пропускайте заголовки WAV при чтении**

   Если вы используете WAV формат, при отправке аудио пропускайте первые 44 байта (заголовок WAV):

   ```dart
   final raf = await file.open(mode: FileMode.read);
   await raf.setPosition(44); // Пропускаем WAV заголовок
   
   final audioBytes = await raf.read(fileLength - 44);
   await raf.close();
   ```

## Обработка ошибок сети

### Таймауты запросов

При работе с API могут возникать таймауты запросов, особенно при нестабильном соединении.

#### Решение

1. **Установка таймаутов для запросов**

   ```dart
   final dio = Dio()
     ..options.baseUrl = 'https://api.gladia.io/'
     ..options.connectTimeout = const Duration(seconds: 10)
     ..options.receiveTimeout = const Duration(seconds: 10)
     ..options.headers = {
       'x-gladia-key': apiKey,
       'Content-Type': 'application/json',
     };
   ```

2. **Обработка таймаутов**

   ```dart
   try {
     await dio.delete('v2/live/$sessionId').timeout(
       const Duration(seconds: 5),
       onTimeout: () {
         print('Таймаут при закрытии сессии');
         return Response(
           requestOptions: RequestOptions(path: 'v2/live/$sessionId'),
           statusCode: 408,
         );
       },
     );
   } catch (e) {
     print('Ошибка при закрытии сессии: $e');
   }
   ```

### Разрывы WebSocket соединения

WebSocket соединения могут разрываться по разным причинам: проблемы с сетью, перезагрузка серверов API и т.д.

#### Решение

1. **Обработка событий закрытия соединения**

   ```dart
   socket = gladiaClient.createLiveTranscriptionSocket(
     sessionUrl: sessionResult.url,
     onMessage: handleMessage,
     onDone: () {
       print('Соединение закрыто');
       reconnectWebSocket();
     },
     onError: (error) {
       print('Ошибка WebSocket: $error');
       reconnectWebSocket();
     },
   );
   ```

2. **Функция переподключения**

   ```dart
   Future<void> reconnectWebSocket() async {
     if (!shouldReconnect) return;
     
     try {
       print('Попытка переподключения...');
       socket = gladiaClient.createLiveTranscriptionSocket(
         sessionUrl: sessionResult.url,
         onMessage: handleMessage,
         onDone: () => reconnectWebSocket(),
         onError: (error) => reconnectWebSocket(),
       );
     } catch (e) {
       print('Ошибка при переподключении: $e');
       // Пробуем снова через некоторое время
       Future.delayed(Duration(seconds: 2), reconnectWebSocket);
     }
   }
   ```

## Рекомендации для стабильной работы

1. **Управляйте жизненным циклом сессий**
   - Явно закрывайте сессии после использования
   - Реализуйте обработку жизненного цикла приложения для корректного закрытия при выходе

2. **Оптимизируйте отправку аудио**
   - Отправляйте аудио блоками оптимального размера (4-10 Кб)
   - Выбирайте подходящий интервал отправки (300-500 мс)

3. **Обрабатывайте ошибки**
   - Добавьте логирование всех этапов работы с API
   - Реализуйте логику повторных попыток при временных сбоях

4. **Тестируйте разные форматы аудио**
   - Если транскрипция не работает с одним форматом, попробуйте другой
   - Проверьте корректность параметров аудио

## Дополнительная информация

Для получения актуальной информации о лимитах и ограничениях API, обратитесь к [официальной документации Gladia](https://docs.gladia.io/) 