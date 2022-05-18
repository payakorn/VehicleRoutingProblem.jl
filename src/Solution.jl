# implement new struct with the truncated distance matrix 

mutable struct Solution
    name::String
    route::Array
    processing_time::Array
    lower::Array
    upper::Array
    demand::Array
    max_capacity::Float64
    distance_matrix::Array
    distance_matrix_floor::Array
    service_time::Array
    # max_vehicle::Int64
end


"""
    seperate_route(solution::Solution)

return Vector of route with length = number of vehicles

# Example 
```julia
solution = read_solution("particle_swarm\\total_distance\\case1\\r101\\15\\1\\r101-1.txt", "r101")
seperate_route(solution)
```
"""
function seperate_route(solution::Solution)
    separation_point = findall(x -> x == 0, solution.route)

    solution_route = solution.route

    # Route
    route = []
    for i in 1:length(separation_point) - 1
        route_i = Array(solution_route[(separation_point[i]+1):(separation_point[i+1]-1)])
        push!(route, route_i)
    end
    return route
end


function read_solution(location::String)
    file_name = split(splitpath(location)[end], "-")
    if length(file_name) == 3
        Name = "$(file_name[1])-$(file_name[2])"
    else
        Name = "$(file_name[1])"
    end
    read_solution(location, Name)
end


function test_walk(location::String)
    for (root, dirs, files) in walkdir("$location")
        println("Directories in $root")
        for dir in dirs
            println(joinpath(root, dir)) # path to directories
        end
        println("Files in $root")
        for file in files
            println(joinpath(root, file)) # path to files
        end
    end
end


function read_solution(file_name::AbstractString, instance_name::AbstractString)
    route = read_route(file_name)

    # load data
    processing_time, upper, lower, demand, max_capacity, distance_matrix, service = read_data_solomon(instance_name)

    # crete the truncated matrix
    distance_matrix_floor = floor.(distance_matrix, digits=1)

    # apply to Solution struct
    solution = Solution(instance_name, route, processing_time, lower, upper, demand, max_capacity, distance_matrix, distance_matrix_floor, service)

    return solution
end


function seperate_route(particle::Particle)
    routes = vcat(0, particle.route, 0)
    separation_point = findall(x -> x == 0, routes)

    # Route
    output_route = []
    for i in 1:length(separation_point) - 1
        route_i = Array(routes[(separation_point[i]+1):(separation_point[i+1]-1)])
        push!(output_route, route_i)
    end
    return output_route
end


"""
    total_route(solution::Solution)

Return the number of route
"""
function total_route(solution::Solution)
    return length(findall(x -> x == 0, solution.route)) - 1
end


"""
    total_route(route::Vector)

Return the number of route
"""
function total_route(route::Vector)
    return length(findall(x -> x == 0, route)) - 1
end


"""
    total_route(particle::Particle)

Return the number of route
"""
function total_route(particle::Particle)
    return length(findall(x -> x == 0, particle.route)) + 1
end


function total_distance(solution::Solution; floor_digit=false::Bool)
    # inititialize
    dis = 0
    route = solution.route .+ 1

    # choose method of distance matrix
    if floor_digit
        distance_matrix = solution.distance_matrix_floor
    else
        distance_matrix = solution.distance_matrix
    end

    for i in 1:(length(solution.route) - 1)
        dis += distance_matrix[route[i], route[i+1]]
    end

    return dis

end


function write_solution_to_txt(particle::Particle, location::String)
    routes = seperate_route(particle)

    io = open(location, "w")
    for route in routes
        for i in route
            write(io, "$i ")
        end
        write(io, "\n")
    end
    close(io)
end


function location_opt_solomon(name::String)
    if ispath(joinpath(@__DIR__, "..", "data", "opt_solomon", name[1:2]))
        println("true")
        return joinpath(@__DIR__, "..", "data", "opt_solomon", name[1:2])
    else
        println("false")
        return joinpath(@__DIR__, "..", "data", "opt_solomon", name[1:3])
    end
end


function create_csv_solomon_25_50()
    io = open("")
    for name in Full_Name()
        instance_name = "$name-25"
        location = location_particle_swarm(instance_name)
        min_solution = minimum([total_distance(read_solution(location_name, instance_name), floor_digit=true) for location_name in glob("$name*.txt", location)])
        # opt_value = read_solution("$(location_opt_solomon()/$())")
        println("$instance_name: $min_solution")
    end
end


function find_min_solution(name)
    solution = [read_solution("data\\simulations\\particle_swarm\\total_distance\\$name\\$name-$i.txt", "$name") for i in 1:length(glob("$name*.txt", "data\\simulations\\particle_swarm\\total_distance\\$name\\"))]
    min_dis = minimum(total_distance.(solution, floor_digit=true))
    println("min distance = $min_dis")
end


function instance_names(;num_ins=(2, 4, 6, 8, 10))
    class_name = ("C1", "C2", "R1", "R2", "RC1", "RC2")
    all_names = ("$(cln)_$(numc)_$(numi)" for numi in 1:10, cln in class_name, numc in num_ins)
    return all_names
end


function find_min_distance_from_dir(location::AbstractString, name::String)
    all_files = []
    for num_par in readdir(location)
        for seed in readdir("$location/$num_par")
            println("#par/seed: $num_par/$seed")
            append!(all_files, glob("$name*.txt", "$location/$num_par/$seed"))
        end
    end
    solutions = read_solution.(all_files)
    all_dis = total_distance.(solutions)
    if isempty(all_dis)
        return (missing, missing, missing)
    else
        arg_min = argmin(all_dis)
        return all_dis[arg_min], total_route(solutions[arg_min]), splitpath(all_files[arg_min])[end-3:end]
    end
end


function create_csv_all_homberger(num_case::Int64)
    data = load_object(joinpath(@__DIR__, "..", "data", "morethan100", "jld2", "best-known$(num_case)00.jld2"))
    bn_vehi = data[!, 2]
    bn_dist = data[!, 3]
    io = open("homberger$num_case.csv", "w")
    write(io, "Name,BNVehi,BNDis,NumVehi,Dis,NumPar,Dir\n")
    for (num, Name) in enumerate(collect(instance_names())[:, :, 1])
        dis, vehi, loca = find_min_distance_from_dir(joinpath(@__DIR__, "..", "particle_swarm", "total_distance", "case16", Name), Name)
        println("$(dis), $(vehi), $(loca)")
        println("Name: $Name")
        loca2 = try loca[2] catch e; missing end
        loca3 = try loca[end] catch e; missing end
        write(io, "$Name,$(bn_vehi[num]),$(bn_dist[num]),$vehi,$dis,$(loca2),$(loca3)\n")
    end
    close(io)
end