export Spectrum, AlphaSpectrum
export AlphaSpectrum
export example_alpha_spectrum, to_histogram

abstract type Spectrum end

find_peak(s::Spectrum) = []
slice(s::Spectrum) = Spectrum()
to_histogram(s::Spectrum) = nothing

@static if @isdefined(DEBUG) || @isdefined(TEST) ALPHA_SPECTRUM_TEST_FILE = "Alpha2.csv" end

"""spectrum from a solid state sensor"""
struct AlphaSpectrum <: Spectrum
    channels::Vector{Int}
    energies::Vector{Float64}
    numchannels::Int32

    "constructor for default AlphaSpectrum"
    function AlphaSpectrum()
        chs = zeros(Int32,1024)
        e = zeros(1024)
        numchs = 512
        new(chs,e,512)
    end

    "alpha spectrum from a DataFrameRow instance"
    function AlphaSpectrum(row::DataFrameRow)
        numcolumns = length(row)
        # @show numcolumns
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
# return array of alpha spectra
"""read and return an array of alpha spectra from a CSV file"""
function read_alpha_spectrum_file(file)
    frame = CSV.File(file; header=false) |> DataFrame
    num_rows = nrow(frame)
    ret_alpha_spects = [AlphaSpectrum(frame[i,:]) for i in 1:num_rows]
    return ret_alpha_spects
end

function to_histogram(as::AlphaSpectrum)
    len = as.numchannels;
    edges = collect(1:len+1)
    return hist = StatsBase.Histogram(edges,as.channels)
end

function example_alpha_spectrum()
    asdatafile = joinpath(DetectAlpha.TEST_DATA_FOLDER,ALPHA_SPECTRUM_TEST_FILE)
    return read_alpha_spectrum_file(asdatafile)
end

