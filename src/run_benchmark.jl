# include("heuristic.jl")
# include("benchmark.jl")
# include("read_file.jl")
# using StatsPlots
# using PyPlot
# pyplot()

# Name list = ["r", "c", "rc"]
r1  =  ["r$(i)"   for i in 101:112]
r2  =  ["r$(i)"   for i in 201:211]
c1  =  ["c$(i)"   for i in 101:109]
c2  =  ["c$(i)"   for i in 201:208]
rc1 =  ["rc$(i)"  for i in 101:108]
rc2 =  ["rc$(i)"  for i in 201:208]

Name = [r1, r2, c1, c2, rc1, rc2]

"""
    run()

Returns double the number `x` plus `1`.
"""
function run(;duedate=true, low_duedate=false)
    data = benchmark(duedate=duedate, low_duedate=low_duedate)
    solomon = read_Solomon()
    
    if duedate == true
        Solo = open("benchmark/solomon.csv", "w")
        alg1 = 1
        alg2 = 2
    elseif low_duedate == true
        Solo = open("benchmark/solomon_low_duedate.csv", "w")
        alg1 = 7
        alg2 = 8
    end

    
    # write(io, "name,Alg1(late),Alg1(comp),Alg1(late),Alg1(comp),Alg3(late),Alg3(comp),Alg4(late),Alg4(vehicle),Alg4(max-dist),Alg2(late),Alg2(vehicle),Alg2(max-dist)\n")
    # write(io," name,late1,late2,late3,last_comp1,last_comp2,last_comp3,late4,late5,vehicle4,vehicle5,max-comp4,max-comp5\n")
    write(Solo, "name,NV$(alg1),NV$(alg2),NVSolo,Dis$(alg1),Dis$(alg2),DisSolo\n")
    for names in Name
        for name in names
            
            # load demand and solomon demand
            solo_p, solo_d, solo_low_d, demand, solomon_demand = load_all_data(name)

            # remove service time
            if name[1] == 'c' # including c and rc
                service = 90
            else
                service = 10
            end
            println("service time = $(service)")

            # # alg1
            # sch1 = heuristic(p=data[name]["p"], d=data[name]["d"], full=true, low_d=data[name]["low_d"])
            # (late1, last_completiontime1) = job_late(sch1; p=data[name]["p"], d=data[name]["d"], low_d=data[name]["low_d"])
            # late1 = sum(late1)
            # # last_completiontime1 -= service * (100 - late1)
            # println("Run problem: $(name)")
            # println("Alg: 1")
            # println("late(Alg1)     = $(late1)")
            # println("max comp(Alg1) = $(last_completiontime1)\n")
            # # create csv  file
            
            # # alg2
            # sch2 = heuristic_single_min(p=data[name]["p"], d=data[name]["d"], full=true)
            # (late2, last_completiontime2) = job_late(sch2; p=data[name]["p"], d=data[name]["d"], low_d=data[name]["low_d"])
            # late2 =  sum(late2)
            # # last_completiontime2 -= service * (100 - late2)
            # println("Alg: 2")
            # println("late(Alg1)     = $(late2)")
            # println("max comp(Alg1) = $(last_completiontime2)\n")
            
            
            # # alg3
            # sch3, late3, last_completiontime3 = processingtime_min(p=data[name]["p"], d=data[name]["d"], low_d=low_d)
            # # last_completiontime3 -= service * (100 - late3)
            # # println("Alg: 1 (processing time)")
            # println("late(Alg3)     = $(late3)")
            # println("max comp(Alg3) = $(last_completiontime3)\n")
            
            # alg4
            (num_vehicle4, num_remaining_job4, max_processingtime4) = heuristic_multi(p=data[name]["p"], d=data[name]["d"], low_d=data[name]["low_d"], name=name, duedate=duedate, low_duedate=low_duedate, demand=demand, solomon_demand=solomon_demand)
            println("Alg: $(alg1) (multi using alg1)")
            println("late(Alg$(alg1))     = $(num_remaining_job4)")
            println("num vehicle(Alg$(alg1)) = $(num_vehicle4)")
            println("sum processing time(Alg$(alg1)) = $(max_processingtime4)\n")
            # max_processingtime4 -= service * (100-num_remaining_job4)
            
            
            # alg5
            (num_vehicle5, num_remaining_job5, max_processingtime5) = heuristic_multi_min(p=data[name]["p"], d=data[name]["d"], disp=false, low_d=data[name]["low_d"], name=name, duedate=duedate, low_duedate=low_duedate)
            println("Alg: $(alg2) (multi using alg2)")
            println("late(Alg$(alg2))     = $(num_remaining_job5)")
            println("num vehicle(Alg$(alg2)) = $(num_vehicle5)")
            println("sum processing time(Alg$(alg2)) = $(max_processingtime5)\n")
            # max_processingtime5 -= service * (100-num_remaining_job5)

            # add data to csv
            write(Solo, "$(name),$(num_vehicle4),$(num_vehicle5),$(solomon[name]["NV"]),$(@sprintf("%.2f", max_processingtime4)),$(@sprintf("%.2f", max_processingtime5)),$(solomon[name]["Distance"])\n")
        end
    end
    close(Solo)
end

"""
read_solomon()
Return Somthings
"""
function read_Solomon()
    f = CSV.read("Benchmark/Solomon_data.csv", DataFrame)
    # colomn 1 : Name
    # colomn 2 : NV (the number of vehicles)
    # colomn 3 : Distance
    solomon = Dict()
    for i in 1:size(f, 1)
        name = f[i, 1]
        if 6 <= length(name) <= 9
            name = uppercase(name)
        end
        solomon[name] = Dict()
        solomon[name]["NV"] = f[i, 2] 
        solomon[name]["Distance"] = f[i, 3]
    end 
    return solomon
end


function test_lower_bound()
    data = benchmark()
    name = "r101"
    d = data[name]["d"]
    p = data[name]["p"]
    low_d = data[name]["low_d"]
    sch, late = heuristic(p=p, d=d, low_d=[])
end

# function calculate distance by total completion time minus service time
# this might be incorrect 
function total_distance_solomon(sch, name)

    if isempty(sch) == true
        return [0]
    end

    data = benchmark()
    n =  length(sch)
    p = data[name]["p"]
    diag_p =  [p[i, i] for i in 1:n]
    # remove service time
    if name[1] == 'c' # including c and rc
        service = 90
    else
        service = 10
    end
    for i in 1:n
        for j in 1:n
            if i != j 
                p[i, j] = p[i, j] - service
            end
        end
    end
    completion_time  = []
    append!(completion_time, p[sch[1], sch[1]])
    for i in 2:n
        append!(completion_time, p[sch[i - 1],  sch[i]])
    end
    return completion_time
end


# testing for heuristic_multi_min 
function check_solomon(name)
    data = benchmark()
    (num_vehicle5, num_remaining_job5, max_processingtime5) = heuristic_multi_min(p=data[name]["p"], d=data[name]["d"], disp=true, low_d=data[name]["low_d"], name=name)
    println("Alg: 5 (multi using alg2)")
    println("late(Alg2)     = $(num_remaining_job5)")
    println("num vehicle(Alg2) = $(num_vehicle5)")
    println("sum processing time(Alg2) = $(max_processingtime5)\n")
end


# testing for multiple_vehicle and multiple_heursitic
function test_new_alg()
    data = benchmark()
    solomon = read_Solomon()
    global name = "rc108"
    remain1 = multiple_fixed_vehicle([i for i in 1:100], data[name]["p"], data[name]["d"], data[name]["low_d"], 3, name=name)
    remain2 = multiple_fixed_heuristic([i for i in 1:100], data[name]["p"], data[name]["d"], data[name]["low_d"], 21, name=name)
end


function run_multiple_vehicle()
    # data = benchmark()
    solomon = read_Solomon()

    io = open("Benchmark/multiple_solomon.csv", "w")
    write(io, "name,NV3,NV4,NVSolo,Dis3,Dis4,DisSolo\n")
    for Names in Name
        for name in Names
            (num_vehicle3, total_dis3) = multiple_vehicle(name, multiple_fixed_vehicle)
            (num_vehicle4, total_dis4) = multiple_vehicle(name, multiple_fixed_heuristic)
            write(io, "$(name),$(num_vehicle3), $(num_vehicle4), $(solomon[name]["NV"]), $(@sprintf("%.2f", total_dis3)), $(@sprintf("%.2f", total_dis4)), $(solomon[name]["Distance"])\n")
        end
    end
    close(io)
end


function run_processingtime_multiple()
    # data = benchmark()
    solomon = read_Solomon()
    
    io = open("Benchmark/processing_multi_solomon.csv", "w")
    write(io, "name,NV5,NV6,NVSolo,Dis5,Dis6,DisSolo\n")
    for Names in Name
        for name in Names
            (num_vehicle5, total_dis5) = processingtime_min_multi(name)
            (num_vehicle6, total_dis6) = multiple_processingtime(name)
            write(io, "$(name),$(num_vehicle5), $(num_vehicle6), $(solomon[name]["NV"]), $(@sprintf("%.2f", total_dis5)), $(@sprintf("%.2f", total_dis6)), $(solomon[name]["Distance"])\n")
        end
    end
    close(io)
end


function run_pair()
    solomon = read_Solomon()
    io = open("Benchmark/multiple_pair.csv", "w")
    write(io, "name,late9,NV9,NVSolo,Dis9,DisSolo\n")
    for names in Name
        for name in names
            num_vehicle9, total_dis9, remain = heuristic_pair_multi(name)
            write(io, "$(name),$(sum(remain)),$(num_vehicle9),$(solomon[name]["NV"]),$(@sprintf("%.2f", total_dis9)),$(@sprintf("%.2f", solomon[name]["Distance"]))\n")
            println("name: $name")
            println("number of vehicle: $num_vehicle9, total distance $total_dis9")
        end
    end
    close(io)
end


# arrange one by one vehicle while choosing the min of last completion time minus before last completion time
function run_diff_multiple(version)
    solomon = read_Solomon()

    # the number of algorithm
    alg = version + 9

    io = open("Benchmark/multiple_diff_ver$(version).csv", "w")
    write(io, "name,late$alg,NV$(alg),NVSolo,Dis$(alg),DisSolo\n")
    for names in Name
        for name in names
            num_vehicle10, total_dis10, remain = heuristic_diff_multi(name, version=version, alg=alg)
            write(io, "$(name),$(length(remain)),$(num_vehicle10),$(solomon[name]["NV"]),$(@sprintf("%.2f", total_dis10)),$(solomon[name]["Distance"])\n")
            println("name: $name")
            println("number of vehicle(solomon): $num_vehicle10($(solomon[name]["NV"])), total distance $total_dis10, Solomon distance: $(solomon[name]["Distance"])")
        end
    end
    close(io)
end


function run_multiple_diff()
    solomon = read_Solomon()
    io = open("Benchmark/diff_multiple.csv", "w")
    write(io, "name,late11,NV11,NVSolo,Dis11,DisSolo\n")
    for names in Name
        for name in names
            num_vehicle11, total_dis11, remain = multiple_diff(name)
            write(io, "$(name),$(length(remain)),$(num_vehicle11),$(solomon[name]["NV"]),$(total_dis11),$(solomon[name]["Distance"])\n")
            println("name: $name")
            println("number of vehicle: $num_vehicle11, total distance: $total_dis11")
        end
    end
    close(io)
end


function run_multiple_diff2()
    # data = benchmark()
    solomon = read_Solomon()
    
    io = open("Benchmark/multiple_diff2.csv", "w")
    write(io, "name,NV12,NV12,NVSolo,Dis12,Dis12,DisSolo\n")
    for Names in Name
        for name in Names
            (num_vehicle12, total_dis12) = multiple_diff2(name)
            write(io, "$(name),$(num_vehicle12), $(num_vehicle12), $(solomon[name]["NV"]), $(@sprintf("%.2f", total_dis12)), $(@sprintf("%.2f", total_dis12)), $(solomon[name]["Distance"])\n")
        end
    end
    close(io)
end



function cat_heuristic()
    df = CSV.read("Benchmark/solomon.csv", DataFrame)
    dg = CSV.read("Benchmark/multiple_solomon.csv", DataFrame)
    dh = CSV.read("Benchmark/processing_multi_solomon.csv", DataFrame)
    dk = CSV.read("Benchmark/solomon_low_duedate.csv", DataFrame)
    dj = CSV.read("Benchmark/multiple_pair.csv", DataFrame)
    dl = CSV.read("Benchmark/multiple_diff.csv", DataFrame)
    insertcols!(df, 4, :NV3 => dg["NV3"])
    insertcols!(df, 5, :NV4 => dg["NV4"])
    insertcols!(df, 9, :Dis3 => dg["Dis3"])
    insertcols!(df, 10, :Dis4 => dg["Dis4"])
    insertcols!(df, 6, :NV5 => dh["NV5"])
    insertcols!(df, 7, :NV6 => dh["NV6"])
    insertcols!(df, 13, :Dis5 => dh["Dis5"])
    insertcols!(df, 14, :Dis6 => dh["Dis6"])
    insertcols!(df, 8, :NV7 => dk["NV7"])
    insertcols!(df, 9, :NV8 => dk["NV8"])
    insertcols!(df, 17, :Dis7 => dk["Dis7"])
    insertcols!(df, 18, :Dis8 => dk["Dis8"])
    insertcols!(df, 10, :NV9 => dj["NV9"])
    insertcols!(df, 20, :Dis9 => dj["Dis9"])
    insertcols!(df, 11, :NV10 => dl["NV10"])
    insertcols!(df, 22, :Dis10 => dl["Dis10"])
    CSV.write("Benchmark/solomon_all.csv", df)
end


function cat_alg12_alg78()
    # read
    df = CSV.read("Benchmark/solomon.csv", DataFrame)
    dg = CSV.read("Benchmark/solomon_low_duedate.csv", DataFrame)

    # add columns
    insertcols!(df, 3, :NV7 => dg["NV7"])
    insertcols!(df, 5, :NV8 => dg["NV8"])
    insertcols!(df, 8, :Dis7 => dg["Dis7"])
    insertcols!(df, 10, :Dis8 => dg["Dis8"])

    # export
    CSV.write("Benchmark/solomon_Alg12-78.csv", df)
    
    # test for low_d and d
    println("\nTesting d and low_d\n")
    data1 = benchmark(duedate=true, low_duedate=false)
    data2 = benchmark(duedate=false, low_duedate=true)
    for names in Name
        for name in names
            d1 = data1[name]["d"]
            d2 = data2[name]["d"]
            println("Name: $name => d1 = d2 : $(d1 == d2)")
        end
    end

    # print
    println("\n==== Comparison between Alg 1, 2, 7, 8 ====\n")


    println("Number of vehcile 1 == 7: $(df[:NV1] == df[:NV7])")
    println("Number of vehcile 2 == 8: $(df[:NV2] == df[:NV8])")
    println("Distance of vehcile 1 == 7: $(df[:Dis1] == df[:Dis7])")
    println("Distance of vehcile 2 == 8: $(df[:Dis2] == df[:Dis8])")
end
    

function cat_alg2_alg9()
    # read
    df = CSV.read("Benchmark/solomon.csv")
    dg = CSV.read("Benchmark/multiple_pair.csv")

    # add columns
    insertcols!(df, 3, :NV9 => dg["NV9"])
    insertcols!(df, 8, :Dis9 => dg["Dis9"])

    # export
    CSV.write("Benchmark/solomon_Alg2-9.csv", df)
end

function cat_diff()
    d1 = CSV.read("Benchmark/multiple_diff.csv", DataFrame)
    d2 = CSV.read("Benchmark/multiple_diff_ver2.csv", DataFrame)
    d3 = CSV.read("Benchmark/multiple_diff_ver3.csv", DataFrame)
    d4 = CSV.read("Benchmark/multiple_diff_ver4.csv", DataFrame)
    d5 = CSV.read("Benchmark/multiple_diff_ver5.csv", DataFrame)
    d6 = CSV.read("Benchmark/multiple_diff_ver6.csv", DataFrame)
    
    all_distance = [d1[:Dis10] d2[:Dis11] d3[:Dis12] d4[:Dis13] d5[:Dis14] d6[:Dis15]]
    min_distance = [argmin(all_distance[i, :]) for i in 1:length(d1[:name])] 
    alg = min_distance .+ 9
    min_name = ["Alg$(i)" for i in alg]

    num_vehicle = findall(d1[:NV10] .< d1[:NVSolo])
    println("number of vehicle less than Solomon: $num_vehicle")

    df = DataFrame(name=d1[:name],
    NV10=d1[:NV10],
    NV11=d2[:NV11],
    NV12=d3[:NV12],
    NV13=d4[:NV13],
    NV14=d5[:NV14],
    NV15=d6[:NV15],
    NVSolo=d1[:NVSolo],
    Dis10=d1[:Dis10],
    Dis11=d2[:Dis11],
    Dis12=d3[:Dis12],
    Dis13=d4[:Dis13],
    Dis14=d5[:Dis14],
    Dis15=d6[:Dis15],
    DisSolo=d1[:DisSolo],
    DisMin=min_name,
    )


    CSV.write("Benchmark/solomon_diff_ver.csv", df)
    return df
end


function solomon_capacity(name::AbstractString)
    # solomon cap
    return solomon100[name]["capacity"]
end


function Full_Name()
    name_instance = []
    append!(name_instance, Name[1])
    append!(name_instance, Name[2])
    append!(name_instance, Name[3])
    append!(name_instance, Name[4])
    append!(name_instance, Name[5])
    append!(name_instance, Name[6])
    return name_instance
end


function Full_Name(type::String)
    name_instance = []
    if type == "r1"
        append!(name_instance, Name[1])
    elseif type == "r2"
        append!(name_instance, Name[2])
    elseif type == "c1"
        append!(name_instance, Name[3])
    elseif type == "c2"
        append!(name_instance, Name[4])
    elseif type == "rc1"
        append!(name_instance, Name[5])
    elseif type == "rc2"
        append!(name_instance, Name[6])
    else
        name_instance = ["$(type)_$i" for i in 1:10]
    end
    return name_instance
end


function compare_benchmark(alg::Int; phase=1, type=nothing, phase_2=1, full_name=false, iteration=1)
    data = load_route_solomon()
    dir = "exact_solomon"

    if full_name
        all_name = Full_Name()
    else
        all_name = readdir(dir)
    end

    # load solomon data
    solomon = load_all_solomon_100()
    data_solomon = read_Solomon()

    # alg = 2

    for name in all_name

        # because name have .txt
        name = split(name, ".")
        name = name[1]
        # name = parse(String, name)

        # load solotion from algorithm
        vehicle = read_txt(name, alg=alg, phase=phase, phase_2=phase_2, iteration=iteration)
        
        # load data solomon
        d = solomon[name]["duedate"]
        low_d = solomon[name]["readytime"]
        per = solomon[name]["per"]
        per = solomon[name]["per"]
        p = ProcessingTimeMatrix(solomon[name]["xcoor"], solomon[name]["ycoor"], name)

        if full_name == false
            all_completion_time_solomon = []
            for i in 1:length(data[name])
                starting_solomon, completion_solomon = StartingAndCompletion(data[name][i], p, low_d)
                latest_completion_solomon = completion_solomon[end]
                append!(all_completion_time_solomon, latest_completion_solomon)
            end
            sum_solomon = sum(all_completion_time_solomon)
        end

        # # solomon cap
        # if name[1:2] == "c1" || name[1:2] == "r1"
        #     solomon_cap = 200
        # elseif name[1:2] == "c2"
        #     solomon_cap = 700
        # elseif name[1:2] == "r2"
        #     solomon_cap = 1000
        # elseif name[1:3] == "rc1"
        #     solomon_cap = 200
        # elseif name[1:3] == "rc2"
        #     solomon_cap = 1000
        # end
        solomon_cap = solomon_capacity(name)


        # solotion from algorithm
        vec_completiontime_alg = [vehicle[i]["CompletionTime"][end] for i in 1:vehicle["num_vehicle"]]
        sum_completiontime_alg = sum(vec_completiontime_alg)
        cap = [solomon[name]["demand"][i] for i in 1:length(d) - 1]
        each_demand = [sum(cap[vehicle[i]["sch"]]) for i in 1:vehicle["num_vehicle"]]
        if full_name
            println("name: $(@sprintf("%5s", name)), L: $(sum([sum(vehicle[i]["Late"]) for i in 1:vehicle["num_vehicle"]])), Alg$alg:p:$phase, dis_Alg: $(@sprintf("%8.2f", distance_solomon_all(vehicle, name))), dis_solo: $(@sprintf("%8.2f", data_solomon[name]["Distance"])), diff: $(@sprintf("%8.2f", distance_solomon_all(vehicle, name) - data_solomon[name]["Distance"])), NV_alg: $(@sprintf("%2d", vehicle["num_vehicle"])), NV_solo: $(@sprintf("%2d", data_solomon[name]["NV"])), diff: $(@sprintf("%2d", vehicle["num_vehicle"] - data_solomon[name]["NV"])), per:$(@sprintf("%.2f", (distance_solomon_all(vehicle, name) - data_solomon[name]["Distance"]) / (distance_solomon_all(vehicle, name))))")
        else
            println("name: $name, L: $(sum([sum(vehicle[i]["Late"]) for i in 1:vehicle["num_vehicle"]])), Alg$alg:p:$phase, dis_Alg: $(@sprintf("%8.2f", distance_solomon_all(vehicle, name))), dis_solo: $(@sprintf("%8.2f", data_solomon[name]["Distance"])), diff: $(@sprintf("%8.2f", distance_solomon_all(vehicle, name) - data_solomon[name]["Distance"])), NV_alg: $(@sprintf("%2d", vehicle["num_vehicle"])), NV_solo: $(@sprintf("%2d", data_solomon[name]["NV"])), diff: $(@sprintf("%2d", vehicle["num_vehicle"] - data_solomon[name]["NV"])), C_solo: $(@sprintf("%8.2f", sum_solomon)), C_Alg: $(@sprintf("%8.2f", sum_completiontime_alg)), $(sum_completiontime_alg < sum_solomon), total_cap: $(maximum(each_demand))($(solomon_cap)), $(maximum(each_demand) <= solomon_cap)")
        end
        # return sum_solomon, sum_completiontime_alg
    end
end


function compare_benchmark(;phase=1, phase_2=1)
    if phase == "clustering"
        compare_benchmark(1, phase=phase)
    else
        for i in 1:15
            compare_benchmark(i, phase=phase)
        end
    end
end


function phase2(;alg=nothing, phase=1, phase_2=nothing, type=nothing, sort_function=sort_processing_matrix, num_start_name=1, to_txt=false)
    # load phase 1 from algorithm and swap_all positions
    fullname = Full_Name()
    for name in fullname[num_start_name:end]
        vehicle = read_txt2(name, alg=alg)
        println("name: $name")
        original_dis, dis_final, vehicle = swap_all(vehicle, name, alg=phase, phase=2, phase_2=phase_2, type=type, sort_function=sort_function, to_txt=false)
        
        # save to txt
        if to_txt
            save_to_txt(vehicle, alg=alg, phase_2="swap_all-$(sort_function)")
        end
    end
end

# phase 2 uses swap
function phase2_no_update(;alg=nothing, phase=1, phase_2=nothing, type=nothing, sort_function=sort_processing_matrix, num_start_name=1)
    # load phase 1 from algorithm and swap_all positions
    fullname = Full_Name()
    for name in fullname[num_start_name:end]
        vehicle = read_txt2(name, alg=alg)
        println("name: $name")
        original_dis = 1
        dis_final = 0
        while dis_final < original_dis
            @time original_dis, dis_final, vehicle = swap_all_no_update(vehicle, name, alg=phase, phase=2, phase_2=phase_2, type=type, sort_function=sort_function, to_txt=false)
        end
        
        # save to txt
        save_to_txt(vehicle, alg=alg, phase_2="swap_all_no_update-$(sort_function)")
    end
end


# (not complete)
# function phase2_no_update_case_study(case_size, num, sort_function=sort_processing_matrix, num_start_name=1)
#     # load phase 1 from algorithm and swap_all positions
#     vehicle = read_case_study(case_size, num)
#     original_dis = 1
#     dis_final = 0
#     while dis_final < original_dis
#         original_dis, dis_final, vehicle = swap_all_no_update(vehicle, name, alg=phase, phase=2, phase_2=phase_2, type=type, sort_function=sort_function, to_txt=false)
#     end
    
#     # save to txt
#     # dir = "case_study_solutions/casestudy$(case_size)-1_clustering.txt"
#     # io = open(dirr, "w")
#     # for i in 1:vehicle["num_vehicle"]
#     #     for j in vehicle[i]["sch"]
#     #         write(io, "$j ")
#     #     end
#     #     write(io, "\n")
#     # end
#     # close(io)
# end


# run all algorithm and all name
function run_phase2(;sort_function=sort_processing_time, phase=1, phase_2=1, type=nothing, phase_function=phase2::Function)
    for i in 1:15
        println("Alg: $i")
        phase_function(i, sort_function=sort_function, type=type, phase=phase, phase_2=phase_2)
    end
end


function compare_phase12(name::String, alg::Int)
    vehicle1 = read_txt(name, alg=alg, phase=1)
    vehicle2 = read_txt(name, alg=alg, phase=2)
    dis1 = vehicle1["TotalDistance"]
    dis2 = vehicle2["TotalDistance"]
    println("name: $name")
    println("dis1: $dis1")
    println("dis2: $dis2")
    return dis1, dis2
end


function compare_all_phase2()
    solomon = read_Solomon()
    for alg in 1:15
        io = open("phase2/Alg$alg-conclusion2.csv", "w")
        write(io, "name,Dis1,Dis2,DisSolo\n")
        for names in Name
            for name in names
                dis1, dis2 = compare_phase12(name, alg)
                write(io, "$name,$dis1,$dis2,$(solomon[name]["Distance"])\n")
            end
        end
        close(io)
    end
end


function phase3(name::String, alg::Int, sort_function=sort_processing_matrix)
    # rerun phase 2
    final = []
    # load vehicle
    new_vehicle = read_txt(name, alg=alg, phase=2, iteration=1)
    original_dis, dis_final = swap_all(new_vehicle, name, alg=alg, iteration=2, sort_function=sort_function)
    append!(final, original_dis)
    println("Iteration: 2 original: $(original_dis) final: $(dis_final)")
    
    # run pahse 2
    iter = 2
    while abs(original_dis - dis_final) > 1e-3 && iter <= 50
        append!(final, dis_final)
        new_vehicle = read_txt(name, alg=alg, phase=2, iteration=iter)
        original_dis, dis_final = swap_all(new_vehicle, name, alg=alg, iteration=iter + 1, sort_function=sort_function)
        println("Iteration: $iter original: $(original_dis) final: $(dis_final)")
        iter += 1
    end
    return final
end


function phase3(alg::Int)
    dis_final = Dict()
    for names in Name
        for name in names
            dis_final[name] = phase3(name, alg)
        end
    end
    # CSV.write("Benchmark/phase3-Alg$alg.csv", dis_final)
    return dis_final
end


function run_phase3()
    for alg in 1:15
        dis_final = phase3(alg)
    end
end


function conclusion_phase3()
    # not finished
    Alg = 1:15
    for alg in Alg
        read_txt(name, alg=alg, phase=2, iteration=1)
    end
end


function run_clustering(f::Function; Alg=heuristic::Function, function_name=Full_name::Function, start=1, stop=false, max_iter=10)

    dir = "run_clustering_save"
    
    vehicle = Dict()
    to = TimerOutput()
    all_name = function_name()[start:end]
    
    for (iter, name) in enumerate(all_name)

        io = open("$dir/$name.csv", "w")
        write(io, "iter,NV,TD\n")
        
        @timeit to "$(name)" global best_vehicle = clustering(name; f=f, Alg=Alg, to_txt=false)
        global best_dis = distance_solomon_all(best_vehicle, name)

        write(io, "1,$(best_vehicle["num_vehicle"]),$(best_dis)\n")
        
        for i in 1:max_iter
            
            @timeit to "$(name)" vehicle = clustering(name; f=f, Alg=Alg, to_txt=false)
            new_dis = distance_solomon_all(vehicle, name)
            write(io, "$(i+1),$(vehicle["num_vehicle"]),$(new_dis)\n")

            if new_dis < best_dis

                best_vehicle = deepcopy(vehicle)
                best_dis = deepcopy(new_dis)
                
            end
        end

        close(io)
        
        # try to save best vehicle
        try 
            read_vehicle = read_txt2(name, alg="clustering-$Alg")
            read_dis = distance_solomon_all(read_vehicle, name)
            
            if read_dis > best_dis
                save_to_txt(best_vehicle, alg="$(f)-$(Alg)")
            end
            
        catch 
            save_to_txt(best_vehicle, alg="$(f)-$(Alg)")
        end
        if stop == iter
            break
        end
    end
    println(to)
end


function create_csv(alg::Int, phase)
    vehicle = Dict()
    name_instance = []
    append!(name_instance, Name[1])
    append!(name_instance, Name[2])
    append!(name_instance, Name[3])
    append!(name_instance, Name[4])
    append!(name_instance, Name[5])
    append!(name_instance, Name[6])
    for names in Name
        for name in names
            vehicle[name] = read_txt(name, alg=alg, phase=phase)
        end
    end

    dis = [vehicle[name]["TotalDistance"] for name in name_instance]
    num_vehicle = [vehicle[name]["num_vehicle"] for name in name_instance]

    solomon = read_Solomon()
    dis_solomon = [solomon[name]["Distance"] for name in name_instance]
    NV_solomon = [solomon[name]["NV"] for name in name_instance]


    # create csv
    df = DataFrame(name=name_instance, NV_alg=num_vehicle, NV_solo=NV_solomon, dis_alg=dis, dis_solo=dis_solomon)
    if typeof(phase) == String
        CSV.write("Benchmark/conclution$(uppercase(phase)).csv", df)
    else
        CSV.write("Benchmark/conclutionAlg$(alg)Phase$(phase).csv", df)
    end
end


function create_csv(alg::Array, phase::Array, phase_2::Array)
    # load data
    name_instance = []
    if sum(phase .== "exact_solomon") >= 1
        for h in readdir("exact_solomon")
            append!(name_instance, [h[1:end - 4]])
        end
    else
        append!(name_instance, Name[1])
        append!(name_instance, Name[2])
        append!(name_instance, Name[3])
        append!(name_instance, Name[4])
        append!(name_instance, Name[5])
        append!(name_instance, Name[6])
    end

    n = length(alg)
    A = name_instance
    B = name_instance

    # dict
    vehicle = Dict()
    for i in 1:length(alg)
        vehicle[i] = Dict()
        if phase[i] == "exact_solomon"
            for name in name_instance
                vehicle[i][name] = read_txt(name, alg=alg[i], phase=phase[i], phase_2=phase_2[i])
            end
        else
            for names in Name
                for name in names
                    vehicle[i][name] = read_txt(name, alg=alg[i], phase=phase[i], phase_2=phase_2[i])
                end
            end
        end

        dis = [vehicle[i][name]["TotalDistance"] for name in name_instance]
        num_vehicle = [vehicle[i][name]["num_vehicle"] for name in name_instance]

        A = [A num_vehicle]
        B = [B dis]

    end


    solomon = read_Solomon()
    dis_solomon = [solomon[name]["Distance"] for name in name_instance]
    NV_solomon = [solomon[name]["NV"] for name in name_instance]

    A = [A NV_solomon]
    B = [B dis_solomon]

    column_list = ["name"]
    append!(column_list, ["NV-$(alg[i])-P$(phase[i])" for i in 1:n])
    append!(column_list, ["NvSl"])
    append!(column_list, ["Dis_A$(alg[i])-P$(phase[i])" for i in 1:n])
    append!(column_list, ["DisSl"])

    matrix = [A B[:, 2:end]]

    df = DataFrame(matrix)

    names!(df, Symbol.(column_list)) 

    return df
end


function create_csv(alg::String)
    # load data
    name_instance = []
    append!(name_instance, Name[1])
    append!(name_instance, Name[2])
    append!(name_instance, Name[3])
    append!(name_instance, Name[4])
    append!(name_instance, Name[5])
    append!(name_instance, Name[6])

    A = name_instance
    B = name_instance
    C = name_instance

    # dict
    vehicle = Dict()
    for names in Name
        for name in names
            vehicle[name] = read_txt(name, alg=1, phase=alg)
        end
    end

    dis = [vehicle[name]["TotalDistance"] for name in name_instance]
    num_vehicle = [vehicle[name]["num_vehicle"] for name in name_instance]

    vec_completiontime_alg = [vehicle[i]["CompletionTime"][end] for i in 1:vehicle["num_vehicle"]]
    sum_completiontime_alg = sum(vec_completiontime_alg)
    cap = [solomon[name]["demand"][i] for i in 1:length(d) - 1]
    each_demand = [sum(cap[vehicle[i]["sch"]]) for i in 1:vehicle["num_vehicle"]]

    A = [A num_vehicle]
    B = [B dis]

    solomon = read_Solomon()
    dis_solomon = [solomon[name]["Distance"] for name in name_instance]
    NV_solomon = [solomon[name]["NV"] for name in name_instance]

    A = [A NV_solomon]
    B = [B dis_solomon]

    column_list = ["name"]
    append!(column_list, ["NV_Alg$(phase)"])
    append!(column_list, ["NV_solo"])
    append!(column_list, ["Dis_Alg$(phase)"])
    append!(column_list, ["Dis_solo"])

    matrix = [A B[:, 2:end]]

    df = DataFrame(matrix)

    names!(df, Symbol.(column_list)) 

    return df
end


function delete_files_in_phase2()
    rm.(glob("phase2/Alg10-*-iter*[!1].txt"), recursive=true)
end
    

function print_alg(name::AbstractString, phase, phase_2; disp=true, alg=10)
    vehicle1 = read_txt(name, alg=alg, phase=phase, phase_2=phase_2)

    solomon = read_Solomon()

    println("Name: $name phase$phase")
    println("total dis(solomon): $(distance_solomon_all(vehicle1, name))($(solomon[name]["Distance"]))")
    println()

    n = vehicle1["num_vehicle"]
    if disp == false
        for i in 1:n
            println("vehicle Algorit $i: $(vehicle1[swaping[i][1]]["sch"])")
            println("vehicle solomon $i: $(vehicle2[swaping[i][2]]["sch"])")
            println()
        end
    else
        for i in 1:n
            B = [hcat(["vehicle Algorit $i:"], vehicle1[i]["sch"]');
            hcat(["release Algorit $i:"], vehicle1[i]["ReleaseDate"]');
            hcat(["duedate Algorit $i:"], vehicle1[i]["DueDate"]');
            hcat(["startin Algorit $i:"], [round(g, digits=2) for g in vehicle1[i]["StartingTime"]]');
            hcat(["process Algorit $i:"], [round(g, digits=2) for g in vehicle1[i]["ProcessingTime"]']);
            hcat(["complet Algorit $i:"], [round(g, digits=2) for g in vehicle1[i]["CompletionTime"]']);
            ]
            show(stdout, "text/plain", B)
            println()
        end
    end

    return vehicle1
end


function print_alg_exact(name::AbstractString, phase, phase_2; swaping=nothing, disp=true)
    # c101 [[1, 10], [4, 7], [2, 8], [6, 5], [7, 3], [5, 6], [3, 9], [8, 4], [9, 2], [10, 1]]
    # c101 phase 5 [[1, 3], [2, 5], [3, 9], [4, 4], [5, 2], [6, 1], [7, 6], [8, 7], [9, 10], [10, 8]]
    # c102 [[1, 8], [3, 4], [6, 2], [7, 3], []]
    # c103 [[1, 3], [2, 9], [3, 6], [4, 10], [5, 1], [6, 7], [7, 4], [8, 2], [9, 8], [10, 5]]
    # c105 [[1, 10], [4, 7], [2, 8], [3, 9], [5, 6], [6, 5], [7, 3], [8, 4], [9, 2], [10, 1]]
    # c206 [[1, 1], [2, 3], [3, 2]]
    vehicle1 = read_txt(name, alg=10, phase=phase, phase_2=phase_2)
    vehicle2 = read_exact()
    vehicle2 = vehicle2[name]

    vehicle3 = Dict()
    vehicle4 = Dict()

    println("Name: $name phase$phase")
    println("total dis(solomon): $(distance_solomon_all(vehicle1, name))($(distance_solomon_all(vehicle2, name)))")
    println()

    n = maximum([vehicle1["num_vehicle"], vehicle2["num_vehicle"]])
    if isnothing(swaping)
        swaping = [[i, i] for i in 1:n]
    end
    if disp == false
        for i in 1:n
            println("vehicle Algorit $i: $(vehicle1[swaping[i][1]]["sch"])")
            println("vehicle solomon $i: $(vehicle2[swaping[i][2]]["sch"])")
            println()
        end
    else
        # for i in 1:n
        #     A = [hcat(["vehicle Algorit $i:"], [vehicle1[swaping[i][1]]["sch"]]);
        #         hcat(["vehicle solomon $i:"], [vehicle2[swaping[i][2]]["sch"]]);
        #         hcat(["release Algorit $i:"], [vehicle1[swaping[i][1]]["ReleaseDate"]]);
        #         hcat(["release solomon $i:"], [vehicle2[swaping[i][2]]["ReleaseDate"]]);
        #         hcat(["duedate Algorit $i:"], [vehicle1[swaping[i][1]]["DueDate"]]);
        #         hcat(["duedate solomon $i:"], [vehicle2[swaping[i][2]]["DueDate"]]);
        #         hcat(["startin Algorit $i:"], [[round(g, digits=2) for g in vehicle1[swaping[i][1]]["StartingTime"]]]');
        #         hcat(["startin solomon $i:"], [[round(g, digits=2) for g in vehicle2[swaping[i][2]]["StartingTime"]]]');
        #         hcat(["process Algorit $i:"], [[round(g, digits=2) for g in vehicle1[swaping[i][1]]["ProcessingTime"]]]');
        #         hcat(["process solomon $i:"], [[round(g, digits=2) for g in vehicle2[swaping[i][2]]["ProcessingTime"]]]');
        #         hcat(["complet Algorit $i:"], [[round(g, digits=2) for g in vehicle1[swaping[i][1]]["CompletionTime"]]]');
        #         hcat(["complet solomon $i:"], [[round(g, digits=2) for g in vehicle2[swaping[i][2]]["CompletionTime"]]]');
        #     ]
        #     writedlm(stdout, A)
        #     println()
        # end
        for i in 1:n
            B = [hcat(["vehicle Algorit $i:"], vehicle1[swaping[i][1]]["sch"]');
            hcat(["release Algorit $i:"], vehicle1[swaping[i][1]]["ReleaseDate"]');
            hcat(["duedate Algorit $i:"], vehicle1[swaping[i][1]]["DueDate"]');
            hcat(["startin Algorit $i:"], [round(g, digits=2) for g in vehicle1[swaping[i][1]]["StartingTime"]]');
            hcat(["process Algorit $i:"], [round(g, digits=2) for g in vehicle1[swaping[i][1]]["ProcessingTime"]']);
            hcat(["complet Algorit $i:"], [round(g, digits=2) for g in vehicle1[swaping[i][1]]["CompletionTime"]']);
            ]
            C = [
                    hcat(["vehicle solomon $i:"], vehicle2[swaping[i][2]]["sch"]');
                    hcat(["release solomon $i:"], vehicle2[swaping[i][2]]["ReleaseDate"]');
                    hcat(["duedate solomon $i:"], vehicle2[swaping[i][2]]["DueDate"]');
                    hcat(["startin solomon $i:"], [round(g, digits=2) for g in vehicle2[swaping[i][2]]["StartingTime"]]');
                    hcat(["process solomon $i:"], [round(g, digits=2) for g in vehicle2[swaping[i][2]]["ProcessingTime"]]');
                    hcat(["complet solomon $i:"], [round(g, digits=2) for g in vehicle2[swaping[i][2]]["CompletionTime"]]');
            ]
            show(stdout, "text/plain", B)
            show(stdout, "text/plain", C)
            println()
        end
    end

    for i in 1:n
        vehicle3[i] = vehicle1[swaping[i][1]]
        vehicle4[i] = vehicle2[swaping[i][2]]
    end
    return vehicle3, vehicle4
end


function run_phase5(;alg=10, phase=1::Int64, num_name_start=1::Int64, sort_function=sort_processing_matrix::Function, fullname=Full_Name)
    full_name = fullname()
    for name in full_name[num_name_start:end]
        phase5(name, alg=alg, phase=phase, to_txt=true, sort_function=sort_function)
    end
end


function run_phase5_no_update(;alg=10, phase=1::Int64, num_name_start=1::Int64, sort_function=sort_processing_matrix::Function, fullname=Full_Name)
    full_name = fullname()
    for name in full_name[num_name_start:end]
        phase5_no_update(name, alg=alg, phase=phase, to_txt=true, sort_function=sort_function)
    end
end


function run_phase6(;alg=10, phase=1::Int8)
    for names in Name
        for name in names
            phase6(name, alg=alg, phase=phase, to_txt=true)
        end
    end
end


function run_phase2_phase5(;alg="clustering-heuristic", sort_function=sort_processing_matrix)
    
    fullname = Full_Name()
    phase_2 = "swap_all-$(sort_function)"
    phase_3 = "move_job-$(sort_function)"

    for name in fullname
        vehicle = read_txt2(name, alg=alg, phase_2=phase_2)
        original_dis = distance_solomon_all(vehicle, name)
        vehicle = move_job(vehicle, sort_function=sort_function)
        final_dis = distance_solomon_all(vehicle, name)
        while original_dis != final_dis
            original_dis = deepcopy(final_dis)
            vehicle = move_job(vehicle, sort_function=sort_function)
            final_dis = distance_solomon_all(vehicle, name)
        end
        
        dirr = "phase2_phase5/$(sort_function)"
        save_to_txt(vehicle, alg=alg, phase_2=phase_2, phase_3=phase_3)
    end
end


function run_phase5_phase2(;alg="clustering-heuristic", sort_function=sort_processing_matrix)

    # alg = "clustering-heuristic"
    fullname = Full_Name()
    phase_3 = "swap_all-$(sort_function)"
    phase_2 = "move_job-$(sort_function)"
    for name in fullname

        # load phase 5 data
        vehicle = read_txt2(name, alg=alg, phase_2=phase_2, phase_3=nothing)

        # original_dis = distance_solomon_all(vehicle, name)
        original_dis, final_dis, vehicle = swap_all(vehicle, name, alg=alg, to_txt=false, sort_function=sort_function)
        # final_dis = distance_solomon_all(vehicle, name)
        while original_dis != final_dis
            # original_dis = deepcopy(final_dis)
            original_dis, final_dis, vehicle = swap_all(vehicle, name, alg=alg, to_txt=false, sort_function=sort_function)
            # final_dis = distance_solomon_all(vehicle, name)
        end

        # dirr = "phase5_phase2/$(sort_function)/Alg$alg-$(name).txt"
        dirr = "phase5_phase2/$(sort_function)"
        # save_to_txt(dirr, vehicle=vehicle, phase=5, phase_2=2)
        save_to_txt(vehicle, alg=alg, phase_2=phase_2, phase_3=phase_3)
    end
end


function run_phase7(;alg=10, phase=1, phase_2=1, iteration=1, disp=false)
    fullname = Full_Name()
    for name in fullname
        vehicle, original_dis, final_dis = phase7(name, alg=alg, phase_2=phase_2, iteration=1, disp=disp, phase=phase)
        println("name: $name, original dis: $original_dis, final dis: $final_dis, diff: $(original_dis - final_dis)")
    end
end


function Alg_phase5(alg)
    fullname = Full_Name()
    for name in fullname
        vehicle = read_txt(name, alg=alg)
        vehicle = move_job(vehicle, disp=true)
        # println("name: $name, total dis: $(distance_solomon_all(vehicle, name))")
    end
end


# function Conclusion()
#     df = create_csv([10 10 10], ["clustering-heuristic", "phase2_phase5", "phase5_phase2"], [1, 1, 1])
#     CSV.write("Conclusion.csv", df)
# end


function pull_out_insert(name::AbstractString, alg; sort_function=sort_processing_matrix)
    final_vehicle = read_txt(name, alg=alg)
    original_dis = distance_solomon_all(final_vehicle, name)
    for i in 1:2
        vehicle = deepcopy(final_vehicle)
        vehicle = fix_missing_vehicle(vehicle)
        # println("NV: $(vehicle["num_vehicle"]), original dis: $original_dis")
        
        # pull out
        pull_vehicle, job_out = pull_out(vehicle);
        pull_out_dis = distance_solomon_all(vehicle, name)
        pull_vehicle = fix_missing_vehicle(pull_vehicle)
        # println("NV: $(vehicle["num_vehicle"]), pull out dis: $pull_out_dis")
        
        # insert
        insert_vehicle = insert_job(pull_vehicle, num_of_all_job=100, disp=false)
        insert_dis = distance_solomon_all(insert_vehicle, name)
        # println("NV: $(vehicle["num_vehicle"]), insert   dis: $insert_dis")
        
        # swap 
        # original_dis, final_dis, vehicle = swap_all(vehicle, name, alg; phase=2, iteration=1, disp=true, to_txt=false, sort_function=sort_function)
        
        # move job
        final_vehicle = move_job(insert_vehicle, sort_function=sort_function)
        final_dis = distance_solomon_all(final_vehicle, final_vehicle["name"])

        # println("NV: $(final_vehicle["num_vehicle"]), final distane = $final_dis")
        
        # println("(pull_out_insert), name: $name, original dis: $original_dis, final dis: $(final_dis), diff: $(original_dis-final_dis)")
    end
end


function waiting_time(starting::Array, completion::Array)::Float64
	waitingtime = starting[1]
	for i in 1:length(starting) - 1
		waitingtime += (starting[i + 1] - completion[i])
	end
	return waitingtime
end


function total_waiting_time(vehicle::Dict)::Float64
    num_vehicle = vehicle["num_vehicle"]
    tol_waiting = 0
    for i in 1:num_vehicle
        starting = vehicle[i]["StartingTime"]
        completion = vehicle[i]["CompletionTime"]
        tol_waiting += waiting_time(starting, completion)
    end
    return tol_waiting
end


function total_waiting_time_vec(vehicle::Dict)
    num_vehicle = vehicle["num_vehicle"]
    tol_waiting = Dict()
    for i in 1:num_vehicle
        v = []
        starting = vehicle[i]["StartingTime"]
        completion = vehicle[i]["CompletionTime"]
        for k in 1:length(starting) - 1
            append!(v, starting[k + 1] - completion[k])
        end
        tol_waiting[i] = v
    end
    return tol_waiting
end


function max_completion_time(vehicle::Dict)
    num_vehicle = vehicle["num_vehicle"]
    m = []
    for i in 1:num_vehicle
        append!(m, maximum(vehicle[i]["CompletionTime"]))
    end
    return maximum(m)
end


function working_time(starting::Array, completion::Array)::Float64
    working = 0
    for i in 1:length(starting)
        working += (completion[i] - starting[i])
    end
    return working
end



function total_working_time(vehicle::Dict)::Float64
    num_vehicle = vehicle["num_vehicle"]
    total_working = 0
    for i in 1:num_vehicle
        starting = vehicle[i]["StartingTime"]
        completion = vehicle[i]["CompletionTime"]
        total_working += working_time(starting, completion)
    end
    return total_working
end


function conclusion_200(;dir="run_clustering_save")
    all_name = glob_only_name("*.csv", dir)
    for (i, name) in enumerate(all_name)
        println("$i, size: $(size(CSV.read("$dir/$(name).csv", DataFrame)))")
    end
    df = [CSV.read("$dir/$(name).csv", DataFrame) for name in all_name]
    min_TD = [minimum(dg[!, :TD]) for dg in df]
    max_TD = [maximum(dg[!, :TD]) for dg in df]
    min_NV = [minimum(dg[!, :NV]) for dg in df]
    max_NV = [maximum(dg[!, :NV]) for dg in df]
    df = DataFrame(name=all_name, min_NV=min_NV, max_NV=max_NV, min_TD=min_TD, max_TD=max_TD)
    return df
end


function conclusion_clustering_200()
    dir = "phase1/Alg-clustering-heuristic/"
    dirr = "run_clustering_save"

    all_name = glob_only_name("*.csv", dirr)
    dis = []
    num_vehicle = []

    # load benchmark
    solomon = read_Solomon()
    dis_solomon = [solomon[name]["Distance"] for name in all_name]
    NV_solomon = [solomon[name]["NV"] for name in all_name]

    for name in all_name
        # load data from txt
        vehicle = read_txt2(name, alg="clustering-heuristic")

        append!(dis, vehicle["TotalDistance"])
        append!(num_vehicle, vehicle["num_vehicle"])
    end

    df = DataFrame(name=all_name, NV=num_vehicle, NV_solo=NV_solomon, dis=dis, dis_solo=dis_solomon, diff=dis-dis_solomon)
    return df
end



function total_completion_time(vehicle::Dict)
    # vehicle = fix_missing_vehicle(vehicle)
    num_vehicle = vehicle["num_vehicle"]
    TotalCompletionTime = 0
    name = vehicle["name"]
    # data = load_all_solomon_100()[name]
    service = service_time(name)
    if name == "case_study"
        case_study_size = vehicle["case_size"]
        case_study_num = vehicle["num"]
        p, d, low_d, demand, service, distance_matrix, solomon_demand = import_case_study(case_study_size, case_study_num)
    else
        p, d, low_d, demand, solomon_demand, service, distance_matrix = load_all_data(name)
    end
    
    for i in 1:num_vehicle
        sch = vehicle[i]["sch"]
        if isempty(sch)
            continue
        else
            starting, completion = starting_completion_time(sch, distance_matrix, low_d, service)

            # add end point
            # last_job = sch[end]

            # dis_last = p[last_job, last_job]
            TotalCompletionTime += sum(completion)
            # if name == "case_study"
            #     LastCompletionTime = dis_last + service[last_job]
            # else
            #     LastCompletionTime = dis_last + service
            # end
            # TotalCompletionTime += LastCompletionTime
        end
    end
    return TotalCompletionTime
end


function total_completion_time(vehicle::Dict, name::AbstractString)
    return total_completion_time(vehicle)
end


function conclusion_waiting_time(alg; phase_2=nothing, pre_dir=nothing)

    fullname = glob_only_name("*.txt", "solutions_benchmark")
    TotalWaitingTime_alg = []
    TotalWaitingTime_benchmark = []
    TotalDistanceAlg = []
    TotalDistanceBenchmark = []
    TotalCompletionAlg = []
    TotalCompletionBenchmark = []
    for name in fullname
        # @show name
        # vehicle_from_alg = read_txt2(name, alg="clustering-heuristic", phase_2="swap_all-sort_completion_time")
        vehicle_from_alg = read_txt2(name, alg=alg, phase_2=phase_2, pre_dir=pre_dir)
        # vehicle_from_alg = read_txt(name, phase="phase5_phase2")
        vehicle_benchmark = read_txt2(name, dir="solutions_benchmark")
        # @show total_waiting_time(vehicle_from_alg)
        append!(TotalWaitingTime_alg, total_waiting_time(vehicle_from_alg))
        append!(TotalWaitingTime_benchmark, total_waiting_time(vehicle_benchmark))
        append!(TotalDistanceAlg, distance_solomon_all(vehicle_from_alg, name))
        append!(TotalDistanceBenchmark, distance_solomon_all(vehicle_benchmark, name))
        append!(TotalCompletionAlg, total_completion_time(vehicle_from_alg))
        append!(TotalCompletionBenchmark, total_completion_time(vehicle_benchmark))
        # @show total_waiting_time(vehicle_benchmark)
    end

    Solomon = read_Solomon()
    TotalDistanceSolomon = [Solomon[name]["Distance"] for name in fullname]
    df = DataFrame(name=fullname, 
                    WA=TotalWaitingTime_alg, 
                    WB=TotalWaitingTime_benchmark, 
                    Diff_W=TotalWaitingTime_alg-TotalWaitingTime_benchmark,
                    CA=TotalCompletionAlg,
                    CB=TotalCompletionBenchmark,
                    Diff_C=TotalCompletionAlg-TotalCompletionBenchmark,
                    DA=TotalDistanceAlg, 
                    DB=TotalDistanceBenchmark, 
                    DS=TotalDistanceSolomon,)
    CSV.write("waiting_time_$(alg)_$(phase_2).csv", df)
    
    # find waiting time 
    w = findall(x -> x < -0.001, TotalWaitingTime_alg-TotalWaitingTime_benchmark)
    println("there is $(length(w)) of $(length(fullname)) cases have total waiting time less than benchmark")
    less_than_cases = fullname[w]
    dg = df[w, :]
    CSV.write("waiting_time_less_$(alg)_$(phase_2).csv", dg)


    # find completion time 
    r = findall(x -> x < -0.001, TotalCompletionAlg-TotalCompletionBenchmark)
    println("there is $(length(r)) of $(length(fullname)) cases have total completion time less than benchmark")
    less_than_cases = fullname[r]
    dh = df[r, :]
    CSV.write("completion_time_less_$(alg)_$(phase_2).csv", dh)

    return df
end


function conclusion_waiting_time_diff(;pre_dir=nothing)
    fullname = glob_only_name("*.txt", "solutions_benchmark")
    df = DataFrame(name=fullname,
                    swap_processing_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all_no_update-sort_processing_matrix", pre_dir=pre_dir)[:Diff_W],
                    swap_completion_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all_no_update-sort_completion_time", pre_dir=pre_dir)[:Diff_W],
                    swap_processing=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all-sort_processing_matrix", pre_dir=pre_dir)[:Diff_W],
                    swap_completion=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all-sort_completion_time", pre_dir=pre_dir)[:Diff_W],
                    move_processing_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="move_all_no_update-sort_processing_matrix", pre_dir=pre_dir)[:Diff_W],
                    move_completion_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="move_all_no_update-sort_completion_time", pre_dir=pre_dir)[:Diff_W],
                    move_processing=conclusion_waiting_time("clustering-heuristic", phase_2="move_all-sort_processing_matrix", pre_dir=pre_dir)[:Diff_W],
                    move_completion=conclusion_waiting_time("clustering-heuristic", phase_2="move_all-sort_completion_time", pre_dir=pre_dir)[:Diff_W],
                    )

    if isnothing(pre_dir)
        CSV.write("conclusion_waiting_time_diff.csv", df)
    else
        CSV.write("conclusion_waiting_time_diff_completion_time.csv", df)
    end
    return df
end


function conclusion_completion_time_diff(;pre_dir=nothing)
    fullname = glob_only_name("*.txt", "solutions_benchmark")
    df = DataFrame(name=fullname,
                    swap_processing_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all_no_update-sort_processing_matrix", pre_dir=pre_dir)[:Diff_C],
                    swap_completion_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all_no_update-sort_completion_time", pre_dir=pre_dir)[:Diff_C],
                    swap_processing=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all-sort_processing_matrix", pre_dir=pre_dir)[:Diff_C],
                    swap_completion=conclusion_waiting_time("clustering-heuristic", phase_2="swap_all-sort_completion_time", pre_dir=pre_dir)[:Diff_C],
                    move_processing_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="move_all_no_update-sort_processing_matrix", pre_dir=pre_dir)[:Diff_C],
                    move_completion_no_update=conclusion_waiting_time("clustering-heuristic", phase_2="move_all_no_update-sort_completion_time", pre_dir=pre_dir)[:Diff_C],
                    move_processing=conclusion_waiting_time("clustering-heuristic", phase_2="move_all-sort_processing_matrix", pre_dir=pre_dir)[:Diff_C],
                    move_completion=conclusion_waiting_time("clustering-heuristic", phase_2="move_all-sort_completion_time", pre_dir=pre_dir)[:Diff_C],
                    )

    if isnothing(pre_dir)
        CSV.write("conclusion_completion_time_diff.csv", df)
    else
        CSV.write("conclusion_completion_time_diff_completion_time.csv", df)
    end

    return df
end


function phase3_random_swap_move(name; alg="clustering-heuristic", phase_2=nothing, phase_3=nothing, start_iter=1, pre_dir=nothing, to_txt=true, num_swap=2, max_iter=500, distance_function=total_completion_time::Function)
    
    # define directory
    # base_dir = find_dir(name, alg=alg, phase_2=phase_2, phase_3=phase_3, pre_dir=pre_dir)
    
    # define parameters
    iter = start_iter
    not_improve = 1
    
    # load vehicle
    vehicle = read_txt2(name, alg=alg, phase_2=phase_2, phase_3=phase_3, pre_dir=pre_dir)
    original_makespan = distance_function(vehicle)
    best_vehicle = deepcopy(vehicle)
    best_makespan = deepcopy(original_makespan)
    move_vehicle = deepcopy(vehicle)
    move_makespan = deepcopy(original_makespan)

    # define name of phase3
    phase_3 = "random_swap_move"
    
    while iter <= max_iter
        
        println("$name: iteration: $iter")
        
        # if do this iteration 
        if not_improve <= 10
            current_vehicle = deepcopy(move_vehicle)
            current_makespan = distance_function(current_vehicle)
        else
            current_vehicle = deepcopy(best_vehicle)
            current_makespan = distance_function(current_vehicle)
            println("current makespan: $current_makespan")
            not_improve = 1
        end
        
        # fix empty random_swap
        random_vehicle = random_swap(current_vehicle, num_swap=num_swap)
        random_makespan = distance_function(random_vehicle)
        println("random  makespan: $random_makespan")
        
        move_vehicle = move_job_no_update(random_vehicle, sort_function=sort_processing_matrix, distance_function=distance_function)
        move_makespan = distance_function(move_vehicle)
        println("phase2  makespan: $move_makespan")

        if move_makespan < best_makespan
            best_vehicle = deepcopy(move_vehicle)
            best_makespan = deepcopy(move_makespan)
            not_improve = 1
        else
            println("not improve: $not_improve")
            not_improve += 1
        end
        
        # save solution to text file
        if to_txt == true
            save_to_txt(move_vehicle, alg=alg, phase_2=phase_2, phase_3=phase_3, phase_3_iter=iter, pre_dir=pre_dir)
        end
        iter += 1
    end
end


function phase3_random_swap_move_case_study(case_size::Int, num::Int; start_iter=1::Int, to_txt=true::Bool, num_swap=2::Int, max_iter=500::Int, distance_function=total_completion_time::Function)
    
    # define parameters
    iter = start_iter
    not_improve = 1
    
    # load vehicle
    vehicle = read_case_study(case_size, num, phase2_swap=true, distance_function=distance_function)
    original_makespan = distance_function(vehicle)
    best_vehicle = deepcopy(vehicle)
    best_makespan = deepcopy(original_makespan)
    move_vehicle = deepcopy(vehicle)
    move_makespan = deepcopy(original_makespan)

    # define name of phase3
    phase_3 = "random_swap_move"
    
    while iter <= max_iter
        
        println("case_study phase3: iteration: $iter best total completion time: $best_makespan")
        
        # if do this iteration 
        if not_improve <= 10
            current_vehicle = deepcopy(move_vehicle)
            current_makespan = distance_function(current_vehicle)
        else
            current_vehicle = deepcopy(best_vehicle)
            current_makespan = distance_function(current_vehicle)
            println("current makespan: $current_makespan")
            not_improve = 1
        end
        
        # fix empty random_swap
        random_vehicle = random_swap(current_vehicle, num_swap=num_swap)
        random_makespan = distance_function(random_vehicle)
        println("random  makespan: $random_makespan")
        
        move_vehicle = move_job_no_update_case_study(random_vehicle, sort_function=sort_processing_matrix, distance_function=distance_function, disp=false)
        move_makespan = distance_function(move_vehicle)
        println("phase2  makespan: $move_makespan")

        if move_makespan < best_makespan
            best_vehicle = deepcopy(move_vehicle)
            best_makespan = deepcopy(move_makespan)
            not_improve = 1
        else
            println("not improve: $not_improve")
            not_improve += 1
        end
        
        # save solution to text file
        if to_txt
            dirr = "case_study_solutions/phase3/casestudy$(case_size)-$(num)-$(distance_function)_clustering_swap_random-$(iter).txt"
            io = open(dirr, "w")
            for i in 1:move_vehicle["num_vehicle"]
                for j in move_vehicle[i]["sch"]
                    write(io, "$j ")
                end
                write(io, "\n")
            end
            close(io)
        end

        iter += 1
    end

    # save best vehicle
    if to_txt
        dirr = "case_study_solutions/casestudy$(case_size)-$(num)-$(distance_function)_clustering_swap_random.txt"
        io = open(dirr, "w")
        for i in 1:best_vehicle["num_vehicle"]
            for j in best_vehicle[i]["sch"]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)
    end
end


function phase3_makespan(name; alg="clustering-heuristic", phase_2="move_all_no_update-sort_processing_matrix", phase_3="random_swap_move", pre_dir=nothing, objective_function=total_completion_time::Function)
    
    # dir = find_dir(name, alg=alg, phase_2=phase_2, phase_3=phase_3, pre_dir=pre_dir)
    if isnothing(pre_dir)
        dir = "phase1/Alg-$alg/$phase_2/$phase_3/$name"
    else
        dir = "phase1_completion_time/phase1/Alg-$alg/$phase_2/$phase_3/$name"
    end


    # define all name
    # alg = "clustering-heuristic"
    # phase_2 = "move_all_no_update-sort_processing_matrix"
    # phase_3 = "random_swap_move"
    
    num_of_iterations = length(glob("*.txt", dir))

    # makespan = total completion time
    makespan = []

    # Phase 1
    vehicle = read_txt2(name, alg=alg, pre_dir=pre_dir)
    t = objective_function(vehicle)
    append!(makespan, t)

    # Phase 2
    vehicle = read_txt2(name, alg=alg, phase_2=phase_2, pre_dir=pre_dir)
    t = objective_function(vehicle)
    append!(makespan, t)
    
    # Phase 3
    for i in 1:num_of_iterations
        vehicle = read_txt2(name, alg=alg, phase_2=phase_2, phase_3=phase_3, phase_3_iter=i, pre_dir=pre_dir)
        t = objective_function(vehicle)
        append!(makespan, t)
    end

    return makespan
end


function phase3_graph()
    nothing
end


function create_csv_makespan_all_phase()
    # FullName = glob_only_name("*.txt", "solutions_benchmark")
    FullName = Full_Name()

    allname = []
    c_solomon = []
    d_solomon = []
    w_solomon = []
    phase1 = []
    phase2 = []
    phase3 = []
    dis_phase1 = []
    dis_phase2 = []
    dis_phase3 = []
    w_phase1 = []
    w_phase2 = []
    w_phase3 = []


    for name in FullName

        # if name == "c108"
        #     break
        # end

        y = try phase3_makespan(name, pre_dir="phase1_completion_time") catch e; [missing, missing] end

        d = try phase3_makespan(name, pre_dir="phase1_completion_time", objective_function=distance_solomon_all) catch e; [missing, missing] end

        w = try phase3_makespan(name, pre_dir="phase1_completion_time", objective_function=total_waiting_time) catch e; [missing, missing] end

        min_y_index = try argmin(y) catch e; missing end
        min_y = try y[min_y_index] catch e; missing end
        min_d = try d[min_y_index] catch e; missing end
        min_w = try w[min_y_index] catch e; missing end
        # min_d = try minimum(d) catch e; missing end
        # min_w = try minimum(w) catch e; missing end

        t = try total_completion_time(read_txt2(name, pre_dir="solutions_benchmark")) catch e; missing end
        
        dis_t = try distance_solomon_all(read_txt2(name, pre_dir="solutions_benchmark")) catch e; missing end

        waiting_time = try total_waiting_time(read_txt2(name, pre_dir="solutions_benchmark")) catch e; missing end

        append!(dis_phase1, [d[1]])
        append!(dis_phase2, [d[2]])
        append!(dis_phase3, [min_d])
        append!(phase1, [y[1]])
        append!(phase2, [y[2]])
        append!(phase3, [min_y])
        append!(w_phase1, [w[1]])
        append!(w_phase2, [w[2]])
        append!(w_phase3, [min_w])
        append!(allname, [name])
        append!(c_solomon, [t])
        append!(d_solomon, [dis_t])
        append!(w_solomon, [waiting_time])
        
    end

    df = DataFrame(Name=allname, 
                    Solomon=c_solomon, 
                    Phase1=phase1, 
                    Phase2=phase2, 
                    Phase3=phase3, 
                    Dis_Solomon=d_solomon, 
                    Dis_phase1=dis_phase1, 
                    Dis_phase2=dis_phase2, 
                    Dis_phase3=dis_phase3,
                    W_solomon=w_solomon,
                    W_phase1=w_phase1,
                    W_phase2=w_phase2,
                    W_phase3=w_phase3,
                    )
    CSV.write("Phase3Conclusion.csv", df)
end


# include("read_file.jl")
# and then run this function
function run_in_com_arjarn(;start_iter=1, pre_dir="phase1_completion_time")

    # define all name
    all_name = glob_only_name("*.txt", "solutions_benchmark")
    alg = "clustering-heuristic"
    phase_2 = "move_all_no_update-sort_processing_matrix"
    phase_3="random_swap_move"
    

    # run phase 3 for all instances
    for name in all_name[start_iter:end]
        println("......................running phase 3 of $name..................................")
        phase3_random_swap_move(name, alg=alg, phase_2=phase_2, to_txt=true, max_iter=500, num_swap=2, start_iter=1, pre_dir=pre_dir)
    end
end


function plot_scatter_points()

    Solomon = load_all_solomon_100()

    c101 = Solomon["c101"]
    xcoor = c101["xcoor"]
    ycoor = c101["ycoor"]
    xcoor = [xcoor[i] for i in 0:100]
	ycoor = [ycoor[i] for i in 0:100]
    marker_solomon =  vcat([1], 2*ones(Int, 100))

    p1 = plot()
    p1 = scatter([xcoor[1]], [ycoor[1]], markershape=:diamond)
    p1 = scatter!(xcoor[2:end], ycoor[2:end], legend=false)
    savefig(p1, "scatter-C.png")
    savefig(p1, "scatter-C.pdf")
    # savefig(p1, "scatter-C.eps")
    
    r101 = Solomon["r101"]
    xcoor = r101["xcoor"]
    ycoor = r101["ycoor"]
    xcoor = [xcoor[i] for i in 0:100]
	ycoor = [ycoor[i] for i in 0:100]
    marker_solomon =  vcat([1], 2*ones(Int, 100))
    
    p2 = plot()
    # p2 = scatter!(xcoor, ycoor, legend=false, marker_z=marker_solomon, color=:lightrainbow)
    p2 = scatter([xcoor[1]], [ycoor[1]], markershape=:diamond)
    p2 = scatter!(xcoor[2:end], ycoor[2:end], legend=false)
    savefig(p2, "scatter-R.png")
    savefig(p2, "scatter-R.pdf")
    # savefig(p2, "scatter-R.eps")
    
    rc101 = Solomon["rc101"]
    xcoor = rc101["xcoor"]
    ycoor = rc101["ycoor"]
    xcoor = [xcoor[i] for i in 0:100]
	ycoor = [ycoor[i] for i in 0:100]
    marker_solomon =  vcat([1], 2*ones(Int, 100))
    
    p3 = plot()
    p3 = scatter([xcoor[1]], [ycoor[1]], markershape=:diamond)
    p3 = scatter!(xcoor[2:end], ycoor[2:end], legend=false)
    # p3 = scatter!(xcoor, ycoor, legend=false, marker_z=marker_solomon, color=:lightrainbow)
    savefig(p3, "scatter-RC.png")
    savefig(p3, "scatter-RC.pdf")
    # savefig(p3, "scatter-RC.eps")
end


function range_of_time_window()
    Solomon = load_all_solomon_100()
    for i in 1:8
        C1type =  Solomon["c10$i"]
        R1type =  Solomon["r10$i"]
        RC1type = Solomon["rc10$i"]
        C2type =  Solomon["c20$i"]
        R2type =  Solomon["r20$i"]
        RC2type = Solomon["rc20$i"]

        lower_d_C1 =  [C1type["readytime"][i] for i in 1:100]
        lower_d_R1 =  [R1type["readytime"][i] for i in 1:100]
        lower_d_RC1 = [RC1type["readytime"][i] for i in 1:100]
        lower_d_C2 =  [C2type["readytime"][i] for i in 1:100]
        lower_d_R2 =  [R2type["readytime"][i] for i in 1:100]
        lower_d_RC2 = [RC2type["readytime"][i] for i in 1:100]
        
        upper_d_C1 =  [C1type["duedate"][i] for i in 1:100]
        upper_d_R1 =  [R1type["duedate"][i] for i in 1:100]
        upper_d_RC1 = [RC1type["duedate"][i] for i in 1:100]
        upper_d_C2 =  [C2type["duedate"][i] for i in 1:100]
        upper_d_R2 =  [R2type["duedate"][i] for i in 1:100]
        upper_d_RC2 = [RC2type["duedate"][i] for i in 1:100]

        diff_d_C1  = upper_d_C1 - lower_d_C1
        diff_d_R1  = upper_d_R1 - lower_d_R1
        diff_d_RC1 = upper_d_RC1 - lower_d_RC1
        diff_d_C2  = upper_d_C2 - lower_d_C2
        diff_d_R2  = upper_d_R2 - lower_d_R2
        diff_d_RC2 = upper_d_RC2 - lower_d_RC2

        max_d_C1  = maximum(diff_d_C1)
        max_d_R1  = maximum(diff_d_R1)
        max_d_RC1 = maximum(diff_d_RC1)
        max_d_C2  = maximum(diff_d_C2)
        max_d_R2  = maximum(diff_d_R2)
        max_d_RC2 = maximum(diff_d_RC2)

        min_d_C1  = minimum(diff_d_C1)
        min_d_R1  = minimum(diff_d_R1)
        min_d_RC1 = minimum(diff_d_RC1)
        min_d_C2  = minimum(diff_d_C2)
        min_d_R2  = minimum(diff_d_R2)
        min_d_RC2 = minimum(diff_d_RC2)

        println("i: $i") 
        println("C1type  min: $min_d_C1,  max: $max_d_C1,  diff: $(min_d_C1-max_d_C1)")
        println("R1type  min: $min_d_R1,  max: $max_d_R1,  diff: $(min_d_R1-max_d_R1)")
        println("RC1type min: $min_d_RC1, max: $max_d_RC1, diff: $(min_d_RC1-max_d_RC1)")
        println("C2type  min: $min_d_C2,  max: $max_d_C2,  diff: $(min_d_C2-max_d_C2)")
        println("R2type  min: $min_d_R2,  max: $max_d_R2,  diff: $(min_d_R2-max_d_R2)")
        println("RC2type min: $min_d_RC2, max: $max_d_RC2, diff: $(min_d_RC2-max_d_RC2)")
        println("")
    end
end


function vec_total_completion_time_phase2_all_iteration(case_size::Int64, num::Int64, max_iteration::Int64)
    vec_t = []
    for i in 1:max_iteration
        vehicle = read_case_study(case_size, num, phase2_swap=true, phase2_iteration=i)
        t = total_completion_time(vehicle)
        append!(vec_t, t)
    end
    return vec_t
end

# save graph with 3 types
function save_fig(fig, dir::String, name::String)
    savefig(fig, dir*"/$(name).png")
    savefig(fig, dir*"/$(name).pdf")
    savefig(fig, dir*"/$(name).eps")
end


# plot graph and save from phase2 of case study
function plot_total_completion_time_phase2(case_size::Int64, num::Int64, max_iteration::Int64)
    vec_t = vec_total_completion_time_phase2_all_iteration(case_size, num, max_iteration)
    fig = plot(vec, xaxis="iteration", yaxis="total completion time", label="")
    save_fig(fig, "case_study_solutions/fig", "case_study_clustering_swap$(case_size)-$(num)")
end


function the_number_of_jobs_for_each_vehicle(vehicle::Dict)
    num_vehicle = vehicle["num_vehicle"]
    num_jobs = []
    for i in 1:num_vehicle
        append!(num_jobs, length(vehicle[i]["sch"]))
    end
    return num_jobs
end


function conclusion_case_study()

    vehicle1_com = read_case_study(200, 1, distance_function=total_completion_time)
    vehicle2_com = read_case_study(200, 1, distance_function=total_completion_time, phase2_swap=true)

    vehicle1_dis = read_case_study(200, 1, distance_function=total_distance_case_study)
    vehicle2_dis = read_case_study(200, 1, distance_function=total_distance_case_study, phase2_swap=true)

    waiting1_com = total_waiting_time(vehicle1_com)
    waiting2_com = total_waiting_time(vehicle2_com)

    waiting1_dis = total_waiting_time(vehicle1_dis)
    waiting2_dis = total_waiting_time(vehicle2_dis)

    max1_com = max_completion_time(vehicle1_com)
    max2_com = max_completion_time(vehicle2_com)

    max1_dis = max_completion_time(vehicle1_dis)
    max2_dis = max_completion_time(vehicle2_dis)

    work1_com = total_working_time(vehicle1_com)
    work1_dis = total_working_time(vehicle1_dis)

    work2_com = total_working_time(vehicle2_com)
    work2_dis = total_working_time(vehicle2_dis)

    println("total waiting  time phase 1 (com), (dis): $(waiting1_com), $(waiting1_dis)")
    println("total waiting  time phase 2 (com), (dis): $(waiting2_com), $(waiting2_dis)")
    println("max completion time phase 1 (com), (dis): $(max1_com), $(max1_dis)")
    println("max completion time phase 2 (com), (dis): $(max2_com), $(max2_dis)")
    println("total working  time phase 1 (com), (dis): $(work1_com), $(work1_dis)")
    println("total working  time phase 2 (com), (dis): $(work2_com), $(work2_dis)")
end



function waiting_time_for_each_vehicle(vehicle::Dict)
    tol_waiting = total_waiting_time_vec(vehicle)
    w = []
    for i in 1:length(tol_waiting)
        append!(w, sum(tol_waiting[i])/3600)
        println("total waiting time for nurse $i: $(sum(tol_waiting[i])/3600)")
    end
    println("average: $(mean(w))")
end


function load_phase3_best_solution(name, pre_dir="phase1_completion_time")

    # load all total completion time of all phases
    total_C = phase3_makespan(name, pre_dir=pre_dir)[3:end]

    # find the best vehicle
    position_min = argmin(total_C)

    # load_ vehicle
    vehicle_phase_3 = read_txt2(name, alg="clustering-heuristic", pre_dir=pre_dir, phase_2="move_all_no_update-sort_processing_matrix", phase_3="random_swap_move", phase_3_iter=position_min)

    return vehicle_phase_3
end


function load_phase3_best_solution_case_study(case_size, case_num)
    dir = "case_study_solutions/phase3/"
    num_of_iter = length(glob("casestudy$(case_size)-$(case_num)_clustering_swap_random-*", dir))

    vehicle = read_case_study(case_size, case_num, phase3=true, distance_function=total_completion_time)

    return vehicle
end
