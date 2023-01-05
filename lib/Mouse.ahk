class Mouse
{
    Static I := "MOUSE_LEFT"
    Static D := "MOUSE_RIGHT"
    Static M := "MOUSE_MIDDLE"
    Static MU := "MOUSE_MIDDLE_UP"
    Static MD := "MOUSE_MIDDLE_DOWN"

    __New(window)
    {
        this.__readVariables(background)
        this.window := window
        this.background := background
    }

    __readVariables(ByRef background){
        IniRead, background, settings.ini, mouse, background
    }

    use(button, x, y)
    {
        if this.background
            return this.modeBackground(button, x, y)
        this.modeForeground(button, x, y)
    }

    move(x, y, speed := 30, relative := false)
    {
        MouseMove, %x%, %y%, %speed%, %relative%
    }

    modeForeground(button, x, y, speed := 30, options := "")
    {
        this.window.activate()
        Switch button
        {
        Case Mouse.I: MouseClick, Left, %x%, %y%, 1, %speed%, %options%
        Case Mouse.D: MouseClick, Right, %x%, %y%, 1, %speed%, %options%
        Case Mouse.M: MouseClick, Middle, %x%, %y%, 1, %speed%, %options%
        Case Mouse.MU: MouseClick, WheelUp, %x%, %y%, 1, %speed%, %options%
        Case Mouse.MD: MouseClick, WheelDown, %x%, %y%, 1, %speed%, %options%
        Default: MouseClick, %button%, %x%, %y%, 1, %speed%, %options%
        }
    }

    modeBackground(button, x, y, options := "")
    {
        Switch button
        {
        Case Mouse.I: ControlClick, x%x% y%y%, % this.window.title,, L, 1,, NA %options%
        Case Mouse.D: ControlClick, x%x% y%y%, % this.window.title,, R, 1,, NA %options%
        Case Mouse.M: ControlClick, x%x% y%y%, % this.window.title,, M, 1,, NA %options%
        Case Mouse.MU: ControlClick, x%x% y%y%, % this.window.title,, WU, 1,, NA %options%
        Case Mouse.MD: ControlClick, x%x% y%y%, % this.window.title,, WD, 1,, NA %options%
        Default: ControlClick, x%x% y%y%, % this.window.title,, %button%, 1,, NA %options%
        }
    }

    __getCoor(ByRef x, ByRef y, relative := false)
    {
        if (relative)
        {
            CoordMode, Mouse, Relative
            id := this.window.id
            MouseGetPos, x, y, %id%
        }
        else
        {
            CoordMode, Mouse, Screen
            MouseGetPos, x, y
        }
    }
}