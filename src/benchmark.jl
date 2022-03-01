
# Solomon benchmark names:
# Name list = ["r", "c", "rc"]
r1  =  ["r$(i)"   for i in 101:112]
r2  =  ["r$(i)"   for i in 201:211]
c1  =  ["c$(i)"   for i in 101:109]
c2  =  ["c$(i)"   for i in 201:208]
rc1 =  ["rc$(i)"  for i in 101:108]
rc2 =  ["rc$(i)"  for i in 201:208]

vehicle_capacity = Dict("r1" => 200, "r2" => 1000, "c1" => 200, "c2" => 700, "rc1" => 200, "rc2" => 1000)

Name = [r1, r2, c1, c2, rc1, rc2]


function benchmark(;duedate=true, low_duedate=false)

    dir = "Benchmark"

    data = Dict()

    if duedate == true
        for names in Name
            for name in names
                data["$(name)"] = Dict()
                folder = joinpath(dir, name)
                dd = matread(joinpath(folder, "$(name).mat"))
                
                # due  date
                d = dd["duedate"]
                d = dropdims(d, dims=2)
                per = sortperm(d)
                data["$(name)"]["per"] = per
                data["$(name)"]["d"] = d[per]
                
                # low_d
                low_d = dd["lduedate"]
                # low_d = dropdims(low_d, dims=2)
                # per = sortperm(low_d)
                data["$(name)"]["low_d"] = low_d[per]

                # processing time
                p =  dd["p"]
                data["$(name)"]["p"] = p[per, per]

                reper = Dict()
                j = 1
                for i in per
                    reper[i] = j
                    j += 1
                end
                reper = [reper[i] for i in 1:100]
                data["$(name)"]["reper"] = reper

            end
        end
    elseif low_duedate == true
        for names in Name
            for name in names
                data["$(name)"] = Dict()
                folder = joinpath(dir, name)
                dd = matread(joinpath(folder, "$(name).mat"))
                
                # due  date
                low_d = dd["lduedate"]
                low_d = dropdims(low_d, dims=2)
                per = sortperm(low_d)
                data["$(name)"]["per"] = per
                data["$(name)"]["low_d"] = low_d[per]
                
                # low_d
                d = dd["duedate"]
                # low_d = dropdims(low_d, dims=2)
                # per = sortperm(low_d)
                data["$(name)"]["d"] = d[per]

                # processing time
                p =  dd["p"]
                data["$(name)"]["p"] = p[per, per]

                reper = Dict()
                j = 1
                for i in per
                    reper[i] = j
                    j += 1
                end
                reper = [reper[i] for i in 1:100]
                data["$(name)"]["reper"] = reper

            end
        end
    end

    # test equality for sortperm
    test_perm = false
    if test_perm == true
        for names in Name
            for name in names
                folder = joinpath(dir, name)
                dd = matread(joinpath(folder, "$(name).mat"))
                low_d = dd["lduedate"]
                d = dd["duedate"]
                d = dropdims(d, dims=2)
                low_d = dropdims(low_d, dims=2)
                per1 = sortperm(d)
                per2 = sortperm(low_d)
                println("per1 == per 2 : $(per1 == per2)")
            end
        end
    end
    return data
end


function Reverse_permutation(permutation)
    reper = Dict()
    j = 1
    for i in permutation
        reper[i] = j
        j += 1
    end
    reper = [reper[i] for i in 1:100]
    return reper
end


function benchmark_non_perm()

    @eval using MAT
    dir = "Benchmark"

    data = Dict()
    for names in Name
        for name in names
            data["$(name)"] = Dict()
            folder = joinpath(dir, name)
            dd = matread(joinpath(folder, "$(name).mat"))
            
            # due  date
            d = dd["duedate"]
            d = dropdims(d, dims=2)
            data["$(name)"]["d"] = d
            
            # low_d
            low_d = dd["lduedate"]
            # low_d = dropdims(low_d, dims=2)
            # per = sortperm(low_d)
            data["$(name)"]["low_d"] = low_d
            
            # processing time
            p =  dd["p"]
            data["$(name)"]["p"] = p
            
        end
    end
    return data
    
end

# for load original ata
function get_solomon(name::String)
    
    @eval using MAT
    dir = "Benchmark/"
    
    folder = joinpath(dir, name)
    dd = matread(joinpath(folder, "$(name).mat"))

    p = dd["p"]
    d = dd["duedate"]
    low_d = dd["lduedate"]

    return p, d, low_d
end
    

# this is a part of load_all_solomon_100() function
function load_solomon_100(name::AbstractString)
    detail = Dict()
    name = uppercase(name)
    dir = "solomon_100"
    data = Dict()
    # open("solomon_100//$(name).txt") do file
    open(joinpath(@__DIR__, "..", "solomon_100", "$name.txt")) do file
        lines = eachline(file)
        for i in enumerate(lines)
            data[i[1]] = split(i[2])
            # println("line: $(i[1]) ", split(i[2]))
        end
    end

    # convert text to Integer
    detail["max_vehicle"] = parse(Int64, data[5][1])
    detail["capacity"] = parse(Int64, data[5][2])

    # convert text to Integer
    for i in 10:110
        data[i] = [parse(Int64, j) for j in data[i]]
    end 
    # cooerdinate
    for i = 0:100
        detail[i] = data[10 + i]
    end
    return detail
end


function load_solomon_100_random(name::AbstractString, num_of_customers::Int)
    detail = Dict()
    name = uppercase(name)
    dir = "solomon_100"
    data = Dict()
    open("solomon_100//$(name).txt") do file
        lines = eachline(file)
        for i in enumerate(lines)
            data[i[1]] = split(i[2])
            # println("line: $(i[1]) ", split(i[2]))
        end
    end

    # convert text to Integer
    detail["max_vehicle"] = parse(Int64, data[5][1])
    detail["capacity"] = parse(Int64, data[5][2])

    # convert text to Integer
    for i in 10:num_of_customers+10
        data[i] = [parse(Int64, j) for j in data[i]]
    end 
    # cooerdinate
    for i = 0:num_of_customers
        detail[i] = data[10 + i]
    end
    return detail
end


function read_solomon(class::AbstractString, num_jobs::Int64, num_instance::Int64)
    # add Dict
    detail = Dict()
    detail["num_jobs"] = num_jobs

    class = uppercase(class)
    dir = "homberger_$(num_jobs)_customer_instances"
    num_job = Int64(num_jobs / 100)
    data = Dict()

    open("$(dir)/$(class)_$(num_job)_$(num_instance).TXT") do file
        lines = eachline(file)
        for i in enumerate(lines)
            data[i[1]] = split(i[2])
        end
    end
    
    # convert text to Integer
    detail["max_vehicle"] = parse(Int64, data[5][1])
    detail["capacity"] = parse(Int64, data[5][2])
    
    # convert text to Integer
    for i in 10:length(data)
        data[i] = [parse(Int64, j) for j in data[i]]
    end 

    # cooerdinate
    for i = 0:num_jobs
        detail[i] = data[10 + i]
    end
    return detail
end

function AllName(;num_job=[200, 400])
    name = []
    for n in num_job
        dir = "homberger_$(n)_customer_instances"
        g = glob("*.TXT", dir)
        gg1 = split.(g, "/")
        gg2 = split.(g, "\\")
        ggg = try 
            split.([m[2] for m in gg1], ".")
        catch e
            split.([m[2] for m in gg2], ".")
        end
        append!(name, [m[1] for m in ggg])
    end
    return name
end



function All_solution_name()
    name = []
    for n in num_job
        dir = "solutions_benchmark/"
        g = glob("*.txt", dir)
        gg1 = split.(g, "/")
        gg2 = split.(g, "\\")
        ggg = try 
            split.([m[2] for m in gg1], ".")
        catch e
            split.([m[2] for m in gg2], ".")
        end
        append!(name, [m[1] for m in ggg])
    end
    return name
end

# load all data from Solomon, return in the dictionary form(not sort)
# Dictionary: solomon[name of data][type of data][No. of customer]
# types of data including:
#   1. cus-no    = all No. of customer 0,1,2,3,...,100
#   2. xcoor     = X coordinate 
#   3. ycoor     = Y coordinate 
#   4. demand    = demand 
#   5. duedate   = due date 
#   6. readytime = ready time
#   7. service   = service time of all customer, origin has 0 service time
function load_all_solomon_200(;duedate=true, low_dudate=false, num_job=[200, 400, 600, 800, 1000])

    # create Dict
    solomon200 = Dict()

    for name in AllName(num_job=num_job)

        # read from txt file
        class, num_jobs, num_instance = split(name, "_")
        num_jobs = parse(Int64, num_jobs) * 100
        num_instance = parse(Int64, num_instance)
        data = read_solomon(class, num_jobs, num_instance)
        
        solomon200["$(name)"]              = Dict()
        solomon200["$(name)"]["cus-no"]    = Dict(a => data[a][1] for a in 0:num_jobs)
        solomon200["$(name)"]["xcoor"]     = Dict(a => data[a][2] for a in 0:num_jobs)
        solomon200["$(name)"]["ycoor"]     = Dict(a => data[a][3] for a in 0:num_jobs)
        solomon200["$(name)"]["demand"]    = Dict(a => data[a][4] for a in 0:num_jobs)
        solomon200["$(name)"]["readytime"] = Dict(a => data[a][5] for a in 0:num_jobs)
        solomon200["$(name)"]["duedate"]   = Dict(a => data[a][6] for a in 0:num_jobs)
        solomon200["$(name)"]["service"]   = Dict(a => data[a][7] for a in 0:num_jobs)
        
        # sort
        d = [solomon200["$(name)"]["duedate"][i] for i in 1:num_jobs]
        per = sortperm(d)
        solomon200["$(name)"]["per"]       = per
        solomon200["$(name)"]["reper"]     = Reverse_permutation(per)
        solomon200["$(name)"]["num_jobs"]  = num_jobs
        solomon200["$(name)"]["capacity"]  = data["capacity"]
    end
    return solomon200
end

# load all data from Solomon, return in the dictionary form(not sort)
# Dictionary: solomon[name of data][type of data][No. of customer]
# types of data including:
#   1. cus-no    = all No. of customer 0,1,2,3,...,100
#   2. xcoor     = X coordinate 
#   3. ycoor     = Y coordinate 
#   4. demand    = demand 
#   5. duedate   = due date 
#   6. readytime = ready time
#   7. service   = service time of all customer, origin has 0 service time
function load_all_solomon_100(;duedate=true, low_dudate=false)
    solomon100 = Dict()
    for names in Name
        for name in names
            # read from txt file
            data = load_solomon_100(name)
            
            solomon100["$(name)"]              = Dict()
            solomon100["$(name)"]["cus-no"]    = Dict(a => data[a][1] for a in 0:100)
            solomon100["$(name)"]["xcoor"]     = Dict(a => data[a][2] for a in 0:100)
            solomon100["$(name)"]["ycoor"]     = Dict(a => data[a][3] for a in 0:100)
            solomon100["$(name)"]["demand"]    = Dict(a => data[a][4] for a in 0:100)
            solomon100["$(name)"]["readytime"] = Dict(a => data[a][5] for a in 0:100)
            solomon100["$(name)"]["duedate"]   = Dict(a => data[a][6] for a in 0:100)
            solomon100["$(name)"]["service"]   = Dict(a => data[a][7] for a in 0:100)
            
            # sort
            d = [solomon100["$(name)"]["duedate"][i] for i in 1:100]
            per = sortperm(d)
            solomon100["$(name)"]["per"]       = per
            solomon100["$(name)"]["reper"]     = Reverse_permutation(per)
            solomon100["$(name)"]["num_jobs"]  = 100
            solomon100["$(name)"]["capacity"]  = data["capacity"]
        end
    end
    
    # add random problem
    # num_of_customers = 932
    # name = "r$(num_of_customers)"
    # data = load_solomon_100_random(name, num_of_customers)
    # solomon100["$(name)"]              = Dict()
    # solomon100["$(name)"]["cus-no"]    = Dict(a => data[a][1] for a in 0:num_of_customers)
    # solomon100["$(name)"]["xcoor"]     = Dict(a => data[a][2] for a in 0:num_of_customers)
    # solomon100["$(name)"]["ycoor"]     = Dict(a => data[a][3] for a in 0:num_of_customers)
    # solomon100["$(name)"]["demand"]    = Dict(a => data[a][4] for a in 0:num_of_customers)
    # solomon100["$(name)"]["readytime"] = Dict(a => data[a][5] for a in 0:num_of_customers)
    # solomon100["$(name)"]["duedate"]   = Dict(a => data[a][6] for a in 0:num_of_customers)
    # solomon100["$(name)"]["service"]   = Dict(a => data[a][7] for a in 0:num_of_customers)
    
    # # sort
    # d = [solomon100["$(name)"]["duedate"][i] for i in 1:num_of_customers]
    # per = sortperm(d)
    # solomon100["$(name)"]["per"]       = per
    # solomon100["$(name)"]["reper"]     = Reverse_permutation(per)
    # solomon100["$(name)"]["num_jobs"]  = num_of_customers
    # solomon100["$(name)"]["capacity"]  = data["capacity"]

    return solomon100
end

# 1D
function EUdis(x::Number, y::Number)
    return sqrt(x^2 + y^2)
end

# 2D
function EUdis(x::Array, y::Array)
    return sqrt((x[1] - y[1])^2 + (x[2] - y[2])^2)
end


function EUdis(x::Array; disp=true, xcoor=xcoor, ycoor=ycoor)
    dis = EUdis_point(0, x[1], xcoor=xcoor, ycoor=ycoor)
    n = length(x)
    if disp
        println("Route: $x")
        println("dis from origin to     $(x[1]) = $(@sprintf("%.2f", dis)) => Total: $(dis)")
    end
    for i in 2:n
        current_dis = EUdis_point(x[i - 1], x[i], xcoor=xcoor, ycoor=ycoor)
        dis += current_dis
        if disp
            println("dis from     $(x[i - 1]) to     $(x[i]) = $(@sprintf("%.2f", current_dis)) => Total: $(dis)")
        end
    end
    last_dis = EUdis_point(0, x[n], xcoor=xcoor, ycoor=ycoor)
    dis += last_dis
    if disp
        println("dis from     $(x[n]) to origin = $(@sprintf("%.2f", last_dis)) => Total: $(dis)")
    end
    return dis
end


function Capacity(x::Array; demand=c, disp=true)
    n = length(x)
    c = 0
    if disp
        println("Route: $x")
    end
    for i in x
        c += demand[i]
        if disp
            println("demand of $i = $(demand[i]) => Total: $(c)")
        end
    end
    return c
end



function EUdis_point(i, j;xcoor=xcoor, ycoor=ycoor)
    return EUdis([xcoor[i], ycoor[i]], [xcoor[j], ycoor[j]])
end

# input must be dic, 0 represented origin
function ProcessingTimeMatrix(xcoor::Dict, ycoor::Dict, name::AbstractString)
    N = length(xcoor) - 1
    p = zeros(N, N)
    service = service_time(name)
    for i in 1:N
        for j in 1:N
            p[i, j] = EUdis([xcoor[i], ycoor[i]], [xcoor[j], ycoor[j]]) + service
        end
    end

    # for diagonal
    for i in 1:N
        p[i, i] = EUdis([xcoor[0], ycoor[0]], [xcoor[i], ycoor[i]])
    end

    return p
end


function DistanceMatrix(xcoor::Dict, ycoor::Dict, name::AbstractString)
    N = length(xcoor)
    p = zeros(N, N)
    for i in 1:N
        for j in 1:N
            p[i, j] = EUdis([xcoor[i-1], ycoor[i-1]], [xcoor[j-1], ycoor[j-1]])
        end
    end

    # # for diagonal
    # for i in 1:N
    #     p[i, i] = EUdis([xcoor[0], ycoor[0]], [xcoor[i], ycoor[i]])
    # end

    return p
end


function service_time(name::AbstractString)
    if name[1:2] == "c1" || name[1:2] == "C1"
        service = 90
    elseif name[1:2] == "r1" || name[1:2] == "R1"
        service = 10
    elseif name[1:2] == "c2" || name[1:2] == "C2"
        service = 90
    elseif name[1:2] == "r2" || name[1:2] == "R2"
        service = 10
    elseif name[1:3] == "rc1" || name[1:3] == "RC1"
        service = 10
    elseif name[1:3] == "rc2" || name[1:3] == "RC2"
        service = 10
    elseif name[1:2] == "r3"
        service = 10
    else 
        service = 10
    end
    return service
end

# function load_case_study_dict(name, case_size, num)
#     split_name = split(name, "-")

#     c = Dict()
#     c[name] = Dict()

#     location = "case_study_solutions"
#     p = readdlm("case_study_solutions/save_data/p/p$(case_size)-$(num).csv", ',', Float64)
#     d = readdlm("case_study_solutions/save_data/d/d$(case_size)-$(num).csv", ',', Float64)
#     low_d = readdlm("case_study_solutions/save_data/low_d/low_d$(case_size)-$(num).csv", ',', Float64)
#     distance_matrix = readdlm("case_study_solutions/save_data/distance_matrix/distance_matrix$(case_size)-$(num).csv", ',', Float64)
#     service = readdlm("case_study_solutions/save_data/service/service$(case_size)-$(num).csv", ',', Float64)

#     demand = zeros(length(d))
#     solomon_demand = 10000

#     dd = Dict()
#     dd[0] = 1000000
#     for (iter, i) in enumerate(d[2:end])
#         dd[iter] = i
#     end
#     c[name]["duedate"] = dd

#     return c
# end


# the function calculate the  distance from coordinate
solomon100 = load_all_solomon_100()  # load solomon data out size the function, for use all function below
# add new 200 points of problem
merge!(solomon100, load_all_solomon_200())  # load solomon data out size the function, for use all function below

# merge!(solomon100, load_case_study_dict("case_study-400-1", 400, 1))  # load case_study data out size the function, for use all function below
# merge!(solomon100, load_case_study_dict("case_study-400-2", 400, 1))  # load case_study data out size the function, for use all function below

function distance_solomon(route, name; sort=false, disp=false)

    if isempty(route) == true
        return 0
    end

    if sort == true
        # route = solomon100[name]["reper"][route]
        route = solomon100[name]["per"][route]
    end


    # add 0, origin, in the first node on the route
    if route[1] != 0
        route = append!([0], route)
    end

    # parameters
    N = length(route)
    dis = 0

    split_name = split(name, "-")
    if split_name[1] == "case_study"
        dis = 0
        p, d, low_d, demand, solomon_demand, distance_matrix, service = load_data_solomon(name)

        for i = 1:N - 1
            if disp == true
                println("distance from $(route[i]) to $(route[i + 1]) = $(EUdis(solomon100[name]["xcoor"][route[i]] - solomon100[name]["xcoor"][route[i + 1]], solomon100[name]["ycoor"][route[i]] - solomon100[name]["ycoor"][route[i + 1]]))")
            end
            dis += distance_matrix[route[i]+1, route[i+1]+1]
        end
        dis += distance_matrix[route[N]+1, 1]
        
    else
        # origin to last node
        for i = 1:N - 1
            if disp == true
                println("distance from $(route[i]) to $(route[i + 1]) = $(EUdis(solomon100[name]["xcoor"][route[i]] - solomon100[name]["xcoor"][route[i + 1]], solomon100[name]["ycoor"][route[i]] - solomon100[name]["ycoor"][route[i + 1]]))")
            end
            dis += EUdis(solomon100[name]["xcoor"][route[i]] - solomon100[name]["xcoor"][route[i + 1]], solomon100[name]["ycoor"][route[i]] - solomon100[name]["ycoor"][route[i + 1]])
        end

        # the last node back to origin
        dis += EUdis(solomon100[name]["xcoor"][route[N]] - solomon100[name]["xcoor"][route[1]], solomon100[name]["ycoor"][route[N]] - solomon100[name]["ycoor"][route[1]])
        if disp == true
            println("distance from $(route[N]) to $(route[1]) = $(EUdis(solomon100[name]["xcoor"][route[N]] - solomon100[name]["xcoor"][route[1]], solomon100[name]["ycoor"][route[N]] - solomon100[name]["ycoor"][route[1]]))")
            println("distance of $(route) = $(dis)")
        end

        return dis
    end
end

function demand_solomon(route, name; sort=false, disp=false)

    if isempty(route) == true
        return 0
    end

    if sort == true
        # route = solomon100[name]["reper"][route]
        route = solomon100[name]["per"][route]
    end


    # add 0, origin, in the first node on the route
    if route[1] != 0
        route = append!([0], route)
    end

    # parameters
    N = length(route)
    demand = []

    # origin to last node
    for i = 1:N
        if disp == true
            println("demand of $(route[i]) = $(solomon100[name]["demand"])")
        end
        append!(demand, solomon100[name]["demand"][route[i]])
        # total_demand += solomon100[name]["demand"][route[i]]
    end

    # # the last node back to origin
    # total_demand += EUdis(solomon100[name]["xcoor"][route[N]] - solomon100[name]["xcoor"][route[1]], solomon100[name]["ycoor"][route[N]] - solomon100[name]["ycoor"][route[1]])
    # if disp == true
    #     println("distance from $(route[N]) to $(route[1]) = $(EUdis(solomon100[name]["xcoor"][route[N]] - solomon100[name]["xcoor"][route[1]], solomon100[name]["ycoor"][route[N]] - solomon100[name]["ycoor"][route[1]]))")
    #     println("distance of $(route) = $(dis)")
    # end

    return demand
end

# load benchmark route
function load_route_solomon()
    dir = "exact_solomon"

    all_files = readdir(dir)
    data = Dict()
    for name in all_files
        name = split(name, ".")
        name = name[1]
        data[name] = Dict()
        open("$(dir)//$(name).txt") do file
            lines = eachline(file)
            for i in enumerate(lines)
                if i[1] >= 6 && isempty(split(i[2])) == false
                    data[name][i[1] - 5] = split(i[2])
                    data[name][i[1] - 5] = data[name][i[1] - 5][4:end]
                    # first data start at line index 6
                    # and each data the point start at index 4
                end
            end
        end

        # convert text to Integer
        num_vehicle = length(data[name])
        for i in 1:num_vehicle
            data[name][i] = [parse(Int64, j) for j in data[name][i]]
        end 
    end
    return data
end


function write_csv(x::Array, dir::AbstractString, name::AbstractString)
    io = open("$(dir)/$(name)", "w")
    for item in x
        write(io, "$(item)\n")
    end
    close(io)
end


function load_all_data(name::AbstractString; case_size=200, num=1)

    if name == "case_study"
        # data = load_case_study()

        # import data
        p, d, low_d, demand, service, distance_matrix, solomon_demand = import_case_study(case_size, num)

        # p, distance_matrix = create_processing_matrix()
        # low_d, d, service = create_time_window(p)

        demand = zeros(size(p, 1))
        solomon_demand = 10000
        return p, d, low_d, demand, solomon_demand, service, distance_matrix
    else
        solomon = solomon100[name]
        num_jobs = solomon["num_jobs"]
        d = solomon["duedate"]
        d = [d[i] for i in 1:num_jobs]
        service = service_time(name)
        service = service * ones(length(d))
        xcoor = solomon["xcoor"]
        ycoor = solomon["ycoor"]
        p = ProcessingTimeMatrix(xcoor, ycoor, name)
        distance_matrix = DistanceMatrix(xcoor, ycoor, name)
        low_d = solomon["readytime"]
        low_d = [low_d[i] for i in 1:num_jobs]
        demand = solomon["demand"]
        demand = [demand[i] for i in 1:num_jobs]
        solomon_demand = solomon["capacity"]
        return p, d, low_d, demand, solomon_demand, service, distance_matrix
    end
end


function total_distance_case_study(vehicle::Dict)
    case_size = vehicle["case_size"]
    num = vehicle["num"]
    num_vehicle = vehicle["num_vehicle"]
    p, d, low_d, demand, service, distance_matrix, solomon_demand = import_case_study(case_size, num)

    dis = 0

    for i in 1:num_vehicle
        first_job = vehicle[i]["sch"][1]
        dis += p[first_job, first_job]

        for k in 1:length(vehicle[i]["sch"])-1
            dis += p[vehicle[i]["sch"][k], vehicle[i]["sch"][k+1]]
        end

        last_job = vehicle[i]["sch"][end]
        dis += p[last_job, last_job]

    end
    return dis
end


# plot gantt chart
# alg = 1 is heuristic 
# alg = 2 is heuristic_min 
function Gantt(name; alg=1, save=false)

    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]

    if alg == 1 || alg == 2
        dir = "heuristic_multiple"
    elseif alg == 3 || alg == 4
        dir = "multiple_vehicle"
        # if alg == 3
        #     alg = 1
        # else
        #     alg = 2
        # end
    elseif alg == 5 || alg == 6
        dir = "processing_multi"
    end
    
    # create dict data
    vehicle = Dict()
    open("$(dir)/only_sch/Alg$(alg)-$(name).txt") do file
        lines = eachline(file)
        for i in enumerate(lines)
            vehicle[i[1]] = split(i[2])
        end
    end

    # convert text to Integer
    num_vehicle = length(keys(vehicle))
    for i in 1:num_vehicle
        vehicle[i] = [parse(Int8, j) for j in vehicle[i]]
    end
    if isempty(vehicle[num_vehicle]) == true
        delete!(vehicle, num_vehicle)
        num_vehicle -= 1
    end

    # create worker, starting time, completion time
    worker = []
    start = []
    stop = []
    for i in 1:num_vehicle
        num_job = length(vehicle[i])
        startingtime, completiontime = StartingAndCompletion(vehicle[i], p, low_d)
        append!(worker, i * ones(Int8, num_job))
        append!(start, startingtime)
        append!(stop, completiontime)
    end

    df = DataFrame(worker=worker, start=start, stop=stop, type=[string(i) for i in 1:length(worker)])

    p = df |> @vlplot(
        :bar,
        y = "worker:n",
        x = :start,
        x2 = :stop,
        color = {:job, legend = false, scale = {range = ["#127e59",
        # "#71dcb0",
        "#f2048a",
        # "#40bd14",
        "#1862db",
        "#f163d7",
        "#ff2553",
        "#aa594f",
        "#435359",
        "#f246a8",
        "#a67f43",
        "#b08864",
        "#7a1736",
        "#382173",
        "#663900",
        "#f8311d",
        # "#72bb9d",
        "#a10bf0",
        "#3b400c",
        "#f7217c",
        "#b71c77",
        "#ddda34",
        # "#4204bb",
        "#27079b",
        # "#ed84db",
        "#d9c0f6",
        "#786b0b",
        "#3c5355",
        "#dc62db",
        "#6a7bc9",
        # "#35f642",
        # "#1f9ea6",
        # "#baee70",
        # "#1cd2ea",
        # "#b2cc08",
        "#c1ad6b",
        "#913756",
        "#c54221",
        "#f84749",
        "#077685",
        "#977503",
        "#951c1c",
        "#c330d6",
        "#ce6354",
        # "#5ade4d",
        # "#0aad0a",
        "#4d8357",
        "#829a09",
        "#5058e8",
        "#c271da",
        "#e83ec4",
        "#d006ce",
        "#e21829",
        "#217ad7",
        "#c22641",
        "#61546f",
        "#985762",
        "#94a8f4",
        # "#43d249",
        "#ae3465",
        "#840594",
        "#a8b079",
        "#7eb216",
        "#fd0e8b",
        "#c6bfe0",
        "#a49f9d",
        "#271b04",
        "#d2a122",
        "#b4c98f",
        "#f55f58",
        "#94e2ff",
        # "#0efb04",
        "#47a582",
        "#9db20c",
        "#a84e9b",
        "#5ad7ee",
        "#d05a49",
        "#897252",
        "#f3e278",
        # "#14bf69",
        "#e44d17",
        "#55a8ff",
        "#bb6b28",
        "#1d34dc",
        "#a05e1f",
        "#b3f533",
        "#1e6876",
        "#469c80",
        # "#1dd0be",
        "#9dddf3",
        "#3b9fb6",
        "#116efc",
        # "#18d19a",
        "#9a702e",
        "#c0debb",
        "#241f24",
        "#a7d2d0",
        "#4d8ad6",
        "#311752"]}},
        encoding={x={field="pubyear",typ="ordinal",axis={title="Year",format="d"}}}
    )

    if save == true
        output = name
        p |> save("figures/$(output)-Alg$(alg).png")
    end
end


function plot_solomon()
    @eval using Plots
    r_x = [solomon100["r101"]["xcoor"][i] for i in 0:100]
    r_y = [solomon100["r101"]["ycoor"][i] for i in 0:100]
    c_x = [solomon100["c101"]["xcoor"][i] for i in 0:100]
    c_y = [solomon100["c101"]["ycoor"][i] for i in 0:100]
    rc_x = [solomon100["rc101"]["xcoor"][i] for i in 0:100]
    rc_y = [solomon100["rc101"]["ycoor"][i] for i in 0:100]
    # scatter(r_x, r_y)
    # scatter!(c_x, c_y)
    scatter!(rc_x, rc_y)
    # scatter(r_x[1], r_y[1])
end

# function load_all_data(name::AbstractString)
#     p, d, low_d, demand = load_solomon(name)
#     solomon_demand = solomon_capacity(name)
#     return p, d, low_d, demand, solomon_demand
# end


function plot_Grantt(Vehicle::Dict; fig_name=nothing)
    case_size = Vehicle["case_size"]
    num = Vehicle["num"]

    if isnothing(fig_name)
        fig_name = "schedule$(case_size)-$(num)"
    end

	p, d, low_d, demand, solomon_demand = load_all_data(Vehicle["name"], case_size=case_size, num=num)
	# create worker, starting time, completion time
    care_staff = []
    start = []
    stop = []
    for i in 1:Vehicle["num_vehicle"]
        num_job = length(Vehicle[i]["sch"])
        startingtime, completiontime = StartingAndCompletion(Vehicle[i]["sch"], p, low_d)
        append!(care_staff, i * ones(Int64, num_job))
        append!(start, startingtime)
        append!(stop, completiontime)
    end

    start /= 3600
    stop /= 3600

    dff = DataFrame(care_staff=care_staff, start=start, stop=stop, type=[string(i) for i in 1:length(care_staff)])

    p = dff |> @vlplot(
        :bar,
        y = "care_staff:n",
        x = :start,
        x2 = :stop,
        color = {:type, scale = {range = ["#127e59",
        "#0a7501",
        # "#71dcb0",
        "#f2048a",
        # "#40bd14",
        "#1862db",
        "#f163d7",
        "#ff2553",
        "#aa594f",
        "#435359",
        "#f246a8",
        "#a67f43",
        "#b08864",
        "#7a1736",
        "#382173",
        "#663900",
        "#f8311d",
        # "#72bb9d",
        "#a10bf0",
        "#3b400c",
        "#f7217c",
        "#b71c77",
        "#ddda34",
        # "#4204bb",
        "#27079b",
        # "#ed84db",
        "#d9c0f6",
        "#786b0b",
        "#3c5355",
        "#dc62db",
        "#6a7bc9",
        # "#35f642",
        # "#1f9ea6",
        # "#baee70",
        # "#1cd2ea",
        # "#b2cc08",
        "#c1ad6b",
        "#913756",
        "#c54221",
        "#f84749",
        "#077685",
        "#977503",
        "#951c1c",
        "#c330d6",
        "#ce6354",
        # "#5ade4d",
        # "#0aad0a",
        "#4d8357",
        "#829a09",
        "#5058e8",
        "#c271da",
        "#e83ec4",
        "#d006ce",
        "#e21829",
        "#217ad7",
        "#c22641",
        "#61546f",
        "#985762",
        "#94a8f4",
        # "#43d249",
        "#ae3465",
        "#840594",
        "#a8b079",
        "#7eb216",
        "#fd0e8b",
        "#c6bfe0",
        "#a49f9d",
        "#271b04",
        "#d2a122",
        "#b4c98f",
        "#f55f58",
        "#94e2ff",
        # "#0efb04",
        "#47a582",
        "#9db20c",
        "#a84e9b",
        "#5ad7ee",
        "#d05a49",
        "#897252",
        "#f3e278",
        # "#14bf69",
        "#e44d17",
        "#55a8ff",
        "#bb6b28",
        "#1d34dc",
        "#a05e1f",
        "#b3f533",
        "#1e6876",
        "#469c80",
        # "#1dd0be",
        "#9dddf3",
        "#3b9fb6",
        "#116efc",
        # "#18d19a",
        "#9a702e",
        "#c0debb",
        "#241f24",
        "#a7d2d0",
        "#4d8ad6",
        "#311752"]}},
        mark = "line",
        encoding={x={axis={title="Year",format="d"}}}
    ) |> save("$(fig_name).pdf")

end

function glob_only_name(pattern, dir)
    
    all_name_split1 = split.(glob("$(pattern)", "$(dir)"), "\\")
    all_name_split2 = split.(glob("$(pattern)", "$(dir)"), "/")
    if length(all_name_split1[1]) > 1
        all_name_split = all_name_split1
    else
        all_name_split = all_name_split2
    end
        
    # if length(all_name_split[1]) == 1
    #     all_name_split = split.(glob("$(pattern)", "$(dir)"), "\\")
    # end
	all_name = [all_name_split[i][end] for i in 1:length(all_name_split)]
	all_name_split = split.(all_name, ".")
	all_name = [all_name_split[i][1] for i in 1:length(all_name_split)]
	return all_name
end

