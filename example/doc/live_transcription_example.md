# Пример транскрипции в реальном времени

В этом документе описывается пример использования Gladia API SDK для транскрипции аудио в реальном времени.

## Обзор

Транскрипция в реальном времени позволяет преобразовывать речь в текст по мере поступления аудиоданных. Это полезно для приложений, требующих мгновенной обработки речи, таких как:

- Живые субтитры в видеоконференциях
- Голосовое управление
- Ассистивные технологии
- Расшифровка интервью и встреч в реальном времени

## Код примера (live_audio_transcription_example.dart)

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gladia/gladia.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const LiveTranscriptionApp());
}

class LiveTranscriptionApp extends StatelessWidget {
  const LiveTranscriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gladia Live Transcription Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LiveTranscriptionScreen(),
    );
  }
}

class LiveTranscriptionScreen extends StatefulWidget {
  const LiveTranscriptionScreen({super.key});

  @override
  State<LiveTranscriptionScreen> createState() => _LiveTranscriptionScreenState();
}

class _LiveTranscriptionScreenState extends State<LiveTranscriptionScreen> {
  final GladiaClient _client = GladiaClient(
    apiKey: dotenv.env['GLADIA_API_KEY'] ?? '',
    enableLogging: true,
  );

  LiveTranscriptionSocket? _socket;
  final _recorder = Record();
  bool _isRecording = false;
  String _transcriptionText = '';
  String _status = 'Готов к началу';
  String _errorMessage = '';

  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() {
        _errorMessage = 'Для работы приложения требуется доступ к микрофону';
      });
      return;
    }
  }

  Future<void> _startRecording() async {
    try {
      // Запрос разрешений
      await _requestPermissions();
      if (_errorMessage.isNotEmpty) return;

      setState(() {
        _status = 'Инициализация сессии...';
        _transcriptionText = '';
      });

      // 1. Инициализация сессии транскрипции
      final options = LiveTranscriptionOptions(
        encoding: 'pcm',
        sampleRate: 16000,
        bitDepth: 16,
        language: 'ru',
        diarize: true,
        speakerCount: 2,
        interim: true, // Получение промежуточных результатов
      );

      final initResult = await _client.initiateLiveTranscription(
        options: options,
      );

      setState(() {
        _status = 'Подключение к WebSocket...';
      });

      // 2. Создание WebSocket соединения
      _socket = _client.createLiveTranscriptionSocket(
        websocketUrl: initResult.websocketUrl,
        onTranscriptionResult: (result) {
          setState(() {
            _transcriptionText = result.text;
            
            if (result.metadata?.isFinal == true) {
              _status = 'Финальный результат получен';
            } else {
              _status = 'Идет транскрипция...';
            }
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Ошибка WebSocket: $error';
            _isRecording = false;
          });
        },
        onDone: () {
          setState(() {
            _status = 'Соединение закрыто';
            _isRecording = false;
          });
        },
      );

      // 3. Запуск соединения
      await _socket!.connect();

      setState(() {
        _status = 'Запуск записи аудио...';
      });

      // 4. Настройка записи аудио
      await _recorder.start(
        encoder: AudioEncoder.pcm16bits,
        samplingRate: 16000,
        numChannels: 1,
      );

      setState(() {
        _isRecording = true;
        _status = 'Запись и транскрипция активны';
      });

      // 5. Запуск периодического получения и отправки аудиоданных
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((amp) async {
        if (_isRecording && _socket != null) {
          try {
            final buffer = await _recorder.getCurrent();
            if (buffer != null) {
              _socket!.sendAudioData(buffer);
            }
          } catch (e) {
            print('Ошибка при получении аудиоданных: $e');
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при запуске записи: $e';
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      setState(() {
        _status = 'Завершение записи...';
      });

      // Остановка записи
      await _recorder.stop();

      // Отправка сигнала о завершении потока
      _socket?.sendEndOfStream();

      // Ожидание финальной обработки
      await Future.delayed(const Duration(seconds: 2));

      // Закрытие соединения
      await _socket?.close();
      _socket = null;

      setState(() {
        _isRecording = false;
        _status = 'Запись завершена';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Транскрипция в реальном времени'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информация о статусе
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Статус: $_status',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Кнопка записи
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Text(
                _isRecording ? 'Остановить запись' : 'Начать запись',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            
            // Область транскрипции
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _transcriptionText.isEmpty
                          ? 'Говорите после нажатия кнопки записи...'
                          : _transcriptionText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Пояснение принципа работы

Процесс транскрипции в реальном времени состоит из следующих этапов:

1. **Инициализация сессии**:
   ```dart
   final options = LiveTranscriptionOptions(
     encoding: 'pcm',
     sampleRate: 16000,
     bitDepth: 16,
     language: 'ru',
     diarize: true,
     speakerCount: 2,
     interim: true, // Получение промежуточных результатов
   );
   
   final initResult = await _client.initiateLiveTranscription(options: options);
   ```

2. **Создание WebSocket соединения**:
   ```dart
   _socket = _client.createLiveTranscriptionSocket(
     websocketUrl: initResult.websocketUrl,
     onTranscriptionResult: (result) {
       // Обработка результата
     },
     onError: (error) {
       // Обработка ошибок
     },
     onDone: () {
       // Обработка завершения
     },
   );
   
   // Запуск соединения
   await _socket!.connect();
   ```

3. **Запись аудио с микрофона**:
   ```dart
   await _recorder.start(
     encoder: AudioEncoder.pcm16bits,
     samplingRate: 16000,
     numChannels: 1,
   );
   ```

4. **Отправка аудиоданных**:
   ```dart
   _recorder.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((amp) async {
     if (_isRecording && _socket != null) {
       final buffer = await _recorder.getCurrent();
       if (buffer != null) {
         _socket!.sendAudioData(buffer);
       }
     }
   });
   ```

5. **Получение результатов транскрипции**:
   ```dart
   onTranscriptionResult: (result) {
     setState(() {
       _transcriptionText = result.text;
       
       if (result.metadata?.isFinal == true) {
         _status = 'Финальный результат получен';
       } else {
         _status = 'Идет транскрипция...';
       }
     });
   },
   ```

6. **Завершение сессии**:
   ```dart
   // Остановка записи
   await _recorder.stop();
   
   // Отправка сигнала о завершении потока
   _socket?.sendEndOfStream();
   
   // Закрытие соединения
   await _socket?.close();
   ```

## Настройка

Для запуска этого примера вам потребуется:

1. **API ключ Gladia** — Добавьте его в файл `.env`:
   ```
   GLADIA_API_KEY=ваш_api_ключ
   ```

2. **Зависимости** — Добавьте следующие пакеты в `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     gladia: ^0.1.0
     record: ^5.0.0
     permission_handler: ^10.0.0
     flutter_dotenv: ^5.0.2
   ```

3. **Разрешения** — Добавьте разрешение на доступ к микрофону:
   - Android (`android/app/src/main/AndroidManifest.xml`):
     ```xml
     <uses-permission android:name="android.permission.RECORD_AUDIO" />
     <uses-permission android:name="android.permission.INTERNET" />
     ```
   
   - iOS (`ios/Runner/Info.plist`):
     ```xml
     <key>NSMicrophoneUsageDescription</key>
     <string>Этому приложению требуется доступ к микрофону для транскрипции речи</string>
     ```

## Важные параметры

При настройке транскрипции в реальном времени обратите внимание на следующие параметры:

1. **encoding** — Формат кодирования аудио (`pcm`, `opus`, `wav`)
2. **sampleRate** — Частота дискретизации (обычно 16000 Гц)
3. **bitDepth** — Глубина битов (16 бит для PCM)
4. **interim** — Получение промежуточных результатов
5. **language** — Язык аудио
6. **diarize** — Определение говорящих

## Возможные проблемы и решения

1. **Проблема**: Не удаётся получить доступ к микрофону  
   **Решение**: Проверьте настройки разрешений в манифесте и добавьте запрос разрешения в коде

2. **Проблема**: Ошибка WebSocket соединения  
   **Решение**: Проверьте подключение к интернету и правильность API ключа

3. **Проблема**: Низкое качество распознавания  
   **Решение**: Настройте правильный язык и проверьте качество входного аудио

4. **Проблема**: Высокая задержка  
   **Решение**: Уменьшите размер отправляемых аудио-чанков или частоту отправки

## Дополнительная информация

- [Руководство по транскрипции в реальном времени](../../doc/live_transcription_guide.md)
- [API справочник](../../doc/api_reference.md)
- [Обработка ошибок](../../doc/error_handling.md) 