Global NewMap Verbs.i()
Global NewMap Rooms.i()

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  Define Range.NSRange
CompilerEndIf

Declare WriteRoom ()

Global task.s
Global room.i = 0
Global bananagone.i = 0
Global watergone.i = 0

Global Window_0

Global String_0, Text_0, Button_0, Editor_0

Procedure OpenWindow_0(x = 0, y = 0, width = 690, height = 440)
  Window_0 = OpenWindow(#PB_Any, x, y, width, height, "Search the Exit", #PB_Window_TitleBar | #PB_Window_Tool | #PB_Window_ScreenCentered | #PB_Window_WindowCentered)
  String_0 = StringGadget(#PB_Any, 180, 400, 500, 25, "")
  Text_0 = TextGadget(#PB_Any, 10, 400, 160, 25, "Your Command, Master?")
  Editor_0 = EditorGadget(#PB_Any, 10, 10, 670, 380, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
  DisableGadget(Editor_0, 1)
  
  SetWindowColor(Window_0, RGB(0,0,0))
  SetGadgetColor(String_0, #PB_Gadget_FrontColor,RGB(254,255,255))
  SetGadgetColor(String_0, #PB_Gadget_BackColor,RGB(0,0,0))
  SetGadgetColor(Text_0, #PB_Gadget_FrontColor,RGB(254,255,255))
  SetGadgetColor(Text_0, #PB_Gadget_BackColor,RGB(0,0,0))
  SetGadgetColor(Editor_0, #PB_Gadget_FrontColor,RGB(254,255,255))
  SetGadgetColor(Editor_0, #PB_Gadget_BackColor,RGB(0,0,0))

EndProcedure

Procedure Writething (text.s,adder=1)
  addme.s = ""
  If adder = 1
    addme = Chr(13) + Chr(10) + "--- You wanted: " + task + " ---" + Chr(13) + Chr(10)
  EndIf
  SetGadgetText(Editor_0,GetGadgetText(editor_0) + addme + text + Chr(13) + Chr(10))
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Linux
;             gtk_tree_view_scroll_to_point_(GadgetID(0), -1, (GetGadgetState(1) - 1) * 22 - 20)
     CompilerCase #PB_OS_MacOS
       Range.NSRange\location = Len(GetGadgetText(editor_0))
       CocoaMessage(0, GadgetID(editor_0), "scrollRangeToVisible:@", @Range)
       
       ; !!
     CompilerCase #PB_OS_Windows
       SendMessage_(GadgetID(editor_0), #EM_SETSEL,-1,-1)
       MessageRequester("!","!")
  CompilerEndSelect
;   
EndProcedure

Procedure.i GetTask(task.s) 
  Define order = Verbs(task)
  
  If task = "quit" Or task = "exit" 
    ProcedureReturn -1
  EndIf
  
  If room = 11
    writeroom()
    ProcedureReturn 0
  EndIf

  Select task
    Case "help"
      Writething("Today, you may use these words. Use them wisely, and please write two words sentences, only. As you might have noticed already, I am not that word-witty." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "quit, exit, help (alas!), get, drink, eat, go, investigate, use, fight." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Yes, that are the words. Now, go on, escape!")
      ProcedureReturn 0
    Case "look"
      WriteRoom()
      ProcedureReturn 0
    Case "get banana"
      If bananagone < 1
        Writething("Ok, I took the banana. It's ripe!")
        bananagone = 1
      Else
        writething("There are no more bananas.")
      EndIf
      room = 4
      ProcedureReturn 0
    Case "get water"
      If watergone < 1
       Writething("Ok, I took the water. What now?")
      Else
        writething("There is no water.")
      EndIf
      watergone = 1
      ProcedureReturn 0
    Case "drink water"
      Select watergone 
        Case 0 : writething("You don't have it.") : ProcedureReturn 0
        Case 1 : writething("Ah, that's better. You feel refreshed.")
        Case 2 : writething("You already drank it. Don't you feel refreshed?")
      EndSelect
      watergone = 2
      room = 3
      ProcedureReturn 0
    Case "eat banana"
      Select bananagone 
        Case 0 : writething("You don't have it.") : ProcedureReturn 0
        Case 1 : Writething("You eat the banana, as it is a nice looking fruit.")
        Case 2 : writething("You already ate it.")
      EndSelect
      bananagone = 2
      ProcedureReturn 0
    Case "investigate bed"
      If room = 7
        writething("Between the sheets and the straw, you discover something.")
        room = 8
      Else
        writething("Dust emerges from the bed, as you touch it. It's lets your nose tickle. But nothing is here. Only the bed is destroyed.")
        room = 7
      EndIf
      ProcedureReturn 0
    Case "get key"
      If room < 8
        writething("No key here. Try again.")
      Else
        writething("Now, you have the key. Would you spare your idea of using it somewhat?")
        room = 8
      EndIf
      ProcedureReturn 0
    Case "use key"
      writething("You turn the key inside the giant lock. But a big monkey runs at you. Fast, what will you do?")
      If bananagone = 1
        room = 9
      Else
        room = 10
       EndIf
       ProcedureReturn 0
     Case "fight"
       If room < 8
         Writething("There is a time for fight. But not now.")
       Else
         Writething("Yes, you fight!")
         writeroom()
         room = 11
       EndIf
       
      ProcedureReturn 0                
  EndSelect

  ProcedureReturn 1
EndProcedure

Procedure WriteRoom ()
  SetGadgetText(Editor_0,"")
  Select room
    Case 0
      SetGadgetText(Editor_0,"Welcome to your grave." + Chr(13) + Chr(10) + Chr(13) + Chr(10))
      Writething("You wake up in a funny smelling room. There is only one window giving a bit of light. You can't remember, when you arrived here, but the hurting bump on your head tells you, it's was not on free will." + Chr(13) + Chr(10),0)
      room = 1
      ProcedureReturn
    Case 1
      Writething("After investigating a bit further, you find a small bed made of straw, and a closed door with a big lock. The walls seem to have scratches by fingernails. But you cannot say if its for real, or your imagination." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "On the ground lies a banana. There is some water, too." + Chr(13) + Chr(10))
      room = 2
    Case 2
      Writething("You thirst is killing you. Maybe, you try to find something to drink, first?")
      room = 1
    Case 3
      writething("What up? The room didn't change. There still is a bed.")     
    Case 4
      writething("Don't you dare. YOU ARE THIRSTY! Maybe you could find something to drink?")
    Case 5
      writething("The light seemed to change its color. Wait. No. It's your imagination, and dry throat. The water is yours. What are you gonna do with it?")
    Case 6
      writething("A delicious meal. And the lock is still on the door. Try harder.")
    Case 7
      writething("You look around. No more things to get, but a distroyed bed. Something twinkles at you. It's a key!")
      room = 8
    Case 8
      writething("The room is destroyed, like the hotel room of them stars, after a rock concert. You have a deep look at the door, and find: a lock. Yes it was hanging there all the time.")
    Case 9
      writething("As the monkey runs at you, you have the idea of throwing the banana at him. He catches the fruit, eats it, and opens a small hatch. Sunlight." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "You leave through the hatch, and breath fresh air. It's nice to be outside again, after these ten minutes in prison. Well done. It's over. Full score.")
      writething("Thanks For playing - www.joerg-burbach.de.")
    Case 10
      writething("The monkey is upset and hungry! It runs at you, like a beserk. You better had not eaten the banana. You throw the peel at him, he slides, and crashes into some crates. The crates open an exit to the outside, through which you escape. Next time, better be not that greedy. The monkey was hungry. But, well done, almost full score.")
      writething("Thanks For playing - www.joerg-burbach.de.")
    Case 11
      writething("The game ends here. Sorry")
      
  EndSelect
EndProcedure


OpenWindow_0()
AddKeyboardShortcut(window_0, #PB_Shortcut_Return, 15)
SetGadgetFont(editor_0,LoadFont(0,"Arial",20))
SetActiveGadget(string_0)
writeroom()

Repeat
  event = WaitWindowEvent(50)
  Select event
      Case #PB_Event_Menu
        Select EventMenu()
          Case 15: 
            task = LCase(GetGadgetText(string_0))
            answer = GetTask(task)
            Select answer
              Case -1 : End
              Case 1  : Writething(Chr(13) + Chr(10) + "Sorry, I do not know what to do with your order '" + task + "'. You may enter 'help' to get help.")
            EndSelect
            SetGadgetText(string_0,"")
            SetActiveGadget(string_0)
      EndSelect
      
   EndSelect
ForEver
; IDE Options = PureBasic 5.30 (MacOS X - x64)
; CursorPosition = 181
; FirstLine = 178
; Folding = -
; EnableUnicode
; EnableXP
; Executable = Escape!.exe
; CompileSourceDirectory