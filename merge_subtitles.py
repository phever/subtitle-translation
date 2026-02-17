import sys
import subprocess
import os

def merge(original_video, stripped_video, srt_file):
    """
    Merges the English subtitle file with the subtitle-stripped video.
    The final output will be named with a '.final.mkv' suffix.
    """
    output_final = stripped_video.replace('.mkv', '.final.mkv')
    if output_final == stripped_video:
        output_final += ".final.mkv"
        
    print(f"Merging {srt_file} into {stripped_video}...")
    
    # We map all streams from the stripped video (0) and the srt file (1)
    # Since the stripped video has no subtitles, the srt will become the first subtitle stream (index 0)
    cmd = [
        'ffmpeg', '-i', stripped_video, '-i', srt_file,
        '-map', '0', '-map', '1',
        '-c', 'copy',
        '-metadata:s:s:0', 'language=eng',
        '-metadata:s:s:0', 'title=English',
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
    # Parameters: <original_input> <stripped_output> <subtitle_file>
    if len(sys.argv) < 4:
        print("Usage: python merge_subtitles.py <original_video> <stripped_video> <srt_file>")
        sys.exit(1)
    
    original_video = sys.argv[1]
    stripped_video = sys.argv[2]
    srt_file = sys.argv[3]
    
    if not os.path.exists(stripped_video):
        print(f"Error: Stripped video file '{stripped_video}' not found.")
        sys.exit(1)
        
    if not os.path.exists(srt_file):
        print(f"Error: Subtitle file '{srt_file}' not found.")
        sys.exit(1)

    merge(original_video, stripped_video, srt_file)
