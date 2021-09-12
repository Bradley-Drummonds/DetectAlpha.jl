module DetectAlpha

using CSV

export Radiation 

@enum DecayType α β γ n
# Write your package code here.
struct Radiation
    type::DecayType
    energy::Float32
    Radiation() = new(α,6.5)
end

elementsFile = CSV.File("/home/b/Data/Elements.csv")

struct Isotope
    Z
    A
    symbol::String
    Isotope() = (Z = 92;A=238;symbol = "Pu")
    function Isotope(z::Int,a::Int) 
        isoRow = elementsDf[elementsDf.AtomicNumber .== z,:]
        sym = first(isoRow).Symbol
        new(z,a,sym)
    end
end
end
