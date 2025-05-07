import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gladia/src/models/transcription_list.dart';
import 'package:http_parser/http_parser.dart';

import 'models/models.dart';
import 'exceptions/exceptions.dart';

/// Main class for working with Gladia API
class GladiaClient {
  /// API key for accessing Gladia services
  final String apiKey;

  /// HTTP client for making requests
  final Dio _dio;

  /// Base URL for API v2
  static const String _baseUrl = 'https://api.gladia.io/';

  /// Enable detailed HTTP request logging
  final bool enableLogging;

  /// Creates a new instance of [GladiaClient]
  ///
  /// [apiKey] - API key for accessing Gladia
  /// [dio] - optional HTTP client, if not specified, a new one is created
  /// [enableLogging] - enable HTTP request logging
  GladiaClient({
    required this.apiKey,
    Dio? dio,
    this.enableLogging = false,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'x-gladia-key': apiKey,
      'Content-Type': 'application/json',
    };

    if (enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// Uploads an audio file to Gladia server
  ///
  /// [file] - audio file to upload
  /// Returns [UploadResult] with URL and file metadata
  Future<UploadResult> uploadAudioFile(File file) async {
    try {
      // Create FormData to send the file
      final String fileName = file.path.split('/').last;
      final String extension = fileName.split('.').last.toLowerCase();

      // Determine MIME type based on extension
      String mimeType = 'audio/mpeg'; // Default for mp3
      if (extension == 'wav') {
        mimeType = 'audio/wav';
      } else if (extension == 'ogg') {
        mimeType = 'audio/ogg';
      } else if (extension == 'flac') {
        mimeType = 'audio/flac';
      } else if (extension == 'm4a') {
        mimeType = 'audio/m4a';
      }

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      // Set temporary headers for multipart/form-data request
      final originalHeaders = Map<String, dynamic>.from(_dio.options.headers);
      _dio.options.headers = {
        'x-gladia-key': apiKey,
        'Content-Type': 'multipart/form-data',
      };

      // Make request to upload the file
      final response = await _dio.post(
        'v2/upload',
        data: formData,
      );

      // Restore original headers
      _dio.options.headers = originalHeaders;

      // Check that the response contains data and is of the correct type
      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      if (response.data is! Map<String, dynamic>) {
        if (response.data is String) {
          try {
            // Try to parse the string as JSON
            final jsonData = json.decode(response.data as String);
            if (jsonData is Map<String, dynamic>) {
              return UploadResult.fromJson(jsonData);
            }
          } catch (e) {
            throw GladiaApiException(
              message: 'Unable to parse response as JSON: ${response.data}',
            );
          }
        }
        throw GladiaApiException(
          message:
              'Invalid response format from server: ${response.data.runtimeType}',
        );
      }

      return UploadResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Sends a request for audio transcription by URL
  ///
  /// [audioUrl] - URL of the audio file for transcription
  /// [language] - audio language (optional)
  /// [options] - additional transcription options
  /// Returns [TranscriptionInitResult] with task ID and URL for getting the result
  Future<TranscriptionInitResult> initiateTranscription({
    required String audioUrl,
    String? language,
    TranscriptionOptions? options,
  }) async {
    try {
      // Prepare request parameters
      final Map<String, dynamic> requestData = {
        'audio_url': audioUrl,
      };

      // Add language if specified
      if (language != null) {
        requestData['language'] = language;
      }

      // Add options if specified
      if (options != null) {
        // Merge parameters from TranscriptionOptions
        requestData.addAll(options.toJson());
      }

      // Make request for transcription using the new v2/pre-recorded endpoint
      final response = await _dio.post(
        'v2/pre-recorded',
        data: requestData,
      );

      // Check that the response contains data and is of the correct type
      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      if (response.data is! Map<String, dynamic>) {
        if (response.data is String) {
          try {
            // Try to parse the string as JSON
            final jsonData = json.decode(response.data as String);
            if (jsonData is Map<String, dynamic>) {
              return TranscriptionInitResult.fromJson(jsonData);
            }
          } catch (e) {
            throw GladiaApiException(
              message: 'Unable to parse response as JSON: ${response.data}',
            );
          }
        }
        throw GladiaApiException(
          message:
              'Invalid response format from server: ${response.data.runtimeType}',
        );
      }

      return TranscriptionInitResult.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Gets transcription results by task ID or URL
  ///
  /// [transcriptionIdOrUrl] - task ID or full URL for getting the result
  /// Returns [TranscriptionResult] with transcription results
  Future<TranscriptionResult> getTranscriptionResult(
      String transcriptionIdOrUrl) async {
    try {
      String url;
      bool isAbsoluteUrl = false;

      // Check if the passed parameter is URL or ID
      if (transcriptionIdOrUrl.startsWith('http')) {
        url = transcriptionIdOrUrl;
        isAbsoluteUrl = true;
      } else {
        // Update path for new API
        url = 'v2/pre-recorded/$transcriptionIdOrUrl';
      }

      // Make request
      final Response<dynamic> response;
      if (isAbsoluteUrl) {
        // For absolute URL create temporary Dio without baseUrl
        final tempDio = Dio();
        tempDio.options.headers = _dio.options.headers;

        if (enableLogging) {
          tempDio.interceptors.add(LogInterceptor(
            requestBody: true,
            responseBody: true,
          ));
        }

        response = await tempDio.get(url);
      } else {
        response = await _dio.get(url);
      }

      // Check that the response contains data and is of the correct type
      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      // Convert data to Map<String, dynamic>
      Map<String, dynamic> responseData;

      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          // Try to parse the string as JSON
          final jsonData = json.decode(response.data as String);
          if (jsonData is Map<String, dynamic>) {
            responseData = jsonData;
          } else {
            throw const FormatException(
                'Response is not a correct JSON object');
          }
        } catch (e) {
          throw GladiaApiException(
            message: 'Unable to parse response as JSON: ${response.data}',
          );
        }
      } else {
        throw GladiaApiException(
          message:
              'Invalid response format from server: ${response.data.runtimeType}',
        );
      }

      // Check transcription status
      final status = responseData['status'];
      if (status == null) {
        throw GladiaApiException(
          message: 'Status field is missing in response',
          responseData: responseData,
        );
      }

      final String statusStr = status is String ? status : status.toString();

      if (statusStr == 'done') {
        // Transcription completed, return result
        try {
          // Use new model for parsing full answer
          final result = TranscriptionResult.fromJson(responseData);

          return result;
        } catch (e) {
          try {
            // If an error occurred during parsing full structure,
            // use simplified method for extracting basic data
            final result = responseData['result'];
            if (result is! Map<String, dynamic>) {
              throw const FormatException('Result field is not an object');
            }

            final transcription = result['transcription'];
            if (transcription is! Map<String, dynamic>) {
              throw const FormatException(
                  'Transcription field is not an object');
            }

            // Get full transcription text
            String fullTranscript = '';
            final transcript = transcription['full_transcript'];
            if (transcript is String) {
              fullTranscript = transcript;
            } else if (transcript != null) {
              fullTranscript = transcript.toString();
            }

            // Extract metadata
            final metadata = result['metadata'] as Map<String, dynamic>?;
            String? language;
            double? duration;

            if (metadata != null) {
              final langValue = metadata['language'];
              if (langValue is String) {
                language = langValue;
              } else if (langValue != null) {
                language = langValue.toString();
              }

              final durationValue = metadata['audio_duration'];
              if (durationValue is double) {
                duration = durationValue;
              } else if (durationValue is int) {
                duration = durationValue.toDouble();
              } else if (durationValue is String) {
                try {
                  duration = double.parse(durationValue);
                } catch (_) {
                  duration = null;
                }
              }
            }

            // Create basic transcription result
            return TranscriptionResult(
              id: responseData['id'] as String? ?? 'unknown_id',
              status: 'done',
              file: FileInfo(
                audioDuration: duration,
              ),
              result: TranscriptionResultData(
                transcription: TranscriptionData(
                  fullTranscript: fullTranscript,
                  languages: language != null ? [language] : null,
                ),
              ),
            );
          } catch (innerError) {
            // If even backup option didn't work, throw original error with useful information
            throw GladiaApiException(
              message:
                  'Unable to parse result: $e. Additional error: $innerError',
              responseData: responseData,
            );
          }
        }
      } else if (statusStr == 'processing' || statusStr == 'queued') {
        // Transcription not completed yet
        throw GladiaApiException(
          message:
              'Transcription not completed yet. Current status: $statusStr',
          statusCode: 202,
          responseData: responseData,
        );
      } else {
        // Transcription error
        final errorMessage = responseData['error'];
        final errorText =
            errorMessage != null ? errorMessage.toString() : statusStr;

        throw GladiaApiException(
          message: 'Transcription error: $errorText',
          statusCode: 400,
          responseData: responseData,
        );
      }
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Performs audio transcription with the ability to wait for the result
  ///
  /// [file] - audio file for transcription
  /// [language] - audio language (optional)
  /// [options] - additional transcription options
  /// [waitForResult] - wait for transcription completion
  /// [pollInterval] - transcription status polling interval in milliseconds
  /// [maxAttempts] - maximum number of polling attempts
  ///
  /// If [waitForResult] = true, the method will wait for transcription completion.
  /// Otherwise, it will return [TranscriptionInitResult] with URL and ID for getting the result later.
  Future<dynamic> transcribeFile({
    required File file,
    String? language,
    TranscriptionOptions? options,
    bool waitForResult = true,
    int pollInterval = 1000,
    int maxAttempts = 60,
  }) async {
    try {
      // Step 1: Upload file
      final uploadResult = await uploadAudioFile(file);

      // Step 2: Initiate transcription
      final transcriptionInit = await initiateTranscription(
        audioUrl: uploadResult.audioUrl,
        language: language,
        options: options,
      );

      // If no need to wait for result, return initialization data
      if (!waitForResult) {
        return transcriptionInit;
      }

      // Step 3: Wait for transcription result
      int attempts = 0;
      while (attempts < maxAttempts) {
        try {
          final result =
              await getTranscriptionResult(transcriptionInit.resultUrl);
          return result; // Successfully got result
        } on GladiaApiException catch (e) {
          // If status 202, transcription not completed yet
          if (e.statusCode == 202) {
            // Wait before next attempt
            await Future.delayed(Duration(milliseconds: pollInterval));
            attempts++;
          } else {
            // Other errors propagate further
            rethrow;
          }
        }
      }

      // If maximum attempts exceeded, return error
      throw GladiaApiException(
        message: 'Maximum waiting time for transcription result exceeded',
        statusCode: 408,
      );
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Gets transcription list
  Future<TranscriptionList> getTranscriptionList() async {
    final response = await _dio.get('v2/pre-recorded');
    return TranscriptionList.fromJson(response.data);
  }

  /// Deletes transcription by ID
  ///
  /// [id] - transcription ID
  /// Returns true if transcription deleted successfully
  Future<bool> deleteTranscription({required String id}) async {
    try {
      final originalHeaders = Map<String, dynamic>.from(_dio.options.headers);
      _dio.options.headers = {
        'x-gladia-key': apiKey,
        'Content-Type': 'application/json',
      };

      final response = await _dio.delete('v2/pre-recorded/$id');

      _dio.options.headers = originalHeaders;

      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      return true;
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Downloads file by URL
  ///
  /// [recordId] - recording ID
  /// [outputPath] - path where the file will be saved (optional)
  /// Returns saved file path
  Future<String> downloadFile({
    required String recordId,
    String? outputPath,
  }) async {
    try {
      final originalHeaders = Map<String, dynamic>.from(_dio.options.headers);
      _dio.options.headers = {
        'x-gladia-key': apiKey,
      };

      // Set parameters for downloading file
      final options = Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      );

      final response = await _dio.get(
        'v2/pre-recorded/$recordId/file',
        options: options,
      );

      _dio.options.headers = originalHeaders;

      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      // Determine file name from headers or generate randomly
      String fileName = 'gladia_audio_$recordId.mp3';

      // If there is Content-Disposition header, try to extract file name
      final contentDisposition = response.headers.value('content-disposition');
      if (contentDisposition != null &&
          contentDisposition.contains('filename=')) {
        final match =
            RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
        if (match != null) {
          fileName = match.group(1) ?? fileName;
        }
      }

      // Determine save path
      final savePath = outputPath ?? fileName;

      // Create file and write data
      final file = File(savePath);
      await file.writeAsBytes(response.data as List<int>);

      return file.path;
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Performs audio transcription
  ///
  /// [audioFile] - path or URL to audio file
  /// [language] - audio language (optional)
  /// [options] - additional transcription options
  ///
  /// @deprecated Use [transcribeFile] instead of this method
  Future<TranscriptionResult> transcribeAudio({
    required String audioFile,
    String? language,
    TranscriptionOptions? options,
  }) async {
    try {
      // Check if audioFile is URL or path to file
      if (audioFile.startsWith('http')) {
        // If it's URL, initiate transcription and wait for result
        final transcriptionInit = await initiateTranscription(
          audioUrl: audioFile,
          language: language,
          options: options,
        );

        // Wait for result (5 attempts with 2 seconds interval)
        int attempts = 0;
        while (attempts < 5) {
          try {
            return await getTranscriptionResult(transcriptionInit.resultUrl);
          } on GladiaApiException catch (e) {
            if (e.statusCode == 202) {
              await Future.delayed(const Duration(seconds: 2));
              attempts++;
            } else {
              rethrow;
            }
          }
        }

        throw GladiaApiException(
          message: 'Maximum waiting time for transcription result exceeded',
          statusCode: 408,
        );
      } else {
        // If it's path to file, use transcribeFile
        final file = File(audioFile);
        if (!file.existsSync()) {
          throw GladiaApiException(
            message: 'File not found: $audioFile',
            statusCode: 404,
          );
        }

        final result = await transcribeFile(
          file: file,
          language: language,
          options: options,
        );

        return result as TranscriptionResult;
      }
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Performs speech recognition in real time
  ///
  /// [audioStream] - audio data stream
  /// [language] - audio language (optional)
  /// [options] - additional transcription options
  /// [sampleRate] - audio sampling rate in Hz (default 16000)
  /// [bitDepth] - audio bit depth (default 16)
  /// [channels] - audio channel count (default 1)
  /// [encoding] - audio encoding format (default 'wav/pcm')
  ///
  /// Returns transcription result stream
  Stream<TranscriptionMessage> streamTranscribeAudio({
    required Stream<List<int>> audioStream,
    String? language,
    TranscriptionOptions? options,
    int sampleRate = 16000,
    int bitDepth = 16,
    int channels = 1,
    String encoding = 'wav/pcm',
  }) async* {
    try {
      // Session initialization
      final sessionResult = await initLiveTranscription(
        sampleRate: sampleRate,
        bitDepth: bitDepth,
        channels: channels,
        encoding: encoding,
        language: language,
        options: options,
      );

      // Create stream controller for result stream
      final streamController = StreamController<TranscriptionMessage>();

      // Create WebSocket connection
      final socket = createLiveTranscriptionSocket(
        sessionUrl: sessionResult.url,
        onMessage: (message) {
          if (message is Map<String, dynamic> &&
              message['type'] == 'transcript') {
            try {
              final transcriptionMessage =
                  TranscriptionMessage.fromJson(message);
              streamController.add(transcriptionMessage);
            } catch (e) {
              streamController.addError(GladiaApiException(
                message: 'Error processing message: $e',
                innerException: e,
              ));
            }
          }
        },
        onDone: () {
          if (!streamController.isClosed) {
            streamController.close();
          }
        },
        onError: (error) {
          streamController.addError(GladiaApiException(
            message: 'WebSocket error: $error',
            innerException: error,
          ));
          if (!streamController.isClosed) {
            streamController.close();
          }
        },
      );

      // Subscribe to audio data stream
      final audioSubscription = audioStream.listen(
        (data) {
          if (socket.isConnected) {
            socket.sendAudioData(data);
          }
        },
        onError: (error) {
          streamController.addError(GladiaApiException(
            message: 'Error in audio stream: $error',
            innerException: error,
          ));
        },
        onDone: () {
          // Send signal about recording end
          if (socket.isConnected) {
            socket.sendStopRecording();
          }
        },
      );

      // Return result stream
      yield* streamController.stream;

      // Free resources when stream ends
      await streamController.done.then((_) {
        audioSubscription.cancel();
        socket.close();
      });
    } catch (e) {
      throw GladiaApiException(
        message: 'Error in stream transcription: $e',
        innerException: e,
      );
    }
  }

  /// Initializes session for speech recognition in real time
  ///
  /// [sampleRate] - audio sampling rate in Hz (default 16000)
  /// [bitDepth] - audio bit depth (default 16)
  /// [channels] - audio channel count (default 1)
  /// [encoding] - audio encoding format (default 'wav/pcm')
  /// [language] - audio language (optional)
  /// [options] - additional options for recognition
  ///
  /// Returns [LiveSessionInitResult] with session ID and URL for WebSocket connection
  Future<LiveSessionInitResult> initLiveTranscription({
    int sampleRate = 16000,
    int bitDepth = 16,
    int channels = 1,
    String encoding = 'wav/pcm',
    String? language,
    TranscriptionOptions? options,
  }) async {
    try {
      // Prepare request parameters
      final Map<String, dynamic> requestData = {
        'sample_rate': sampleRate,
        'bit_depth': bitDepth,
        'channels': channels,
        'encoding': encoding,
      };

      // Add language if specified
      if (language != null) {
        requestData['language'] = language;
      }

      // Add options if specified
      if (options != null) {
        // Merge parameters from TranscriptionOptions
        requestData.addAll(options.toJson());
      }

      // Make request for session initialization
      final response = await _dio.post(
        'v2/live',
        data: requestData,
      );

      // Check that the response contains data and is of the correct type
      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      if (response.data is! Map<String, dynamic>) {
        if (response.data is String) {
          try {
            // Try to parse the string as JSON
            final jsonData = json.decode(response.data as String);
            if (jsonData is Map<String, dynamic>) {
              return LiveSessionInitResult.fromJson(jsonData);
            }
          } catch (e) {
            throw GladiaApiException(
              message: 'Unable to parse response as JSON: ${response.data}',
            );
          }
        }
        throw GladiaApiException(
          message:
              'Invalid response format from server: ${response.data.runtimeType}',
        );
      }

      return LiveSessionInitResult.fromJson(response.data);
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }

  /// Creates WebSocket connection for speech recognition in real time
  ///
  /// [sessionUrl] - URL of session obtained during initialization
  /// [onMessage] - callback for processing messages from server
  /// [onDone] - callback called when connection closed
  /// [onError] - callback for processing errors
  ///
  /// Returns [LiveTranscriptionSocket] for managing connection
  LiveTranscriptionSocket createLiveTranscriptionSocket({
    required String sessionUrl,
    void Function(dynamic)? onMessage,
    void Function()? onDone,
    Function? onError,
  }) {
    return LiveTranscriptionSocket(
      url: sessionUrl,
      onMessage: onMessage,
      onDone: onDone,
      onError: onError,
    );
  }

  /// Gets live transcription result by ID
  ///
  /// [id] - ID of the live transcription result
  ///
  /// Returns [LiveTranscriptionResult] with transcription results
  Future<LiveTranscriptionResult> getLiveTranscriptionResult({
    required String id,
  }) async {
    final response = await _dio.get('v2/live/$id');
    return LiveTranscriptionResult.fromJson(response.data);
  }

  /// Deletes live transcription by ID
  ///
  /// [id] - live transcription ID
  /// Returns true if live transcription deleted successfully
  Future<bool> deleteLiveTranscription({required String id}) async {
    try {
      final originalHeaders = Map<String, dynamic>.from(_dio.options.headers);
      _dio.options.headers = {
        'x-gladia-key': apiKey,
        'Content-Type': 'application/json',
      };

      final response = await _dio.delete('v2/live/$id');

      _dio.options.headers = originalHeaders;

      if (response.data == null) {
        throw GladiaApiException(message: 'Empty response from server');
      }

      return true;
    } on DioException catch (e) {
      throw GladiaApiException.fromDioError(e);
    } catch (e) {
      if (e is GladiaApiException) {
        rethrow;
      }
      throw GladiaApiException(message: e.toString());
    }
  }
}
