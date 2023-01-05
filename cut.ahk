#NoEnv
#SingleInstance, Force
#Persistent
SendMode, Input
SetWorkingDir, %A_ScriptDir%

#Include <Libraries>

global cut := new Cut()

class Cut
{
    __New()
    {
        CoordMode, Mouse, Relative
    }

    setCoorXY(frist := true)
    {
        this.__getCoorMouse(x, y)
        if frist
            this.x := x, this.y := y
        else {
            this._x := x, this._y := y
            this.__printCoor()
        }
    }

    __getCoorMouse(ByRef x, ByRef y)
    {
        MouseGetPos, x, y, id
        this.window := new Window(,, id)
        this.window.update()
    }

    __printCoor() {
        print(this.window.title "(" this.x ", " this.y ")"), print(this.window.title "(" this._x ", " this._y ")")
    }

    interfaceCreateCapture()
    {
        InputBox, name, Guardar como, Nombre:,, 200, 125
        this.image := new Image(this.window, name)
        this.image.editFromWindowByCoor(this.x, this.y, this._x, this._y)
        print("Guardando " name)
        this.name := name
    }

    sendFunction()
    {
        this.__getCoorsSearch(x, y, _x, _y)
        name := this.name
        Send search.click(I, ["%name%"], %x%, %y%, %_x%, %_y%)
    }

    __getCoorsSearch(ByRef x, ByRef y, ByRef _x, ByRef _y, range:= 3)
    {
        x := this.x - range, y := this.y - range
        _x := this._x + range, _y := this._y + range

        if(x < 0)
            x := 0
        if(y < 0)
            y := 0
        if(_x > this.window._x)
            _x := this.window._x
        if(_y > this.window._y)
            _y := this.window._y
    }
}

Numpad0::
    cut.openCapture()
Return

Numpad1::
    cut.setCoorXY(true)
Return

Numpad2::
    cut.setCoorXY(false)
Return

Numpad3::
    cut.interfaceCreateCapture()
Return

NumpadEnter::
    cut.sendFunction()
Return

NumpadDot:: exitapp

