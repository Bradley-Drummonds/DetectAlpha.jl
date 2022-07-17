using DetectAlpha
using Test
using Revise
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
    alphaspectra = DetectAlpha.example_alpha_spectrum()   
    @test length(alphaspectra) >= 1
    spectrum = first(alphaspectra)
    hs = DetectAlpha.to_histogram(spectrum)
    @test hs !== nothing

    @test_throws BoundsError fit_peak_in_range(StepRange(1,1,5128),spectrum)

    @test !valid_peak(fit_peak_in_range(StepRange(Int32(1),Int32(1),Int32(128)),spectrum)) 
end