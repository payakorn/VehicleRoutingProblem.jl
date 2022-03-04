module VehicleRoutingProblems

using Glob, Printf, Combinatorics, JSON, TimerOutputs, Dates, PrettyTables, DelimitedFiles, CSV, VegaLite, DataFrames, Statistics, Plots, Clustering, Random, JLD2, JuMP, DrWatson, SMTPClient

# include files
include("read_file.jl")
include("heuristic.jl")
include("benchmark.jl")
include("run_benchmark.jl")
include("ParticleSwarm.jl")
include("Conclusions.jl")
include("compare.jl")
include("tabulation.jl")
include("Solution.jl")
include("run_project.jl")
# include("model.jl")
# include("model2.jl")


export load_all_data, 
        read_txt3, 
        Particle, 
        vehicle_to_particle, 
        particle_swarm_distance, 
        read_csv_to_dataframe, 
        dataframe_opt_solomon,
        dataframe_group_opt_solomon, 
        create_conclution_opt_solomon,
        Khoo,
        create_csv_min_all_distance,
        read_route,
        Solution,
        read_solution,
        seperate_route,
        total_distance,
        add_our_best_to_dataframe,
        run_simulation_opt
end
