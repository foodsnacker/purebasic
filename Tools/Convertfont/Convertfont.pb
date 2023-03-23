; ----------------------------------
; - FontConvert.pb
; ----------------------------------
; - by Jörg Burbach
; ----------------------------------
; - Converts installed fonts to PNG.
; - Results depends on on used font.
; - Exports up to 512x512.
; ----------------------------------
; - Use as you wish.
; ----------------------------------

EnableExplicit

Global mydefChars.s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890äöüÄÖÜß,.-;:<>=!" + Chr(34) + "§$%&/()=?+*#'"

Global myfontImage 
Global myfontID
Global myFontColor = RGB(255,255,255)
Global myBackColor = RGB(0,0,0)
Global myFakeImage
Global myFakeImageBack
Global myOffsetX = 0
Global myOffsetY = 0

Procedure SetFakeImage(myImage,color)
  If IsImage(myImage)
    FreeImage(myImage)
  EndIf
  
  myImage = CreateImage(#PB_Any,200,120,32,color)
  ProcedureReturn myImage
EndProcedure

; Init Tool
Procedure Init()
  myFakeImage = SetFakeImage(myFakeImage,RGB(255,255,255))
  myFakeImageBack = SetFakeImage(myFakeImageBack,RGB(0,0,0))
  
  UsePNGImageEncoder()
  OpenWindow(0,100,100,768,512,"FontConvert")
  ButtonGadget(0,658,10,100,24,"Set Font")
  StringGadget(1,522,40,236,24,"Arial",#PB_String_ReadOnly)
  TextGadget(#PB_Any,522,90,90,24,"Fontsize")
  SpinGadget(2,638,88,126,26,10,100,#PB_Spin_Numeric) : SetGadgetState(2,30)
  TextGadget(#PB_Any,522,120,90,24,"Image-Width (square)")
  SpinGadget(3,638,118,58,24,128,512,#PB_Spin_Numeric) : SetGadgetState(3,512)
  SpinGadget(4,706,118,58,24,128,512,#PB_Spin_Numeric) : SetGadgetState(4,512)
  
  TextGadget(#PB_Any,522,150,120,24,"Chars per Column")
  SpinGadget(5,638,148,126,24,8,24,#PB_Spin_Numeric) : SetGadgetState(5,16)
  
  TextGadget(#PB_Any,522,180,90,24,"Color of Chars")
  ButtonImageGadget(6,638,178,124,24,ImageID(myFakeImage))
  
  TextGadget(#PB_Any,522,210,90,24,"Background")
  ButtonImageGadget(11,638,208,124,24,ImageID(myFakeImageBack))
  
  TextGadget(#PB_Any,522,248,90,24,"Offset (x / y)")
  SpinGadget(12,638,240,58,24,-16,16,#PB_Spin_Numeric) : SetGadgetState(12,0)
  SpinGadget(13,706,240,58,24,-16,16,#PB_Spin_Numeric) : SetGadgetState(13,0)
  
  TextGadget(#PB_Any,560,308,90,24,"OR")
  CheckBoxGadget(14,522,280,226,20,"Save Grid") : SetGadgetState(14,1)
  CheckBoxGadget(15,522,336,226,20,"Transparent Background")
  SetGadgetState(15,0)
  DisableGadget(15,1)
  
  ButtonGadget(7,638,386,100,24,"Standard")
  EditorGadget(8,522,414,236,60,#PB_Editor_WordWrap)
  SetGadgetText(8,mydefChars)
  ButtonGadget(9,658,478,100,24,"Export")
  ImageGadget(10,0,0,512,512,0)
EndProcedure

; load font
Procedure LoadAFont(filename.s, Height)
  If IsFont(myfontID) 
    FreeFont(myfontID)
  EndIf
  
  myfontID = LoadFont(#PB_Any,filename,Height,#PB_Font_HighQuality)
EndProcedure

; create the output-image
Procedure CreateMyImage()
  If IsImage(myfontImage) 
    FreeImage(myfontImage)
  EndIf
  If GetGadgetState(15) = 0
    myfontImage = CreateImage(#PB_Any,GetGadgetState(3),GetGadgetState(4),32,myBackColor)
  Else
    myfontImage = CreateImage(#PB_Any,GetGadgetState(3),GetGadgetState(4),32,#PB_Image_Transparent)
  EndIf     
EndProcedure

; Draw on Image
Procedure DrawChars(myChars.s)
  StartDrawing(ImageOutput(myFontImage))
  
  ; set my font
  DrawingFont(FontID(myfontID))
  DrawingMode(#PB_2DDrawing_Transparent)
  
  Define max = GetGadgetState(5)
  Define col = GetGadgetState(3) / GetGadgetState(5)
  
  ; Draw all Chars
  Define aktuellesZeichen = 1, x, y
  For y = 0 To max - 1
    For x = 0 To  max - 1
      If aktuellesZeichen <= Len(myChars)
        DrawText(myOffsetX + x * col + 1, myOffsetY + y * col + 1, Mid(myChars,aktuellesZeichen,1),myFontColor,#PB_Image_Transparent)
      EndIf
      aktuellesZeichen + 1
    Next x
  Next y
  
  If GetGadgetState(14) = 1
    ; Draw grid
    For y = 0 To 127
      Line(y * col, 0, 1, GetGadgetState(4), RGB(127,127,127))  
      Line(0, y * col, GetGadgetState(3), 1, RGB(127,127,127))  
    Next y
  EndIf
  
  ; Stop drawing
  StopDrawing()
  
  ;apply image
  If GetGadgetState(14) = 1
    SetGadgetState(10,ImageID(myfontImage))
  EndIf
EndProcedure

; Save image
Procedure SaveFontImage(filename.s)
  SaveImage(myfontImage,filename,#PB_ImagePlugin_PNG)  
EndProcedure

; do the magic
Procedure ConvertTTF2Image()
  LoadAFont(GetGadgetText(1),GetGadgetState(2)) 
  CreateMyImage()
  DrawChars(GetGadgetText(8))
EndProcedure

Init()
ConvertTTF2Image()

Define Quit = 0, Event, Gadget, Result, Temp.s

Repeat
  Event = WaitWindowEvent()
  Gadget = EventGadget()
  
  Select Event
    Case #PB_Event_Gadget
      Select Gadget
        Case 0: ; load Font
          Result = FontRequester(GetGadgetText(1),GetGadgetState(2),0,myFontColor)
          If result
            temp = SelectedFontName()
            If temp <> ""
              SetGadgetText(1,temp)
              SetGadgetState(2,SelectedFontSize())
              ConvertTTF2Image()
            EndIf
          EndIf
        Case 2: ; font-size
          ConvertTTF2Image()
          
        Case 3: ; image-size
          ConvertTTF2Image()
          
        Case 4:
          ConvertTTF2Image()
          
        Case 5: ; grid-size
          SetGadgetState(2,GetGadgetState(3) / GetGadgetState(5) - 2)
          ConvertTTF2Image()
          
        Case 6: ; Farbe
          Result = ColorRequester(myFontColor)
          If result > -1
            myFontColor = Result
            myFakeImage = SetFakeImage(myFakeImage,myFontColor)
            SetGadgetAttribute(6,#PB_Button_Image,ImageID(myFakeImage))
            ConvertTTF2Image()
          EndIf
          
        Case 7: ; standard-zeichen
          SetGadgetText(8,mydefChars)
          ConvertTTF2Image()
          
        Case 8: ; zeichensatz
          ConvertTTF2Image()
          
        Case 9: ; export png
          temp = SaveFileRequester("Save File","export.png",".",0)
          If temp <> ""
            ConvertTTF2Image() ; 0 = no grid
            SaveFontImage(temp)
          EndIf
          
        Case 11: ; background-color
          Result = ColorRequester(myBackColor)
          If result > -1
            myBackColor = Result
            myFakeImageBack = SetFakeImage(myFakeImageBack,myBackColor)
            SetGadgetAttribute(11,#PB_Button_Image,ImageID(myFakeImageBack))
            ConvertTTF2Image()
          EndIf          
          
        Case 12: ; Offset X
            myOffsetX = GetGadgetState(12)
            ConvertTTF2Image()
          
        Case 13: ; Offset Y
            myOffsetY = GetGadgetState(13)
            ConvertTTF2Image()
            
          Case 14: ; Grid (and not transparent)
            If GetGadgetState(14) = #True
              DisableGadget(15,1)
              SetGadgetState(15,0)
            Else
              DisableGadget(15,0)
            EndIf            
            
          Case 15: ; transparent (and not grid)

      EndSelect
    Case  #PB_Event_CloseWindow
      Quit = 1
  EndSelect
  
Until Quit = 1
; IDE Options = PureBasic 5.60 (MacOS X - x64)
; CursorPosition = 225
; FirstLine = 200
; Folding = --
; EnableXP
; EnableUnicode