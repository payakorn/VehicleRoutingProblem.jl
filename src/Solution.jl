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


function seperate_route(solution::Array)
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


"""
    total_route(solution::Solution)

Return the number of route
"""
function total_route(solution::Solution)
    return length(findall(x -> x == 0, solution.route)) - 1
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