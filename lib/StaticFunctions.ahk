isEmpty(var) {
    return !var || var == "" ? true : false
}

rand(min, max)
{
    Random, rand, %min%, %max%
    return rand
}

sleep(min, max := 0)
{
    ms := max == 0 ? min : rand(min, max)
    Sleep, % Round(ms)
    return ms
}

class Var{
    __New(section, name)
    {
        this.section := section
        this.name := name
    }

    get()
    {
        IniRead, value, settings.ini, % this.section, % this.name
        return value
    }

    set(value)
    {
        IniWrite, %value%, settings.ini, % this.section, % this.name
    }
}