

set_of_simulations = Dict()

set_of_simulations[1] = Dict(
    "n" => [25], # it is inside vector. It is expanded.
    "num_vehicle" => [8],
    "file_name" => ["r101"],     # single element inside vector; no expansion
)
set_of_simulations[2] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 7,
    "file_name" => "r102",     # single element inside vector; no expansion
)
set_of_simulations[3] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 5,
    "file_name" => "r103",     # single element inside vector; no expansion
)
set_of_simulations[4] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 4,
    "file_name" => "r104",     # single element inside vector; no expansion
)
set_of_simulations[5] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 6,
    "file_name" => "r105",     # single element inside vector; no expansion
)
set_of_simulations[6] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 3,
    "file_name" => "r106",     # single element inside vector; no expansion
)
set_of_simulations[7] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 4,
    "file_name" => "r107",     # single element inside vector; no expansion
)
set_of_simulations[8] = Dict(
    "n" => 25, # it is inside vector. It is expanded.
    "num_vehicle" => 4,
    "file_name" => "r108",     # single element inside vector; no expansion
)


# create set of simulations
dicts = dict_list(set_of_simulations[1])
# append others
append!(dicts, [set_of_simulations[i] for i in 2:8])


function makesim_opt(d::Dict)
    @unpack n, num_vehicle, file_name=d
    tx, Opt_value, Solve_time, Relative_gap, Solver_name, m = find_opt(file_name, n, num_vehicle)
    if JuMP.has_values(m)
        fulld = copy(d)
        fulld["text_route"] = tx
        fulld["opt_value"] = Opt_value
        fulld["solve_time"] = Solve_time
        # fulld["node_count"] = Node_count
        fulld["gap"] = Relative_gap
        fulld["solver"] = Solver_name
        return fulld
    else
        return nothing
    end
end


function run_simulation_opt()
    for (i, d) in enumerate(dicts)
        f = makesim_opt(d)
        if isnothing(f)
            nothing
        else
            safesave(datadir(joinpath("simulations", "opt_solomon"), savename(d, "jld2")), f)
        end
    end
end