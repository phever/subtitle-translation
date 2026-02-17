import sys
import subprocess
import os

def merge(original_video, stripped_video, original_srt, english_srt, original_lang):
    """
    Merges the original and English subtitle files with the subtitle-stripped video.
    The final output will be named with a '.final.mkv' suffix.
    """
    output_final = stripped_video.replace('.stripped.mkv', '.final.mkv')
    if output_final == stripped_video:
        output_final = stripped_video.replace('.mkv', '.final.mkv')
    if output_final == stripped_video:
        output_final += ".final.mkv"
        
    print(f"Merging {original_srt} and {english_srt} into {stripped_video}...")
    
    # We map all streams from the stripped video (0), original srt (1), and english srt (2)
    cmd = [
        'ffmpeg', '-i', stripped_video, '-i', original_srt, '-i', english_srt,
        '-map', '0', '-map', '1', '-map', '2',
        '-c', 'copy',
        '-metadata:s:s:0', f'language={original_lang}',
        '-metadata:s:s:0', f'title={original_lang.capitalize()}',
        '-metadata:s:s:1', 'language=eng',
        '-metadata:s:s:1', 'title=English',
        output_final, '-y'
    ]
    
    try:
        # Run ffmpeg command
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"Successfully created final video: {output_final}")
    except subprocess.CalledProcessError as e:
        print(f"Error during merging:
{e.stderr}")
        sys.exit(1)

if __name__ == "__main__":
    # Parameters: <original_input> <stripped_output> <original_srt> <english_srt> <original_lang>
    if len(sys.argv) < 6:
        print("Usage: python merge_subtitles.py <original_video> <stripped_video> <original_srt> <english_srt> <original_lang>")
        sys.exit(1)
    
    original_video = sys.argv[1]
    stripped_video = sys.argv[2]
    original_srt = sys.argv[3]
    english_srt = sys.argv[4]
    original_lang = sys.argv[5]
    
    if not os.path.exists(stripped_video):
        print(f"Error: Stripped video file '{stripped_video}' not found.")
        sys.exit(1)
        
    if not os.path.exists(original_srt):
        print(f"Error: Original subtitle file '{original_srt}' not found.")
        sys.exit(1)
        
    if not os.path.exists(english_srt):
        print(f"Error: English subtitle file '{english_srt}' not found.")
        sys.exit(1)

    merge(original_video, stripped_video, original_srt, english_srt, original_lang)
