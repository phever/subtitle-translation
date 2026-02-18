#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <input_file> <language_name_or_code> [output_file]"
    echo "Example: $0 movie.mkv swedish"
    echo "Example: $0 movie.mkv swedish movie_with_subtitles.mkv"
    exit 1
fi

INPUT_FILE="$1"
LANG_INPUT="$2"
OUTPUT_FILE="$3"

SCRIPT_DIR="${HOME}/subtitle-translation"
MERGE_SCRIPT="merge_subtitles.py"
TRANSLATION_SCRIPT="translate_subs.py"

# Determine Python executable
if [ -f "$SCRIPT_DIR/.venv/bin/python3" ]; then
    PYTHON_EXEC="$SCRIPT_DIR/.venv/bin/python3"
elif [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    PYTHON_EXEC="$SCRIPT_DIR/venv/bin/python3"
else
    PYTHON_EXEC="python3"
fi

# Resolve language code (e.g., swedish -> sv)
LANGUAGE=$($PYTHON_EXEC -c "from deep_translator.constants import GOOGLE_LANGUAGES_TO_CODES; print(GOOGLE_LANGUAGES_TO_CODES.get('$LANG_INPUT'.lower(), '$LANG_INPUT'))" 2>/dev/null || echo "$LANG_INPUT")

ORIGINAL_SRT="${LANGUAGE}.srt"
ENGLISH_SRT="en.srt"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
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
    # Keep the English subtitle for reference
    mv "$ENGLISH_SRT" "${OUTPUT_FILE%.mkv}.en.srt"
else
    echo "Error: Subtitle translation failed."
    exit 1
fi

# 4. Merge the $1 mkv with $3.srt and en.srt
if [[ -n "$OUTPUT_FILE" ]]; then
  echo "Step 3: Merging original and translated subtitles into new mkv..."
  if $PYTHON_EXEC "$SCRIPT_DIR/$MERGE_SCRIPT" "$INPUT_FILE" "$ENGLISH_SRT"; then
      # The merge_subtitles.py script creates a file with '.final.mkv' suffix
      FINAL_OUTPUT="${INPUT_FILE}.final.mkv"
      if [ -f "$FINAL_OUTPUT" ]; then
          mv "$FINAL_OUTPUT" "$OUTPUT_FILE"
          echo "Successfully created: $OUTPUT_FILE"
      else
          echo "Error: Final output file not found."
          exit 1
      fi
  else
      echo "Error: Merging failed."
      exit 1
  fi
fi

echo "Processing complete."
