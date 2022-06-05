using DetectAlpha
using Test
include("../src/Utils.jl")

@testset "DetectAlpha.jl" begin
    # Write your tests here.
    @test π ≈ 3.14 atol=0.01
    elemens = Elements()
    plutrow = DetectAlpha.get_iso_row(94,elemens) 
    @test plutrow !== nothing

    spectra = DetectAlpha.read_alpha_spectrum_file("../Alpha2.csv")
    @test spectra !== nothing

    alphaspectrum = first(spectra)
    @test alphaspectrum.numchannels == 512

    for spectrum in spectra
        find_peaks(spectrum)
    end
    
end

@testset "Utils.jl" begin
    @test parsebool("false") == false
    @test parsebool("yes") == true
    @test between2and8(5) == true
    @test between2and8(9) == false
    @test between2and8(5//2) == true
    @test between2and8(4//2) == false
end

@testset "AlphaSpectrum" begin
    as = AlphaSpectrum.example_alpha_spectrum()   
    @test as !== nothing
    hs = AlphaSpectrum.to_histogram(as)
    @test hs !== nothing
end