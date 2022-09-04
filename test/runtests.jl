using DetectAlpha
using Test
using Revise
using Plots
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

    # for spectrum in spectra
    #     find_peaks(spectrum)
    # # e
    peaks,h_alpha = DetectAlpha.find_peaks(alphaspectrum)
    @test length(peaks) > 0
    @show peaks 
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
    alphaspectrum = DetectAlpha.example_alpha_spectrum()   
    hs = DetectAlpha.to_histogram(alphaspectrum)
    @test hs !== nothing
    # @show hs
    # @test_throws BoundsError fit_peak_in_range(StepRange(1,1,5128),alphaspectrum)

    # @test !valid_peak(fit_peak_in_range(StepRange(Int32(1),Int32(1),Int32(128)),alphaspectrum)) 
    p0s = AlphaSpectrumDensity{Float64}[]
    h_strongest = find_and_fit_peaks(AlphaSpectrumDensity,alphaspectrum,p0s)
    @test h_strongest !== nothing
    # plot(h_strongest,st=:step,size=(800,400))
end

@testset "DecaySeries" begin
    @test length(U238DecaySeries) == 2

    @testset "test U238 decay series" begin
        next = iterate(U238DecaySeries)
        @test next !== nothing 
        pb214Decay = (ratio = 1.0,decay_type = α,disotope = Pb214)
        (next_decay,state) = next
        @test next_decay == pb214Decay
    end
end
