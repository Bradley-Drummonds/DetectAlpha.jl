module DetectAlpha

using CSV
using DataFrames
include("Utils.jl")

export Radiation, Elements, Isotope

@enum DecayType α β γ n
# Write your package code here.
struct Radiation
    type::DecayType
    energy::Float32
    Radiation() = new(α,6.5)
end

struct Elements
    file
    Elements() = new(CSV.File("/home/b/Data/Elements.csv"))
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
        sym = result.Symbol
        nme = result.Element
        wkStr = result.Radioactive
        if wkStr !== nothing 
            active = parsebool(String(wkStr))
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

abstract type Spectrum end
find_peak(s::Spectrum) = []
slice(s::Spectrum) = Spectrum()

struct AlphaSpectrum <: Spectrum
    channels::Vector{Int}
    energies::Vector{Float64}
    numchannels::Int32
    function AlphaSpectrum()
        chs = zeros(Int32,1024)
        e = zeros(1024)
        numchs = 512
        new(chs,e,512)
    end
    function AlphaSpectrum(row::DataFrameRow)
        numcolumns = length(row)
        @show numcolumns
        indexfirstch = 4
        numchs = numcolumns - indexfirstch + 1
        chs = [row[i] for i=indexfirstch:numcolumns]
        RANGE_MEV = 10_000_000; 
        b = convert(Float64,RANGE_MEV) / convert(Float64,numcolumns)
        es = [b * i for i=1:numcolumns-3]
        new(chs,es,numchs)
    end
end

# abstract type SpectrumSource end 
# get_spectra(source::SpectrumSource) = Vector{Spectrum}
# alphaDataFrame = CSV.File("/home/b/Data/Spectra/Alpha2.csv"; header=false) |> DataFrame
function read_alpha_spectrum_file(file)
    frame = CSV.File(file; header=false) |> DataFrame
    num_rows = nrow(frame)
    ret_alpha_spects = [AlphaSpectrum(frame[i,:]) for i in 1:num_rows]
    #Vector{AlphaSpectrum}(undef,num_rows)
    
    # for rows in eachrow(frame)
# 
    # end

    # ret_alpha_spects = collect(AlphaSpectrum, eachrow(frame))
    return ret_alpha_spects
end

end
