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

; Infos des Plugins
Global Plugin_Title.s = "Hello, World!"
Global Plugin_Description.s = "Test-Plugin. Will randomize a given string."
Global Plugin_Version.s = "0.0.1"
Global Plugin_Copyright.s = "(c) 2021 Jörg Burbach"
Global Plugin_Build.s = "0012"
Global Plugin_Web.s = "https://www.joerg-burbach.de"
Global Plugin_Mail.s = "post@joerg-burbach.de"
Global Plugin_Type = #Plugin_Type_TXT

; !! welche Parameter und welche Grenzen

; Info holen
ProcedureDLL.s Plugin__Get_Info ( InfoType.i )
  Plugin_Info.s = "-"
  Select InfoType
    Case #Plugin_Info_Title        : Plugin_Info = Plugin_Title
    Case #Plugin_Info_Description  : Plugin_Info = Plugin_Description
    Case #Plugin_Info_Copyright    : Plugin_Info = Plugin_Copyright
    Case #Plugin_Info_Version      : Plugin_Info = Plugin_Version
    Case #Plugin_Info_Build        : Plugin_Info = Plugin_Build
    Case #Plugin_Info_Web          : Plugin_Info = Plugin_Web
    Case #Plugin_Info_Mail         : Plugin_Info = Plugin_Mail
  EndSelect
  ProcedureReturn Plugin_Info
EndProcedure

ProcedureDLL.s Plugin__Last_Error()
  ProcedureReturn "0"
EndProcedure

ProcedureDLL.s Plugin__Process_Text ( InString.s )
  OutString.s = ReverseString(InString)
  ProcedureReturn OutString
EndProcedure

; Image Test

Global intensity = 0
Global bw = 1

Procedure Lim_Max (now, up, max)
  max-1
  While (now > max - up)
    up-1
  Wend
  ProcedureReturn up
EndProcedure

Procedure LimitValues (x)
  If x < 0 
    x = 0
  EndIf
  If x > 255
    x = 255
  EndIf
  ProcedureReturn x
EndProcedure

Structure Data_struct
  intensity.i
  bw.i
EndStructure

Global PencilData.Data_struct

ProcedureDLL.i Plugin__Image_Settings ( *parameter3.Data_struct )
  PencilData\intensity = *parameter3\intensity
  PencilData\bw = *parameter3\bw
EndProcedure

ProcedureDLL.i Plugin__Process_Image ( SourceImageMem.i, SourceImageMemSize.i, width.i, height.i )
  trim = 4
  intensity = PencilData\intensity
  bw = PencilData\bw
  
  If Intensity < 0: Intensity = 0: ElseIf Intensity > 5 : Intensity = 5:EndIf
  If BW < 1 : BW = 1: ElseIf BW > 5:BW = 5: EndIf
  
  For  h = 0 To Height-1
    For w = 0 To Width-1
      For k = 0 To 2
        i = h * Pitch + Trim * w
        j = h * Pitch + Trim * (w + Lim_Max (w, BW, Width))
        color_1 = Int((PeekB(SourceImageMem+i+k) - PeekB(SourceImageMem+j+k)) * (PeekB(SourceImageMem+i+k) - PeekB(SourceImageMem+j+k)))
        j = (h + Lim_Max (h, BW, Height)) * Pitch + Trim * w
        color_2 = Int((PeekB(SourceImageMem+i+k) - PeekB(SourceImageMem+j+k)) * (PeekB(SourceImageMem+i+k) - PeekB(SourceImageMem+j+k)))
        PokeB(SourceImageMem+i+k, 255 - LimitValues (Int(Sqr ((color_1 + color_2))) << Intensity))
      Next
    Next
  Next
  
  ProcedureReturn 0
EndProcedure

; IDE Options = PureBasic 5.73 LTS (MacOS X - x64)
; ExecutableFormat = Shared .dylib
; CursorPosition = 87
; FirstLine = 41
; Folding = g-
; EnableXP
; Executable = lib.dylib