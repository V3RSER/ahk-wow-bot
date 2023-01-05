print(str){
	Global print

	If((IsObject(print) == false) || (print == ""))
	{
		Global print = new BensConsole()
		Global nameTitle
		print.setTitle(nameTitle)
	}

	print.log(str)
}

consoleClear(){
	Global print
	If(!(IsObject(print) == false) || !(print == ""))
	{
		print.Clear()
	}
}

consoleClose(){
	Global print
	If(!(IsObject(print) == false) || !(print == ""))
	{
		print.Close()
	}
}

class BensConsole
{
	; exposed in __NEW constructor
	consolecol := "000000"
	fontcol := "15bb10"
	textBackgroundCol := "000000"
	opacity := 160
	fontsize := 10
	titlebar := True
	topToBottom := True
	prependDate := True
	animate := False
	clearOnClose := True
	alwaysFlushToDisk := False
	enableCommands := True
	consoleMode := False
	logCommands := True
	nameInLog := False

	; User changable
	minHeight := 130
	maxHeight := 150
	width := 170
	padding := 5
	; posX := A_ScreenWidth - 170
	posX := A_ScreenWidth*0.67
	posY := A_ScreenHeight - 150 - 5

	; best don't touch
	consid := 0
	LogContsID := ""
	LogContents := ""
	consslid := True
	logloc := A_WorkingDir . "\AHK_LOG.log"
	conshide := False
	startpos := 0
	ctH := 0
	oH := 0
	maxTextHeight := 0
	minTextHeight := 0
	winHeightAdd := 0
	winAbsMinHeight := 0
	allset := False
	myName := ""
	myTitle := "AHK Console"
	myGUIName := "AHK_Console"
	ctit := ""
	; End of variable declarations

	setTitle(name)
	{
		; This.myName := "Bot"
		; This.ctit := This.myName != "" ? This.myName . ": " : ""
		; This.myTitle := This.ctit . name
		This.myTitle := name
		varsafename := RegExReplace(This.myTitle, "i)([^\w]+)", "_")
		If inStr("0123456789", substr(varsafename, 1,1))
			varsafename := "v" . varsafename
		This.myGUIName := varsafename
	}

	setLocation(path)
	{
		This.logloc := path
	}

	__New(name = "", color = "000000", fontColor = "15bb10", textBackgroundCol = "000000", opacity = 150, fontsize = 8, titlebar = True, topToBottom = False, prependDate = True, animate = False, clearOnClose = True, alwaysFlushToDisk = False, enableCommands = True, consoleMode = False, logCommands = True, nameInLog = False)
	{
		If(isObject(name))
		{
			This.setTitle(name.name)
			This.consolecol := name.color
			This.fontcol := name.fontColor
			This.textBackgroundCol := name.textBackgroundCol
			This.opacity := name.opacity
			This.fontsize := name.fontsize
			This.topToBottom := name.topToBottom
			This.prependDate := name.prependDate
			This.animate := name.animate
			This.clearOnClose := name.clearOnClose
			This.titlebar := name.titlebar
			This.alwaysFlushToDisk := name.alwaysFlushToDisk
			This.enableCommands := name.enableCommands
			This.consoleMode := name.consoleMode
			This.logCommands := name.logCommands
			This.nameInLog := name.nameInLog
		}
		Else
		{
			This.setTitle(name)
			This.consolecol := color
			This.fontcol := fontColor
			This.textBackgroundCol := textBackgroundCol
			This.opacity := opacity
			This.fontsize := fontsize
			This.topToBottom := topToBottom
			This.prependDate := prependDate
			This.animate := animate
			This.clearOnClose := clearOnClose
			This.titlebar := titlebar
			This.alwaysFlushToDisk := alwaysFlushToDisk
			This.enableCommands := enableCommands
			This.consoleMode := consoleMode
			This.logCommands := logCommands
			This.nameInLog := nameInLog
		}
	}

	log(msg)
	{
		tv := False
		If(This.enableCommands && ! This.logCommands)
		{
			tv := This.doEvals(msg)
		}
		If(tv != False)
			Return

		omsg := msg

		If(This.nameInLog)
			msg := This.ctit . msg

		If(This.prependDate)
			msg := "|" This.DateString() . "| " . msg
		If(This.alwaysFlushToDisk)
		{
			FileRead, lc, % This.logloc
			This.LogContents := lc
			FileDelete, % This.logloc
		}

		If(This.LogContents != "")
		{
			If(This.topToBottom)
			{
				This.LogContents := msg . "`r`n" . This.LogContents
				; msgbox, ttb
			}
			Else
			{
				This.LogContents := This.LogContents . "`r`n" . msg
				; msgbox, btt
			}
		}
		Else
		{
			; msgbox, no content yet...
			This.LogContents := msg
		}
		; msgbox, % "result: `n" This.LogContents

		If(This.alwaysFlushToDisk)
		{
			FileAppend, % This.LogContents, % This.logloc
		}

		If(This.consid == 0)
		{
			This.buildGui()
			; This.setTextHeight(20)
			; This.doSizePos()
		}
		Else
		{
			If(This.conshide)
			{
				; WinShow, % "ahk_id " This.consid
				gui, % This.myGUIName ": show", % "x" This.posX " y" This.posY " NoActivate"
				This.conshide := False
			}
			This.applyContents()
		}

		If(This.enableCommands && This.logCommands)
			This.doEvals(omsg)

	} ; END log

	buildGui()
	{
		; +E0x20 ; <-- click through!
		GUI, % This.myGUIName ": New", +Lastfound +AlwaysOnTop +ToolWindow +E0x08000000, % This.myTitle ;
		gui, % This.myGUIName ": color", % This.consolecol
		WinSet, Transparent, % This.opacity
		Gui, % This.myGUIName ": -Caption"
		Gui, % This.myGUIName ": Color",, % This.textBackgroundCol
		This.startpos := This.padding
		If(This.titlebar)
		{
			Gui, % This.myGUIName ": Font", S8 bold
			tmw := This.width - 2* This.padding
			Global titbar
			Gui, % This.myGUIName ": Add", Text, % "x" This.padding " y" This.padding " w" tmw " h15 c" This.fontcol " vtitbar", % This.myTitle
			This.startpos := 15 + 2* This.padding
		}

		cbuy := This.startpos
		cbuwi := 17
		cbuhe := 14
		cbux := This.width - cbuwi - This.padding

		gui, % This.myGUIName ": Font", S7 norm center
		gui, % This.myGUIName ": Add", button, w%cbuwi% h%cbuhe% x%cbux% y%cbuy% hwndtbutt, _
		fn := This.minimize.Bind(This)
		GuiControl +g, %tbutt%, % fn
		cbuy += 18
		gui, % This.myGUIName ": Add", button, w%cbuwi% h%cbuhe% x%cbux% y%cbuy% hwndtbutt, <
		fn := This.slide.Bind(This)
		GuiControl +g, %tbutt%, % fn
		cbuy += 18
		gui, % This.myGUIName ": Add", button, w%cbuwi% h%cbuhe% x%cbux% y%cbuy% hwndtbutt, C
		fn := This.clear.Bind(This)
		GuiControl +g, %tbutt%, % fn
		cbuy += 18
		gui, % This.myGUIName ": Add", button, w%cbuwi% h%cbuhe% x%cbux% y%cbuy% hwndtbutt, S
		fn := This.save.Bind(This)
		GuiControl +g, %tbutt%, % fn
		cbuy += 18
		gui, % This.myGUIName ": Add", button, w%cbuwi% h%cbuhe% x%cbux% y%cbuy% hwndtbutt, O
		fn := This.open.Bind(This)
		GuiControl +g, %tbutt%, % fn
		cbuy += 18
		gui, % This.myGUIName ": Add", button, w%cbuwi% h%cbuhe% x%cbux% y%cbuy% hwndtbutt, X
		fn := This.close.Bind(This)
		GuiControl +g, %tbutt%, % fn

		absminh := cbuy + cbuhe - This.padding
		If This.minHeight < absminh
			This.minHeight := absminh

		This.tWmax := This.width - (2*This.padding) - 25
		Gui, % This.myGUIName ": Font", % "S" This.fontsize, Consolas
		Gui, % This.myGUIName ": Add", Edit, % "x" This.padding " y" This.startpos " w" This.tWmax " +Multi c" This.fontcol " -VScroll -E0x200 HwndtLogContsID", % This.LogContents
		This.LogContsID := tLogContsID
		gui, % This.myGUIName ": show", % "x" This.posX " y" This.posY " autosize NoActivate"
		gui, % This.myGUIName ": +LastFound"
		This.consid := WinExist()

		WinGetPos,,,,mbH, % "ahk_id " This.consid
		This.winAbsMinHeight := mbH
		This.setMaxTextHeight()

		clickdrag := ObjBindMethod(This, "drag")
		OnMessage(0x201, clickdrag) ; WM_LBUTTONDOWN

		moving := ObjBindMethod(This, "moving")
		OnMessage(0x03, moving) ; WM_MOVE
		; OnMessage(0x0047, moving) ; WINDOWPOSCHANGED

		; applyContents()
	}

	applyContents()
	{
		; controlRemove(This.Ghost)
		Gui, % This.myGUIName ": Font", % "S" This.fontsize, Consolas
		Gui, % This.myGUIName ": Add", Edit, % "x" This.padding " y" This.startpos " w" This.tWmax " +Hidden -VScroll -E0x200 HwndtGhost", % This.LogContents
		This.Ghost := tGhost
		ControlGetPos,,,, ctH,, % "ahk_id " This.Ghost
		SendMessage, 0x10,,,, % "ahk_id " This.Ghost

		GuiControl, Text, % This.LogContsID, % This.LogContents

		This.setTextHeight(ctH)

		If(This.topToBottom)
			postMessage,0x115,0x6,,,% "ahk_id " This.LogContsID ; WM_VSCROLL = 0x0115 ; controlsend,, ^{home}, % "ahk_id " This.LogContsID
		Else
			postMessage,0x115,0x7,,,% "ahk_id " This.LogContsID ; WM_VSCROLL = 0x0115 ; controlsend,, ^{end}, % "ahk_id " This.LogContsID

	}

	setTextHeight(num)
	{
		; msgbox, % "in: " num
		This.ctH := num > This.maxTextHeight ? This.maxTextHeight : num
		; This.ctH := This.ctH < This.minTextHeight ? This.minTextHeight : This.ctH
		; msgbox, % "out: " This.ctH
		If(This.ctH != This.oH)
		{
			ControlMove,,,,,This.ctH, % "ahk_id " This.LogContsID
			This.oH := This.ctH
			If (This.ctH + This.winHeightAdd > This.winAbsMinHeight)
				winmove, % "ahk_id " This.consid,,,,,% This.ctH + This.winHeightAdd
			; This.allset := False
		}
	}

	setMaxTextHeight()
	{
		This.winHeightAdd := This.startpos + This.padding
		This.maxTextHeight := This.maxHeight-This.winHeightAdd
		; This.minTextHeight := This.minHeight-This.winHeightAdd
	}

	doSizePos(isUpdate = False)
	{
		; capTextHeight()

		; If(This.ctH != This.oH)
		; {
		; If This.ctH < This.minHeight
		; {
		; This.ctH := This.minHeight
		; }
		; This.oH := This.ctH
		; winmove, % "ahk_id " This.consid,,,,,% This.ctH + This.startpos + This.padding
		; }

	}

	position(x="",y="")
	{
		If(x!="")
			This.posX := x
		If(y!="")
			This.posY := y
		WinMove, % "ahk_id " This.consid,,% This.posX,% This.posY
		Print(2)
	}

	setX(x)
	{
		This.position(x)
	}

	setY(y)
	{
		This.position(,y)
	}

	doEvals(msg)
	{
		cmd := This.explode(msg, ",")
		If(cmd.MaxIndex()<1 || subStr(msg, 1, 1) != "\")
			Return False

		; why does AHK not support SWITCH statements yet? :(
		If(This.toLower(cmd[1]) == "\close")
			This.close()
		Else If(This.toLower(cmd[1]) == "\hide")
			This.minimize()
		Else If(This.toLower(cmd[1]) == "\show")
			This.restore()
		Else If(This.toLower(cmd[1]) == "\save")
			This.save()
		Else If(This.toLower(cmd[1]) == "\view")
			This.open()
		Else If(This.toLower(cmd[1]) == "\setx")
			This.setX(cmd[2])
		Else If(This.toLower(cmd[1]) == "\sety")
			This.setY(cmd[2])
		Else If(This.toLower(cmd[1]) == "\setpos")
			This.position(cmd[2], cmd[3])
		Else If(This.toLower(cmd[1]) == "\rep")
			msgbox, % This.posX ", " This.posY
		Else
			Return False
	}

	minimize(){
		WinHide, % "ahk_id " This.consid
		This.conshide := True
	}

	restore(){
		; WinShow, % "ahk_id " This.consid
		gui, % This.myGUIName ": show", % "x" This.posX " y" This.posY " NoActivate"
		This.conshide := False
	}

	close()
	{
		If(This.animate)
		{
			This.fadeWin(This.consid, 1, True)
		}
		Else
		{
			gui, % This.myGUIName ": Destroy"
		}
		If(This.clearOnClose)
		{
			This.LogContents := ""
			FileDelete, % This.logloc
		}
		This.consid := 0
	}

	drag(w,l,m,h)
	{
		If(h == This.consid)
		{
			PostMessage, 0xA1, 2,,, % "Ahk_id " h
			Return
		}
	}

	moving(w, l, m, h)
	{
		If(h == This.consid && ! This.sliding)
		{
			This.posX := This.GET_X_LPARAM(l)
			This.posY := This.GET_Y_LPARAM(l)
			This.consslid := True
		}
	}

	save(){
		GUI, % This.myGUIName ": +OwnDialogs"
		FileSelectFile, logsaveloc,S,% "Log " . This.DateString(True) . ".log",Save Log, Logs (*.log)
		If(logsaveloc)
		{
			filecopy, % This.logloc, %logsaveloc%
		}
	}

	open(){
		Run, % This.logloc
	}
	sliding := False
	slide()
	{
		This.sliding := True
		If(This.consslid := ! This.consslid)
		{
			If(This.animate)
			{
				This.slideWin(This.consid, This.posX,This.posY,200)
			}
			Else
			{
				WinMove, % "ahk_id " This.consid,,% This.posX,% This.posY
			}
		}
		Else
		{
			If(This.animate)
			{
				This.slideWin(This.consid, 30 - This.width,This.posY, 200)
			}
			Else
			{
				WinMove, % "ahk_id " This.consid,,% 30 - This.width,% This.posY
			}

		}
		This.sliding := False
	}

	clear(){
		This.LogContents := ""
		FileDelete, % This.logloc
		This.applyContents()
	}

	; ######### general functions ##########

	DateString(filesafe = False)
	{
		If(filesafe)
			FormatTime, mcurrentTime, %A_Now%, HH-mm-ss ;yyyy-MM-dd HH-mm-ss
		Else
			FormatTime, mcurrentTime, %A_Now%, mm:ss
		; FormatTime, mcurrentTime, %A_Now%, HH:mm:ss
		Return mcurrentTime
	}

	explode(string, delim=",", trimvals = True)
	{
		parr := StrSplit(string, delim)
		If(trimvals)
		{
			for k, v in parr{
				parr[k] := trim(v)
			}
		}
		Return, parr
	}

	toLower(string)
	{
		StringLower, string, string
		Return % string
	}

	fadeWin(msid, ms = 10, closeOnFinish = False, trans = 256)
	{
		If(trans>=256)
		{
			WinGet, trans, Transparent, ahk_id %msid%
		}
		ntrans := trans-2
		WinSet, Transparent, %ntrans%, ahk_id %msid%
		If(ntrans>0)
		{
			Sleep, ms
			This.fadeWin(msid, ms, closeOnFinish, ntrans)
		}
		Else
			If(closeOnFinish)
			WinClose, ahk_id %msid%
	}

	slideWin(msid, tX = 0, tY = 0, T = 500, rightAlign = False, closeOnFinish = False, frst = True, dX = 0, dY = 0, step=0, maxStep=0)
	{
		anint := 100
		winGetPos, wX,wY,wW,wH,ahk_id %msid%
		woX := wX
		If(rightAlign)
		{
			wX += wW
		}

		If(frst)
		{
			maxStep := Round(T/(anint + 0))
			dX := Round((tX - wX) / maxStep)
			dY := Round((tY - wY) / maxStep)
		}

		If(step<maxStep)
		{
			newX := woX + dX
			newY := wY + dY
			winMove, ahk_id %msid%,,newX,newY
			; Sleep, anint-19
			This.slideWin(msid, tX, tY, T, rightAlign, closeOnFinish, False, dX, dY, step+1, maxStep)
		}
		Else
		{
			If(rightAlign)
			{
				winMove, ahk_id %msid%,, tX-wW,tY
			}
			Else
			{
				winMove, ahk_id %msid%,, tX,tY
			}
			If(closeOnFinish)
			{
				WinClose, ahk_id %msid%
			}
		}
	}

	GET_X_LPARAM(lParam) {
		NumPut(lParam, Buffer:=" ", "UInt")
		Return NumGet(Buffer, 0, "Short")
	}
	GET_Y_LPARAM(lParam) {
		NumPut(lParam, Buffer:=" ", "UInt")
		Return NumGet(Buffer, 2, "Short")
	}
}

