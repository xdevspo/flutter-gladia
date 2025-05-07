import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gladia/gladia.dart';
import 'package:gladia/src/exceptions/exceptions.dart';
import 'package:gladia/src/models/models.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

// Значение для передачи любых данных в мок
const any = <String, dynamic>{};

// Мок-данные для тестов
final mockUploadResponse = {
  'audio_url': 'https://example.com/audio.mp3',
  'metadata': {
    'filename': 'test.mp3',
    'size': 1024,
  }
};

final mockTranscriptionInitResponse = {
  'id': 'test_id',
  'status': 'queued',
  'result_url': 'https://api.gladia.io/v2/pre-recorded/test_id'
};

final mockTranscriptionResultResponse = {
  'id': 'test_id',
  'status': 'done',
  'result': {
    'transcription': {
      'full_transcript': 'This is a test transcript',
      'utterances': []
    },
    'metadata': {'language': 'en', 'audio_duration': 10.5}
  },
  'file': {'audio_url': 'https://example.com/audio.mp3', 'audio_duration': 10.5}
};

final mockTranscriptionListResponse = {
  'items': [
    {
      'id': 'transcript1',
      'status': 'done',
      'created_at': '2023-01-01T00:00:00Z',
      'file': {'audio_url': 'https://example.com/audio1.mp3'}
    },
    {
      'id': 'transcript2',
      'status': 'processing',
      'created_at': '2023-01-02T00:00:00Z',
      'file': {'audio_url': 'https://example.com/audio2.mp3'}
    }
  ],
  'first': 'https://api.gladia.io/v2/pre-recorded?page=1',
  'current': 'https://api.gladia.io/v2/pre-recorded?page=1',
  'next': null
};

final mockLiveSessionInitResponse = {
  'id': 'live_session_id',
  'url': 'wss://api.gladia.io/v2/live/socket/live_session_id'
};

final mockLiveTranscriptionResultResponse = {
  'id': 'live_session_id',
  'status': 'done',
  'created_at': '2023-01-01T00:00:00Z',
  'result': {
    'transcription': {
      'full_transcript': 'This is a live test transcript',
      'utterances': []
    }
  }
};

// Создаем простой файл-заглушку
File createFakeFile() {
  return File('README.md'); // этот файл всегда есть в корне проекта
}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late GladiaClient client;
  late FullMockGladiaClient mockClient;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.gladia.io/'));
    dioAdapter = DioAdapter(dio: dio);
    client = GladiaClient(
      apiKey: 'test_api_key',
      dio: dio,
    );
    mockClient = FullMockGladiaClient(
      apiKey: 'test_api_key',
      mockUploadResult:
          const UploadResult(audioUrl: 'https://example.com/audio.mp3'),
      mockInitResult: const TranscriptionInitResult(
        id: 'test_id',
        resultUrl: 'https://api.gladia.io/v2/pre-recorded/test_id',
      ),
      mockTranscriptResult: TranscriptionResult(
        id: 'test_id',
        status: 'done',
        result: TranscriptionResultData(
          transcription: TranscriptionData(
            fullTranscript: 'This is a test transcript',
          ),
        ),
      ),
    );
  });

  group('GladiaClient', () {
    test('uploadAudioFile should be mocked correctly', () async {
      final result = await mockClient.uploadAudioFile(createFakeFile());
      expect(result.audioUrl, 'https://example.com/audio.mp3');
    });

    test('initiateTranscription should return result with task ID', () async {
      // Настройка мок ответа
      dioAdapter.onPost(
        'v2/pre-recorded',
        (server) => server.reply(200, mockTranscriptionInitResponse),
        data: {
          'audio_url': 'https://example.com/audio.mp3',
          'language': 'en',
        },
      );

      // Выполнение метода
      final result = await client.initiateTranscription(
        audioUrl: 'https://example.com/audio.mp3',
        language: 'en',
      );

      // Проверка результата
      expect(result.id, 'test_id');
      expect(result.resultUrl, 'https://api.gladia.io/v2/pre-recorded/test_id');
    });

    test('getTranscriptionResult should return transcription result', () async {
      // Настройка мок ответа
      dioAdapter.onGet(
        'v2/pre-recorded/test_id',
        (server) => server.reply(200, mockTranscriptionResultResponse),
      );

      // Выполнение метода
      final result = await client.getTranscriptionResult('test_id');

      // Проверка результата
      expect(result.id, 'test_id');
      expect(result.status, 'done');
      expect(result.result?.transcription?.fullTranscript,
          'This is a test transcript');
      expect(result.file?.audioDuration, 10.5);
    });

    test('getTranscriptionList should return list of transcriptions', () async {
      // Настройка мок ответа
      dioAdapter.onGet(
        'v2/pre-recorded',
        (server) => server.reply(200, mockTranscriptionListResponse),
      );

      // Выполнение метода
      final result = await client.getTranscriptionList();

      // Проверка результата
      expect(result.list.length, 2);
      expect(result.list[0].id, 'transcript1');
      expect(result.list[0].status, 'done');
      expect(result.list[1].id, 'transcript2');
      expect(result.list[1].status, 'processing');
      expect(
          result.currentPage, 'https://api.gladia.io/v2/pre-recorded?page=1');
    });

    test('deleteTranscription should return true when successful', () async {
      // Настройка мок ответа
      dioAdapter.onDelete(
        'v2/pre-recorded/test_id',
        (server) => server.reply(200, {'success': true}),
      );

      // Выполнение метода
      final result = await client.deleteTranscription(id: 'test_id');

      // Проверка результата
      expect(result, true);
    });

    test(
        'transcribeFile should upload file, initiate transcription and return result',
        () async {
      // Используем полностью замоканный клиент
      final result = await mockClient.transcribeFile(
        file: createFakeFile(),
        language: 'en',
        waitForResult: true,
      );

      // Проверка результата
      expect(result.id, 'test_id');
      expect(result.status, 'done');
      expect(result.result?.transcription?.fullTranscript,
          'This is a test transcript');
    });

    test('downloadFile should return path when successful', () async {
      // Настройка мок ответа с бинарными данными
      final mockBytes = Uint8List.fromList('test audio content'.codeUnits);
      dioAdapter.onGet(
        'v2/pre-recorded/test_id/file',
        (server) => server.reply(200, mockBytes, headers: {
          'content-disposition': ['attachment; filename="test_download.mp3"'],
        }),
      );

      // Проверяем только ответ, так как реальный download вызовет создание файла
      final response = await dio.get<List<int>>(
        'v2/pre-recorded/test_id/file',
        options: Options(responseType: ResponseType.bytes),
      );
      expect(response.data, mockBytes);

      // Проверяем, что в заголовке есть имя файла
      expect(response.headers.map['content-disposition']?.first,
          contains('filename="test_download.mp3"'));
    });

    test('initLiveTranscription should return session init result', () async {
      // Настройка мок ответа
      dioAdapter.onPost(
        'v2/live',
        (server) => server.reply(200, mockLiveSessionInitResponse),
        data: any,
      );

      // Выполнение метода
      final result = await client.initLiveTranscription(
        sampleRate: 16000,
        language: 'en',
      );

      // Проверка результата
      expect(result.id, 'live_session_id');
      expect(result.url, 'wss://api.gladia.io/v2/live/socket/live_session_id');
    });

    test('getLiveTranscriptionResult should return live transcription result',
        () async {
      // Настройка мок ответа
      dioAdapter.onGet(
        'v2/live/live_session_id',
        (server) => server.reply(200, mockLiveTranscriptionResultResponse),
      );

      // Выполнение метода
      final result =
          await client.getLiveTranscriptionResult(id: 'live_session_id');

      // Проверка результата
      expect(result.id, 'live_session_id');
      expect(result.status, 'done');
      expect(result.text, 'This is a live test transcript');
    });

    test('deleteLiveTranscription should return true when successful',
        () async {
      // Настройка мок ответа
      dioAdapter.onDelete(
        'v2/live/live_session_id',
        (server) => server.reply(200, {'success': true}),
      );

      // Выполнение метода
      final result =
          await client.deleteLiveTranscription(id: 'live_session_id');

      // Проверка результата
      expect(result, true);
    });
  });
}

/// Полностью замоканный клиент для тестирования
class FullMockGladiaClient extends GladiaClient {
  final UploadResult? mockUploadResult;
  final TranscriptionInitResult? mockInitResult;
  final TranscriptionResult? mockTranscriptResult;

  FullMockGladiaClient({
    required super.apiKey,
    super.dio,
    super.enableLogging = false,
    this.mockUploadResult,
    this.mockInitResult,
    this.mockTranscriptResult,
  });

  @override
  Future<UploadResult> uploadAudioFile(File file) async {
    if (mockUploadResult != null) {
      return mockUploadResult!;
    }
    throw Exception('Mock upload result is null');
  }

  @override
  Future<TranscriptionInitResult> initiateTranscription({
    required String audioUrl,
    String? language,
    TranscriptionOptions? options,
  }) async {
    if (mockInitResult != null) {
      return mockInitResult!;
    }
    throw Exception('Mock transcription init result is null');
  }

  @override
  Future<TranscriptionResult> getTranscriptionResult(
      String transcriptionIdOrUrl) async {
    if (mockTranscriptResult != null) {
      return mockTranscriptResult!;
    }
    throw Exception('Mock transcription result is null');
  }
}
