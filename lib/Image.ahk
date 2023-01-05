class Image
{
    static FOLDER := A_ScriptDir "\images\"
    static EXTENSION := ".png"
    bitmap := "", dir := ""
    __New(window := "", name := "")
    {
        this.__readVariables(background)
        this.window := window
        this.name := name
        this.background := background
    }

    __readVariables(ByRef background) {
        IniRead, background, settings.ini, capture, background
    }

    getFromFile()
    {
        name := this.getNameByResolution()
        this.dir := Image.FOLDER name Image.EXTENSION
        this.bitmap := Gdip_CreateBitmapFromFile(this.dir)
        return this.bitmap <= 0 ? false : true
    }

    getFromWindow()
    {
        if this.background
            return this.getFromWindowBackground()
        this.getFromWindowForeground()
    }

    getFromWindowForeground()
    {
        this.window.activate()
        this.bitmap := Gdip_BitmapFromScreen(this.window.x "|" this.window.y "|" this.window.w "|" this.window.h)
    }

    getFromWindowBackground() {
        this.bitmap := Gdip_BitmapFromHWND(this.window.id)
    }

    cut(x, y, _x := "", _y := "")
    {
        this.comprobateCoorLimit(_x, _y)
        this.bitmap := Gdip_CropBitmap(this.bitmap, x, _x, y, _y)
    }

    comprobateCoorLimit(ByRef _x, ByRef _y)
    {
        w := Gdip_GetImageWidth(this.bitmap), h := Gdip_GetImageHeight(this.bitmap)
        if (isEmpty(_x) || _x > w)
            _x := w
        if (isEmpty(_y) || _y > h)
            _y := h
    }

    editFromWindowByCoor(x := 0, y := 0, _x := "", _y := "")
    {
        this.saveFromWindowByCoor(x, y, _x, _y)
        this.edit()
    }

    editFromFileByCoor(x := 0, y := 0, _x := "", _y := "")
    {
        this.saveFromFileByCoor(x, y, _x, _y)
        this.edit()
    }

    edit()
    {
        dir := this.dir
        Run, MsPaint.exe %dir%
    }

    save(bitmap := "")
    {
        bitmap := isEmpty(bitmap) ? this.bitmap : bitmap
        name := this.getNameByResolution()
        this.dir := Image.FOLDER name Image.EXTENSION
        result := Gdip_SaveBitmapToFile(bitmap, this.dir, 100)
        log.info("Guardado: " result)
    }

    saveFromWindowByCoor(x := 0, y := 0, _x := "", _y := "")
    {
        this.getFromWindow()
        this.cut(x, y, _x, _y)
        this.save()
    }

    saveFromFileByCoor(x := 0, y := 0, _x := "", _y := "")
    {
        this.getFromFile()
        this.cut(x, y, _x, _y)
        this.save()
    }

    getNameByResolution() {
        return this.name "_" this.window.w "x" this.window.h
    }

    __interfaceNotExistImage(x, y, _x, _y)
    {
        name := this.name
        extension := Image.EXTENSION
        name := name extension
        MsgBox, 16, %name%, No se encuentra el archivo %name%`nDebe crearlo manualmente
        IfMsgBox Ok
        {
            this.editFromWindowByCoor(x, y, _x, _y)
            msgYes := true
            while(msgYes)
            {
                MsgBox, 4, %name%.png, ¿Quiere capturar de nuevo la imagen %name%?
                IfMsgBox Yes
                {
                    this.editFromWindowByCoor(x, y, _x, _y)
                    msgYes := true
                }
                else
                {
                    msgYes := false
                }
            }
        }
    }

    dispose() {
        Gdip_DisposeImage(this.bitmap)
        this.bitmap := 0
    }
}