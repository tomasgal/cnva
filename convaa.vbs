Option Explicit

Dim objShell, objFSO, strVideoFile, strOutputFile, strCmd, objExec, strAudioCodec

' Create necessary objects
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Ask the user to input the video file path
strVideoFile = InputBox("Enter the full path of the video file:", "Select Video File")
If strVideoFile = "" Then
    WScript.Quit
End If

' Check if the file exists
If Not objFSO.FileExists(strVideoFile) Then
    MsgBox "The file does not exist.", vbExclamation, "Error"
    WScript.Quit
End If

' Determine the audio codec used in the input video file
strCmd = "ffmpeg -i """ & strVideoFile & """ 2>&1"
Set objExec = objShell.Exec(strCmd)
Do While Not objExec.StdOut.AtEndOfStream
    Dim strLine
    strLine = objExec.StdOut.ReadLine()
    If InStr(strLine, "Audio:") > 0 Then
        strAudioCodec = Trim(Split(strLine, ":")(1))
        Exit Do
    End If
Loop

' Map audio codecs to file extensions
Dim dictAudioExtensions
Set dictAudioExtensions = CreateObject("Scripting.Dictionary")
dictAudioExtensions.Add "mp3", "mp3"
dictAudioExtensions.Add "aac", "aac"
dictAudioExtensions.Add "vorbis", "ogg"
dictAudioExtensions.Add "opus", "opus"
' Add more mappings as needed

Dim strExtension
strExtension = "mp3" ' Default extension
Dim key
For Each key In dictAudioExtensions.Keys
    If InStr(LCase(strAudioCodec), key) > 0 Then
        strExtension = dictAudioExtensions(key)
        Exit For
    End If
Next

' Construct the output file path
strOutputFile = objFSO.BuildPath(objFSO.GetParentFolderName(strVideoFile), _
                                objFSO.GetBaseName(strVideoFile) & "." & strExtension)

' Run ffmpeg command to extract audio
strCmd = "ffmpeg -i """ & strVideoFile & """ -q:a 0 -map a """ & strOutputFile & """ -y"
objShell.Run strCmd, 0, True

' Notify the user
objShell.Popup "Audio extracted and saved as " & strOutputFile, 0, "Success", 64

' Clean up
Set objShell = Nothing
Set objFSO = Nothing
Set objExec = Nothing
Set dictAudioExtensions = Nothing
