using DetectAlpha
using Test
include("../src/Utils.jl")

@testset "DetectAlpha.jl" begin
    # Write your tests here.
    @test π ≈ 3.14 atol=0.01
end

@testset "Utils.jl" begin
    @test parsebool("false") == false
    @test parsebool("yes") == true
    @test between2and8(5) == true
    @test between2and8(9) == false
    @test between2and8(5//2) == true
    @test between2and8(4//2) == false
end