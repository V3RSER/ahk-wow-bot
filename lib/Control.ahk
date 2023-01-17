class Control
{
    vectorRandomCoor := [-5, 5]
    __New(window, randomCoor := true, background := true)
    {
        this.window := window
        this.randomCoor := randomCoor
        if background
            this.foreground := new Control(window, randomCoor, false)
        this.mouse := new Mouse(this.window, background)
        this.keyboard := new Keyboard(this.window)
    }

    sendClick(button := "", x := 0, y := 0)
    {
        this.window.update()
        if this.randomCoor
            this.__getRandomCoor(x, y)
        if isEmpty(button)
            button := Mouse.I
        this.mouse.use(button, Floor(x), Floor(y))
    }

    sendKey(key, raw := false) {
        this.keyboard.use(key, raw)
    }

    moveMouse(x := 0, y := 0, speed := 0, relative := false)
    {
        relative := relative ? "R" : ""
        if this.randomCoor
            this.__getRandomCoor(x, y)
        this.mouse.move(x, y, speed, relative)
    }

    __getRandomCoor(ByRef x, ByRef y)
    {
        x := x + rand(this.vectorRandomCoor[1], this.vectorRandomCoor[2])
        y := y + rand(this.vectorRandomCoor[1], this.vectorRandomCoor[2])
    }
}