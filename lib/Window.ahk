class Window
{
    x := 0, y := 0, _x := 0, _y := 0, w := 0, h := 0
    __New(title := "", dir := "", id := 0)
    {
        this.__readVariables(title, dir)
        if id
            title := this.__getTitleById(id)
        this.title := title
        this.dir := dir
        this.id := id
        Window.ico()
    }

    __getTitleById(id)
    {
        WinGetTitle, titleComplete, ahk_id %id%
        return isEmpty(titleComplete) ? "" : titleComplete
    }

    __readVariables(ByRef title, ByRef dir)
    {
        if isEmpty(title)
            title := new Var("window", "title").get()
        if new Var("window", "completeTitle").get()
            title := this.__completeTitle(title)
        if isEmpty(dir)
            dir := new Var("window", "dir").get()
    }

    __completeTitle(title)
    {
        WinGetTitle, titleComplete, %title%
        return isEmpty(titleComplete) ? title : titleComplete
    }

    isExecute()
    {
        IfWinNotExist, % this.title
            return false
        return true
    }

    execute(parameters := "")
    {
        dir := this.dir
        Run %dir% %parameters%
    }

    wait(sec := 1)
    {
        WinWait, % this.title,, %sec%
        return !ErrorLevel
    }

    activate() {
        WinActivate, % this.title
    }

    update()
    {
        WinGet, id, id, % this.title
        WinGetPos, x, y, w, h, % this.title
        this.id := id
        this.x := x, this.y := y
        this._x := x + w, this._y := y + h
        this.h := h, this.w := w
    }

    isFullScreen()
    {
        WinGet style, Style, % this.id
        Return ((style & 0x20800000) or this.h < A_ScreenHeight or this.w < A_ScreenWidth) ? false : true
    }

    move(x, y, h, w)
    {
        x := x
        y := y
        _x := w
        _y := h
        WinMove, % this.title,, x, y, _x, _y
        this.update()
    }

    comprobateCoorLimit(ByRef _x, ByRef _y)
    {
        if (isEmpty(_x) || _x > this.w)
            _x := this.w
        if (isEmpty(_y) || _y > this.h)
            _y := this.h
    }

    ico()
    {
        IfExist % Image.FOLDER . "icon.ico"
            Menu Tray, Icon, % Image.FOLDER . "icon.ico"
    }
}
