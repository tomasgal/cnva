@echo off
REM Check if input video file is provided
if "%~1"=="" (
    echo Usage: extract.bat input_video_file [output_audio_file]
    exit /b 1
)

REM Set input video file
set input_video=%~1

REM Determine the audio codec of the input video file
for /f "tokens=2 delims=:" %%a in ('ffmpeg -i "%input_video%" 2^>^&1 ^| findstr /i /c:"Audio"') do (
    set audio_codec=%%a
)

REM Trim spaces from the audio codec
set audio_codec=%audio_codec: =%

REM Set default audio extension based on codec
set audio_ext=mp3
if "%audio_codec%"=="aac" set audio_ext=aac
if "%audio_codec%"=="vorbis" set audio_ext=ogg
if "%audio_codec%"=="opus" set audio_ext=opus

REM Set output audio file name
set output_audio=%~2
if "%output_audio%"=="" (
    set output_audio=%~n1.%audio_ext%
)

REM Extract audio using ffmpeg
ffmpeg -i "%input_video%" -q:a 0 -map a "%output_audio%"

echo Audio extracted to %output_audio%
