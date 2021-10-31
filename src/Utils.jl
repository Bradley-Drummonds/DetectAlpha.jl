export parsebool
export between2and8
parsebool(s::String) = lowercase(s) == "yes" ? true : false
between2and8(x) = 2 < x < 8