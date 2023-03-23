OpenWindow(0,100,100,270,50,"Nectarine",#PB_Window_Tool|#PB_Window_SystemMenu)
WebGadget(0,0,0,270,50,"https://scenestream.net/demovibes/play/")
AddKeyboardShortcut(0,#PB_Menu_Quit,1)
Repeat
  Delay(50)
Until WaitWindowEvent() = #PB_Event_CloseWindow
  
; IDE Options = PureBasic 5.70 LTS (MacOS X - x64)
; CursorPosition = 5
; EnableXP
; UseIcon = Nectarine.icns
; Executable = ../../../Desktop/Nectarine.app