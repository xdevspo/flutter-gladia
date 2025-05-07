# Gladia API v2 Console Example

This example demonstrates using the Gladia API v2 for audio file transcription without Flutter UI.

## Preparation

1. **Get a Gladia API key**
   
   Register on the [Gladia website](https://app.gladia.io/) and get an API key.

2. **Prepare an audio file for testing**
   
   Place an audio file in the project folder or specify a full path to it when launching.

3. **Run the example**
   
   You can use the API key from the `GLADIA_API_KEY` environment variable or pass it as a command line argument.

## Running Examples

To run examples, you need to specify the Gladia API key. You can use the API key from the `GLADIA_API_KEY` environment variable or pass it as a command line argument.

### Console example with detailed output

```bash
# With command line parameter
dart run console_sync_example.dart --api-key=<API_KEY> --audio-file=path/to/audio.mp3

# With environment variable
export GLADIA_API_KEY=<API_KEY>
dart run console_sync_example.dart --audio-file=path/to/audio.mp3
```

### Installing dependencies

Navigate to the example folder and install dependencies:

```bash
cd example
dart pub get
```

### Running the example

Basic launch:
```bash
dart run console_sync_example.dart
```

### Additional options

```
--verbose=true            # Enables detailed logging
--diarization=true        # Enables diarization (speaker identification)
--sentiment=true          # Enables sentiment analysis
```

## Expected result

Upon successful execution, the console will display the transcription progress and the final text:

```
🚀 Starting Gladia API test...
  API key: abcd...1234
  Audio file: audio_file.mp3
  Logging: disabled
📤 Uploading audio file to Gladia server...
✅ File successfully uploaded. URL: https://api.gladia.io/file/...
🕒 Duration: 25.5 sec.
🔄 Sending transcription request...
✅ Request accepted. ID: 123e4567-...
⏳ Waiting for transcription results...
⏳ Waiting... (attempt 1)
⏳ Waiting... (attempt 2)
...
✅ Transcription successfully received!

===========================================================
📋 TRANSCRIPTION RESULTS
===========================================================

📝 Full text:
[Transcription text...]

📊 Metadata:
  🌐 Language: en
  ⏱️ Duration: 25.5 sec.

📁 File information:
  📄 Filename: audio_file.mp3
  ⏱️ Duration: 25.5 sec.
  🔊 Number of channels: 1

📊 Request information:
  🆔 Request ID: 123e4567-...
  📊 Status: done
  🔖 Request ID: G-123e4567
  🔢 API Version: 2
  🕒 Created: 2023-05-01T12:34:56.789Z
  ✅ Completed: 2023-05-01T12:35:06.789Z

📈 Detailed metadata:
  ⏱️ Audio duration: 25.5 sec.
  🔊 Channels: 1
  💰 Billing time: 25.5 sec.
  ⏲️ Transcription time: 10.0 sec.

🔊 Segments with timestamps and speakers:
1. [0.00 - 2.50] 👤 Speaker 1 🔊 Channel 0
   [Segment text...]
...

🎉 Testing completed!
```

### Error handling

If there are errors in the request, you will see detailed information about each error:

```
🔄 Sending transcription request...
❌ Error executing request: Invalid parameter(s). See validation_errors for more details.
📊 Status code: 400
🚫 Validation error details:
  - audio_url: Value is required
  - diarization_config.min_speakers: Number must be greater than or equal to 1
```

In case of validation errors or other issues, the library provides detailed debug information including status codes, error messages, and suggestions for fixing issues. 