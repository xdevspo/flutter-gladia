# Gladia API SDK Usage Examples

This directory contains examples of using the Gladia API SDK for various scenarios. Each example comes with detailed explanations and instructions.

## Available Examples

- [Basic Example](basic_example.md) - simple audio file transcription
- [Live Transcription](live_transcription_example.md) - real-time audio transcription
- [Advanced Examples](advanced_examples.md) - advanced features and settings

## Running the Examples

To run the examples, follow these steps:

1. Get a Gladia API key from the [official website](https://app.gladia.io/)
2. Create a `.env` file in the example directory with the following content:
   ```
   GLADIA_API_KEY=your_api_key_here
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the desired example:
   ```bash
   dart run example/main.dart
   ```

## Examples Structure

Example | File | Description
-------|------|--------
Basic Example | `main.dart` | Simple audio file transcription example
Console Example | `console_sync_example.dart` | Console application with advanced options
URL Transcription | `download_audio_example.dart` | Example of transcribing audio from a URL
Live Transcription | `live_audio_transcription_example.dart` | Real-time transcription example
Transcription Result | `live_transcription_result_example.dart` | Working with transcription results

## Additional Information

* [API Documentation](../doc/api_reference.md)
* [Error Handling](../doc/error_handling.md)
* [API Limitations](../doc/api_limitations.md) 