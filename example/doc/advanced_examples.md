# Продвинутые примеры использования Gladia API SDK

В этом документе представлены продвинутые примеры использования Gladia API SDK для различных сценариев.

## Пример транскрипции с диаризацией (определением говорящих)

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final file = File('путь/к/файлу.mp3');
  
  try {
    // Настройка опций с диаризацией
    final options = TranscriptionOptions(
      diarize: true,       // Включить определение говорящих
      speakerCount: 2,     // Предполагаемое количество говорящих
      diarizationConfig: DiarizationConfig(
        minSpeakers: 1,    // Минимальное количество говорящих
        maxSpeakers: 3,    // Максимальное количество говорящих
      ),
    );
    
    // Транскрипция файла с опциями
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    // Вывод полного текста
    print('Полный текст: ${result.text}');
    
    // Вывод информации по говорящим
    if (result.utterances != null) {
      for (final utterance in result.utterances!) {
        print('Говорящий ${utterance.speaker}: ${utterance.text}');
        print('Время: ${utterance.start} - ${utterance.end}');
        print('---');
      }
    }
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Пример генерации субтитров

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final audioUrl = 'https://example.com/audio.mp3';
  
  try {
    // Настройка опций для генерации субтитров
    final options = TranscriptionOptions(
      language: 'ru',
      subtitles: true,            // Включить генерацию субтитров
      subtitlesFormat: 'srt',     // Формат субтитров (srt, vtt)
      subtitlesConfig: SubtitlesConfig(
        maxLineLength: 40,        // Максимальная длина строки
        maxLinesCount: 2,         // Максимальное количество строк
        minDuration: 1,           // Минимальная длительность субтитра (в секундах)
        maxDuration: 7,           // Максимальная длительность субтитра (в секундах)
      ),
    );
    
    // Инициировать транскрипцию
    final initResult = await client.initiateTranscription(
      audioUrl: audioUrl,
      options: options,
    );
    
    // Получить результат
    final result = await client.getTranscriptionResult(taskId: initResult.id);
    
    // Получить URL субтитров
    if (result.metadata?.subtitle != null) {
      final subtitlesUrl = result.metadata!.subtitle!.url;
      print('URL субтитров: $subtitlesUrl');
      
      // Скачать файл субтитров
      final response = await client.downloadFile(subtitlesUrl);
      final file = File('subtitles.srt');
      await file.writeAsBytes(response.data);
      
      print('Субтитры сохранены в файл subtitles.srt');
      
      // Вывести содержимое субтитров
      final content = await file.readAsString();
      print('\nПример содержимого:\n');
      print(content.split('\n\n').take(3).join('\n\n'));
    }
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Пример с пользовательским словарем

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final file = File('путь/к/файлу.mp3');
  
  try {
    // Настройка пользовательского словаря и произношения
    final options = TranscriptionOptions(
      language: 'ru',
      // Пользовательский словарь для улучшения распознавания специфичных терминов
      customVocabularyConfig: CustomVocabularyConfig(
        terms: [
          'Flutter',
          'Dart',
          'Gladia',
          'SDK',
          'WebSocket',
          'API',
        ],
        phrases: [
          'Flutter Framework',
          'Dart Programming Language',
          'Gladia API',
        ],
      ),
      // Пользовательское произношение для аббревиатур
      customSpellingConfig: CustomSpellingConfig(
        dictionary: {
          'API': 'Эй-Пи-Ай',
          'SDK': 'Эс-Ди-Кей',
        },
      ),
    );
    
    // Транскрипция файла с опциями
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    print('Текст: ${result.text}');
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Пример транскрипции с переводом

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final file = File('путь/к/файлу.mp3');
  
  try {
    // Настройка опций с переводом
    final options = TranscriptionOptions(
      language: 'ru',          // Исходный язык аудио
      directTranslation: true,
      translation: TranslationConfig(
        target: 'en',          // Целевой язык перевода
        model: 'base',         // Модель перевода
      ),
    );
    
    // Загрузка и транскрипция файла
    final uploadResult = await client.uploadAudioFile(file);
    final initResult = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: options,
    );
    
    final result = await client.getTranscriptionResult(taskId: initResult.id);
    
    // Вывод оригинального текста
    print('Оригинальный текст: ${result.text}');
    
    // Вывод переведенного текста
    if (result.translation != null) {
      print('\nПереведенный текст (EN): ${result.translation!.text}');
    }
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Пример с колбеками

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final file = File('путь/к/файлу.mp3');
  
  try {
    // Настройка опций с колбеком
    final options = TranscriptionOptions(
      language: 'ru',
      callbackConfig: CallbackConfig(
        url: 'https://your-server.com/api/transcription-webhook',
        method: 'POST',
        headers: {
          'Authorization': 'Bearer your-token',
          'Custom-Header': 'custom-value',
        },
      ),
    );
    
    // Загрузка файла
    final uploadResult = await client.uploadAudioFile(file);
    
    // Инициировать транскрипцию с колбеком
    final initResult = await client.initiateTranscription(
      audioUrl: uploadResult.audioUrl,
      options: options,
    );
    
    print('Транскрипция запущена с ID: ${initResult.id}');
    print('Результаты будут отправлены на URL: ${options.callbackConfig!.url}');
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Пример интеграции с LLM (языковыми моделями)

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final file = File('путь/к/файлу.mp3');
  
  try {
    // Настройка опций для интеграции с LLM
    final options = TranscriptionOptions(
      language: 'ru',
      // Включить обработку текста языковой моделью
      audioToLLM: true,
      audioToLLMConfig: AudioToLLMConfig(
        prompt: 'Создай краткое резюме следующего разговора:',
        model: 'gpt-3.5-turbo',
      ),
    );
    
    // Транскрипция файла с опциями
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    // Вывод оригинального текста
    print('Оригинальный текст: ${result.text}');
    
    // Вывод результатов обработки LLM
    if (result.audioToLLM != null) {
      print('\nРезультат обработки LLM:');
      print(result.audioToLLM!.result);
    }
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Пример с сегментацией и извлечением структурированных данных

```dart
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  final file = File('путь/к/файлу.mp3');
  
  try {
    // Настройка извлечения структурированных данных
    final options = TranscriptionOptions(
      language: 'ru',
      // Включить извлечение структурированных данных
      structuredDataExtraction: true,
      structuredDataExtractionConfig: StructuredDataExtractionConfig(
        schema: {
          "type": "object",
          "properties": {
            "клиент": {
              "type": "object",
              "properties": {
                "имя": {"type": "string"},
                "телефон": {"type": "string"},
                "email": {"type": "string"},
              },
              "required": ["имя"]
            },
            "заказ": {
              "type": "object",
              "properties": {
                "номер": {"type": "string"},
                "сумма": {"type": "number"},
                "товары": {
                  "type": "array",
                  "items": {"type": "string"}
                }
              }
            }
          },
          "required": ["клиент"]
        },
      ),
    );
    
    // Транскрипция файла с опциями
    final result = await client.transcribeFile(
      file: file,
      options: options,
    );
    
    // Вывод полного текста
    print('Полный текст: ${result.text}');
    
    // Вывод извлеченных структурированных данных
    if (result.structuredData != null) {
      print('\nИзвлеченные данные:');
      print('Клиент: ${result.structuredData?['клиент']?['имя']}');
      print('Телефон: ${result.structuredData?['клиент']?['телефон']}');
      print('Email: ${result.structuredData?['клиент']?['email']}');
      
      if (result.structuredData?['заказ'] != null) {
        print('Номер заказа: ${result.structuredData?['заказ']?['номер']}');
        print('Сумма: ${result.structuredData?['заказ']?['сумма']}');
        
        if (result.structuredData?['заказ']?['товары'] is List) {
          print('Товары:');
          for (final item in result.structuredData!['заказ']['товары']) {
            print('- $item');
          }
        }
      }
    }
  } catch (e) {
    print('Ошибка: $e');
  }
}
```

## Обработка результатов транскрипции в реальном времени

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gladia/gladia.dart';

Future<void> main() async {
  final client = GladiaClient(apiKey: 'ваш_api_ключ');
  
  // Собственный обработчик результатов транскрипции
  class TranscriptionHandler {
    String _fullText = '';
    final List<String> _keywords = ['важно', 'срочно', 'проблема', 'ошибка'];
    
    void onTranscriptionResult(LiveTranscriptionResult result) {
      // Обновляем полный текст только для финальных результатов
      if (result.metadata?.isFinal == true) {
        _fullText += ' ${result.text}';
        print('Добавлен финальный текст: ${result.text}');
        
        // Поиск ключевых слов
        for (final keyword in _keywords) {
          if (result.text.toLowerCase().contains(keyword)) {
            print('⚠️ ОБНАРУЖЕНО КЛЮЧЕВОЕ СЛОВО: $keyword');
          }
        }
        
        // Сохранение полного текста в файл
        File('transcription_output.txt').writeAsStringSync(_fullText);
      } else {
        // Промежуточный результат
        print('Промежуточный: ${result.text}');
      }
    }
    
    String getFullText() => _fullText.trim();
  }
  
  final handler = TranscriptionHandler();
  LiveTranscriptionSocket? socket;
  
  try {
    final options = LiveTranscriptionOptions(
      encoding: 'pcm',
      sampleRate: 16000,
      language: 'ru',
      interim: true,
    );
    
    final initResult = await client.initiateLiveTranscription(options: options);
    
    socket = client.createLiveTranscriptionSocket(
      websocketUrl: initResult.websocketUrl,
      onTranscriptionResult: handler.onTranscriptionResult,
      onError: (error) => print('Ошибка: $error'),
      onDone: () => print('Соединение закрыто'),
    );
    
    await socket.connect();
    
    // Чтение аудиофайла и отправка данных по частям
    // (в реальном приложении это может быть поток с микрофона)
    final audioFile = File('путь/к/файлу.wav');
    final bytes = await audioFile.readAsBytes();
    
    const chunkSize = 4096; // Размер чанка (4KB)
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);
      
      socket.sendAudioData(chunk);
      
      // Имитация потоковой передачи с задержкой
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // Отправка сигнала завершения потока
    socket.sendEndOfStream();
    
    // Ожидание обработки последних данных
    await Future.delayed(Duration(seconds: 3));
    
    print('\nИтоговый текст:');
    print(handler.getFullText());
  } catch (e) {
    print('Ошибка: $e');
  } finally {
    // Закрытие соединения
    await socket?.close();
  }
}
```

Все приведенные выше примеры демонстрируют расширенные возможности Gladia API. Для получения дополнительной информации об API и его параметрах, см. [справочник API](../doc/api_reference.md) и [руководство по продвинутому использованию](../doc/advanced_usage.md). 