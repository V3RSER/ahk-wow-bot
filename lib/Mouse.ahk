class Mouse
{
    Static I := "LEFT"
    Static D := "RIGHT"
    Static M := "MIDDLE"
    Static MU := "MIDDLE_UP"
    Static MD := "MIDDLE_DOWN"

    __New(window, background := "")
    {
        if (background == "")
            this.__readVariables(background)
        this.window := window
        this.background := background
    }

    __readVariables(ByRef background){
        IniRead, background, settings.ini, mouse, background
    }

    use(button, x, y)
    {
        log.debug("Mouse: [" . button . "]", "(" . x . ", " . y . ") -", this.background ? "back" : "fore")
        if this.background
            return this.modeBackground(button, x, y)
        this.modeForeground(button, x, y)
    }

    move(x, y, speed := 30, relative := false)
    {
        MouseMove, %x%, %y%, %speed%, %relative%
    }

    modeForeground(button, x, y, speed := 100, options := "")
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