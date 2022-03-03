module VehicleRoutingProblems

using Glob, Printf, Combinatorics, JSON, TimerOutputs, Dates, PrettyTables, DelimitedFiles, CSV, VegaLite, DataFrames, Statistics, Plots, Clustering, Random, JLD2

# include files
include("read_file.jl")
include("heuristic.jl")
include("benchmark.jl")
include("run_benchmark.jl")
include("ParticleSwarm.jl")
include("Conclusions.jl")
include("compare.jl")
include("tabulation.jl")

export load_all_data, read_txt3, Particle, vehicle_to_particle, particle_swarm_distance, read_csv_to_dataframe, tabulation_group_opt_solomon, create_conclution_opt_solomon

end
