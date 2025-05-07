# Example of downloading audio file from Gladia API

This example demonstrates how to use the Gladia library to download audio files from the Gladia API server via a console application.

## Preparation

1. Make sure you have a valid Gladia API key
2. Install dependencies:
```bash
dart pub get
```

## Usage

```bash
# With command line parameter
dart download_audio_example.dart --api-key=<API_KEY> --record-id=RECORD_ID [--output=OUTPUT_PATH]

# With environment variable
export GLADIA_API_KEY=<API_KEY>
dart download_audio_example.dart --record-id=RECORD_ID [--output=OUTPUT_PATH]
```

### Parameters

- `--api-key`, `-k`: (required) Your Gladia API key
- `--record-id`, `-r`: (required) ID of the record to download
- `--output`, `-o`: (optional) Path to save the file
- `--help`, `-h`: Show help

### Example

```bash
dart download_audio_example.dart -k <API_KEY> -r rec_xyz789 -o audio/my_file.mp3
```

## How it works

The console application:

1. Accepts parameters from the user
2. Creates a `GladiaClient` instance with the specified API key
3. Downloads the audio file with the specified ID
4. Saves the file to the specified location or to the current directory if no path is specified
5. Displays information about the download result (path and file size)

## Error handling

In case of errors, the application:
- Displays an understandable error message
- Shows usage help
- Exits with error code 1 