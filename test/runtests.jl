using VehicleRoutingProblems
using Test

@testset "VehicleRoutingProblems.jl" begin
    # Write your tests here.
    @test total_route([0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]) == 3
end
