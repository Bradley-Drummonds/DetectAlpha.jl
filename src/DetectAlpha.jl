module DetectAlpha
export find_peak,find_peaks,alphamodel,valid_peak

using CSV
using DataFrames
using RadiationSpectra
using StatsBase
using Plots

TEST = true
DEBUG = true

include("Utils.jl")
include("Isotope.jl")
include("Spectrum.jl")
include("Models.jl")

@static if @isdefined(DEBUG) || @isdefined(TEST) TEST_DATA_FOLDER = "/home/b/Data/Spectra" end

struct Peak
    range
    channel
    μ
    σ 
    τ
    A
    function Peak()
        new(StepRange(typemin(Int32),Int32(1),typemax(Int32)),typemin(Int32))
    end
end

struct AlphaSpectrumDensity{T} <: RadiationSpectra.AbstractSpectrumDensity{T}
    μ::T
    σ::T
    τ::T
    A::T
    function AlphaSpectrumDensity(nt::NamedTuple{(:μ,:σ,:τ,:A)}) 
        T = promote_type(typeof.(values(nt)))
        new{T}(T(nt.μ),T(nt.σ),T(nt.τ),T(nt.A))
    end
end

function RadiationSpectra.evaluate(d::AlphaSpectrumDensity, x)
    amp = d.A / 2τ 
    oneOverSqrt2 = 1.0 / √2 
    sigScaledByTau  = d.σ / d.τ  
    return amp * exp((x - d.μ ) / d.τ + (sigScaledByTau^2) ) * 
        erfc( oneOverSqrt2 * ((x - d.μ ) / d.σ  +  sigScaledByTau ))
end


valid_peak(pk1::Peak) = pk1.channel != typemin(Int32) && 
    first(pk1.range) != typemin(Int32)

""" 
find a peak within a certain channel range of a AlphaSpectrum
"""
function find_peak(channelrange::StepRange,as::AlphaSpectrum)
    #get the channels from the range

    if last(channelrange) <= length(as.channels) #issubset(channels,as.channels)
        println("channelrange is within alpha spectrum channel arrays") 
        # v = view(as.channels,channelrange)
        # @show v
        # set_initial_parameters!(fitfunc,( μ = 256.0, σ = 15.0, τ = 4.2, A = 10000.0))

        ashist = to_histogram(as)
        startenergy = as.energies[channelrange.start]
        endenergy = as.energies[channelrange.stop] 
        energyrange = (min = startenergy,max = stopenergy)
        linenergyrange = to_energy_linearrange(channelrange,energyrange)
        RadiationSpectrn.subhist(ashist,linenergyrange)

        #need to figure out the low and high values of the parameters of the 
        #alpha model
        # lsqfit!(fitfunc, ashist)
        return Peak() 
    else
        throw(BoundsError())
    end
end


"""
detect peaks in a alpha spectrum
"""
function find_peaks(as::AlphaSpectrum,model = alphamodel,params = [256.0,15.0,4.2,10000.0])
    # println("find an alpha peak in spectrum ",as)
    #params = [256.0,15.0,4.2,10000.0]
end


end #end module DetectAlpha
