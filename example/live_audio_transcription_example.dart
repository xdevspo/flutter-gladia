import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gladia/gladia.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// Класс для обработки событий жизненного цикла приложения
class LifecycleObserver extends WidgetsBindingObserver {
  final Future<void> Function()? onDetached;

  LifecycleObserver({this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached && onDetached != null) {
      onDetached!();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gladia Live Transcription Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LiveTranscriptionPage(),
    );
  }
}

class LiveTranscriptionPage extends StatefulWidget {
  const LiveTranscriptionPage({Key? key}) : super(key: key);

  @override
  State<LiveTranscriptionPage> createState() => _LiveTranscriptionPageState();
}

class _LiveTranscriptionPageState extends State<LiveTranscriptionPage> {
  // Экземпляр Gladia клиента
  GladiaClient? _gladiaClient;

  // Recorder для записи аудио с микрофона
  final _audioRecorder = AudioRecorder();

  // WebSocket соединение для передачи аудио данных
  LiveTranscriptionSocket? _socket;

  // Статусы для UI
  bool _isInitializing = false;
  bool _isRecording = false;
  bool _isTranscribing = false;

  // Индикация активности микрофона
  double _currentAmplitude = 0.0;

  // Буфер транскрипций
  final List<String> _transcriptions = [];

  // Контроллер для текстового поля с API ключом
  final TextEditingController _apiKeyController = TextEditingController();

  // Стрим аудио данных
  StreamSubscription? _amplitudeSubscription;
  Timer? _sendAudioTimer;
  String? _tempFilePath;

  // Записываем данные сессии
  String? _sessionId;

  // Включить подробное логирование
  bool _enableLogging = true;

  // Наблюдатель жизненного цикла
  late LifecycleObserver _lifecycleObserver;

  // Ключи для SharedPreferences
  static const _apiKeyPrefKey = 'gladia_api_key';

  @override
  void initState() {
    super.initState();
    _loadApiKey();

    // Регистрация обработчика для корректного закрытия сессии при выходе из приложения
    _lifecycleObserver = LifecycleObserver(
      onDetached: () async {
        // Вызываем очистку ресурсов при закрытии приложения
        await _stopRecordingAndTranscription();
        await _closeGladiaSession();
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // Очищаем активные сессии при запуске приложения
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetActiveSessions();
    });
  }

  // Загрузка API ключа из настроек
  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_apiKeyPrefKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        setState(() {
          _apiKeyController.text = savedKey;
        });
        _log('API ключ загружен из кеша');
      }
    } catch (e) {
      _log('Ошибка при загрузке API ключа: $e');
    }
  }

  // Сохранение API ключа в настройки
  Future<void> _saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyPrefKey, apiKey);
      _log('API ключ сохранен в кеш');
    } catch (e) {
      _log('Ошибка при сохранении API ключа: $e');
    }
  }

  // Логирование для отладки
  void _log(String message) {
    if (_enableLogging) {
      debugPrint('[Gladia] $message');
    }
  }

  // Инициализация Gladia клиента
  void _initGladiaClient() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showError('Пожалуйста, введите API ключ');
      return;
    }

    // Сохраняем API ключ для следующего запуска
    _saveApiKey(apiKey);

    _gladiaClient = GladiaClient(
      apiKey: apiKey,
      enableLogging: _enableLogging,
    );
  }

  // Запрос разрешений на запись аудио
  Future<bool> _requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Подготовка временного файла для записи аудио
  Future<String> _prepareAudioFile() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/gladia_live_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  // Начало записи и транскрипции
  Future<void> _startRecordingAndTranscription() async {
    if (_isRecording || _isTranscribing) return;

    setState(() {
      _isInitializing = true;
    });

    // Инициализация клиента
    _initGladiaClient();

    // Проверка разрешений
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showError('Нет разрешения на запись аудио');
      setState(() {
        _isInitializing = false;
      });
      return;
    }

    try {
      // Подготовка файла для записи
      _tempFilePath = await _prepareAudioFile();
      _log('Подготовлен временный файл: $_tempFilePath');

      // Инициализация сессии для распознавания речи в реальном времени
      final sessionResult = await _gladiaClient!.initLiveTranscription(
        sampleRate: 16000,
        bitDepth: 16,
        channels: 1,
        encoding: 'wav/pcm',
      );
      _sessionId = sessionResult.id;
      _log('Сессия инициализирована: ${sessionResult.id}');

      // Создание WebSocket соединения
      _socket = _gladiaClient!.createLiveTranscriptionSocket(
        sessionUrl: sessionResult.url,
        onMessage: _handleTranscriptionMessage,
        onDone: () {
          _log('WebSocket соединение закрыто');
          _stopRecordingAndTranscription();
        },
        onError: (error) {
          _showError('Ошибка WebSocket: $error');
          _log('WebSocket ошибка: $error');
          _stopRecordingAndTranscription();
        },
      );
      _log('WebSocket соединение установлено');

      // Очистка предыдущих транскрипций
      setState(() {
        _transcriptions.clear();
      });

      try {
        // Запуск записи аудио с настройками
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 256000,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _tempFilePath!,
        );
        _log('Запись аудио запущена в файл: $_tempFilePath');

        // Настройка мониторинга активности микрофона
        _startAudioMonitoring();

        // Запуск периодической отправки аудио данных
        _startPeriodicAudioSending();

        // Обновление UI
        setState(() {
          _isInitializing = false;
          _isRecording = true;
          _isTranscribing = true;
        });
      } catch (recordError) {
        _showError('Ошибка при запуске записи: $recordError');
        _log('Ошибка при запуске записи: $recordError');

        // Закрываем соединение если запись не удалась
        if (_socket != null && _socket!.isConnected) {
          _socket!.close();
          _socket = null;
        }

        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      _showError('Ошибка при инициализации: $e');
      _log('Ошибка при инициализации: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  // Сбрасывает зависшие активные сессии
  Future<void> _resetActiveSessions() async {
    if (_apiKeyController.text.trim().isEmpty) {
      return; // API ключ не задан, не можем продолжить
    }

    try {
      _log('Попытка сброса активных сессий...');

      // Отправляем запрос на получение списка активных сессий
      final dio = Dio()
        ..options.baseUrl = 'https://api.gladia.io/'
        ..options.headers = {
          'x-gladia-key': _apiKeyController.text.trim(),
          'Content-Type': 'application/json',
        };

      // Пробуем сбросить сессии, отправляя DELETE запрос на специальный эндпоинт
      await dio.delete('v2/live/reset').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('Тайм-аут при сбросе сессий');
          return Response(
            requestOptions: RequestOptions(path: 'v2/live/reset'),
            statusCode: 408,
          );
        },
      );

      _log('Сброс активных сессий выполнен успешно');
    } catch (e) {
      _log('Не удалось сбросить активные сессии: $e');
      // Не показываем ошибку пользователю, это фоновый процесс
    }
  }

  // Закрытие сессии на стороне API
  Future<void> _closeGladiaSession() async {
    if (_sessionId != null && _apiKeyController.text.trim().isNotEmpty) {
      try {
        _log('Закрытие сессии Gladia API: $_sessionId');
        // Отправляем DELETE запрос, чтобы закрыть сессию на стороне API
        final dio = Dio()
          ..options.baseUrl = 'https://api.gladia.io/'
          ..options.headers = {
            'x-gladia-key': _apiKeyController.text.trim(),
            'Content-Type': 'application/json',
          };

        await dio.delete('v2/live/$_sessionId').timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _log('Тайм-аут при закрытии сессии');
            // В случае тайм-аута пробуем выполнить сброс всех сессий
            dio
                .delete('v2/live/reset')
                .catchError((e) => _log('Ошибка при сбросе сессий: $e'));
            return Response(
              requestOptions: RequestOptions(path: 'v2/live/$_sessionId'),
              statusCode: 408,
            );
          },
        );
        _log('Сессия успешно закрыта');
      } catch (e) {
        _log('Ошибка при закрытии сессии: $e');
        // Пробуем выполнить сброс всех сессий при ошибке
        try {
          final dio = Dio()
            ..options.baseUrl = 'https://api.gladia.io/'
            ..options.headers = {
              'x-gladia-key': _apiKeyController.text.trim(),
              'Content-Type': 'application/json',
            };

          await dio.delete('v2/live/reset').timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              _log('Тайм-аут при сбросе сессий после ошибки');
              return Response(
                requestOptions: RequestOptions(path: 'v2/live/reset'),
                statusCode: 408,
              );
            },
          );
          _log('Выполнен сброс всех сессий после ошибки закрытия');
        } catch (resetError) {
          _log('Не удалось сбросить сессии: $resetError');
        }
      }
      _sessionId = null;
    }
  }

  // Остановка записи и транскрипции
  Future<void> _stopRecordingAndTranscription() async {
    if (!_isRecording && !_isTranscribing) return;

    // Отмена подписок и таймеров
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    _sendAudioTimer?.cancel();
    _sendAudioTimer = null;

    // Остановка записи
    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        _log('Запись аудио остановлена: $path');
      } catch (e) {
        _log('Ошибка при остановке записи: $e');
        // Пробуем принудительно отменить запись
        try {
          await _audioRecorder.cancel();
          _log('Запись аудио принудительно отменена');
        } catch (ce) {
          _log('Ошибка при отмене записи: $ce');
        }
      }
    }

    // Отправка сигнала об остановке записи
    if (_socket != null && _socket!.isConnected) {
      try {
        _socket!.sendStopRecording();
        _log('Отправлен сигнал остановки записи');
      } catch (e) {
        _log('Ошибка при отправке сигнала остановки: $e');
      } finally {
        _socket!.close();
        _socket = null;
        _log('WebSocket соединение закрыто');
      }
    }

    // Закрытие сессии на сервере Gladia
    await _closeGladiaSession();

    // Очистка временного файла
    if (_tempFilePath != null) {
      try {
        final tempFile = File(_tempFilePath!);
        if (await tempFile.exists()) {
          await tempFile.delete();
          _log('Временный файл удален: $_tempFilePath');
        }
      } catch (e) {
        _log('Ошибка при удалении временного файла: $e');
      }
      _tempFilePath = null;
    }

    // Обновление UI
    setState(() {
      _currentAmplitude = 0.0;
      _isRecording = false;
      _isTranscribing = false;
    });
  }

  // Мониторинг уровня звука микрофона
  void _startAudioMonitoring() {
    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      setState(() {
        // Защита от некорректных значений амплитуды
        if (!amp.current.isNaN && !amp.current.isInfinite) {
          _currentAmplitude = amp.current;
        } else {
          _currentAmplitude = 0.0;
        }
      });
    });
  }

  // Периодическая отправка аудио данных
  void _startPeriodicAudioSending() {
    // Интервал между чтениями аудиофайла (мс)
    const sendInterval = 300;

    // Размер секций для чтения аудио (44 байта - размер заголовка WAV)
    const wavHeaderSize = 44;

    // Флаг первой отправки (для отправки WAV заголовка)
    bool isFirstSend = true;

    // Запускаем периодическое чтение и отправку аудио данных
    _sendAudioTimer = Timer.periodic(
      const Duration(milliseconds: sendInterval),
      (timer) async {
        if (!_isRecording || _socket == null || !_socket!.isConnected) {
          timer.cancel();
          return;
        }

        try {
          // Создаем буфер для аудио данных
          final file = File(_tempFilePath!);

          // Проверяем, существует ли файл
          if (await file.exists()) {
            final fileLength = await file.length();

            // Проверяем, есть ли данные для чтения
            if (fileLength > wavHeaderSize) {
              final raf = await file.open(mode: FileMode.read);

              if (isFirstSend) {
                // При первой отправке сначала пропускаем WAV заголовок
                isFirstSend = false;
                await raf.setPosition(wavHeaderSize);
              } else {
                // Читаем последний фрагмент аудио данных, пропуская заголовок
                final chunkSize = 8 * 1024; // 8KB
                final endPos = fileLength;
                final startPos = fileLength > chunkSize + wavHeaderSize
                    ? fileLength - chunkSize
                    : wavHeaderSize;

                await raf.setPosition(startPos);

                final audioBytes = await raf.read(endPos - startPos);
                await raf.close();

                // Отправляем аудио данные через WebSocket
                if (_socket != null &&
                    _socket!.isConnected &&
                    audioBytes.isNotEmpty) {
                  try {
                    // Отправляем сырые PCM данные
                    _socket!.sendAudioData(audioBytes);

                    // Альтернативно, можно отправлять данные в формате base64
                    // Раскомментируйте следующую строку, если нужно отправлять в base64
                    // _socket!.sendBase64AudioData(audioBytes);

                    _log('Отправлено ${audioBytes.length} байт аудио данных');
                  } catch (e) {
                    _log('Ошибка при отправке аудиоданных: $e');
                  }
                }
              }
            } else if (fileLength > 0 && fileLength <= wavHeaderSize) {
              _log('Аудиофайл содержит только заголовок WAV');
            } else {
              _log('Файл аудиозаписи пуст');
            }
          } else {
            _log('Файл аудиозаписи не существует');
          }
        } catch (e) {
          _log('Ошибка при чтении аудио данных: $e');
        }
      },
    );
  }

  // Обработка сообщений от сервера транскрипции
  void _handleTranscriptionMessage(dynamic message) {
    _log('Получено сообщение от сервера: $message');

    // Обработка сообщения о транскрипции
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
              _log('Получена финальная транскрипция: $text');

              // Ограничиваем количество транскрипций для избежания переполнения памяти
              if (_transcriptions.length > 50) {
                _transcriptions.removeAt(0);
              }
            } else {
              // Для промежуточных результатов обновляем последний элемент
              if (_transcriptions.isEmpty) {
                _transcriptions.add('(частично) $text');
              } else {
                _transcriptions[_transcriptions.length - 1] =
                    '(частично) $text';
              }
              _log('Получена частичная транскрипция: $text');
            }
          });
        }
      } catch (e) {
        _log('Ошибка обработки сообщения: $e');
      }
    }
    // Обработка сообщения о готовности сессии
    else if (message is Map<String, dynamic> && message['type'] == 'ready') {
      _log('Сессия готова к приему аудио данных');
    }
    // Обработка сообщения об ошибке
    else if (message is Map<String, dynamic> && message['type'] == 'error') {
      final errorMessage = message['data']?['message'] ?? 'Неизвестная ошибка';
      _log('Ошибка от сервера: $errorMessage');
      _showError('Ошибка от сервера: $errorMessage');
    }
  }

  // Отображение ошибки
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _stopRecordingAndTranscription();
    _closeGladiaSession();
    _audioRecorder.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gladia Live Транскрипция'),
        actions: [
          // Кнопка сброса сессий
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Сбросить активные сессии',
            onPressed: _isInitializing
                ? null
                : () async {
                    setState(() {
                      _isInitializing = true;
                    });
                    await _resetActiveSessions();
                    setState(() {
                      _isInitializing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Выполнен сброс активных сессий'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API ключ
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Ключ Gladia',
                hintText: 'Введите ваш API ключ Gladia',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !_isRecording && !_isTranscribing,
            ),
            const SizedBox(height: 16),

            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isInitializing || _isRecording || _isTranscribing
                            ? null
                            : _startRecordingAndTranscription,
                    child: _isInitializing
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Начать'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!_isRecording && !_isTranscribing)
                        ? null
                        : _stopRecordingAndTranscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Остановить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Статус
            Center(
              child: Text(
                _isRecording
                    ? 'Запись и транскрипция...'
                    : _isTranscribing
                        ? 'Транскрипция...'
                        : 'Готов к записи',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Индикатор записи и амплитуды
            if (_isRecording)
              Column(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Идет запись...',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Индикатор уровня звука
                  LinearProgressIndicator(
                    value: _currentAmplitude.isNaN ||
                            _currentAmplitude.isInfinite
                        ? 0.0
                        : (_currentAmplitude / 100).clamp(
                            0.0, 1.0), // Нормализуем и ограничиваем значение
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentAmplitude > 50
                          ? Colors.red
                          : _currentAmplitude > 20
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Уровень звука: ${_currentAmplitude.isNaN || _currentAmplitude.isInfinite ? "0.0" : _currentAmplitude.toStringAsFixed(1)} dB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Заголовок для транскрипций
            const Text(
              'Транскрипция:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Список транскрипций
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _transcriptions.isEmpty
                    ? const Center(
                        child: Text(
                          'Транскрипции будут отображаться здесь',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _transcriptions.length,
                        shrinkWrap:
                            true, // Добавляем для предотвращения переполнения
                        physics:
                            const ClampingScrollPhysics(), // Улучшаем скроллинг
                        itemBuilder: (context, index) {
                          final text = _transcriptions[index];
                          final isPartial = text.startsWith('(частично)');
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isPartial
                                    ? Colors.grey.shade100
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPartial
                                      ? Colors.grey.shade300
                                      : Colors.blue.shade200,
                                ),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontStyle: isPartial
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: isPartial
                                      ? Colors.grey.shade700
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
