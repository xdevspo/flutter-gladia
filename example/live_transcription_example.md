# Пример распознавания речи в реальном времени с Gladia API

Этот пример демонстрирует, как использовать Gladia API для распознавания речи в реальном времени с помощью Flutter приложения.

## Возможности

- Запись аудио с микрофона устройства
- Транскрипция речи в реальном времени
- Отображение распознанного текста с пометкой о финальности результата
- Остановка записи и транскрипции

## Необходимые зависимости

Для работы примера необходимы следующие пакеты:

```yaml
dependencies:
  flutter:
    sdk: flutter
  gladia: ^0.1.0
  record: ^4.4.4
  path_provider: ^2.0.15
  permission_handler: ^10.2.0
```

## Использование

1. Введите ваш API ключ Gladia в соответствующее поле
2. Нажмите кнопку "Начать" для начала записи и распознавания
3. Говорите в микрофон, результаты распознавания будут отображаться в режиме реального времени
4. Нажмите кнопку "Остановить" для завершения записи и распознавания

## Код примера

Основной код примера находится в файле [live_audio_transcription_example.dart](./live_audio_transcription_example.dart). В нем используются следующие компоненты API:

- `GladiaClient.initLiveTranscription()` - инициализация сессии распознавания речи
- `GladiaClient.createLiveTranscriptionSocket()` - создание WebSocket соединения
- `LiveTranscriptionSocket.sendAudioData()` - отправка аудио данных на сервер
- `LiveTranscriptionSocket.sendStopRecording()` - отправка сигнала об остановке записи

## Важные моменты

### Инициализация сессии

```dart
final sessionResult = await _gladiaClient.initLiveTranscription(
  sampleRate: 16000,
  bitDepth: 16,
  channels: 1,
  encoding: 'wav/pcm',
);
```

### Создание WebSocket соединения

```dart
_socket = _gladiaClient.createLiveTranscriptionSocket(
  sessionUrl: sessionResult.url,
  onMessage: _handleTranscriptionMessage,
  onDone: () {
    _stopRecordingAndTranscription();
  },
  onError: (error) {
    _showError('Ошибка WebSocket: $error');
    _stopRecordingAndTranscription();
  },
);
```

### Отправка аудио данных

```dart
if (_socket != null && _socket!.isConnected && _isRecording) {
  final buffer = await _audioRecorder.extractRecordingBuffer();
  if (buffer != null && buffer.isNotEmpty) {
    _socket!.sendAudioData(buffer);
  }
}
```

### Обработка сообщений с результатами

```dart
void _handleTranscriptionMessage(dynamic message) {
  if (message is Map<String, dynamic> && message['type'] == 'transcript') {
    try {
      final transcriptionMessage = TranscriptionMessage.fromJson(message);
      final text = transcriptionMessage.data.utterance.text;
      final isFinal = transcriptionMessage.data.isFinal;

      if (text.isNotEmpty) {
        setState(() {
          if (isFinal) {
            // Если это финальная транскрипция, добавляем ее в список
            _transcriptions.add(text);
          } else {
            // Для промежуточных результатов обновляем последний элемент
            if (_transcriptions.isEmpty) {
              _transcriptions.add('(частично) $text');
            } else {
              _transcriptions[_transcriptions.length - 1] = '(частично) $text';
            }
          }
        });
      }
    } catch (e) {
      print('Ошибка обработки сообщения: $e');
    }
  }
}
```

## Дополнительная информация

Подробную документацию по API можно найти на [официальном сайте Gladia](https://docs.gladia.io/api-reference/v2/live/init). 