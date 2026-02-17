#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    echo "Example: $0 movie.mkv movie_stripped.mkv"
    exit 1
fi

INPUT_FILE="$1"
STRIPPED_FILE="$2"
SUBTITLE_FILE="english.srt"
PYTHON_SCRIPT="merge_subtitles.py"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# 1. Strip existing subtitles using ffmpeg
echo "Step 1: Stripping existing subtitles from $INPUT_FILE..."
# -map 0:v (video) -map 0:a (audio) -c copy (no re-encoding)
if ffmpeg -i "$INPUT_FILE" -map 0:v -map 0:a -c copy "$STRIPPED_FILE" -y -loglevel error; then
    echo "Success: Subtitles stripped and saved to $STRIPPED_FILE."
    
    # 2. Check if the python script and subtitle file exist
    if [ ! -f "$PYTHON_SCRIPT" ]; then
        echo "Error: Python script '$PYTHON_SCRIPT' not found."
        exit 1
    fi
    
    if [ ! -f "$SUBTITLE_FILE" ]; then
        echo "Error: Subtitle file '$SUBTITLE_FILE' not found. Please run translation first."
        exit 1
    fi

    # 3. Execute the Python script to merge subtitles
    echo "Step 2: Executing $PYTHON_SCRIPT to merge $SUBTITLE_FILE..."
    
    # Use the virtual environment python if it exists, otherwise system python3
    if [ -f ".venv/bin/python3" ]; then
        PYTHON_EXEC=".venv/bin/python3"
    elif [ -f "venv/bin/python3" ]; then
        PYTHON_EXEC="venv/bin/python3"
    else
        PYTHON_EXEC="python3"
    fi

    if $PYTHON_EXEC "$PYTHON_SCRIPT" "$INPUT_FILE" "$STRIPPED_FILE" "$SUBTITLE_FILE"; then
        echo "All processing steps completed successfully."
    else
        echo "Error: Python merge script failed."
        exit 1
    fi
else
    echo "Error: ffmpeg failed to strip subtitles from $INPUT_FILE."
    exit 1
fi
