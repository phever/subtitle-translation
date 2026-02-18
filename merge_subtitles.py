import sys
import subprocess
import os


def merge(video_file, english_srt):
    """
    Merges the original and English subtitle files with the video.
    The final output will be named with a '.final.mkv' suffix.
    """
    output_final = video_file + ".final.mkv"

    print(f"Merging {english_srt} into {video_file}...")

    # We map all streams from the video (0), exclude its subtitles (-0:s),
    # then add original srt (1), and english srt (2)
    cmd = [
        "ffmpeg",
        "-i",
        video_file,
        "-i",
        english_srt,
        "-map",
        "0",
        "-map",
        "-0:s",
        "-map",
        "1",
        "-map",
        "2",
        "-c",
        "copy",
        "-metadata:s:s:1",
        "language=eng",
        "-metadata:s:s:1",
        "title=English",
        output_final,
        "-y",
    ]

    try:
        # Run ffmpeg command
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"Successfully created final video: {output_final}")
    except subprocess.CalledProcessError as e:
        print(f"Error during merging:\n{e.stderr}")
        sys.exit(1)


if __name__ == "__main__":
    # Parameters: <video_file> <original_srt> <english_srt> <original_lang>
    if len(sys.argv) < 3:
        print("Usage: python merge_subtitles.py <video_file> <english_srt>")
        sys.exit(1)

    video_file = sys.argv[1]
    english_srt = sys.argv[2]

    if not os.path.exists(video_file):
        print(f"Error: Video file '{video_file}' not found.")
        sys.exit(1)

    if not os.path.exists(english_srt):
        print(f"Error: English subtitle file '{english_srt}' not found.")
        sys.exit(1)

    merge(video_file, english_srt)
