export parsebool
export between2and8
export middle_value
parsebool(s::String) = lowercase(s) == "yes" ? true : false
between2and8(x) = 2 < x < 8

middle_value(sr::StepRange) = length(sr) / 2 + sr.start > 1 ? (sr.start - 1) : 0
