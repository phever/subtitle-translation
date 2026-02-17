# Subtitle Translation Tool

A collection of scripts to automate the extraction, translation, and merging of subtitles for MKV video files. This tool extracts the original subtitle track, translates it (default to English) using Google Translate, and creates a new video file with both the original and translated subtitle tracks.

## Features

- **Automated Extraction:** Extracts the first subtitle track from an MKV file using `ffmpeg`.
- **Translation:** Translates subtitles using the `deep-translator` library.
- **Merging:** Creates a new MKV file containing the original video/audio and multiple subtitle tracks (original + translated).
- **Cleanup:** Offers to remove temporary subtitle files after processing.

## Prerequisites

- **Python 3.6+**
- **ffmpeg:** Must be installed and available in your PATH.
- **bash:** For running the main orchestration script.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd subtitle-translation
    ```

2.  **Run the setup script:**
    This will create a virtual environment and install the necessary Python dependencies.
    ```bash
    ./setup.sh
    ```

## Usage

The main entry point is `process_video.sh`.

```bash
./process_video.sh <input_file> <output_file> <language_name_or_code>
```

### Parameters:
- `<input_file>`: The path to the source MKV file.
- `<output_file>`: The desired path for the final processed MKV.
- `<language_name_or_code>`: The language of the original subtitles (e.g., `swedish`, `sv`, `german`, `de`).

### Example:
```bash
./process_video.sh movie.mkv movie_translated.mkv swedish
```

### Setting a variable for batch processing:
If you have multiple episodes, you can use bash variables:
```bash
EP="04"; ./process_video.sh "Show.S01E${EP}.mkv" "Show.S01E${EP}.translated.mkv" swedish
```

## Project Structure

- `process_video.sh`: The main shell script that orchestrates the workflow.
- `translate_subs.py`: Python script to handle subtitle translation using `deep-translator`.
- `merge_subtitles.py`: Python script that uses `ffmpeg` to merge subtitles back into the MKV.
- `setup.sh`: Installation script to set up the Python environment.
- `requirements.txt`: Python dependency list.

## License

This project is released under the [Unlicense](UNLICENSE), which dedicates the work to the public domain.
