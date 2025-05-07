# Руководство по транскрипции в реальном времени с Gladia API

Это руководство подробно описывает процесс реализации транскрипции речи в реальном времени с использованием Flutter SDK для Gladia API.

## Содержание

1. [Введение](#введение)
2. [Архитектура решения](#архитектура-решения)
3. [Основные шаги](#основные-шаги)
4. [Установка соединения](#установка-соединения)
5. [Захват и отправка аудио](#захват-и-отправка-аудио)
6. [Обработка результатов](#обработка-результатов)
7. [Закрытие сессии](#закрытие-сессии)
8. [Устранение проблем](#устранение-проблем)
9. [Пример полной реализации](#пример-полной-реализации)

## Введение

Транскрипция в реальном времени (Live Transcription) — это процесс распознавания речи и её преобразования в текст по мере поступления аудио данных. Gladia API предоставляет мощный механизм для реализации этой функциональности через WebSocket соединение.

### Основные преимущества:

- Низкая задержка распознавания
- Мультиязыковая поддержка
- Высокая точность транскрипции
- Поддержка промежуточных и финальных результатов
- Возможность получать дополнительные метаданные (диаризация, пунктуация и т.д.)

## Архитектура решения

Транскрипция в реальном времени базируется на следующей архитектуре:

```
    +----------------+          +-------------------+
    |                |  Запрос  |                   |
    | Ваше приложение| -------> | Gladia REST API   |
    |                |          |                   |
    +----------------+          +-------------------+
            |                             |
            | Получение URL               | Создание сессии
            | для WebSocket               |
            v                             v
    +----------------+          +-------------------+
    |                |  Аудио   |                   |
    | WebSocket      | -------> | Gladia WebSocket  |
    | Клиент         |          | Сервер            |
    |                | <------- |                   |
    |                |  Текст   |                   |
    +----------------+          +-------------------+
```

## Основные шаги

Процесс транскрипции в реальном времени включает следующие этапы:

1. Инициализация сессии через REST API
2. Установка WebSocket соединения
3. Запись и отправка аудио данных
4. Получение и обработка результатов транскрипции
5. Корректное завершение сессии

## Установка соединения

### 1. Инициализация сессии

Первым шагом является инициализация сессии через REST API Gladia:

```dart
final sessionResult = await gladiaClient.initLiveTranscription(
  sampleRate: 16000,  // Частота дискретизации в Гц
  bitDepth: 16,       // Глубина сэмпла в битах
  channels: 1,        // Количество аудио каналов (1 = моно)
  encoding: 'wav/pcm', // Формат кодирования аудио
);

// Получение идентификатора сессии и URL для WebSocket
final sessionId = sessionResult.id;
final webSocketUrl = sessionResult.url;
```

### 2. Создание WebSocket соединения

После инициализации сессии необходимо установить WebSocket соединение:

```dart
final socket = gladiaClient.createLiveTranscriptionSocket(
  sessionUrl: sessionResult.url,
  onMessage: handleTranscriptionMessage,
  onDone: handleConnectionClosed,
  onError: handleConnectionError,
);
```

## Захват и отправка аудио

### 1. Настройка захвата аудио

Для захвата аудио можно использовать пакет `record`:

```dart
final audioRecorder = AudioRecorder();

// Начало записи
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

### 2. Отправка аудио данных

Отправка аудио осуществляется через WebSocket. Для этого нужно периодически считывать аудио данные и отправлять их на сервер:

```dart
// Пример периодической отправки аудио
Timer.periodic(Duration(milliseconds: 300), (timer) async {
  if (!isRecording || socket == null || !socket.isConnected) {
    timer.cancel();
    return;
  }

  try {
    // Чтение аудио данных из файла
    final file = File(tempFilePath);
    final fileLength = await file.length();
    
    // Пропускаем заголовок WAV (44 байта)
    final wavHeaderSize = 44;
    
    if (fileLength > wavHeaderSize) {
      final raf = await file.open(mode: FileMode.read);
      await raf.setPosition(wavHeaderSize);
      
      final audioBytes = await raf.read(fileLength - wavHeaderSize);
      await raf.close();
      
      // Отправка аудио данных
      socket.sendAudioData(audioBytes);
    }
  } catch (e) {
    print('Ошибка при отправке аудио: $e');
  }
});
```

### 3. Форматы отправки аудио

Gladia API поддерживает несколько форматов отправки аудио:

- **Бинарные данные** - напрямую отправка PCM-аудио через `sendAudioData()`
- **Base64** - кодированное аудио через `sendBase64AudioData()`

```dart
// Отправка бинарных данных
socket.sendAudioData(audioBytes);

// Отправка в формате base64
socket.sendBase64AudioData(audioBytes);
```

## Обработка результатов

### 1. Типы сообщений

Сервер Gladia отправляет несколько типов сообщений:

- `transcript` - результаты транскрипции
- `ready` - сервер готов к получению аудио
- `error` - ошибка при обработке

### 2. Обработка сообщений транскрипции

```dart
void handleTranscriptionMessage(dynamic message) {
  // Обработка сообщения о транскрипции
  if (message is Map<String, dynamic> && message['type'] == 'transcript') {
    final transcriptionMessage = TranscriptionMessage.fromJson(message);
    final text = transcriptionMessage.data.utterance.text;
    final isFinal = transcriptionMessage.data.isFinal;

    if (text.isNotEmpty) {
      if (isFinal) {
        // Обработка финального результата
        print('Финальная транскрипция: $text');
      } else {
        // Обработка промежуточного результата
        print('Промежуточная транскрипция: $text');
      }
    }
  } 
  // Обработка сообщения о готовности
  else if (message is Map<String, dynamic> && message['type'] == 'ready') {
    print('Сессия готова к приему аудио');
  }
  // Обработка ошибок
  else if (message is Map<String, dynamic> && message['type'] == 'error') {
    final errorMessage = message['data']?['message'] ?? 'Неизвестная ошибка';
    print('Ошибка от сервера: $errorMessage');
  }
}
```

## Закрытие сессии

Важно корректно закрыть сессию, чтобы освободить ресурсы и снизить риск достижения лимитов API:

### 1. Остановка записи

```dart
await audioRecorder.stop();
```

### 2. Отправка сигнала завершения записи

```dart
if (socket != null && socket.isConnected) {
  socket.sendStopRecording();
}
```

### 3. Закрытие WebSocket соединения

```dart
if (socket != null && socket.isConnected) {
  socket.close();
}
```

### 4. Закрытие сессии на сервере

```dart
// Отправка DELETE запроса для закрытия сессии
await dio.delete('v2/live/$sessionId');
```

## Устранение проблем

### 1. Проблема с лимитом одновременных сессий

В бесплатном тарифе Gladia API существует лимит на количество одновременных сессий (обычно 1). Если вы столкнулись с ошибкой:

```
GladiaApiException: Maximum number of concurrent sessions reached
```

Решения:
- Используйте функцию сброса всех сессий:
  ```dart
  await dio.delete('v2/live/reset');
  ```
- Убедитесь, что каждая сессия корректно закрывается после использования

### 2. Проблемы с форматом аудио

Если вы не получаете транскрипцию:
- Проверьте параметры аудио (sampleRate, bitDepth, channels)
- Удостоверьтесь, что отправляются действительные аудио данные (не пустые, не только заголовок)
- Попробуйте другой формат кодирования (например, wav/pcm вместо mp3)

### 3. Проблемы с WebSocket соединением

- Проверьте сетевое подключение
- Добавьте обработку ошибок в onError колбек
- Настройте автоматические переподключения при разрыве соединения

## Пример полной реализации

Полный пример реализации транскрипции в реальном времени с использованием Gladia API доступен в файле `example/live_audio_transcription_example.dart`.

Основные компоненты примера:
- Инициализация и управление сессией
- Захват аудио с микрофона
- Отправка аудио через WebSocket
- Обработка результатов транскрипции
- Корректное закрытие сессии
- Обработка ошибок

## Ограничения и рекомендации

1. **Качество сети**: Для стабильной работы транскрипции в реальном времени требуется хорошее интернет-соединение

2. **Формат аудио**: Рекомендуется использовать следующие параметры:
   - Sample rate: 16000 Hz
   - Bit depth: 16 bit
   - Channels: 1 (mono)
   - Encoding: wav/pcm

3. **Управление ресурсами**: Не забывайте закрывать сессии после использования

4. **Размер пакетов**: Оптимальный размер аудио пакетов для отправки - от 4 до 10 Кб

5. **Интервалы отправки**: Рекомендуемый интервал между отправками - от 200 до 500 мс

---

Дополнительную информацию можно найти в официальной документации Gladia API и в исходном коде Flutter SDK.

## См. также

- [Официальная документация Gladia API](https://docs.gladia.io/)
- [Примеры использования Flutter SDK](https://github.com/your-repo/gladia-flutter/tree/main/example)
- [LiveTranscriptionSocket API Reference](https://pub.dev/documentation/gladia/latest/gladia/LiveTranscriptionSocket-class.html) 