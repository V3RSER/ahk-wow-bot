class Control
{
    __New(window, background := "")
    {
        this.window := window
        this.mouse := new Mouse(this.window, background)
        this.keyboard := new Keyboard(this.window)
    }

    sendClick(button := "", x := 0, y := 0, exactCoor := false, vectorMinRandomCoor := "", vectorMaxRandomCoor := "")
    {
        this.window.update()
        if !exactCoor
            this.__getRandomCoor(x, y, vectorMinRandomCoor, vectorMaxRandomCoor)
        if isEmpty(button)
            button := Mouse.I
        this.mouse.use(button, Floor(x), Floor(y))
    }

    sendKey(key, raw := false)
    {
        this.keyboard.use(key, raw)
    }

    moveMouse(x := 0, y := 0, speed := 0, relative := false, exactCoor := false, vectorMinRandomCoor := "", vectorMaxRandomCoor := "")
    {
        relative := relative ? "R" : ""
        if !exactCoor
            this.__getRandomCoor(x, y, vectorMinRandomCoor, vectorMaxRandomCoor)
        this.mouse.move(x, y, speed, relative)
    }

    __getRandomCoor(ByRef x, ByRef y, ByRef vectorMinRandomCoor, ByRef vectorMaxRandomCoor)
    {
        if isEmpty(vectorMinRandomCoor)
            vectorMinRandomCoor := [-5, 5]
        if isEmpty(vectorMaxRandomCoor)
            vectorMaxRandomCoor := [-5, 5]
        x := x + rand(vectorMinRandomCoor[1], vectorMinRandomCoor[2])
        y := y + rand(vectorMaxRandomCoor[1], vectorMaxRandomCoor[2])
    }
}