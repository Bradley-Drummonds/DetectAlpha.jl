

export Radiation, Elements, Isotope, U238DecaySeries,DecayType, α, β, γ, n, Pb214, U238,
    U238Decay, Pb210

@enum DecayType α β γ n
# Write your package code here.
struct Radiation
    type::DecayType
    energy::Float32
    Radiation() = new(α,6.5)
end

struct Elements
    file
    Elements() = new(CSV.File(parent(cwd()) / "Elements.csv"))
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
Base.isequal(dt1::DaughterType,dt2::DaughterType) = dt1.ratio == dt2.ratio && dt1.decay_type == dt2.decay_type && dt1.disotope == dt2.disotope

u238Daughters = DaughterType[(ratio = 1.0,decay_type = α,disotope = Pb214),
    (ratio = 1.0,decay_type = α,disotope = Pb210)]
U238Decay = Decay(U238,u238Daughters)
Base.iterate(d::Decay) = iterate(d.daughters)
Base.iterate(d::Decay,state) = iterate(d.daughters,state)
Base.length(d::Decay) = length(d.daughters)
Base.collect(d::Decay) = collect(d.daughters)

struct DecaySeries
    parent::Decay
end

U238DecaySeries = DecaySeries(U238Decay)
Base.collect(ds::DecaySeries) = collect([decay for decay in ds.parent])
Base.length(ds::DecaySeries) = length([decay for decay in ds.parent])
Base.iterate(ds::DecaySeries) = iterate([decay for decay in ds.parent])
Base.iterate(ds::DecaySeries,state) = iterate([decay for decay in ds.parent],state)