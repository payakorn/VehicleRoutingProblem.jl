module VehicleRoutingProblems

using Glob, Printf, Combinatorics, JSON, TimerOutputs, Dates, PrettyTables, DelimitedFiles, CSV, VegaLite, DataFrames, Statistics, Plots, Clustering, Random, JLD2, JuMP, DrWatson, SMTPClient

# include files
include("read_file.jl")
include("heuristic.jl")
include("benchmark.jl")
include("run_benchmark.jl")
include("ParticleSwarm.jl")
include("ParticleSwarm2.jl")
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
        run_simulation_opt,
        read_data_solomon,
        save_data,
        read_and_save_solomon,
        generate_one_initial_particle,
        generate_one_particle,
        generate_particles,
        generate_initial_particles,
        location_particle_swarm,
        location_particle_swarm_initial,
        load_particle_from_file,
        total_route,
        particle_swarm_fix2,
        run_case2,
        obj_email_text,
        generate_run_name,
        two_opt,
        local_search,
        move,
        swap,
        two_opt_list,
        two_opt_list2,
        sort_processing_matrix,
        create_csv_solomon_25_50,
        location_opt_solomon,
        add_our_best_to_dataframe_25_50
end
