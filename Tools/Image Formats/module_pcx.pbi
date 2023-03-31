;{ ===========================================================================================================[Header ]
;: 
;: Name ......... : TinyPCX
;: Version ...... : 1.0.0
;: Type ......... : Module
;: Author ....... : jamirokwai
;: Compiler ..... : PureBasic V6.01
;: Subsystem .... : none
;: TargetOS ..... : Windows ? / MacOS / Linux ?
;: Description .. : Loading and Saving 256 color PCX-files
;: License ...... : MIT License 
;:
;: thanks to
;: https://moddingwiki.shikadi.net/wiki/PCX_Format
;: https://www.fileformat.info/format/pcx/egff.htm
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

DeclareModule TinyPCX
  
  ; set a VGA / MCGA 8bit palette of exactly 256 triplets Red / Green / Blue with values from 0 to 255
  Declare SetPalette(*source)
  
  ; get a VGA / MCGA 8bit palette from an imported image of exactly 256 triplets Red / Green / Blue with values from 0 to 255
  Declare GetPalette(*dest)
  
  ; load a PCX-file. Currently supports only 256-color RLE encoded images
  Declare LoadPCX(image_id, filename.s)
  
  ; save a PCX-file. Currently supports only 256-color RLE encoded images
  Declare SavePCX(image_id, filename.s)
  
EndDeclareModule

Module TinyPCX
  EnableExplicit
  
  Structure PCX_Header_Struct
    id.a        ; is $0a
    version.a   ; 5 = version 3.0
    use_rle.a   ; 1 = use RLE encoding
    bpb.a       ; bits per pixel
    x1.w        ; coordinates of top left corner
    y1.w
    x2.w        ; coordinates of bottom right corner
    y2.w
    res_w.w     ; DPI, mostly used: image-width and height
    res_h.w     
    pal.a[48]   ; 16 standard colors
    reserved.a  ; 
    planes.a    ; 1 for 256
    bpl.w       ; bytes per line, rounded to next even number
    paltype.w   ; type of palette, 1 = color, 2 = grayscale
    res_hor.w   ; horizontal resolution
    res_ver.w   ; vertical resolution
    res2.a[54]
  EndStructure
  
  Global *palette = AllocateMemory(768)

  
  Procedure CountColorsFromImage(imageid)
    
    Define tempcolor.l, counting, x, y
    Define NewMap foundcolors.l()
    
    ClearMap(foundcolors())
    
    ; read all colors from the image
    If StartDrawing(ImageOutput(imageid))
      For x = 0 To OutputWidth() - 1
        For y = 0 To OutputHeight() - 1
          tempcolor = Point(x,y)
          AddMapElement(foundcolors(), Str(tempcolor))
          foundcolors() = tempcolor
        Next y
      Next x
      StopDrawing()
    EndIf
    
    ; copy the colors into *palette
    counting = 0
    FillMemory(*palette, 0, 768)
    ForEach foundcolors()
      PokeA(*palette + counting,     Red(foundcolors()))
      PokeA(*palette + counting + 1, Green(foundcolors()))
      PokeA(*palette + counting + 2, Blue(foundcolors()))
      counting + 3
    Next
    
    ClearMap(foundcolors())
    
  EndProcedure
  
  Procedure.a ConvertRGBtoIndex(r.a, g.a, b.a)
    Define palentry
    
    For palentry = 0 To 255
      If PeekA(*palette + palentry * 3    ) = r
        If PeekA(*palette + palentry * 3 + 1) = g
          If PeekA(*palette + palentry * 3 + 2) = b
            ProcedureReturn palentry
          EndIf
        EndIf
      EndIf
    Next palentry
    ProcedureReturn 0
  EndProcedure
  
  Procedure ConvertIndextoRGB(index)
    ProcedureReturn RGB(PeekA(*palette + index * 3), PeekA(*palette + index * 3 + 1), PeekA(*palette + index * 3 + 2))
  EndProcedure
  
  Procedure GetPalette(*source)
    CopyMemory(*palette, *source, 768)
  EndProcedure
  
  Procedure SetPalette(*source)
    CopyMemory(*source, *palette, 768)
  EndProcedure
  
  Procedure LoadPCX(image_id, filename.s)
    Define pcxfile = OpenFile(#PB_Any, filename)
    Define pcxsize = FileSize(filename)
    Define tempimage, pixelsum
    Define kennung.a = ReadByte(pcxfile)
    Define wide, high, count.a, palentry.a, x = 0, y = 0, i, quit = #False, singlecolor
    
    If kennung <> $0a
      ProcedureReturn #False
    EndIf
    
    FileSeek(pcxfile, 8) ; X2 and Y2 = size
    wide =  ReadWord(pcxfile) + 1
    high =  ReadWord(pcxfile) + 1
    
    ; only load PCX with embedded palette
    If pcxsize < 769 + 128
      ProcedureReturn #False
    EndIf
    
    FileSeek(pcxfile, pcxsize - 769)
    
    If ReadByte(pcxfile) = $0c
      ReadData(pcxfile, *palette, 768)
    EndIf  
    
    If image_id = #PB_Any
      tempimage = CreateImage(#PB_Any, wide, high, 32)
    Else
      tempimage = image_id
    EndIf
    
    If StartDrawing(ImageOutput(tempimage))
      FileSeek(pcxfile, 128)
      Repeat
        count = ReadByte(pcxfile)
        
        If count >= 192
          pixelsum = count - 192
          palentry = ReadByte(pcxfile)
        EndIf
        singlecolor = ConvertIndextoRGB(palentry)
        
        For i = 0 To pixelsum - 1
          Plot(x, y, singlecolor)
          x + 1
          
          If x = wide
            x = 0
            y + 1
            If y = high - 1
              quit = #True
            EndIf
          EndIf
        Next i
      Until quit = #True
      StopDrawing()
    EndIf
    
    CloseFile(pcxfile)
    
    ProcedureReturn tempimage
  EndProcedure
  
  Procedure SavePCX(image_id, filename.s)
    If IsImage(image_id)
      Define header.PCX_Header_Struct, x, y, pixel
      
      ; first get colors...
      CountColorsFromImage(image_id)
      
      With header
        \id       = $0a
        \version  = 5
        \use_rle  = 1
        \bpb      = 8
        \x1       = 0
        \y1       = 0
        \x2       = ImageWidth(image_id) - 1
        \y2       = ImageHeight(image_id) - 1
        \res_w    = 72; ImageWidth(image_id) - here 
        \res_h    = 72; ImageHeight(image_id)
        CopyMemory(*palette, @\pal, 48)
        \reserved = 0
        \planes   = 1 ; with npn = 8 -> palettized 256 colors, version = 5 -> palette at the end
        \bpl      = ImageWidth(image_id)
        \paltype  = 1 ; color
        \res_hor  = 0; ImageWidth(image_id)
        \res_ver  = 0; ImageHeight(image_id)
        FillMemory(@\res2, 54, 0)      
      EndWith 
      
      Define pcxfile = CreateFile(#PB_Any, filename)
      WriteData(pcxfile, @header, SizeOf(PCX_Header_Struct))
      
      Define count = 1
      Define color.a = 0, prevcolor.a = 0
      Define pixelnum = 0
      
      If StartDrawing(ImageOutput(image_id))
        
        x = 0
        y = 0
        prevcolor = Point(x, y)
        
        ; with RLE compression 
        Repeat
          pixel = Point(x, y)
          color = ConvertRGBtoIndex(Red(pixel), Green(pixel), Blue(pixel))
          
          If color = prevcolor And count < 63
            count + 1
            prevcolor = color
          Else
            WriteByte(pcxfile, $c0 + count)   ; compression: at least one pixel
            WriteByte(pcxfile, color)         ; save color
            count = 1
            prevcolor = color + 1
          EndIf
          
          x + 1
          If x = ImageWidth(image_id)
            x = 0
            y + 1
          EndIf
          
          pixelnum + 1
        Until pixelnum = ImageHeight(image_id) * ImageWidth(image_id)
        StopDrawing()
      EndIf
      
      WriteByte(pcxfile, $0c)          ; id: now the palette
      WriteData(pcxfile, *palette, 768); write palette - got this from the image itself
      
      CloseFile(pcxfile)
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  UsePNGImageEncoder()
  
  Define pcximage = LoadImage(#PB_Any, "input.png")
  TinyPCX::SavePCX(pcximage, "save_to_pcx.pcx")
  
  FreeImage(pcximage)
  
  Define pcximageout = TinyPCX::loadpcx(#PB_Any, "save_to_pcx.pcx")
  SaveImage(pcximageout, "converted_from_pcx.png", #PB_ImagePlugin_PNG)

CompilerEndIf
; IDE Options = PureBasic 6.01 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 253
; FirstLine = 217
; Folding = v-
; EnableXP
; DPIAware