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

@static if @isdefined(DEBUG) || @isdefined(TEST) TEST_DATA_FOLDER = "/home/b/Data/Spectra" end

struct Peak
    range
    channel
    function Peak()
        new(StepRange(typemin(Int32),Int32(1),typemax(Int32)),typemin(Int32))
    end
end

valid_peak(pk1::Peak) = pk1.channel != typemin(Int32) && 
    first(pk1.range) != typemin(Int32)

""" 
find a peak within a certain channel range of a AlphaSpectrum
"""
function find_peak(channelrange::StepRange,as::AlphaSpectrum)
    #get the channels from the range

    @show last(channelrange)
    @show length(as.channels)

    if last(channelrange) <= length(as.channels) #issubset(channels,as.channels)
        println("channelrange is within alpha spectrum channel arrays") 
        v = view(as.channels,channelrange)
        @show v

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

""" model function for an isotope """
function alphamodel(x,var)
    μ = var[1]
    σ = var[2]
    τ = var[3]
    A = var[4]
    amp = A / 2τ 
    oneOverSqrt2 = 1.0 / √2 
    sigScaledByTau  = σ / τ  
    return @.  amp * exp((x - μ ) / τ + (sigScaledByTau^2) ) * erfc( oneOverSqrt2 * ((x - μ ) / σ  +  sigScaledByTau ))
end
end #end module DetectAlpha
