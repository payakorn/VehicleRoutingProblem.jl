using Glob, Printf, Combinatorics, JSON, TimerOutputs, Dates, PrettyTables, DelimitedFiles, CSV, VegaLite, DataFrames, Statistics, Plots, Clustering, Random


# include("heuristic.jl")
# include("benchmark.jl")
# include("run_benchmark.jl")
# include("ParticleSwarm.jl")

# phase_2 use when phase=5 and 6 
function read_txt(name::AbstractString; alg=nothing, phase=1, sort_function=nothing, type=nothing, phase_2=nothing, iteration=nothing, refresh=[false, false, false], given_dir=nothing, given_name=nothing)::Dict
    Alg = alg
    if refresh[1]
        run()
        cat_heuristic()
    elseif refresh[2]
        run_multiple_vehicle()
        cat_heuristic()
    elseif refresh[3]
        run_processingtime_multiple()
        cat_heuristic()
    end
    
    vehicle = Dict()
    
    if isnothing(given_dir)
        p, d, low_d, demand, solomon_demand = load_all_data(name)
        if phase == 1
            if Alg == 1 || Alg == 2 || Alg == 7 || Alg == 8
                dir = "heuristic_multiple"
            elseif Alg == 3 || Alg == 4
                dir = "multiple_vehicle"
            elseif Alg == 5 || Alg == 6
                dir = "processing_multi"
            elseif Alg == 9
                dir = "pair_multiple"
            elseif Alg >= 10
                if type == "multiple_diff"
                    dir = "multiple_diff"
                else
                    dir = "diff_multiple"
                end
            end

            file_location = "$(dir)/only_sch/Alg$(Alg)-$(name).txt"
            open(file_location) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == 2
            if isnothing(sort_function)
                dir = "phase2"
            else
                dir = "phase2/$(sort_function)"
            end

            if isnothing(iteration)
                file_location = save_to_txt(dir, need_save=false, alg=alg, phase=phase, phase_2=phase_2, type=type, name=name)
            else
                file_location = "$(dir)/Alg$(alg)-$(name)-iter$(iteration).txt"
            end
            open(file_location) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == 3
            # not complete
            dir = "phase2"
            g = glob("phase2/Alg$Alg-$name-iter*.txt")
            n = length(g)

            file_location = "$(dir)/Alg$Alg-$name-iter$n.txt"
            open(file_location) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == 4
            # not complete
            dir = "phase4"
            g = glob("phase4/Alg$Alg-$name-iter*.txt")
            n = length(g)

            file_location = "$(dir)/Alg$Alg-$name-iter$n.txt"
            open(file_location) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == 5
            # not complete
            if isnothing(sort_function)
                dir = "phase5"
            else
                dir = "phase5/$(sort_function)"
            end
            if typeof(phase_2) == Int
                if phase_2 == 1
                    dirr = "$(dir)/Alg$Alg-$name.txt"
                else
                    dirr = "$(dir)/Alg$Alg-$name-P-$(phase_2).txt"
                end
            else
                if iteration == 0
                    dirr = "phase5/$name-phase$(phase_2).txt"
                else
                    dirr = "phase5/$name-phase$(phase_2)-iter$(iteration).txt"
                end
            end

            file_location = dirr
            open(dirr) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == 6
            # not complete
            dir = "phase6"
            if typeof(phase_2) == Int
                if phase_2 == 1
                    dirr = "$(dir)/Alg$Alg-$name.txt"
                else
                    dirr = "$(dir)/Alg$Alg-$name-P-$(phase_2).txt"
                end
            else
                if iteration == 0
                    dirr = "phase6/$name-phase$(phase_2).txt"
                else
                    dirr = "phase6/$name-phase$(phase_2)-iter$(iteration).txt"
                end
            end

            file_location = dirr
            open(dirr) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == "clustering" || phase == "hclustering" || phase == "clustering-heuristic_diff" || phase == "clustering-heuristic"
            if isnothing(sort_function)
                dirr = phase
            else
                dirr = "phase$phase/$(sort_function)"
            end

            file_location = "$(dirr)/$(name).txt"
            open(file_location) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
            end
        elseif phase == "exact_solomon"
            vehicle = read_exact()
            return vehicle[name]
        elseif phase == "phase5_phase2" || phase == "phase2_phase5"
            if isnothing(sort_function)
                dirr = "$(phase)/Alg10-$(name).txt"
            else
                dirr = "$(phase)/$(sort_Function)/Alg10-$(name).txt"
            end
                

            file_location = dirr
            open(dirr) do file
                lines = eachline(file)
                for i in enumerate(lines)
                    vehicle[i[1]] = Dict()
                    vehicle[i[1]]["sch"] = split(i[2])
                end
            end
        end
    else
        name = given_name
        p, d, low_d, demand, solomon_demand = load_all_data(name)
        file_location = given_dir
        open(file_location) do file
            lines = eachline(file)
            for i in enumerate(lines)
                vehicle[i[1]] = Dict()
                vehicle[i[1]]["sch"] = split(i[2])
            end
        end
    end



    # convert text to Integer
    num_vehicle = length(keys(vehicle))
    for k in 1:num_vehicle
        if isempty(vehicle[k]["sch"]) == true
            delete!(vehicle, k)
            num_vehicle -= 1
        end
    end
    new_vehicle = Dict()
    for (index_i, index_j) in enumerate(keys(vehicle))
        new_vehicle[index_i] = vehicle[index_j]
    end
    vehicle = new_vehicle
    num_vehicle = length(keys(vehicle))
    for i in 1:num_vehicle
        current_sch = [parse(Int, j) for j in vehicle[i]["sch"]]
        vehicle[i]["sch"] = current_sch
        if isempty(current_sch) == false
            late, last_com = job_late(current_sch, p=p, d=d, low_d=low_d)
            starting, completion = StartingAndCompletion(current_sch, p, low_d)
            vehicle[i]["Late"] = late
            vehicle[i]["CompletionTime"] = completion
            vehicle[i]["StartingTime"] = starting
            vehicle[i]["DueDate"] = d[current_sch]
            vehicle[i]["ReleaseDate"] = low_d[current_sch]
            vehicle[i]["Distance"] = distance_solomon(current_sch, name)

            # calculate processing time
            processing_time = []
            # for iteration 1
            append!(processing_time, p[current_sch[1], current_sch[1]])
            for i in 2:length(current_sch)
                append!(processing_time, p[current_sch[i-1], current_sch[i]])
            end

            vehicle[i]["ProcessingTime"] = processing_time
        end
    end
    vehicle["num_vehicle"] = num_vehicle
    vehicle["name"] = name
    total_dis = sum([vehicle[i]["Distance"] for i in 1:num_vehicle])
    vehicle["TotalDistance"] = total_dis
    vehicle["dir"] = file_location
    return vehicle
end


function find_dir(name; alg=10, phase_2=nothing, phase_3=nothing, phase_3_iter=nothing, pre_dir=nothing, case_size=nothing, num=nothing)

    if name == "case_study"
        if isnothing(phase_2)
            dir = "case_study_solutions/casestudy$(case_size)-1_clustering.txt"
        elseif isnothing(phase_3)
            dir = "case_study_solutions/casestudy$(case_size)-1_clustering_$(phase_2).txt"
        else
            dir = "case_study_solutions/casestudy$(case_size)-1_clustering_$(phase_2)_$(phase_3).txt"
        end
    else
        if isnothing(pre_dir)
            if isnothing(phase_2)
                dir = "phase1/Alg-$(alg)/$(name).txt"
            elseif isnothing(phase_3)
                dir = "phase1/Alg-$(alg)/$(phase_2)/$(name).txt"
            else
                dir = "phase1/Alg-$(alg)/$(phase_2)/$(phase_3)/$(name)/$(name)-$(phase_3_iter).txt"
            end
        else
            if isnothing(phase_2)
                dir = "$(pre_dir)/phase1/Alg-$(alg)/$(name).txt"
            elseif isnothing(phase_3)
                dir = "$(pre_dir)/phase1/Alg-$(alg)/$(phase_2)/$(name).txt"
            else
                dir = "$(pre_dir)/phase1/Alg-$(alg)/$(phase_2)/$(phase_3)/$(name)/$(name)-$(phase_3_iter).txt"
            end
        end
    end

    return dir
end


function read_txt2(name; alg=10, phase_2=nothing, phase_3=nothing, dir=nothing, pre_dir=nothing, phase_3_iter=nothing)

    p, d, low_d, demand, solomon_demand = load_all_data(name)
    # if isnothing(dir)
        # file_location = find_dir(name, alg=alg, phase_2=phase_2, phase_3=phase_3, pre_dir=pre_dir, phase_3_iter=phase_3_iter)
    if pre_dir == "solutions_benchmark"
        file_location = "$pre_dir/$name.txt"
    else
        file_location = find_dir(name, alg=alg, phase_2=phase_2, phase_3=phase_3, pre_dir=pre_dir, phase_3_iter=phase_3_iter)
    end
        

    vehicle = Dict()
    open(file_location) do file
        lines = eachline(file)
        for i in enumerate(lines)
            vehicle[i[1]] = Dict()
            vehicle[i[1]]["sch"] = split(i[2])
        end
    end

    # convert text to Integer
    num_vehicle = length(keys(vehicle))
    for k in 1:num_vehicle
        if isempty(vehicle[k]["sch"]) == true
            delete!(vehicle, k)
            num_vehicle -= 1
        end
    end
    new_vehicle = Dict()
    for (index_i, index_j) in enumerate(keys(vehicle))
        new_vehicle[index_i] = vehicle[index_j]
    end
    vehicle = new_vehicle
    num_vehicle = length(keys(vehicle))
    for i in 1:num_vehicle
        current_sch = [parse(Int, j) for j in vehicle[i]["sch"]]
        vehicle[i]["sch"] = current_sch
        if isempty(current_sch) == false
            late, last_com = job_late(current_sch, p=p, d=d, low_d=low_d)
            starting, completion = StartingAndCompletion(current_sch, p, low_d)
            vehicle[i]["Late"] = late
            vehicle[i]["CompletionTime"] = completion
            vehicle[i]["StartingTime"] = starting
            vehicle[i]["DueDate"] = d[current_sch]
            vehicle[i]["ReleaseDate"] = low_d[current_sch]
            vehicle[i]["Distance"] = distance_solomon(current_sch, name)

            # calculate processing time
            processing_time = []
            # for iteration 1
            append!(processing_time, p[current_sch[1], current_sch[1]])
            for i in 2:length(current_sch)
                append!(processing_time, p[current_sch[i-1], current_sch[i]])
            end

            vehicle[i]["ProcessingTime"] = processing_time
        end
    end
    vehicle["num_vehicle"] = num_vehicle
    vehicle["name"] = name
    total_dis = sum([vehicle[i]["Distance"] for i in 1:num_vehicle])
    vehicle["TotalDistance"] = total_dis
    vehicle["dir"] = file_location
    return vehicle
end


function read_case_study(case_size::Int64, num::Int64; phase2_swap=false, phase2_iteration=nothing, distance_function=nothing, phase3=false)

    if isnothing(distance_function)
        if phase2_swap
            if isnothing(phase2_iteration)
                file_location = "case_study_solutions/casestudy$(case_size)-$(num)_clustering_swap.txt"
            else
                file_location = "case_study_solutions/phase2_all_iterations/casestudy$(case_size)-$(num)_clustering_swap-iter$(phase2_iteration).txt"
            end
        else
            file_location = "case_study_solutions/casestudy$(case_size)-$(num)_clustering.txt"
        end
    else
        if phase3
            file_location = "case_study_solutions/casestudy$(case_size)-$(num)_clustering_swap_random.txt"
        elseif phase2_swap
            if isnothing(phase2_iteration)
                file_location = "case_study_solutions/casestudy$(case_size)-$(num)-$(distance_function)_clustering_swap.txt"
            else
                file_location = "case_study_solutions/phase2_all_iterations/casestudy$(case_size)-$(num)-$(distance_function)_clustering_swap-iter$(phase2_iteration).txt"
            end
        else
            file_location = "case_study_solutions/casestudy$(case_size)-$(num)-$(distance_function)_clustering.txt"
        end
    end

    p, d, low_d, demand, service, distance_matrix, solomon_demand = load_all_data("case_study", case_size=case_size, num=num)
        

    vehicle = Dict()
    open(file_location) do file
        lines = eachline(file)
        for i in enumerate(lines)
            vehicle[i[1]] = Dict()
            vehicle[i[1]]["sch"] = split(i[2])
        end
    end

    # convert text to Integer
    num_vehicle = length(keys(vehicle))
    for k in 1:num_vehicle
        if isempty(vehicle[k]["sch"]) == true
            delete!(vehicle, k)
            num_vehicle -= 1
        end
    end
    new_vehicle = Dict()
    for (index_i, index_j) in enumerate(keys(vehicle))
        new_vehicle[index_i] = vehicle[index_j]
    end
    vehicle = new_vehicle
    num_vehicle = length(keys(vehicle))
    for i in 1:num_vehicle
        current_sch = [parse(Int, j) for j in vehicle[i]["sch"]]
        vehicle[i]["sch"] = current_sch
        if isempty(current_sch) == false
            late, last_com = job_late(current_sch, p=p, d=d, low_d=low_d)
            starting, completion = StartingAndCompletion(current_sch, p, low_d)
            vehicle[i]["Late"] = late
            vehicle[i]["CompletionTime"] = completion
            vehicle[i]["StartingTime"] = starting
            vehicle[i]["DueDate"] = d[current_sch]
            vehicle[i]["ReleaseDate"] = low_d[current_sch]
            # vehicle[i]["Distance"] = distance_solomon(current_sch, name)

            # calculate processing time
            processing_time = []
            # for iteration 1
            append!(processing_time, p[current_sch[1], current_sch[1]])
            for i in 2:length(current_sch)
                append!(processing_time, p[current_sch[i-1], current_sch[i]])
            end

            vehicle[i]["ProcessingTime"] = processing_time
        end
    end
    vehicle["num_vehicle"] = num_vehicle
    vehicle["name"] = "case_study"
    # total_dis = sum([vehicle[i]["Distance"] for i in 1:num_vehicle])
    # vehicle["TotalDistance"] = total_dis
    vehicle["dir"] = file_location
    vehicle["case_size"] = case_size
    vehicle["num"] = num
    return vehicle
end



function read_txt(dir::String, given_name::String)
    return read_txt("no-name", alg=0, given_dir=dir, given_name=given_name)
end


function read_txt_phase3(name::AbstractString, alg::Int)
    g = glob("phase2/Alg$alg-$name-iter*.txt")
    n = length(g)
    return "phase2/Alg$alg-$name-iter$n.txt"
end


function read_exact(;start_line=6)
    vehicle = Dict()
    dir = "exact_solomon"
    
    all_files = readdir(dir)
    
    
    for Names in all_files
        name = Names[1:end-4]
        p, d, low_d, demand, solomon_demand = load_all_data(name)
        vehicle[name] = Dict()
        open("$(dir)/$(Names)") do file
            lines = eachline(file)
            for i in enumerate(lines)
                if i[1] >= start_line
                    vehicle[name][i[1] - start_line + 1] = Dict()
                    vehicle[name][i[1] - start_line + 1]["sch"] = split(i[2])
                end
            end
        end


        # convert text to Integer
        num_vehicle = length(keys(vehicle[name]))
        for i in 1:num_vehicle
            current_sch = [parse(Int, j) for j in vehicle[name][i]["sch"][4:end]]
            vehicle[name][i]["sch"] = current_sch
            if isempty(current_sch) == false
                late, last_com = job_late(current_sch, p=p, d=d, low_d=low_d)
                starting, completion = StartingAndCompletion(current_sch, p, low_d)
                vehicle[name][i]["Late"] = late
                vehicle[name][i]["CompletionTime"] = completion
                vehicle[name][i]["StartingTime"] = starting
                vehicle[name][i]["DueDate"] = d[current_sch]
                vehicle[name][i]["ReleaseDate"] = low_d[current_sch]
                vehicle[name][i]["Distance"] = distance_solomon(current_sch, name)

                # calculate processing time
                processing_time = []
                # for iteration 1
                append!(processing_time, p[current_sch[1], current_sch[1]])
                for i in 2:length(current_sch)
                    append!(processing_time, p[current_sch[i-1], current_sch[i]])
                end

                vehicle[name][i]["ProcessingTime"] = processing_time
            end
        end
        for k in 1:num_vehicle
            if isempty(vehicle[name][k]["sch"]) == true
                delete!(vehicle, num_vehicle)
                num_vehicle -= 1
            end
        end
        vehicle[name]["num_vehicle"] = num_vehicle
        total_dis = distance_solomon_all(vehicle[name], name)
        vehicle[name]["TotalDistance"] = total_dis
    end
    return vehicle
end


function Check_all(name::AbstractString, alg, phase, phase_2)
    # load vehicle data
    vehicle = read_txt(name, alg=alg, phase=phase, phase_2=phase_2)
    # load solomon data
    solomon= load_all_solomon_100()
    service_solomon = solomon_capacity(name)
    xcoor = solomon[name]["xcoor"]
    ycoor = solomon[name]["ycoor"]
    num_vehicle = vehicle["num_vehicle"]
    dis = 0
    C = []
    println("Problem: $name")
    println("Vehicle Capacity: $service_solomon")
    println("Route: $num_vehicle")
    for i in 1:num_vehicle
        dis += EUdis(vehicle[i]["sch"], disp=false, xcoor=xcoor, ycoor=ycoor)
        c = Capacity(vehicle[i]["sch"], demand=solomon[name]["demand"], disp=false) 
        append!(C, c)
        println("vehicle $i, len: $(length(vehicle[i]["sch"])) total dis: $(@sprintf("%.2f", EUdis(vehicle[i]["sch"], disp=false, xcoor=xcoor, ycoor=ycoor))), total demand: $(c)")
    end
    println("Total dis: $(@sprintf("%.2f", dis))")
    println("Max Capac: $(maximum(C))")
end


function save_to_txt(dir::AbstractString; vehicle=Dict()::Dict, alg=nothing, phase=1, phase_2=nothing, type=nothing, need_save=true, name=nothing)

    # parameters
    if isnothing(name)
        name = vehicle["name"]
    end

    if phase == 1
        if isnothing(alg)
            if isnothing(phase_2) && isnothing(type)
                dirr = "$dir/$(name).txt"
            elseif isnothing(phase_2)
                dirr = "$dir/$(name)-M.txt"
            elseif isnothing(type)
                dirr = "$dir/$(name)-P$(phase)_$(phase_2).txt"
            else
                dirr = "$dir/$(name)-P$(phase)_$(phase_2)-M.txt"
            end
        else
            if isnothing(phase_2) && isnothing(type)
                dirr = "$dir/$(name)-Alg$(alg)P$(phase).txt"
            elseif isnothing(phase_2)
                dirr = "$dir/$(name)-Alg$(alg)P$(phase)-M.txt"
            elseif isnothing(type)
                dirr = "$dir/$(name)-Alg$(alg)P$(phase)_$(phase_2).txt"
            else
                dirr = "$dir/$(name)-Alg$(alg)P$(phase)_$(phase_2)-M.txt"
            end
        end
    else
        if isnothing(alg)
            if isnothing(phase_2) && isnothing(type)
                dirr = "$dir/$(name)-P$(phase).txt"
            elseif isnothing(phase_2)
                dirr = "$dir/$(name)-P$(phase)-M.txt"
            elseif isnothing(type)
                dirr = "$dir/$(name)-P$(phase)_$(phase_2).txt"
            else
                dirr = "$dir/$(name)-P$(phase)_$(phase_2)-M.txt"
            end
        else
            if isnothing(phase_2) && isnothing(type)
                dirr = "$dir/$(name)-Alg$(alg)P$(phase).txt"
            elseif isnothing(phase_2)
                dirr = "$dir/$(name)-Alg$(alg)P$(phase)-M.txt"
            elseif isnothing(type)
                dirr = "$dir/$(name)-Alg$(alg)P$(phase)_$(phase_2).txt"
            else
                dirr = "$dir/$(name)-Alg$(alg)P$(phase)_$(phase_2)-M.txt"
            end
        end
    end

    if need_save
        io = open(dirr, "w")
        for i in 1:vehicle["num_vehicle"]
            for j in vehicle[i]["sch"]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)
    else
        return dirr
    end
end


function save_to_txt(vehicle::Dict, dir::AbstractString, pre_dir=nothing)
    
    name = vehicle["name"]

    if isnothing(pre_dir)
        dirr = "$(dir)/$(name).txt"
    else
        dirr = "$(pre_dir)/$(dir)/$(name).txt"
    end
    
    io = open(dirr, "w")
    for i in 1:vehicle["num_vehicle"]
        for j in vehicle[i]["sch"]
            write(io, "$j ")
        end
        write(io, "\n")
    end
    close(io)

end


function save_to_txt(vehicle; alg=10, phase_2=nothing, phase_3=nothing, phase_3_iter=nothing, pre_dir=nothing)

    name = vehicle["name"]

    dirr = find_dir(name, alg=alg, phase_2=phase_2, phase_3=phase_3, pre_dir=pre_dir, phase_3_iter=phase_3_iter)

    io = open(dirr, "w")
    for i in 1:vehicle["num_vehicle"]
        for j in vehicle[i]["sch"]
            write(io, "$j ")
        end
        write(io, "\n")
    end
    close(io)

end


function fix_missing_vehicle(input_vehicle::Dict)
    new_vehicle = deepcopy(input_vehicle)
    # delete all route
    for i in 1:input_vehicle["num_vehicle"]
        delete!(new_vehicle, i)
    end

    num_v = 0
    for i in 1:input_vehicle["num_vehicle"]
        if isempty(input_vehicle[i]["sch"]) == false
            num_v += 1
            new_vehicle[num_v] = Dict()
            new_vehicle[num_v]["sch"] = input_vehicle[i]["sch"]
        end
    end
    new_vehicle["num_vehicle"] = num_v
    return new_vehicle
end


function make_dir()
    # this function run only no folder have been created (run only one time)
    fullname = glob_only_name("*.txt", "solutions_benchmark/")

    # all phase2 folders
    Folders = [
        "swap_all_no_update-sort_completion_time",
        "swap_all_no_update-sort_processing_matrix",
        "move_all_no_update-sort_completion_time",
        "move_all_no_update-sort_processing_matrix",
        "swap_all-sort_processing_matrix",
        "move_all-sort_processing_matrix",
        "swap_all-sort_completion_time",
        "move_all-sort_completion_time",
    ]

    for folder in Folders
        root = "phase1_completion_time/phase1/Alg-clustering-heuristic/$folder/random_swap_move/"
        println("create folder in: $root")
        try mkdir(root) catch e nothing end

        for name in fullname
            println("create folder name: $name")
            try mkdir("$root/$name") catch e nothing end
        end
    end
end


function import_case_study(case_size, num)
    location = "case_study_solutions"
    p = readdlm("case_study_solutions/save_data/p/p$(case_size)-$(num).csv", ',', Float64)
    d = readdlm("case_study_solutions/save_data/d/d$(case_size)-$(num).csv", ',', Float64)
    low_d = readdlm("case_study_solutions/save_data/low_d/low_d$(case_size)-$(num).csv", ',', Float64)
    distance_matrix = readdlm("case_study_solutions/save_data/distance_matrix/distance_matrix$(case_size)-$(num).csv", ',', Float64)
    service = readdlm("case_study_solutions/save_data/service/service$(case_size)-$(num).csv", ',', Float64)

    demand = zeros(length(d))
    solomon_demand = 10000

    return p, d[2:end], low_d[2:end], demand[2:end], service[2:end], distance_matrix, solomon_demand
end


function read_particle(name::String, num::Int64, objective_function::Function, case::String, num_particle::Int64, seed::Int64)
    location = "particle_swarm/$objective_function/$case/$name/$num_particle/$seed"
    return read_txt3("$location/$name-$num.txt", name)
end


function read_csv_to_dataframe(location::String)
    return CSV.File(location) |> DataFrame
end


"""
    read_route(file_name::String)

return route representation from file text

For example: 

-----------------

Text file\n
1 2 4 5\n
8 9 3 6

-----------------

Return Vector[0, 1, 2, 4, 5, 0, 8, 9, 3, 6, 0] where 0 represented depot
"""
function read_route(file_name::String)
    route = Dict()
    open(file_name) do file
        lines = eachline(file)
        for i in enumerate(lines)
            route[i[1]] = [parse(Int, j) for j in split(i[2])]
        end
    end

    # create route representation [route_1, 0, route_2, ..., route_n]
    route_rep = [0]
    for i in 1:length(route)
        if isempty(route[i]) == false
            append!(route_rep, route[i], 0)
        end
    end

    return route_rep
end


function opt_dir(dir...)
    path = joinpath(@__DIR__, "..", "opt_solomon", dir)
end


"""
    read_data_solomon(name_instance::String)

Load instance parameters:

p = processing time matrix \n
upper  \n
lower  \n
demand \n
capacity  \n
service time \n
distance matrix 
"""
function read_data_solomon(name_instance::String)
    data = read_data_solomon_dict(name_instance)
    return data["p"], collect(data["upper"]), data["lower"], data["demand"], data["capacity"], data["distance_matrix"], data["service"], data["last_time_window"]
end


function read_data_solomon_dict(name_instance::String)
    return load(joinpath(@__DIR__, "..", "data", "raw_data_solomon_jld2", "$name_instance.jld2"))
end

"""
    read_and_save_solomon()

run to create data files of solomon
"""
function read_and_save_solomon()
    for num_node in [25, 50, 75, 100]
        for name_instance in Full_Name()
            println("number of vehicle: $num_node, instance name: $name_instance")
            p, upper, lower, demand, capacity, service, distance_matrix, last_time_window = load_all_data2(name_instance)
            p = p[1:num_node, 1:num_node]
            upper = upper[1:num_node+1]
            lower = lower[1:num_node+1]
            demand = demand[1:num_node+1]
            service = service[1:num_node+1]
            distance_matrix = distance_matrix[1:(num_node+1), 1:(num_node+1)]
            jldsave(joinpath(@__DIR__, "..", "data", "raw_data_solomon_jld2", "$name_instance-$num_node.jld2"); p, upper, lower, demand, capacity, service, distance_matrix, last_time_window)
        end
    end
end


function save_HHCRSP(name, num_node, num_vehi, num_serv, mind, maxd, DS, a, r, d, xx, yy, p, e, l)
    jldsave(joinpath(@__DIR__, "..", "data", "raw_HHCRSP", "$name.jld2"); num_node, num_vehi, num_serv, mind, maxd, DS, a, r, d, xx, yy, p, e, l)
end


function save_data(x, name_data::String)
    save_object(joinpath(@__DIR__, "..", "data", "raw_data_solomon-jl", name_data), name_data)
end


"""
To run this function, first, load all data of Homberger instances by `dt = load_all_solomon_200()`
    then run the function `save_all_homberger(dt)`
"""
function save_all_homberger(dt::Dict)
    for Name in instance_names()
        dm = dt[Name]
        # dt[Name]["p"] = []
        # p, upper, lower, demand, capacity, service, distance_matrix, last_time_window = load_all_data2(name_instance)
        p = ProcessingTimeMatrix(dm["xcoor"], dm["xcoor"], Name)
        num_node = length(dm["duedate"])-1
        # p = p[1:num_node, 1:num_node]
        upper = dm["duedate"]
        last_time_window = dm["readytime"][0]
        lower = [dm["readytime"][i] for i in 1:num_node]
        demand = [dm["demand"][i] for i in 1:num_node]
        service = [dm["service"][i] for i in 1:num_node]
        capacity = dm["capacity"]
        distance_matrix = DistanceMatrix(dm["xcoor"], dm["xcoor"], Name)
        # distance_matrix = distance_matrix[1:(num_node+1), 1:(num_node+1)]
        jldsave(joinpath(@__DIR__, "..", "data", "raw_data_solomon_jld2", "$Name.jld2"); p, upper, lower, demand, capacity, service, distance_matrix, last_time_window)
        # save_object(joinpath(@__DIR__, "..", "data", "raw_data_solomon_jld2", "$Name.jld2"), dt[Name])
    end
end