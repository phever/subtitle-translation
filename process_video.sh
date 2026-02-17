#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <output_file> <language>"
    echo "Example: $0 movie.mkv movie_with_english.mkv swedish"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"
LANGUAGE="$3"

ORIGINAL_SRT="${LANGUAGE}.srt"
ENGLISH_SRT="en.srt"

SCRIPT_DIR="${HOME}/subtitle-translation"
MERGE_SCRIPT="merge_subtitles.py"
TRANSLATION_SCRIPT="translate_subs.py"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# Determine Python executable
if [ -f "$SCRIPT_DIR/.venv/bin/python3" ]; then
    PYTHON_EXEC="$SCRIPT_DIR/.venv/bin/python3"
elif [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    PYTHON_EXEC="$SCRIPT_DIR/venv/bin/python3"
else
    PYTHON_EXEC="python3"
fi

# 1. Strip/Extract the subtitle track from $1 mkv and save as $3.srt
echo "Step 1: Extracting subtitle track from $INPUT_FILE to $ORIGINAL_SRT..."
if ffmpeg -i "$INPUT_FILE" -map 0:s:0 "$ORIGINAL_SRT" -y -loglevel error; then
    echo "Success: Subtitle extracted to $ORIGINAL_SRT."
else
    echo "Error: Failed to extract subtitles. Does the file have subtitle tracks?"
    exit 1
fi

# 3. Run the translate_subs.py to create en.srt
echo "Step 2: Translating $ORIGINAL_SRT to $ENGLISH_SRT..."
if $PYTHON_EXEC "$SCRIPT_DIR/$TRANSLATION_SCRIPT" "$ORIGINAL_SRT" "$ENGLISH_SRT" "$LANGUAGE" "en"; then
    echo "Success: Subtitle translation completed."
else
    echo "Error: Subtitle translation failed."
    exit 1
fi

# 4. Merge the $1 mkv (stripped) with $3.srt and en.srt
echo "Step 3: Merging original and translated subtitles into new mkv..."
if $PYTHON_EXEC "$SCRIPT_DIR/$MERGE_SCRIPT" "$INPUT_FILE" "$ORIGINAL_SRT" "$ENGLISH_SRT" "$LANGUAGE"; then
    # The merge_subtitles.py script creates a file with '.final.mkv' suffix
    FINAL_OUTPUT="${INPUT_FILE}.final.mkv"
    if [ -f "$FINAL_OUTPUT" ]; then
        mv "$FINAL_OUTPUT" "$OUTPUT_FILE"
        echo "Successfully created: $OUTPUT_FILE"
        # Cleanup temporary files
        rm "$ENGLISH_SRT" "$ORIGINAL_SRT"
    else
        echo "Error: Final output file not found."
        exit 1
    fi
else
    echo "Error: Merging failed."
    exit 1
fi

echo "Processing complete."
