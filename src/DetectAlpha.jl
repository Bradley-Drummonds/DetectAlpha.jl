module DetectAlpha
export find_peak,find_peaks,alphamodel

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
function find_peak(iso::Isotope,as::AlphaSpectrum)
end

"""
detect peaks in a alpha spectrum
"""
function find_peaks(as::AlphaSpectrum,model = alphamodel,params = [256.0,15.0,4.2,10000.0])
    println("find an alpha peak in spectrum ",as)
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
