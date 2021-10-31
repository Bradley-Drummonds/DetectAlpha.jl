using DetectAlpha
using Test
include("../src/Utils.jl")

@testset "DetectAlpha.jl" begin
    # Write your tests here.
    @test π ≈ 3.14 atol=0.01
    @test parsebool("false") == false
    @test parsebool("yes") == true
end
