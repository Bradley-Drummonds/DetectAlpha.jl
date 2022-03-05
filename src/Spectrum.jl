abstract type Spectrum end
find_peak(s::Spectrum) = []
slice(s::Spectrum) = Spectrum()

"alpha energy spectrum"
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
# return array of alpha spectra
"read and return an array of alpha spectra from a CSV file"
function read_alpha_spectrum_file(file)
    frame = CSV.File(file; header=false) |> DataFrame
    num_rows = nrow(frame)
    ret_alpha_spects = [AlphaSpectrum(frame[i,:]) for i in 1:num_rows]
    return ret_alpha_spects
end

"""
detect peaks in a alpha spectrum
"""
function find_peaks(as::AlphaSpectrum)
    println("find an alpha peak in spectrum ",as)
end