using VehicleRoutingProblems
using Test

@testset "VehicleRoutingProblems.jl" begin
    # Write your tests here.
    vehicle = read_solution(joinpath(@__DIR__, "..", "particle_swarm", "total_distance", "case16", "c101", "15", "1", "c101-1.txt"), "c101")
    @test total_distance(vehicle, floor_digit=true) == 827.3
end
