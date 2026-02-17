#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    echo "Example: $0 movie.mkv movie_with_english.mkv"
    exit 1
fi

INPUT_FILE="$1"
STRIPPED_SUBTITLES="$1.srt"
SUBTITLE_FILE="unknown.srt"
SCRIPT_DIR="/home/$USER/subtitle-translation"
MERGE_SCRIPT="merge_subtitles.py"
TRANSLATION_SCRIPT="translate_subs.py"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# 1. Strip existing subtitles using ffmpeg
echo "Step 1: Stripping existing subtitles from $INPUT_FILE..."
# -map 0:v (video) -map 0:a (audio) -c copy (no re-encoding)
if ffmpeg -i "$INPUT_FILE" -map 0:v -map 0:a -c copy "$STRIPPED_SUBTITLES" -y -loglevel error; then
    echo "Success: Subtitles stripped and saved to $STRIPPED_SUBTITLES."
    
    # 2. Check if the python script and subtitle file exist
    if [ ! -f "$SCRIPT_DIR/$MERGE_SCRIPT" ]; then
        echo "Error: Python script '$SCRIPT_DIR/$MERGE_SCRIPT' not found."
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/$TRANSLATION_SCRIPT" ]; then
        echo "Error: Python script '$SCRIPT_DIR/$TRANSLATION_SCRIPT' not found."
        exit 1
    fi

    echo "Step 2: Executing $SCRIPT_DIR/$TRANSLATION_SCRIPT to translate subtitles..."
    
    # Use the virtual environment python if it exists, otherwise system python3
    if [ -f "$SCRIPT_DIR/.venv/bin/python3" ]; then
        PYTHON_EXEC="$SCRIPT_DIR/.venv/bin/python3"
    elif [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
        PYTHON_EXEC="$SCRIPT_DIR/venv/bin/python3"
    else
        PYTHON_EXEC="python3"
    fi

    if $PYTHON_EXEC "$SCRIPT_DIR/$TRANSLATION_SCRIPT" "$STRIPPED_SUBTITLES" "english.srt"; then
        echo "Subtitle translation completed successfully."
    else
        echo "Error: Python translation script failed."
        exit 1
    fi
    
    # if [ ! -f "$SUBTITLE_FILE" ]; then
    #     echo "Error: Subtitle file '$SUBTITLE_FILE' not found. Please run translation first."
    #     exit 1
    # fi

    # 3. Execute the Python script to merge subtitles
    echo "Step 2: Executing $SCRIPT_DIR/$MERGE_SCRIPT to merge $SUBTITLE_FILE..."
    
    if $PYTHON_EXEC "$SCRIPT_DIR/$MERGE_SCRIPT" "$INPUT_FILE" "english.srt"; then
        echo "All processing steps completed successfully."
    else
        echo "Error: Python merge script failed."
        exit 1
    fi
else
    echo "Error: ffmpeg failed to strip subtitles from $INPUT_FILE."
    exit 1
fi
