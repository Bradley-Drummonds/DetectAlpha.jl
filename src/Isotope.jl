

export Radiation, Elements, Isotope, U238DecaySeries

@enum DecayType α β γ n
# Write your package code here.
struct Radiation
    type::DecayType
    energy::Float32
    Radiation() = new(α,6.5)
end

struct Elements
    file
    Elements() = new(CSV.File("../Elements.csv"))
end
get_iso_row(z::Int,elems::Elements) = elems.file[elems.file.AtomicNumber .== z,:]
get_iso_row(z::Int) = get_iso_row(z,Elements())
get_iso_row(symbol::String,elems::Elements) = elems.file[elems.file.Symbol .== symbol,:] 

struct Isotope
    Z
    A
    symbol::String
    name::String
    radioactive::Bool
    Isotope() = new(94,239,"Plutonium","Pu",true)
    function Isotope(z::Int,a::Int) 
        isoRow = get_iso_row(z)
        result = first(isoRow)
        # @show result
        sym = result.Symbol
        nme = result.Element
        wkStr = result.Radioactive
        if wkStr !== nothing && wkStr !== missing
            active = parsebool(String(wkStr))
        else
            active = false
        end
        a = result.AtomicMass
        new(z,a,sym,nme,active)
    end
    function Isotope(z::Int)
        isoRow = get_iso_row(z)
        result = first(isoRow)
        sym = result.Symbol
        nme = result.Element
        wkStr = result.Radioactive
        if wkStr !== nothing 
            active = parsebool(String(wkStr))
        end
        a = result.AtomicMass
        new(z,a,sym,nme,active)
    end
end
function decay!(iso::Isotope,radType::DecayType)
    if radType == α
        newIso = Isotope(iso.Z-2,iso.A-4)
    elseif radType == β
        newIso = Isotope(iso.Z+1,iso.A)
    elseif radType == n
        newIso = Isotope(iso.Z,iso.A-1)
    else
        newIso = Isotope(iso.Z,iso.A)
    end
    return newIso
end
U238 = Isotope(92,238)
Po218 = Isotope(84,218)
Po214 = Isotope(84,214)
Pb214 = Isotope(82,214)
Pb210 = Isotope(82,210)

Base.isequal(iso1::Isotope,iso2::Isotope) = iso1.Z == iso2.Z && iso1.A && iso2.A

function get_alpha_spectrum_density(iso::Isotope)::AlphaSpectrumDensity{Float64}
    return AlphaSpectrumDensity{Float64}()
end

DaughterType = NamedTuple{(:ratio,:decay_type,:disotope),
                        Tuple{Float64,DecayType,Isotope}}
struct Decay
    parent::Isotope
    daughters::Vector{DaughterType}
end
u238Daughters = DaughterType[(ratio = 1.0,decay_type = α,disotope = Pb214),
    (ratio = 1.0,decay_type = α,disotope = Pb210)]
U238Decay = Decay(U238,u238Daughters)

struct DecaySeries
    parent::Decay
end

U238DecaySeries = DecaySeries(U238Decay)
Base.length(ds::DecaySeries) = length(ds.parent.daughters)

