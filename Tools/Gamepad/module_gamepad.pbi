;{ ===========================================================================================================[Header ]
;: 
;: Name ......... : GamePad
;: Version ...... : 1.0.0
;: Type ......... : Module
;: Author ....... : jamirokwai
;: Compiler ..... : PureBasic V6.01
;: Subsystem .... : none
;: TargetOS ..... : Windows ? / MacOS / Linux ?
;: Description .. : UI for GamePads
;: License ...... : MIT License 
;:
;: Permission is hereby granted, free of charge, to any person obtaining a copy
;: of this software and associated documentation files (the "Software"), to deal
;: in the Software without restriction, including without limitation the rights
;: to use, copy, modify, merge, publish, distribute, sublicense, And/Or sell
;: copies of the Software, and to permit persons to whom the Software is
;: furnished to do so, subject to the following conditions:
;:  
;: The above copyright notice and this permission notice shall be included in all
;: copies or substantial portions of the Software.
;: 
;: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;: SOFTWARE. 
;:
;}

DeclareModule GamePad
  
  EnableExplicit
  
  Enumeration
    #gamepad_0
    #gamepad_1
    #gamepad_2
    #gamepad_3
  EndEnumeration
  
  Enumeration
    #gamepad_padding
    #gamepad_button_b
    #gamepad_button_a
    #gamepad_button_3
    #gamepad_button_4
    #gamepad_button_5
    #gamepad_button_6
    #gamepad_button_7
    #gamepad_button_8
    #gamepad_button_select
    #gamepad_button_start
    #gamepad_button_up
    #gamepad_button_down
    #gamepad_button_left
    #gamepad_button_right
  EndEnumeration
  
  Structure GamePad_Struct
    name.s
    
    button_start.i
    button_select.i
    button_a.i
    button_b.i
    
    left.i
    right.i
    up.i
    down.i
    
    button_a_pressed.i
    button_b_pressed.i
    button_select_pressed.i
    button_start_pressed.i
  EndStructure
  
  Global Dim GamePad.GamePad_Struct(0)
  Global GamePad_Count
  
  ; detect joysticks and set count in GamePad_Count
  Declare DetectJoys()
  
  ; create a gamepad-settings window
  Declare OpenGamepadSettings()
  
  ; run loop for gamepad and fire an event (see above), defaults to first gamepad
  Declare ExamineGamepads(gamepadnum = #gamepad_0)
  
  ; loop for the gamepad-settings window, will return #true, if the window should be closed
  ; returns seettings of gamepad in GamePad_Struct (see above)
  Declare CheckGamepadGadgets(event, menu, gadget)
  
  ; close the window and remove all images and stuf
  Declare CloseGamepadSettings()
  
  ;   ; set a callback for one of the buttons or directions
  ;   Declare SetCallback(proc)
  
EndDeclareModule


Module GamePad
  
  Enumeration #PB_Event_FirstCustomValue
    #gamepad_event_0
    #gamepad_event_1
    #gamepad_event_2
    #gamepad_event_3
  EndEnumeration
  
  Enumeration
    #gamepad
    #gamepad_a
    #gamepad_b
    #gamepad_start
    #gamepad_select
    #gamepad_left
    #gamepad_right
    #gamepad_up
    #gamepad_down
    
    #gamepad_start_test
    #gamepad_select_test
    #gamepad_left_test
    #gamepad_right_test
    #gamepad_up_test
    #gamepad_down_test
    #gamepad_a_test
    #gamepad_b_test
    
    #gamepad_check
    #gamepad_cancel
    #gamepad_ok
    #gamepad_stop
    #gamepad_image
    #gamepad_container
  EndEnumeration
  
  Global GamePad_waitingforbutton
  
  Procedure CheckButtonAndSetText(whichjoystick, whichbutton, whichgadget, text.s)
    Define i
    
    If JoystickButton(whichjoystick, whichbutton)
      For i = #gamepad_a To #gamepad_select
        SetGadgetColor(i, #PB_Gadget_BackColor, #PB_Image_Transparent)
      Next i
      SetGadgetText(whichgadget, text)
      GamePad_waitingforbutton = 0
      SetActiveGadget(#gamepad_image)
    EndIf
  EndProcedure
  
  Procedure CheckJoystickButton(whichjoystick, whichbutton, whichgadget)
    If JoystickButton(whichjoystick, whichbutton)
      HideGadget(whichgadget, #False)
    Else
      HideGadget(whichgadget, #True)
    EndIf
  EndProcedure
  
  Procedure CheckJoystickAxisX(whichjoystick, whichpad, whichgadget, direction = 1 ) ; up
    If JoystickAxisX(whichjoystick, whichpad, #PB_Absolute) = direction
      HideGadget(whichgadget, #False)
    Else
      HideGadget(whichgadget, #True)
    EndIf
  EndProcedure
  
  Procedure CheckJoystickAxisY(whichjoystick, whichpad, whichgadget, direction = 1) ; left
    If JoystickAxisY(whichjoystick, whichpad, #PB_Absolute) = direction
      HideGadget(whichgadget, #False)
    Else
      HideGadget(whichgadget, #True)
    EndIf
  EndProcedure
  
  Procedure GetButtonID(whichgadget)
    Select GetGadgetText(whichgadget)
      Case "Start"  : ProcedureReturn #gamepad_button_start
      Case "A"      : ProcedureReturn #gamepad_button_a
      Case "B"      : ProcedureReturn #gamepad_button_b
      Case "Select" : ProcedureReturn #gamepad_button_select
    EndSelect
  EndProcedure
  
  Procedure DetectJoys()
    GamePad_Count = InitJoystick()
    
    If IsImage(#gamepad) 
      FreeImage(#gamepad)
    EndIf
    
    ; TODO -> more sticks
    If GamePad_Count > 0
      With GamePad(0)
        \name          = JoystickName(0)
        \button_a      = #gamepad_button_a
        \button_b      = #gamepad_button_b
        \button_select = #gamepad_button_select
        \button_start  = #gamepad_button_start
        \up            = #gamepad_button_up
        \down          = #gamepad_button_down
        \left          = #gamepad_button_left
        \right         = #gamepad_button_right
      EndWith
      
      If FindString(GamePad(0)\name, "pad") > 0
        CatchImage(#gamepad, ?ui_gamepad)
      ElseIf FindString(GamePad(0)\name, "stick") > 0
        CatchImage(#gamepad, ?ui_joystick)
      EndIf
    Else
      CatchImage(#gamepad, ?ui_nopad)
    EndIf
    
  EndProcedure
  
  Procedure OpenGamepadSettings()
    
    CatchImage(#gamepad_check, ?ui_gamepad_check)
    
    OpenWindow(#gamepad, 100, 100, 420, 240, "Gamepad: Settings")
    
    CreateStatusBar(#gamepad, WindowID(#gamepad))
    AddStatusBarField(30)
    AddStatusBarField(390)
    
    ResizeWindow(#gamepad, #PB_Ignore, #PB_Ignore, #PB_Ignore, 240 + StatusBarHeight(#gamepad))
    
    ContainerGadget(#gamepad_container, 0,  0, 200, 240)
    
    TextGadget(#PB_Any,                10, 10, 180, 40, "Select and press a button on your gamepad.")
    TextGadget(#PB_Any,                10, 52,  50, 20, "Start")
    StringGadget(#gamepad_start,      150, 50,  50, 24, "")
    ImageGadget(#gamepad_start_test,  120, 50,  24, 24,ImageID(#gamepad_check))
    
    TextGadget(#PB_Any,                10, 78,  50, 20, "Select")
    StringGadget(#gamepad_select,     150, 76,  50, 24, "")
    ImageGadget(#gamepad_select_test, 120, 76,  24, 24,ImageID(#gamepad_check))
    
    TextGadget(#PB_Any,                10,104,  80, 20, "Button A")
    StringGadget(#gamepad_A,          150,102,  50, 24, "")
    ImageGadget(#gamepad_a_test,      120,102,  24, 24,ImageID(#gamepad_check))
    
    TextGadget(#PB_Any,                10,130,  80, 20, "Button B")
    StringGadget(#gamepad_B,          150,128,  50, 24, "")
    ImageGadget(#gamepad_b_test,      120,128,  24, 24,ImageID(#gamepad_check))
    
    TextGadget(#PB_Any,                10,156, 220, 20, "Press directions on your gamepad.")
    ImageGadget(#gamepad_left_test,    69,191,  24, 24,ImageID(#gamepad_check))
    ImageGadget(#gamepad_right_test,  127,191,  24, 24,ImageID(#gamepad_check))
    ImageGadget(#gamepad_up_test,      98,177,  24, 24,ImageID(#gamepad_check))
    ImageGadget(#gamepad_down_test,    98,209,  24, 24,ImageID(#gamepad_check))
    CloseGadgetList()
    
    ImageGadget(#gamepad_image,    210, 10, 200, 200, ImageID(#gamepad))
    
    ButtonGadget(#gamepad_check,   WindowWidth(#gamepad) - 200, WindowHeight(#gamepad) - 34 - StatusBarHeight(#gamepad), 60, 24, "Detect")
    ButtonGadget(#gamepad_cancel,  WindowWidth(#gamepad) - 135, WindowHeight(#gamepad) - 34 - StatusBarHeight(#gamepad), 60, 24, "Cancel")
    ButtonGadget(#gamepad_ok,      WindowWidth(#gamepad) -  70, WindowHeight(#gamepad) - 34 - StatusBarHeight(#gamepad), 60, 24, "OK")
    
    If GamePad_Count = 0
      HideGadget(#gamepad_container, #True)
      DisableGadget(#gamepad_ok, #True)
      GadgetToolTip(#gamepad_image, "No gamepad or joystick found...")
    Else
      HideGadget(#gamepad_container, #False)
      DisableGadget(#gamepad_ok, #False)
      GadgetToolTip(#gamepad_image, "A representation of your gamepad or joystick...")
    EndIf
    
    GadgetToolTip(#gamepad_select,  "Select this gadget to set the 'Select' button of your gamepad / joystick.")
    GadgetToolTip(#gamepad_a,       "Select this gadget to set the 'A' button of your gamepad / joystick.")
    GadgetToolTip(#gamepad_b,       "Select this gadget to set the 'B' button of your gamepad / joystick.")
    GadgetToolTip(#gamepad_start,   "Select this gadget to set the 'Start' button of your gamepad / joystick.")
    
    GadgetToolTip(#gamepad_check,   "Click to scan for gamepads and joysticks.")
    GadgetToolTip(#gamepad_cancel,  "Click to close this window.")
    GadgetToolTip(#gamepad_ok,      "Click to apply the settings and close this window.")
    
    
    AddKeyboardShortcut(#gamepad, #PB_Shortcut_Escape, #gamepad_stop)
  EndProcedure
  
  Procedure CloseGamepadSettings()
    If IsImage(#gamepad_check) : FreeImage(#gamepad_check) : EndIf
    If IsImage(#gamepad) : FreeImage(#gamepad) : EndIf
    RemoveKeyboardShortcut(#gamepad, #PB_Shortcut_Escape)
    CloseWindow(#gamepad)  
  EndProcedure
  
  ; TODO sloppy...
  Procedure ExamineGamepads(gamepadnum = #gamepad_0)
    Define padevent = gamepadnum + #PB_Event_FirstCustomValue
    
    If GamePad_Count = 0
      ProcedureReturn
    EndIf
    
    ExamineJoystick(gamepadnum)
    
    With Gamepad(gamepadnum)
      If JoystickButton(gamepadnum, \button_b)      : PostEvent(padevent, 0, 0, 0, #gamepad_button_b)      : EndIf
      If JoystickButton(gamepadnum, \button_a)      : PostEvent(padevent, 0, 0, 0, #gamepad_button_a)      : EndIf
      If JoystickButton(gamepadnum, \button_select) : PostEvent(padevent, 0, 0, 0, #gamepad_button_select) : EndIf
      If JoystickButton(gamepadnum, \button_start)  : PostEvent(padevent, 0, 0, 0, #gamepad_button_start)  : EndIf
      If JoystickButton(gamepadnum, \up)            : PostEvent(padevent, 0, 0, 0, #gamepad_button_up)     : EndIf
      If JoystickButton(gamepadnum, \down)          : PostEvent(padevent, 0, 0, 0, #gamepad_button_down)   : EndIf
      If JoystickButton(gamepadnum, \left)          : PostEvent(padevent, 0, 0, 0, #gamepad_button_left)   : EndIf
      If JoystickButton(gamepadnum, \right)         : PostEvent(padevent, 0, 0, 0, #gamepad_button_right)  : EndIf
    EndWith
    
  EndProcedure
  
  Procedure CheckGamepadGadgets(event, menu, gadget)
    
    If GamePad_Count <> 0
      
      ;- TODO more joysticks
      
      ExamineJoystick(0)
      
      If GamePad_waitingforbutton <> 0
        CheckButtonAndSetText(0, #gamepad_button_b,      GamePad_waitingforbutton, "B") ; 1
        CheckButtonAndSetText(0, #gamepad_button_a,      GamePad_waitingforbutton, "A") ; 2
        CheckButtonAndSetText(0, #gamepad_button_select, GamePad_waitingforbutton, "Select") ; 9
        CheckButtonAndSetText(0, #gamepad_button_start,  GamePad_waitingforbutton, "Start")  ; 10
      ElseIf GamePad_waitingforbutton = 0                                                    ; just check
        CheckJoystickButton( 0, #gamepad_button_a,      #gamepad_a_test)
        CheckJoystickButton( 0, #gamepad_button_b,      #gamepad_b_test)
        CheckJoystickButton( 0, #gamepad_button_select, #gamepad_select_test)
        CheckJoystickButton( 0, #gamepad_button_start,  #gamepad_start_test)
        CheckJoystickAxisY ( 0, 0, #gamepad_up_test,   -1)
        CheckJoystickAxisY ( 0, 0, #gamepad_down_test,  1)
        CheckJoystickAxisX ( 0, 0, #gamepad_left_test, -1)
        CheckJoystickAxisX ( 0, 0, #gamepad_right_test, 1)
      EndIf
    EndIf
    
    Select event
      Case #PB_Event_Menu
        If menu = #gamepad_stop
          If GamePad_waitingforbutton <> 0
            SetGadgetColor(GamePad_waitingforbutton, #PB_Gadget_BackColor, #PB_Image_Transparent)
            GamePad_waitingforbutton = 0
            StatusBarText(#gamepad, 0, "OK")
            StatusBarText(#gamepad, 1, "You pressed Escape. No settings were harmed.")
          EndIf
        EndIf
        
      Case #PB_Event_Gadget
        Select gadget
          Case #gamepad_a To #gamepad_select
            SetGadgetColor(gadget, #PB_Gadget_BackColor, RGB(127,127,127))
            Define button.s
            Select gadget
              Case #gamepad_start:  button = "Start"
              Case #gamepad_select: button = "Select"
              Case #gamepad_a:      button = "A"
              Case #gamepad_b:      button = "B"
            EndSelect
            
            StatusBarText(#gamepad, 0, "?")
            StatusBarText(#gamepad, 1, "Click a button to set for '" + button + "'")
            GamePad_waitingforbutton = gadget
            
          Case #gamepad_check
            GamePad_Count = DetectJoys()
            
            If GamePad_Count > 0
              HideGadget(#gamepad_container, #False)
              DisableGadget(#gamepad_ok, #False)
              StatusBarText(#gamepad, 0, "OK")
              If GamePad_Count = 1
                StatusBarText(#gamepad, 1, "Found one gamepad/joystick called '" + JoystickName(0) + "'.")
              Else
                StatusBarText(#gamepad, 1, "Found " + Str(GamePad_Count) + " gamepads/joysticks.")
              EndIf
              
            Else
              HideGadget(#gamepad_container, #True)
              DisableGadget(#gamepad_ok, #True)
              StatusBarText(#gamepad, 0, "Err")
              StatusBarText(#gamepad, 1, "Could not find any gamepad/joystick. Connect one and click again!")
            EndIf
            
          Case #gamepad_cancel
            ProcedureReturn #True
            
          Case #gamepad_ok
            With GamePad(0)
              \button_a = GetButtonID(#gamepad_a)
              \button_b = GetButtonID(#gamepad_b)
              \button_start = GetButtonID(#gamepad_start)
              \button_select = GetButtonID(#gamepad_select)
            EndWith
            ProcedureReturn #True
            
        EndSelect
        
      Case #PB_Event_CloseWindow
        ProcedureReturn #True
        
    EndSelect
    
  EndProcedure
  
  DataSection
    ui_joystick:
    IncludeBinary "ui_joystick.png"
    
    ui_gamepad:
    IncludeBinary "ui_gamepad.png"
    
    ui_gamepad_check:
    IncludeBinary "ui_gamepad_check.png"
    
    ui_nopad:
    IncludeBinary "ui_nopad.png"
    
  EndDataSection
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  GamePad::DetectJoys()
  GamePad::OpenGamepadSettings()
  
  Define quit = #False, event, menu, gadget
  
  Repeat
    event  = WaitWindowEvent(30)
    menu   = EventMenu()
    gadget = EventGadget()
    
    quit   = GamePad::CheckGamepadGadgets(event,menu,gadget)
    ;     GamePad::ExamineGamepads()
    
    If event = GamePad::#gamepad_0
      Select EventData()
        Case GamePad::#gamepad_button_a : Debug "a"
        Case GamePad::#gamepad_button_b : Debug "b"
        Case GamePad::#gamepad_button_start : Debug "start"
        Case GamePad::#gamepad_button_select : Debug "select"
      EndSelect
    EndIf
    
    Delay(30)
  Until quit = #True
  
  GamePad::CloseGamepadSettings()
  
CompilerEndIf
; IDE Options = PureBasic 6.01 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 460
; FirstLine = 427
; Folding = ---
; EnableXP
; DPIAware