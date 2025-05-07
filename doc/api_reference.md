# API Reference

This document contains a detailed description of all available classes and methods in the Gladia API SDK.

## GladiaClient

The main class for working with Gladia API.

### Constructor

```dart
GladiaClient({
  required String apiKey,
  Dio? dio,
  bool enableLogging = false,
})
```

#### Parameters:
- `apiKey` (String, required) - API key for accessing Gladia services
- `dio` (Dio?, optional) - HTTP client, if not specified, a new one is created
- `enableLogging` (bool, default false) - enable HTTP request logging

### Methods

#### uploadAudioFile

Uploads an audio file to the Gladia server.

```dart
Future<UploadResult> uploadAudioFile(File file)
```

**Parameters:**
- `file` (File) - audio file to upload

**Returns:** 
- `UploadResult` - upload result with URL and file metadata

#### initiateTranscription

Sends a request for audio transcription by URL.

```dart
Future<TranscriptionInitResult> initiateTranscription({
  required String audioUrl,
  String? language,
  TranscriptionOptions? options,
})
```

**Parameters:**
- `audioUrl` (String, required) - URL of the audio file for transcription
- `language` (String?, optional) - audio language
- `options` (TranscriptionOptions?, optional) - additional transcription parameters

**Returns:**
- `TranscriptionInitResult` - initialization result with task ID and URL for getting the result

#### getTranscriptionResult

Gets the transcription result by task ID.

```dart
Future<TranscriptionResult> getTranscriptionResult({
  required String taskId,
  int maxAttempts = 60,
  Duration retryInterval = const Duration(seconds: 2),
})
```

**Parameters:**
- `taskId` (String, required) - transcription task ID
- `maxAttempts` (int, default 60) - maximum number of attempts to get the result
- `retryInterval` (Duration, default 2 seconds) - interval between attempts

**Returns:**
- `TranscriptionResult` - transcription result with text and metadata

#### transcribeFile

Combined method for the complete file transcription process.

```dart
Future<TranscriptionResult> transcribeFile({
  required File file,
  String? language,
  TranscriptionOptions? options,
  int maxAttempts = 60,
  Duration retryInterval = const Duration(seconds: 2),
})
```

**Parameters:**
- `file` (File, required) - audio file for transcription
- `language` (String?, optional) - audio language
- `options` (TranscriptionOptions?, optional) - additional transcription parameters
- `maxAttempts` (int, default 60) - maximum number of attempts to get the result
- `retryInterval` (Duration, default 2 seconds) - interval between attempts

**Returns:**
- `TranscriptionResult` - transcription result with text and metadata

#### initiateLiveTranscription

Initializes a real-time transcription session.

```dart
Future<LiveSessionInitResult> initiateLiveTranscription({
  LiveTranscriptionOptions? options,
})
```

**Parameters:**
- `options` (LiveTranscriptionOptions?, optional) - options for real-time transcription

**Returns:**
- `LiveSessionInitResult` - initialization result with WebSocket URL

#### createLiveTranscriptionSocket

Creates a WebSocket connection for real-time transcription.

```dart
LiveTranscriptionSocket createLiveTranscriptionSocket({
  required String websocketUrl,
  Function(LiveTranscriptionResult)? onTranscriptionResult,
  Function(String)? onError,
  Function()? onDone,
})
```

**Parameters:**
- `websocketUrl` (String, required) - WebSocket connection URL
- `onTranscriptionResult` (Function?, optional) - transcription results handler
- `onError` (Function?, optional) - error handler
- `onDone` (Function?, optional) - connection close handler

**Returns:**
- `LiveTranscriptionSocket` - object for managing WebSocket connection

## Data Models

### TranscriptionOptions

Options for configuring the transcription process.

```dart
TranscriptionOptions({
  bool? diarize,
  int? speakerCount,
  List<String>? speakers,
  String? language,
  bool? directTranslation,
  TranslationConfig? translation,
  bool? subtitles,
  SubtitlesConfig? subtitlesConfig,
  String? subtitlesFormat,
  DiarizationConfig? diarizationConfig,
  bool? audioToText,
  bool? audioToSummary,
  bool? audioToMessage,
  MessagesConfig? messagesConfig,
  bool? audioToLLM,
  AudioToLLMConfig? audioToLLMConfig,
  String? model,
  LanguageConfig? languageConfig,
  String? prompt,
  bool? structuredDataExtraction,
  StructuredDataExtractionConfig? structuredDataExtractionConfig,
  RealtimeProcessing? realtimeProcessing,
  PreProcessing? preProcessing,
  PostProcessing? postProcessing,
  bool? paragraphizeSentences,
  CustomVocabularyConfig? customVocabularyConfig,
  CustomSpellingConfig? customSpellingConfig,
  Map<String, dynamic>? extraData,
  CallbackConfig? callbackConfig,
})
```

### LiveTranscriptionOptions

Options for configuring real-time transcription.

```dart
LiveTranscriptionOptions({
  String? encoding,
  int? sampleRate,
  int? bitDepth,
  bool? interim,
  List<String>? words,
  String? model,
  String? language,
  bool? diarize,
  int? speakerCount,
  bool? paragraphizeSentences,
  RealtimeProcessing? realtimeProcessing,
  CustomVocabularyConfig? customVocabularyConfig,
  CallbackConfig? callbackConfig,
})
```

## Additional Models

### UploadResult

Result of uploading an audio file.

### TranscriptionInitResult

Result of initializing the transcription process.

### TranscriptionResult

Complete transcription result including text, segments, and metadata.

### LiveSessionInitResult

Result of initializing a real-time transcription session.

### LiveTranscriptionResult

Real-time transcription result.

### Exceptions

#### GladiaApiException

Exception that occurs with API errors.

```dart
GladiaApiException({
  required String message,
  int? statusCode,
  String? errorCode,
  Map<String, dynamic>? data,
})
```

## Complete List of Models

The complete list of all data models used in the API is available in the library source code in the `/lib/src/models` folder. 