using VehicleRoutingProblems
using Test

@testset "VehicleRoutingProblems.jl" begin
    # Write your tests here.
    println(pwd())
    vehicle = read_txt3(joinpath(@__DIR__, "..", "particle_swarm", "total_distance", "case16", "c101", "15", "1", "c101-1.txt"), "c101")
    @test floor(vehicle["TotalDistance"], digits=2) == 828.93
end
