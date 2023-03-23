Enumeration 
  #Plugin_Info_Title
  #Plugin_Info_Description
  #Plugin_Info_Copyright
  #Plugin_Info_Version
  #Plugin_Info_Build
  #Plugin_Info_Web
  #Plugin_Info_Mail
EndEnumeration

Enumeration 1024
  #Plugin_Type_GFX ; Edit a raw image
  #Plugin_Type_SFX ; Edit a soundbuffer
  #Plugin_Type_TXT ; Edit a raw text in UTF-8
EndEnumeration

; Global vorwaerts.s = "Hello, World!"

Structure PencilData_Struct
  intensity.i
  bw.i
EndStructure

Global PencilData.PencilData_Struct

Prototype.i Lib_Info ( InfoType.i )
Prototype.i Lib_Process_Text ( InString.s )
Prototype.i Lib_Process_Image ( SourceImageMem.i, SourceImageMemSize.i, width.i, height.i )
Prototype.i Lib_Image_Settings ( *parameter3.PencilData_Struct )

If OpenLibrary(0,"lib.dylib")
  Global Lib_Info.Lib_Info = GetFunction(0, "Plugin__Get_Info")
  Global Lib_Process_Text.Lib_Process_Text = GetFunction(0, "Plugin__Process_Text")
  Global Lib_Process_Image.Lib_Process_Image = GetFunction(0, "Plugin__Process_Image")
  Global Lib_Image_Settings.Lib_Image_Settings = GetFunction(0, "Plugin__Image_Settings")
  
;   Debug PeekS(Lib_Info(#Plugin_Info_Description))
;   Debug PeekS(Lib_Process_Text(vorwaerts))
  
  ; Prepare Image - always 32 bits
  ;SourceImage = CreateImage(#PB_Any,100,100,32,RGB(255,255,255))
  UsePNGImageDecoder()
  UseJPEG2000ImageDecoder()
  UseJPEGImageDecoder()
  temp$ = OpenFileRequester("Bild","test.png","*.*",0)
  SourceImage = LoadImage(#PB_Any, temp$)
  
  PencilData\intensity = 4
  PencilData\bw = 4
  
  If StartDrawing(ImageOutput(SourceImage))
    *imageMem = DrawingBuffer()
    Pitch     = DrawingBufferPitch()
    width     = ImageWidth(SourceImage)
    height    = ImageHeight(SourceImage)
    imageMemSize = width * height * ImageDepth(SourceImage) / 8 ; ImageDepth is in Bits not Bytes
    Lib_Image_Settings ( PencilData )
    Lib_Process_Image ( *imageMem, imageMemSize, width, height )
    StopDrawing()
  EndIf
  
  SaveImage(SourceImage,"test.bmp")
  
  CloseLibrary(0)
EndIf
; IDE Options = PureBasic 5.73 LTS (MacOS X - x64)
; CursorPosition = 27
; FirstLine = 24
; EnableXP
; Executable = testlib.app