using VehicleRoutingProblems
using Test

@testset "VehicleRoutingProblems.jl" begin
    # Write your tests here.
    @test 1 == 1
    @test VehicleRoutingProblems.total_route([0, 1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 0]) == 3
end
