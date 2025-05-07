# Gladia API Live Transcription Result Example

This example demonstrates how to retrieve results from a previously created live transcription session using the Gladia API.

## Preparation

1. **Get a Gladia API key**
   
   Register on the [Gladia website](https://app.gladia.io/) and get an API key.

2. **Get a Live Transcription Session ID**
   
   You need the ID of a live transcription session. You can get this ID after running a live transcription.

## Running the Example

To run the example, you need to specify the Gladia API key and the session ID. You can use the API key from the `GLADIA_API_KEY` environment variable or pass it as a command line argument.

```bash
# With command line parameter
dart run example/live_transcription_result_example.dart --api-key=<API_KEY> --id=<ID>

# With environment variable
export GLADIA_API_KEY=<API_KEY>
dart run example/live_transcription_result_example.dart --id=<ID>
```

### Additional options

```
--verbose=true            # Enables detailed logging
```

## Using VS Code Launch Configuration

To run the example in VS Code with debugging:

1. Open the project in VS Code
2. Press F5 or select the Run & Debug view
3. Select "Get live result" from the dropdown menu
4. Click the Run button

This will run the example with predefined parameters. You can modify these parameters in the `.vscode/launch.json` file.

## Expected Result

Upon successful execution, the console will display detailed information about the live transcription result:

```
🚀 Starting Gladia API live transcription result retrieval...
  API key: abcd...1234
  ID: 123e4567-...
  Logging: disabled
📥 Retrieving live transcription result...
✅ Live transcription result received!

===========================================================
📋 LIVE TRANSCRIPTION RESULTS
===========================================================

📝 Full text:
[Transcription text...]

📊 Metadata:
  🌐 Language: en

📁 File information:
  📄 Filename: audio_stream.wav
  🔄 Source: upload
  ⏱️ Duration: 45.7 sec.
  🔊 Number of channels: 1

⚙️ Request parameters:
  🌐 Languages: en, fr
  🔊 Channels: 1
  🎵 Sample rate: 16000
  🎚️ Bit depth: 16
  🔡 Encoding: wav/pcm

📊 Request information:
  🆔 Request ID: 123e4567-...
  📊 Status: done
  🔢 API Version: 2
  🕒 Created: 2023-05-01T12:34:56.789Z
  ✅ Completed: 2023-05-01T12:35:06.789Z

🗣️ Utterances:
  ⏱️ 0.0 - 5.5: Hello, this is a test.
     👤 Speaker: A
  ⏱️ 6.2 - 10.8: Yes, I can hear you.
     👤 Speaker: B

🎉 Testing completed!
```

### Error Handling

If there are errors in the request, you will see detailed information about each error:

```
📥 Retrieving live transcription result...
❌ Error executing request: Session not found
📊 Status code: 404
```

In case of validation errors or other issues, the library provides detailed debug information including status codes, error messages, and suggestions for fixing issues. 