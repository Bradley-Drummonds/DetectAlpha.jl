module DetectAlpha
export fit_peak_in_range,find_peaks,alphamodel,valid_peak,find_and_fit_peaks,
        AlphaSpectrumDensity

using CSV
using DataFrames
using RadiationSpectra
using StatsBase
using Plots
using Revise

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

struct AlphaSpectrumDensity{T} <: RadiationSpectra.AbstractSpectrumDensity{T,1}
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
function fit_peak_in_range(channelrange::StepRange,as::AlphaSpectrum)
    #get the channels from the range

    if last(channelrange) <= length(as.channels) #issubset(channels,as.channels)
        # println("channelrange is within alpha spectrum channel arrays") 
        # v = view(as.channels,channelrange)
        # @show v
        # set_initial_parameters!(fitfunc,( μ = 256.0, σ = 15.0, τ = 4.2, A = 10000.0))

        ashist = to_histogram(as)
        startenergy = as.energies[channelrange.start]
        endenergy = as.energies[channelrange.stop] 
        energyrange = (min = startenergy,max = endenergy)
        linenergyrange = to_energy_linearrange(channelrange,energyrange)
        RadiationSpectra.subhist(ashist,(linenergyrange.start,linenergyrange.stop))


        #need to figure out the low and high values of the parameters of the 
        #alpha model
        # lsqfit!(fitfunc, ashist)
        fit(AlphaSpectrumDensity,)
        return Peak() 
    else
        throw(BoundsError())
    end
end


"""
detect peaks in a alpha spectrum, using deconvolution
"""
function find_peaks(as::AlphaSpectrum)
    h_alpha = to_histogram(as)
    h_decon, peaks = RadiationSpectra.peakfinder(h_alpha; σ=9.0) #using spectrum deconvolution
    return peaks,h_alpha
end

function find_peak_ranges(peaks,h_alpha::Histogram)
    num_peaks = length(peaks)
    spect_extrema = [StatsBase.binindex(h_alpha,p) for p in peaks]

    prepend!(spect_extrema,1)
    append!(spect_extrema,length(h_alpha.edges[1]))

    peak_ranges = Vector{StepRange}(undef,num_peaks)
    range_index = 1
    
    @show spect_extrema
    min_ch_range = spect_extrema[1]
    min_ch_peak_range = min_ch_range
    min_channel = 1
    for i in eachindex(spect_extrema)
        if i == 1
            continue
        elseif i > 2 
            min_ch_peak_range = min_channel
        end

        max_ch_range = spect_extrema[i]
        range_min_max_tuple = (min_ch_range,max_ch_range)
        @show range_min_max_tuple
        h_alpha_sub = RadiationSpectra.subhist(h_alpha,range_min_max_tuple)

        min_counts,min_channel = findmin(h_alpha_sub.weights)
        last_min_count = findlast(ct->ct==min_counts,h_alpha_sub.weights)

        min_channel = last_min_count + min_ch_range
        @show last_min_count
        @show min_counts
        @show min_channel

        if i > 2 
            max_ch_peak_range = min_channel
            sr = StepRange(min_ch_peak_range,1,max_ch_peak_range)
            peak_ranges[range_index] = sr
            range_index = range_index + 1
        end

        min_ch_range = max_ch_range
    end
    return peak_ranges
end

function find_and_fit_peaks(m,as::AlphaSpectrum)
    peaks,h_alpha = find_peaks(as)
    strongest_peak_bin_idx = StatsBase.binindex(h_alpha,peaks[1])
    # @show strongest_peak_bin_idx
    strongest_peak_bin_width = StatsBase.binvolume(h_alpha,strongest_peak_bin_idx)
    # @show strongest_peak_bin_width
    strongest_peak_bin_amp = h_alpha.weights[strongest_peak_bin_idx]
    # @show strongest_peak_bin_amp

    peak_ranges = find_peak_ranges(sort(peaks),h_alpha)
    @show peak_ranges
    for peak_range in peak_ranges
        @show peak_range
        peak_tuple = (peak_range.start,peak_range.stop)
        peak_h_sub = RadiationSpectra.subhist(h_alpha,peak_tuple)
    end
    
    p0 = ()
    # fit(model,)
    # return peak_h_sub
end

end #end module DetectAlpha
