module DetectAlpha
export fit_peak_in_range,find_peaks,alphamodel,valid_peak,find_and_fit_peaks,
        AlphaSpectrumDensity

using CSV
using DataFrames
using RadiationSpectra
using StatsBase
using Plots
using Revise
using Statistics
using SpecialFunctions

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

struct AlphaSpectrumDensity{T} <: RadiationSpectra.UvSpectrumDensity{T}
    μ::T
    σ::T
    τ::T
    A::T
end

function AlphaSpectrumDensity(nt::NamedTuple{(:μ,:σ,:τ,:A)}) 
    T = promote_type(typeof.(values(nt))...)
    AlphaSpectrumDensity(T(nt.μ),T(nt.σ),T(nt.τ),T(nt.A))
end

function get_variable_limits(varnam::Symbol)::NamedTuple{(:min,:max), Tuple{Float64,Float64}}
    if varnam == :μ
        return (min = 0.0,max = Float64(DetectAlpha.get_num_channels()))
    elseif varnam == :σ
        return (min = 0.2, max = 10000.0)
    elseif varnam == :τ
        return (min = 1.0, max = 10000.0)
    elseif varnam == :A
        return (min = 0.1, max = typemax(Float64))
    end
end

lower_bounds() = NamedTuple{(:μ,:σ,:τ,:A)}(Tuple(get_variable_limits(sym).min for sym in [:μ :σ :τ :A])) 
upper_bounds() = NamedTuple{(:μ,:σ,:τ,:A)}(Tuple(get_variable_limits(sym).max for sym in [:μ :σ :τ :A]))

function RadiationSpectra.evaluate(d::AlphaSpectrumDensity, x)
    amp = d.A / (2 * d.τ )
    oneOverSqrt2 = 1.0 / √2 
    sigScaledByTau  = d.σ / d.τ  
    return amp * exp((x - d.μ ) / d.τ + (sigScaledByTau^2) ) * 
        erfc( oneOverSqrt2 * ((x - d.μ ) / d.σ  +  sigScaledByTau ))
end


valid_peak(pk1::Peak) = pk1.channel != typemin(Int32) && 
    first(pk1.range) != typemin(Int32)

""" 
fit a peak within a sub historgram and starting coefs 
"""
function fit_peak_in_range(peakHist::Histogram,startcoefs)
        #need to figure out the low and high values of the parameters of the 
        #alpha model
        # lb = lower_bounds()
        edges = peakHist.edges
        startEdge = edges[1]; lastEdge = edges[end];
        @show startEdge[1]
        @show lastEdge
        lb = (μ = startEdge[1],σ = 0.2,τ = 1.0,A = 0.1)
        @show lb
        ub = (μ = startEdge[end], σ = 1000.0,τ = 1000.0, A = 10000000000.0)
        # ub = upper_bounds()
        @show ub
        p0 = startcoefs
        @show p0
        fitted_dens, backend_result = fit(AlphaSpectrumDensity,peakHist,p0,lb,ub)
        @show fitted_dens
        @show backend_result
        return Peak() 
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
        # @show last_min_count
        # @show min_counts
        # @show min_channel

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
    @show peaks
    strongest_peak_bin_idx = StatsBase.binindex(h_alpha,peaks[1])
    @show strongest_peak_bin_idx
    strongest_peak_bin_width = StatsBase.binvolume(h_alpha,strongest_peak_bin_idx)
    @show strongest_peak_bin_width
    strongest_peak_bin_amp = h_alpha.weights[strongest_peak_bin_idx]
    @show strongest_peak_bin_amp

    peak_ranges = find_peak_ranges(sort(peaks),h_alpha)
    @show peak_ranges
    for (p0_ch,peak_range) in zip(sort(peaks),peak_ranges)
        @show peak_range
        @show p0_ch
        peak_tuple = (peak_range.start,peak_range.stop)
        peak_h_sub = RadiationSpectra.subhist(h_alpha,peak_tuple)
        # @show peak_h_sub
        # μ_start = round(Float64,middle_value(peak_range))
        # μ_start = median(peak_range)
        peakIndex = StatsBase.binindex(peak_h_sub,p0_ch)
        probableAmp = peak_h_sub.weights[peakIndex] * 3000
        @show probableAmp
        fit_peak_in_range(peak_h_sub,(μ = p0_ch,σ = 4.25, τ = 70.0,A = probableAmp))
    end
    
end

end #end module DetectAlpha
