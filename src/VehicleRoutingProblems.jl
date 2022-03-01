module VehicleRoutingProblems

using Glob, Printf, Combinatorics, JSON, TimerOutputs, Dates, PrettyTables, DelimitedFiles, CSV, VegaLite, DataFrames, Statistics, Plots, Clustering, Random

# include files
include("read_file.jl")
include("heuristic.jl")
include("benchmark.jl")
include("run_benchmark.jl")
include("ParticleSwarm.jl")

export read_txt, load_all_data, read_txt3

end
