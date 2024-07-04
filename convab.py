import os
import subprocess
import sys
from tkinter import Tk, filedialog

def get_audio_codec(video_file):
    # Run ffmpeg to get the audio codec information
    result = subprocess.run(['ffmpeg', '-i', video_file], stderr=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    output = result.stderr
    for line in output.splitlines():
        if 'Audio:' in line:
            codec_info = line.split(',')[0]  # Get the codec information
            codec = codec_info.split()[1]   # Extract codec name
            return codec.strip()
    return 'mp3'  # Default to mp3 if codec not found

def get_extension(codec):
    extensions = {
        'mp3': 'mp3',
        'aac': 'aac',
        'vorbis': 'ogg',
        'opus': 'opus',
    }
    return extensions.get(codec, 'mp3')

def extract_audio(input_video, output_audio=None):
    if not os.path.isfile(input_video):
        print(f"File not found: {input_video}")
        return

    codec = get_audio_codec(input_video)
    extension = get_extension(codec)

    if output_audio is None:
        output_audio = os.path.splitext(input_video)[0] + '.' + extension

    cmd = ['ffmpeg', '-i', input_video, '-q:a', '0', '-map', 'a', output_audio]

    try:
        subprocess.run(cmd, check=True)
        print(f"Audio extracted to {output_audio}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to extract audio: {e}")

def open_file_dialog():
    root = Tk()
    root.withdraw()  # Hide the root window
    video_file = filedialog.askopenfilename(
        title="Select Video File",
        filetypes=[("Video files", "*.mp4;*.mkv;*.avi;*.mov;*.flv;*.wmv")]
    )
    return video_file

if __name__ == '__main__':
    if len(sys.argv) < 2:
        input_video = open_file_dialog()
        if not input_video:
            print("No video file was selected.")
            sys.exit(1)
        output_audio = None
    else:
        input_video = sys.argv[1]
        output_audio = sys.argv[2] if len(sys.argv) > 2 else None

    extract_audio(input_video, output_audio)
