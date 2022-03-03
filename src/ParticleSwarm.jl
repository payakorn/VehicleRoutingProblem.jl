"""
    Particle(
        route::Array, 
        route::Array
        p::Array
        l::Array
        u::Array
        demand::Array
        max_capacity::Float64
        distance_matrix::Array
        service::Array
        max_vehicle::Int64
        name::String)
where route in the form of [vehicle1, 0, vehicle2, 0, vehicle3, ...] (0 seperates the vehicle)
"""
mutable struct Particle
    route::Array
    p::Array
    l::Array
    u::Array
    demand::Array
    max_capacity::Float64
    distance_matrix::Array
    service::Array
    max_vehicle::Int64
    name::String
end

"""
    point_distance(p1, p2)
- `p1`: coordiante point in the form of [x1, y1]
- `p2`: coordiante point in the form of [x2, y2]

## return eucledian distance from (x1, y1) -> (x2, y2)
"""
function point_distance(p1, p2)
    return sqrt(((p1[1] - p2[1])^2 + (p1[2] - p2[2])^2))
end


function load_data_solomon(name::String; problem_size=100)
    split_name = split(name, "-")

    if split_name[1] == "case_study"
        case_size = parse(Int64, split_name[2])
        num = parse(Int64, split_name[3])
        p, d, low_d, demand, solomon_demand, service, distance_matrix = load_all_data(split_name[1], case_size=case_size, num=num)
        return p, d, low_d, demand, solomon_demand, distance_matrix, service
    else
        p, d, low_d, demand, solomon_demand = load_all_data(name)
        service = service_time(name)
        service = service * ones(length(d))
        
        if length(d) == 100
            solomon_data = load_all_solomon_100()[name]
        else
            solomon_data = load_all_solomon_200()[name]
        end

        xcoor = solomon_data["xcoor"]
        ycoor = solomon_data["ycoor"]
        distance_matrix = DistanceMatrix(xcoor, ycoor, name)
        distance_matrix = floor.(distance_matrix, digits=1)
        # return p, d, low_d, demand, solomon_demand, reshape(distance_matrix, (problem_size+1, problem_size+1)), service
        return p, d, low_d, demand, solomon_demand, distance_matrix, service
    end
end


function find_vehicle(particle::Particle)
    seperate_index = findall(x -> x == 0, particle.route)
    num_vehicle = length(seperate_index) + 1
    vehicle = Dict()
    run_index = vcat(0, seperate_index, length(particle.route) + 1)
    for i in 1:num_vehicle
        vehicle[i] = particle.route[(run_index[i] + 1):(run_index[i + 1] - 1)]
    end
    return vehicle
end


function total_distance_old(particle::Particle)
    vehicle = find_vehicle(particle)
    dis = 0
    for i in 1:length(vehicle)
        sch = vcat(0, vehicle[i], 0)
        dis += sum([particle.distance_matrix[sch[j] + 1, sch[j + 1] + 1] for j in 1:length(sch) - 1])
    end
    return dis
end


function total_distance(particle::Particle)
    route = vcat(0, particle.route, 0) .+ 1
    real_route = vcat(route, 1)
    dis = sum([particle.distance_matrix[real_route[i], real_route[i+1]] for i in 1:length(route)])
    return dis
end


function starting_completion_time(sch, distance_matrix, low_d, service)
    sch_1 = sch .+ 1 # oririgin in sch is 0 but in distance matrix is index 1
    distance_first_job = distance_matrix[1, sch_1[1]]
    if distance_first_job < low_d[sch[1]]
        difference = low_d[sch[1]] - distance_first_job
        starting = [difference]
    else
        starting = [0.0]
    end

    completion = [starting[1] + distance_first_job[1] + service[sch[1]]]

    for i in 2:length(sch)
        distance = distance_matrix[sch_1[i - 1], sch_1[i]]
        if distance < low_d[sch[1]]
            difference = low_d[sch[1]] - distance
            append!(starting, completion[i - 1] + difference)
            append!(completion, starting[i] + distance + service[sch[i]])
        else
            append!(starting, completion[i - 1])
            append!(completion, starting[i] + distance + service[sch[i]])
        end
    end
    return starting, completion
end


function total_completion_time(particle::Particle)
    vehicle = find_vehicle(particle)
    completion_time = 0
    for i in 1:length(vehicle)
        if ~isempty(vehicle[i])
            s, c = starting_completion_time(vehicle[i], particle.distance_matrix, particle.l, particle.service)
            completion_time += sum(c)
            # completion_time += particle.service[sch[end]]
        end
    end
    return completion_time
end


function check_feasible(particle::Particle)
    vehicle = find_vehicle(particle)
    number_of_vehicle = length(vehicle)

    if number_of_vehicle > particle.max_vehicle
        return false
    end

    completion_time = 0
    duedate = solomon100[particle.name]["duedate"][0]
    for i in 1:length(vehicle)
        late, last_completion_time, meet_demand = job_late(vehicle[i], p=particle.p, d=particle.u, low_d=particle.l, demand=particle.demand, solomon_demand=particle.max_capacity)
        completion_time += last_completion_time
        if sum(late) == 0 && meet_demand
            sch = vehicle[i]
            if isempty(sch)
                continue
            end
            starting_time, completion_time2 = StartingAndCompletion(sch, particle.p, particle.l)
            last_com = completion_time2[end] + particle.service[sch[end]] + particle.distance_matrix[sch[end]+1, 1]
            if last_com > duedate
                return false
            end
            # continue
        else
            return false
        end
    end
    # if isnothing(name)
    #     return false #change from true (maybe unnecessary)
    # else
        # vehicle = find_vehicle(particle)
        # p, d, low_d, demand, max_capacity, distance_matrix, service = load_data_solomon(particle.name)
        # for i in 1:length(vehicle)
        #     sch = vehicle[i]
        #     if isempty(sch)
        #         continue
        #     end
        # end
    return true
    # end
end


function check_last_job_completion_time(name::String, dir::String)
    duedate = solomon100[name]["duedate"][0]
    vehicle = read_txt3(dir, name)
    p, d, low_d, demand, max_capacity, distance_matrix, service = load_data_solomon(name)
    for i in 1:vehicle["num_vehicle"]
        sch = vehicle[i]["sch"]
        starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
        last_com = completion_time[end] + service[sch[end]] + distance_matrix[sch[end]+1, 1]
        println("$name, vehicle$i last com: $last_com, duedate: $duedate, $(last_com <= duedate)")
    end
end


function check_last_job_completion_time(;dir="4")
    for name in Full_Name()
        duedate = solomon100[name]["duedate"][0]
        vehicle = read_txt2(name, "particle_swarm/total_distance/$(dir)/")
        p, d, low_d, demand, max_capacity, distance_matrix, service = load_data_solomon(name)
        for i in 1:vehicle["num_vehicle"]
            sch = vehicle[i]["sch"]
            starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
            last_com = completion_time[end] + service[sch[end]] + distance_matrix[sch[end]+1, 1]
            println("$name, vehicle$i last com: $last_com, duedate: $duedate, $(last_com <= duedate)")
        end
    end
end


function check_feasible_all_job(;dir="4")
    for name in Full_Name()
        duedate = solomon100[name]["duedate"][0]
        vehicle = read_txt2(name, "particle_swarm/total_distance/$(dir)/")
        p, d, low_d, demand, max_capacity, distance_matrix, service = load_data_solomon(name)
        for i in 1:vehicle["num_vehicle"]
            sch = vehicle[i]["sch"]
            (late, last_completiontime, meet_demand) = job_late(sch; p=p, d=d, low_d=low_d, demand=demand, solomon_demand=max_capacity)
            # starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
            # last_com = completion_time[end] + service[sch[end]] + distance_matrix[sch[end]+1, 1]
            println("$name, vehicle$i feasible: $(sum(late))")
        end
    end
end


function random_particle(number_of_customer::Int64, max_vehicle::Int64)
    num_vehicle = rand(1:max_vehicle)
    random_position = unique(sort(rand(2:number_of_customer - 1, (num_vehicle - 1,))))
    deleteat!(random_position, findall(x -> x == 1, [random_position[i + 1] - random_position[i] for i in 1:length(random_position) - 1]))
    sch = randcycle(number_of_customer)
    for i in random_position
        insert!(sch, i, 0)
    end
    return sch
end


function remove_job(sch, p, d, low_d, demand, max_capacity)
    late_removed_sch = [true]
    unassign_sch = []
    while sum(late_removed_sch) != 0
        late, last_completion_time, meet_demand = job_late(sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=max_capacity)
        union!(unassign_sch, sch[findall(x -> x == true, late)])
        sch = sch[findall(x -> x == false, late)]
        late_removed_sch, last_completion_time_removed, meet_demand = job_late(sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=max_capacity)
    end
    return sch, unassign_sch
end


function remove_vehicle_and_apply_heuristic(particle::Particle, random_vehicle::Int64)
    test_particle = deepcopy(particle)
    position_zeros = vcat(0, findall(x -> x == 0, particle.route), length(particle.route)+1)
    position_zeros_index = vcat(1, findall(x -> x == 0, particle.route), length(particle.route)+1)
    # random_vehicle = rand(1:(length(position_zeros)-1))
    candidate = particle.route[(position_zeros[random_vehicle]+1):(position_zeros[random_vehicle+1]-1)]
    deleteat!(test_particle.route, (position_zeros_index[random_vehicle]):(position_zeros_index[random_vehicle+1]-1))
    vehicle = find_vehicle(test_particle)
    
    test_particle.route, candidate = apply_heuristic_all_vehicle_local(vehicle, particle.p, particle.u, particle.l, particle.demand, particle.max_capacity, candidate=candidate)
    iter = 1
    while isempty(candidate) == false && iter <= 100
        vehicle = find_vehicle(test_particle)
        test_particle.route, candidate = apply_heuristic_all_vehicle_local(vehicle, particle.p, particle.u, particle.l, particle.demand, particle.max_capacity, candidate=candidate)
        iter += 1
    end
    
    if isempty(candidate)
        # println("apply heuristic, candidate: $(candidate), iter: $iter")
        return test_particle
    else
        return particle
    end
end


function ruin(particle::Particle, num_job::Int64)
    test_particle = deepcopy(particle)
    candidate =  shuffle(1:(length(particle.l)))[1:num_job]

    for j in candidate
        deleteat!(test_particle.route, findall(x -> x == j, test_particle.route))
    end

    vehicle = find_vehicle(test_particle)
    
    test_particle.route, candidate = apply_heuristic_all_vehicle_local(vehicle, particle.p, particle.u, particle.l, particle.demand, particle.max_capacity, candidate=candidate)
    iter = 1
    while isempty(candidate) == false && iter <= 100
        vehicle = find_vehicle(test_particle)
        test_particle.route, candidate = apply_heuristic_all_vehicle_local(vehicle, particle.p, particle.u, particle.l, particle.demand, particle.max_capacity, candidate=candidate)
        iter += 1
    end
    
    if isempty(candidate)
        # println("apply heuristic, candidate: $(candidate), iter: $iter")
        return test_particle
    else
        return particle
    end
end


function apply_heuristic(sch, unassign_sch, p, d, low_d, demand, max_capacity)
    job_cannot_process = []
    while isempty(unassign_sch) == false
        job_in = unassign_sch[1]
        deleteat!(unassign_sch, 1)
        (sch, job_out) = job_in_out(sch, job_in, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=max_capacity)
        union!(job_cannot_process, job_out)
    end
    return sch, job_cannot_process
end


function fix_missing_vehicle(route::Array)
    test_route = deepcopy(route)
    if test_route[1] == 0
        popfirst!(test_route)
    end

    if isempty(test_route) == false
        if test_route[end] == 0
            pop!(test_route)
        end
    end

    vehicle_position = findall(x -> x == 0, test_route)
    s = deepcopy(test_route)
    positions = findall(x -> x == 1, [vehicle_position[i + 1] - vehicle_position[i] for i in 1:length(vehicle_position) - 1])
    delete_position = vehicle_position[positions]
    deleteat!(test_route, delete_position)
    return test_route
end


function remove_best_route(particle::Particle, best_route::Array)
    input_particle = deepcopy(particle)
    for i in best_route
        deleteat!(input_particle.route, findall(x -> x == i, input_particle.route))
    end

    # 
    if isempty(input_particle.route) == false
        input_particle.route = fix_missing_vehicle(input_particle.route)
    end

    return input_particle
end


function path_relinking(particle::Particle, best_route::Array, objective_function::Function)

    original_particle = deepcopy(particle)

    new_particle = remove_best_route(particle, best_route)

    # add the new route
    append!(new_particle.route, 0)
    append!(new_particle.route, best_route)
    # println("path relinking best route = $(best_route)")
    return new_particle
end


function two_opt_list(length_of_route::Int64)
    return shuffle!(collect(combinations(1:length_of_route, 2)))
end


function remove_route(particle::Particle, route::Array)
    nothing
end


function two_opt(particle::Particle, objective_function::Function; best_route=[])
    test_particle = deepcopy(particle)
    original_obj = objective_function(particle)
    test_particle = remove_best_route(test_particle, best_route)
    length_route = length(test_particle.route)
    List = two_opt_list(length_route)
    for list in List
        new_test_particle = deepcopy(test_particle)
        left_sch = new_test_particle.route[1:list[1]]
        right_sch = new_test_particle.route[list[2]:end]
        middle_sch = new_test_particle.route[list[1]+1:list[2]-1]
        new_test_particle.route = vcat(right_sch, middle_sch, left_sch)
        if (check_feasible(new_test_particle) == true) && (objective_function(new_test_particle) < objective_function(test_particle))
            if isempty(best_route)
                println("2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                return new_test_particle
            else
                append!(new_test_particle.route, 0)
                append!(new_test_particle.route, best_route)
                println("2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                return new_test_particle
            end
        end
    end
    return particle
end


function two_opt_new(particle::Particle, objective_function::Function; best_route=[])
    test_particle = deepcopy(particle)
    original_obj = objective_function(particle)
    test_particle = remove_best_route(test_particle, best_route)
    length_route = length(test_particle.route)
    List = two_opt_list(length_route)
    feasible_opt = false

    iter = 1 
    for list in List
        new_test_particle = deepcopy(test_particle)
        left_sch = new_test_particle.route[1:list[1]]
        right_sch = new_test_particle.route[list[2]:end]
        middle_sch = new_test_particle.route[list[1]+1:list[2]-1]
        new_test_particle.route = vcat(right_sch, middle_sch, left_sch)

        if (check_feasible(new_test_particle) == true)
            if isempty(best_route)
                println("2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                return new_test_particle
            else
                append!(new_test_particle.route, 0)
                append!(new_test_particle.route, best_route)
                println("2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                return new_test_particle
            end
            break
        end
        iter += 1
    end
    return particle
end


function two_opt_new3(particle::Particle, objective_function::Function; best_route=[])
    test_particle = deepcopy(particle)
    original_obj = objective_function(particle)
    test_particle = remove_best_route(test_particle, best_route)
    length_route = length(test_particle.route)
    List = two_opt_list(length_route)
    feasible_opt = false

    change_count = 1
    for list in List
        new_test_particle = deepcopy(test_particle)
        left_sch = new_test_particle.route[1:list[1]]
        right_sch = new_test_particle.route[list[2]:end]
        middle_sch = new_test_particle.route[list[1]+1:list[2]-1]
        new_test_particle.route = vcat(right_sch, middle_sch, left_sch)

        if (check_feasible(new_test_particle) == true)
            if isempty(best_route)
                if change_count == 10
                    println("change    2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                    return new_test_particle
                else
                    println("no change 2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                    test_particle = deepcopy(new_test_particle)
                end
            else
                append!(new_test_particle.route, 0)
                append!(new_test_particle.route, best_route)
                if change_count == 10
                    println("change    2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                    return new_test_particle
                else
                    println("no change 2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
                    test_particle = deepcopy(new_test_particle)
                end
            end
            change_count += 1
        end
    end
    return test_particle
end


function apply_heuristic_all_vehicle_local(vehicle, p, d, low_d, demand, max_capacity; candidate=[])
    number_of_vehicle = length(vehicle)
    route = []
    for (i, j) in enumerate(shuffle(1:number_of_vehicle))
        sch = vehicle[j]
        sch, candidate = apply_heuristic(sch, candidate, p, d, low_d, demand, max_capacity)
        append!(route, sch)
        if i != number_of_vehicle
            append!(route, 0)
        end
    end
    return route, candidate
end


function apply_heuristic_all_vehicle(vehicle, p, d, low_d, demand, max_capacity; candidate=[])
    number_of_vehicle = length(vehicle)
    route = []
    for i in 1:number_of_vehicle
        sch, unassign_sch = remove_job(vehicle[i], p, d, low_d, demand, max_capacity)
        union!(candidate, unassign_sch)
        sch, candidate = apply_heuristic(sch, candidate, p, d, low_d, demand, max_capacity)
        append!(route, sch)
        if i != number_of_vehicle
            append!(route, 0)
        end
    end
    return route, candidate
end


function fix_infeasible(particle::Particle; best_route=[])

    # remove best route
    particle = remove_best_route(particle, best_route)

    vehicle = find_vehicle(particle)
    number_of_vehicle = length(vehicle)
    sch, candidate = apply_heuristic_all_vehicle(vehicle, particle.p, particle.u, particle.l, particle.demand, particle.max_capacity)
    if isempty(candidate)
        particle.route = sch
        return particle
    else
        particle.route = sch
        vehicle = find_vehicle(particle)
        sch, candidate = apply_heuristic_all_vehicle(vehicle, particle.p, particle.u, particle.l, particle.demand, particle.max_capacity, candidate=candidate)
    end

    while isempty(candidate) == false
        number_of_vehicle += 1
        append!(sch, 0)
        sch_out, candidate = heuristic(all_job=candidate, p=particle.p, d=particle.u, low_d=particle.l, demand=particle.demand, solomon_demand=particle.max_capacity)
        if length(sch_out) == 1
            push!(sch, sch_out[1])
        else
            append!(sch, sch_out)
        end
    end
    particle.route = sch

    # add best route
    append!(particle.route, 0)
    append!(particle.route, best_route)

    return particle
end


function convert_vehicle_to_list(vehicle)
    number_of_vehicle = length(vehicle)
    route = []
    for i in 1:number_of_vehicle
        append!(route, vehicle[i])
        if i != number_of_vehicle
            append!(route, 0)
        end
    end
    return route
end


function check_particle(particle::Particle, number_of_customer::Int64)
    test_particle = deepcopy(particle)
    deleteat!(test_particle.route, findall(x -> x == 0, test_particle.route))
    number_of_job = length(unique(test_particle.route)) == number_of_customer
end


function check_particle(list::Array, number_of_customer::Int64)
    test_list = deepcopy(list)
    deleteat!(test_list, findall(x -> x == 0, test_list))
    number_of_job = length(unique(test_list)) == number_of_customer
end


function generate_particle(p, d, low_d, demand, max_capacity, distance_matrix, service, max_vehicle, name; best_route=[])
    println("random particle #$(length(d))")
    num_job = length(d)
    sch = random_particle(num_job, max_vehicle)
    particle = Particle(sch, p, low_d, d, demand, max_capacity, distance_matrix, service, max_vehicle, name)
    particle = remove_best_route(particle, best_route)
    
    iter = 1
    while check_feasible(particle) == false 
        particle = fix_infeasible(particle)
        if check_feasible(particle) == false
            sch = random_particle(num_job, max_vehicle)
            particle = Particle(sch, p, low_d, d, demand, max_capacity, distance_matrix, service, max_vehicle, name)
            particle = remove_best_route(particle, best_route)
        end

        iter += 1
    end

    if isempty(best_route) == false
        append!(particle.route, 0)
        append!(particle.route, best_route)
    end
    return particle
    
end


function generate_particle(name::String; max_vehicle=25, best_route=[])
    p, d, low_d, demand, max_capacity, distance_matrix, service = load_data_solomon(name)
    return generate_particle(p, d, low_d, demand, max_capacity, distance_matrix, service, max_vehicle, name, best_route=best_route)
end


function print_particle(particle::Particle)
    vehicle = find_vehicle(particle)
    number_of_vehicle = length(vehicle)
    for i in 1:number_of_vehicle
        print("vehicle $i, route ")
        for j in vehicle[i]
            print("$j ")
        end
        println()
    end
end


function swap_to_first_or_last_position(particle::Particle, input_position::Int64, objective_function::Function)
    best_particle = deepcopy(particle)
    best_obj = objective_function(best_particle)
    position_zero = findall(x -> x == 0, best_particle.route)
    number_of_vehicle = length(position_zero) + 1
    
    if position_zero[1] == 1
        vehicle_index = [(1, position_zero[1])]
    else
        vehicle_index = [(1, position_zero[1] - 1)]
    end

    for k in 2:number_of_vehicle - 1
        append!(vehicle_index, [(vehicle_index[k - 1][2] + 2, position_zero[k] - 1)])
    end

    if number_of_vehicle == 2
        append!(vehicle_index, [(position_zero[end] + 1, length(particle.route))])
    else
        append!(vehicle_index, [(position_zero[end - 1] + 1, length(particle.route))])
    end
    # append!(vehicle_index, [(vehicle_index[end][2]+2, length(particle.route))])

    for vehicle_range in vehicle_index
        first_position_job, last_position_job = vehicle_range
        if input_position == first_position_job || input_position == last_position_job
            current_particle = deepcopy(particle)
            current_particle.route[first_position_job], current_particle.route[last_position_job] = current_particle.route[last_position_job], current_particle.route[first_position_job]
            current_obj = objective_function(current_particle)
            if current_obj <= best_obj && check_feasible(current_particle)
                best_particle = deepcopy(current_particle) 
                best_obj = current_obj
            end
        else
            current_particle_first = deepcopy(particle)
            current_particle_last = deepcopy(particle)
            current_particle_first.route[first_position_job], current_particle_first.route[input_position] = current_particle_first.route[input_position], current_particle_first.route[first_position_job]
            current_particle_last.route[last_position_job], current_particle_last.route[input_position] = current_particle_last.route[input_position], current_particle_last.route[last_position_job]
            first_feasible = check_feasible(current_particle_first)
            last_feasible = check_feasible(current_particle_last)
            if first_feasible && last_feasible
                first_obj = objective_function(current_particle_first)
                last_obj = objective_function(current_particle_last)
                if first_obj < last_obj 
                    if best_obj >= first_obj
                        best_particle = deepcopy(current_particle_first) 
                        best_obj = first_obj
                    end
                else
                    if best_obj >= last_obj
                        best_particle = deepcopy(current_particle_last) 
                        best_obj = last_obj
                    end
                end
            elseif first_feasible
                first_obj = objective_function(current_particle_first)
                if best_obj >= first_obj
                    best_particle = deepcopy(current_particle_first) 
                    best_obj = first_obj
                end
            elseif last_feasible
                last_obj = objective_function(current_particle_last)
                if best_obj >= last_obj
                    best_particle = deepcopy(current_particle_last) 
                    best_obj = last_obj
                end
            end
        end
    end
    return best_particle
end


function move_to_first_or_last_position(particle::Particle, input_position::Int64, objective_function::Function)
    best_particle = deepcopy(particle)
    best_obj = objective_function(best_particle)
    test_particle = deepcopy(best_particle)
    job = splice!(test_particle.route, input_position)
    position_zero = findall(x -> x == 0, test_particle.route)
    number_of_vehicle = length(position_zero) + 1
    
    if position_zero[1] == 1
        vehicle_index = [(1, position_zero[1])]
    else
        vehicle_index = [(1, position_zero[1] - 1)]
    end

    for k in 2:number_of_vehicle - 1
        append!(vehicle_index, [(vehicle_index[k - 1][2] + 2, position_zero[k] - 1)])
    end

    if number_of_vehicle == 2
        append!(vehicle_index, [(position_zero[end] + 1, length(test_particle.route))])
    else
        append!(vehicle_index, [(position_zero[end - 1] + 1, length(test_particle.route))])
    end
    # append!(vehicle_index, [(vehicle_index[end][2]+2, length(test_particle.route))])

    for vehicle_range in vehicle_index
        first_position_job, last_position_job = vehicle_range
        current_particle_first = deepcopy(test_particle)
        current_particle_last = deepcopy(test_particle)
        insert!(current_particle_first.route, first_position_job, job)
        insert!(current_particle_last.route, last_position_job, job)
        first_feasible = check_feasible(current_particle_first)
        last_feasible = check_feasible(current_particle_last)
        if first_feasible && last_feasible
            first_obj = objective_function(current_particle_first)
            last_obj = objective_function(current_particle_last)
            if first_obj < last_obj 
                if best_obj >= first_obj
                    best_particle = deepcopy(current_particle_first) 
                    best_obj = first_obj
                end
            else
                if best_obj >= last_obj
                    best_particle = deepcopy(current_particle_last) 
                    best_obj = last_obj
                end
            end
        elseif first_feasible
            first_obj = objective_function(current_particle_first)
            if best_obj >= first_obj
                best_particle = deepcopy(current_particle_first) 
                best_obj = first_obj
            end
        elseif last_feasible
            last_obj = objective_function(current_particle_last)
            if best_obj >= last_obj
                best_particle = deepcopy(current_particle_last) 
                best_obj = last_obj
            end
        end
    end
    return best_particle
end


function swap(particle::Particle, objective_function::Function; best_route=[]::Array)
    
    # remove best route from particle
    # particle = remove_best_route(particle, best_route)

    # define list
    list = shuffle(sort_processing_matrix(particle.p, best_route=best_route))
    first_obj = objective_function(particle)

    for (iter, (i, j)) in enumerate(list)
        swap_particle = deepcopy(particle)
        
        position1 = findfirst(x -> x == i, swap_particle.route)
        position2 = findfirst(x -> x == j, swap_particle.route)
        
        # swap
        if position1 == position2
            particle = swap_to_first_or_last_position(swap_particle, position1, objective_function)
            continue
        else
            swap_particle.route[position1], swap_particle.route[position2] = swap_particle.route[position2], swap_particle.route[position1]
            if objective_function(swap_particle) < objective_function(particle) && check_feasible(swap_particle)
                particle = deepcopy(swap_particle)
            end
        end
        
    end

    last_objective = objective_function(particle)

    # add the removed route to particle
    # if isnothing(best_route) == false
    #     append!(particle.route, 0)
    #     append!(particle.route, best_route)
    # end
    
    return particle
end


function move(particle::Particle, objective_function::Function; best_route=[])
    list = shuffle(sort_processing_matrix(particle.p, best_route=best_route))
    original_obj = objective_function(particle)
    for (iter, (i, j)) in enumerate(list)
        swap_particle = deepcopy(particle)
        first_obj = objective_function(swap_particle)
        
        position1 = findfirst(x -> x == i, swap_particle.route)
        position2 = findfirst(x -> x == j, swap_particle.route)
        
        # move
        if position1 == position2
            # println("move_to_first_or_last_position $(swap_particle.route)")
            swap_particle = move_to_first_or_last_position(swap_particle, position1, objective_function)
        else
            if position1 < position2
                job = splice!(swap_particle.route, position2)
                insert!(swap_particle.route, position1 + 1, job)
            else
                job = splice!(swap_particle.route, position2)
                insert!(swap_particle.route, position1, job)
            end
        end
        
        if objective_function(swap_particle) < objective_function(particle) && check_feasible(swap_particle)

            swap_particle.route = fix_missing_vehicle(swap_particle.route)

            # set to best vehicle
            particle = deepcopy(swap_particle)
        end
    end
    last_objective = objective_function(particle)
    return  particle
end


function local_search(particle::Particle, objective_function::Function; best_route=[])
    particle = two_opt(particle, objective_function, best_route=best_route)
    particle = swap(particle, objective_function, best_route=best_route)
    particle = move(particle, objective_function, best_route=best_route)
    return particle
end


function local_search_new(particle::Particle, objective_function::Function; best_route=[])
    particle = two_opt_new(particle, objective_function, best_route=best_route)
    particle = swap(particle, objective_function, best_route=best_route)
    particle = move(particle, objective_function, best_route=best_route)
    return particle
end


function local_search_old(particle::Particle, objective_function::Function; best_route=[])
    # particle = two_opt(particle, objective_function, best_route=best_route)
    particle = swap(particle, objective_function, best_route=best_route)
    particle = move(particle, objective_function, best_route=best_route)
    return particle
end


function test_run(name::String)
    particle = generate_particle(name)
    local_search(particle, total_distance)
end


function objective_value(particle::Particle; objective_function=nothing)
    nothing
end


function random_swap(particle::Particle)
    swap_index = rand(findall(x -> x != 0, particle.route), 2)
    particle.route[swap_index[1]], particle.route[swap_index[2]] = particle.route[swap_index[2]], particle.route[swap_index[1]]
    return particle
end


function random_move(particle::Particle)
    remove_index = rand(findall(x -> x != 0, particle.route))
    job = splice!(particle.route, remove_index)
    insert_index = rand(1:length(particle.route))
    insert!(particle.route, insert_index, job)

    particle.route = fix_missing_vehicle(particle.route)
    
    return particle
end


function particle_swarm(name::String, objective_function::Function; num_particle=15, max_iter=150, localsearch=false, cut_car=false, generate=false, num_save=nothing, save_dir=nothing, random_set=false, seed=1)
    particles = Dict()
    best_obj_vec = []
    max_vehicle = read_Solomon()[name]["NV"] + 9

    # try mkdir("particle_swarm/$(objective_function)/$save_dir/") catch nothing end
    # try mkdir("particle_swarm/$(objective_function)/$save_dir/$(name)/") catch nothing end
    # if num_particle != 15
    #     location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/"
    #     try mkdir("$location") catch nothing end
    # else
    #     location = "particle_swarm/$(objective_function)/$save_dir/$(name)/"
    # end
    location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/$seed/"

    if localsearch
        local_search_function = local_search
    else
        local_search_function = local_search_old
    end
        

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    # initial
    start_num, end_num = pull_random_particle(name, 0, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle)
    for i in 1:num_particle
        # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        particles[i] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=i))
        append!(best_obj_vec, objective_function(particles[i]))

        objective_value[1][i] = Dict()
        objective_value[1][i]["obj"] = best_obj_vec[end]
        objective_value[1][i]["method"] = "initial"
        
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    # best_particle = deepcopy(particles[best_index])
    best_obj1 = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    iter = 1
    random = 1
    random_count = 0
    remove = 1
    out = 1
    terminate = false
    khoo = Khoo()[name]

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search_function(particles[i], objective_function)
                # particles[i] = local_search_function(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
            else
                # local search
                particles[i] = local_search_function(particles[i], objective_function)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        if abs(best_obj_save[end]-best_obj_save[end-1]) < 1e-4
            random += 1
            remove += 1
            out += 1
        else
            random = 1
            remove = 1
            out = 1
        end
        
        # generate new particles
        if random == 5 && generate
            random_count += 1
            random = 1
            iter += 1

            start_num, end_num = pull_random_particle(name, random_count, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle)

            # objective value
            objective_value[iter] = Dict()

            sort_obj = sortperm(best_obj_vec, rev=true)
            # vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name", iter=i))
            if random_set
                for (j, random_num) in zip(sort_obj[1:end-1], start_num:end_num)
                    particles[j] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=random_num))
                    best_obj_vec[j] = objective_function(particles[j])
                end
            else
                for j in sort_obj[1:end-1]
                    particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
                    best_obj_vec[j] = objective_function(particles[j])
                end
            end

            # collect objective value
            for i in 1:num_particle
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "random"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)
        end

        if out == 10
            terminate = true
        end
    
        if remove == 5 && cut_car
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
                    obj_before = best_obj_vec[i]
                    particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            best_objective_value = best_obj_vec[best_index]
            append!(best_obj_save, best_objective_value)
            mean_obj = mean(best_obj_vec)
        end

        # save
        im = open("$location/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), #particle: $num_particle, iter: $iter, fix: false, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        println("\n$name, #particle: $num_particle, iter: $iter, fix: false, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        ig = open("$location/save-$(name)-$(num_save).txt", "w")
        vehicle = find_vehicle(particles[best_index])
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)
        end
        iter += 1
    end

    return particles[best_index], objective_value
end


function particle_swarm_fix(name::String, objective_function::Function; num_particle=15, max_iter=100, localsearch=false, cut_car=false, generate=false, num_save=nothing, save_dir=nothing, random_set=false, seed=1)
    particles = Dict()
    best_obj_vec = []
    max_vehicle = read_Solomon()[name]["NV"]*2

    # try mkdir("particle_swarm/$(objective_function)/$save_dir/") catch nothing end
    # try mkdir("particle_swarm/$(objective_function)/$save_dir/$(name)/") catch nothing end
    # if num_particle != 15
    #     location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/"
    #     try mkdir("$location") catch nothing end
    # else
    #     location = "particle_swarm/$(objective_function)/$save_dir/$(name)/"
    # end
    
    location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/$seed"

    if localsearch
        local_search_function = local_search
    else
        local_search_function = local_search_old
    end
        

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    # initial
    start_num, end_num = pull_random_particle(name, 0, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle, objective_function=objective_function)
    for i in 1:num_particle
        # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        particles[i] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=i))
        append!(best_obj_vec, objective_function(particles[i]))

        objective_value[1][i] = Dict()
        objective_value[1][i]["obj"] = best_obj_vec[end]
        objective_value[1][i]["method"] = "initial"
        
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    # best_particle = deepcopy(particles[best_index])
    best_obj1 = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    iter = 1
    random = 1
    random_count = 0
    remove = 1
    out = 1
    terminate = false
    khoo = Khoo()[name]

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search_function(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
            else
                # local search
                particles[i] = local_search_function(particles[i], objective_function, best_route=[])
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        if abs(best_obj_save[end]-best_obj_save[end-1]) < 1e-4
            random += 1
            remove += 1
            out += 1
        else
            random = 1
            remove = 1
            out = 1
        end
        
        # generate new particles
        if random == 5 && generate
            random_count += 1
            random = 1
            iter += 1

            start_num, end_num = pull_random_particle(name, random_count, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle, objective_function=objective_function)

            # objective value
            objective_value[iter] = Dict()

            sort_obj = sortperm(best_obj_vec, rev=true)
            if random_set
                for (j, random_num) in zip(sort_obj[1:end-1], start_num:end_num)
                    particles[j] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=random_num))
                    best_obj_vec[j] = objective_function(particles[j])
                end
            else
                for j in sort_obj[1:end-1]
                    particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
                    best_obj_vec[j] = objective_function(particles[j])
                end
            end

            # collect objective value
            for i in 1:num_particle
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "random"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)
        end

        if out == 10
            terminate = true
        end
    
        if remove == 5 && cut_car
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
                    obj_before = best_obj_vec[i]
                    particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            best_objective_value = best_obj_vec[best_index]
            append!(best_obj_save, best_objective_value)
            mean_obj = mean(best_obj_vec)
        end

        # save
        im = open("$location/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), #particle: $num_particle, iter: $iter, fix: false, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        # println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), Khoo: $(khoo) best objective value: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("\n$name, #particle: $num_particle, iter: $iter, fix: true, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        ig = open("$location/save-$(name)-$(num_save).txt", "w")
        vehicle = find_vehicle(particles[best_index])
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)
        end
        iter += 1
    end

    return particles[best_index], objective_value
end


function particle_swarm_fix_case_study(name::String, objective_function::Function; num_particle=15, max_iter=100, localsearch=false, cut_car=false, generate=false, num_save=nothing, save_dir=nothing, random_set=false, seed=1, max_vehicle=50, start_iter=nothing)
    particles = Dict()
    best_obj_vec = []

    # try mkdir("particle_swarm/$(objective_function)/$save_dir/") catch nothing end
    # try mkdir("particle_swarm/$(objective_function)/$save_dir/$(name)/") catch nothing end
    # if num_particle != 15
    #     location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/"
    #     try mkdir("$location") catch nothing end
    # else
    #     location = "particle_swarm/$(objective_function)/$save_dir/$(name)/"
    # end
    
    location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/$seed"
    try mkdir("$location/save/") catch nothing end

    if localsearch
        local_search_function = local_search
    else
        local_search_function = local_search_old
    end

    iq = open("$location/save/alg-save.txt", "a")
        

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    # initial
    if isnothing(start_iter) == true
        start_num, end_num = pull_random_particle(name, 0, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle, objective_function=objective_function)
        for i in 1:num_particle
            # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
            particles[i] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=i))
            append!(best_obj_vec, objective_function(particles[i]))

            objective_value[1][i] = Dict()
            objective_value[1][i]["obj"] = best_obj_vec[end]
            objective_value[1][i]["method"] = "initial"
            
        end
    else
        for i in 1:num_particle
            particles[i] = vehicle_to_particle(read_txt3("$location/save/$start_iter/$name-$i.txt", name))
            append!(best_obj_vec, objective_function(particles[i]))

            objective_value[1][i] = Dict()
            objective_value[1][i]["obj"] = best_obj_vec[end]
            objective_value[1][i]["method"] = "initial"
        end
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    # best_particle = deepcopy(particles[best_index])
    best_obj1 = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    if isnothing(start_iter)
        iter = 1
    else
        iter = start_iter + 1
    end

    random = 1
    random_count = 0
    remove = 1
    out = 1
    terminate = false
    khoo = 1e15

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search_function(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
                write(iq, "$iter, $i, path local\n")
            else
                # local search
                particles[i] = local_search_function(particles[i], objective_function, best_route=[])
                append!(best_obj_vec, objective_function(particles[i]))
                
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
                write(iq, "$iter, $i, local\n")
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        if abs(best_obj_save[end]-best_obj_save[end-1]) < 1e-4
            random += 1
            remove += 1
            out += 1
        else
            random = 1
            remove = 1
            out = 1
        end
        
        # generate new particles
        # if random == 10 && generate
        #     random_count += 1
        #     random = 1
        #     iter += 1

        #     start_num, end_num = pull_random_particle(name, random_count, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle, objective_function=objective_function)

        #     # objective value
        #     objective_value[iter] = Dict()

        #     sort_obj = sortperm(best_obj_vec, rev=true)
        #     if random_set
        #         for (j, random_num) in zip(sort_obj[1:end-1], start_num:end_num)
        #             particles[j] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=random_num))
        #             best_obj_vec[j] = objective_function(particles[j])
        #         end
        #     else
        #         for j in sort_obj[1:end-1]
        #             particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
        #             best_obj_vec[j] = objective_function(particles[j])
        #         end
        #     end

        #     # collect objective value
        #     for i in 1:num_particle
        #         objective_value[iter][i] = Dict()
        #         objective_value[iter][i]["obj"] = best_obj_vec[i]
        #         objective_value[iter][i]["method"] = "random"
        #     end

        #     # find new best solution
        #     best_index = argmin(best_obj_vec)
        #     append!(best_index_save, best_index)
        #     append!(best_obj_save, best_objective_value)
        #     best_objective_value = best_obj_vec[best_index]
        #     mean_obj = mean(best_obj_vec)
        # end

        if out == 10
            terminate = true
        end
    
        if remove == 5 && cut_car
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
                    obj_before = best_obj_vec[i]
                    particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
                write(iq, "$iter, $i, remove\n")
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            best_objective_value = best_obj_vec[best_index]
            append!(best_obj_save, best_objective_value)
            mean_obj = mean(best_obj_vec)
        end

        # save
        im = open("$location/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), #particle: $num_particle, iter: $iter, fix: false, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        # println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), Khoo: $(khoo) best objective value: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("\n$name, #particle: $num_particle, iter: $iter, fix: true, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        ig = open("$location/save-$(name)-$(num_save).txt", "w")
        vehicle = find_vehicle(particles[best_index])
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)

        # write all particle
        try mkdir("$location/save/$iter") catch nothing end
        for p in 1:num_particle
            ih = open("$location/save/$iter/$name-$p.txt", "w")
            vehicle = find_vehicle(particles[p])
            for i in 1:length(vehicle)
                for j in vehicle[i]
                    write(ig, "$j ")
                end
                write(ig, "\n")
            end
            close(ih)
        end
        iter += 1
    end
    end
    close(iq)
    return particles[best_index], objective_value
end


function particle_swarm_fix_new(name::String, objective_function::Function; num_particle=15, max_iter=150, localsearch=false, cut_car=false, generate=false, num_save=nothing, save_dir=nothing)
    particles = Dict()
    best_obj_vec = []
    max_vehicle = read_Solomon()[name]["NV"] + 9

    if localsearch
        local_search_function = local_search_new
    else
        local_search_function = local_search_old
    end
        

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    for i in 1:num_particle
        # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        particles[i] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name", iter=i))
        append!(best_obj_vec, objective_function(particles[i]))

        objective_value[1][i] = Dict()
        objective_value[1][i]["obj"] = best_obj_vec[end]
        objective_value[1][i]["method"] = "initial"
        
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    current_best_p = deepcopy(particles[best_index])
    current_best_obj = best_obj_vec[best_index]
    current_best_obj_save = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    iter = 1
    random = 1
    remove = 1
    terminate = false
    khoo = Khoo()[name]

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search_function(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
            else
                # local search
                particles[i] = local_search_function(particles[i], objective_function, best_route=[])
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        # save the best particle
        current_best_obj_save = current_best_obj
        if best_objective_value < current_best_obj
            current_best_p = deepcopy(particles[best_index])
            current_best_obj = best_objective_value
        end

        if abs(current_best_obj_save-current_best_obj) < 1e-4
            random += 1
            remove += 1
        else
            random = 1
            remove = 1
        end
        
        # generate new particles
        if random == 30 && generate
            random = 1
            iter += 1

            # objective value
            objective_value[iter] = Dict()

            sort_obj = sortperm(best_obj_vec, rev=true)
            for j in sort_obj[1:(Int(floor(num_particle/2)))]
                particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
                best_obj_vec[j] = objective_function(particles[j])
            end

            # collect objective value
            for i in 1:num_particle
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "random"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end

        if iter > 50
            if abs(mean(best_obj_save[end-50:end]) - best_obj_save[end]) < 1e-4
                terminate = true
            end
        end
    
        if remove == 5 && cut_car
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
                    obj_before = best_obj_vec[i]
                    particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end

        # save
        im = open("particle_swarm/$(objective_function)/$save_dir/$(name)/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), iter: $iter, new1, Khoo: $(khoo), current_best: $(@sprintf("%.2f", current_best_obj)) best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        # println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), Khoo: $(khoo) best objective value: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("\n$name iter: $iter, new1, Khoo: $(khoo), current best: $(@sprintf("%.2f", current_best_obj)), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        ig = open("particle_swarm/$(objective_function)/$save_dir/$(name)/save-$(name)-$(num_save).txt", "w")
        vehicle = find_vehicle(particles[best_index])
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)
        end
        iter += 1
    end

    return particles[best_index], objective_value
end


function particle_swarm_fix_new2(name::String, objective_function::Function; num_particle=15, max_iter=150, localsearch=false, cut_car=false, generate=false, num_save=nothing, save_dir=nothing)
    particles = Dict()
    best_obj_vec = []
    max_vehicle = read_Solomon()[name]["NV"] + 9

    # if localsearch
    #     local_search_function = local_search_new
    # else
    #     local_search_function = local_search_old
    # end

    # use old version of local search (moving and swapping)
    local_search_function = local_search_old
        

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    for i in 1:num_particle
        # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        particles[i] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name", iter=i))
        append!(best_obj_vec, objective_function(particles[i]))

        objective_value[1][i] = Dict()
        objective_value[1][i]["obj"] = best_obj_vec[end]
        objective_value[1][i]["method"] = "initial"
        
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    current_best_p = deepcopy(particles[best_index])
    current_best_obj = best_obj_vec[best_index]
    current_best_obj_save = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    iter = 1
    random = 1
    remove = 1
    two_opt_count = 1
    terminate = false
    khoo = Khoo()[name]

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search_function(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
            else
                # local search
                particles[i] = local_search_function(particles[i], objective_function, best_route=[])
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        # save the best particle
        current_best_obj_save = current_best_obj
        if best_objective_value < current_best_obj
            current_best_p = deepcopy(particles[best_index])
            current_best_obj = best_objective_value
        end

        if abs(current_best_obj_save-current_best_obj) < 1e-4
            random += 1
            remove += 1
            two_opt_count += 1
        else
            random = 1
            remove = 1
            two_opt_count = 1
        end
        
        # apply 2 opt
        if two_opt_count == 10
            two_opt_count = 1
            iter += 1

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                particles[i] = two_opt_new(particles[i], objective_function, best_route=best_route)

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "2-opt"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end


        # generate new particles
        if random == 30 && generate
            random = 1
            iter += 1

            # objective value
            objective_value[iter] = Dict()

            sort_obj = sortperm(best_obj_vec, rev=true)
            for j in sort_obj[1:(Int(floor(num_particle/2)))]
                particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
                best_obj_vec[j] = objective_function(particles[j])
            end

            # collect objective value
            for i in 1:num_particle
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "random"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end

        if iter > 50
            if abs(mean(best_obj_save[end-50:end]) - best_obj_save[end]) < 1e-4
                terminate = true
            end
        end
    
        if remove == 5 && cut_car
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
                    obj_before = best_obj_vec[i]
                    particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end

        # save
        im = open("particle_swarm/$(objective_function)/$save_dir/$(name)/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), iter: $iter, new2, Khoo: $(khoo), current_best: $(@sprintf("%.2f", current_best_obj)) best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        # println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), Khoo: $(khoo) best objective value: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("\n$name iter: $iter, new2, Khoo: $(khoo), current best: $(@sprintf("%.2f", current_best_obj)), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        ig = open("particle_swarm/$(objective_function)/$save_dir/$(name)/save-$(name)-$(num_save).txt", "w")
        vehicle = find_vehicle(particles[best_index])
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)
        end
        iter += 1
    end

    return particles[best_index], objective_value
end


function particle_swarm_fix_new3(name::String, objective_function::Function; num_particle=15, max_iter=150, localsearch=false, cut_car=false, generate=false, num_save=nothing, save_dir=nothing, seed=1)
    particles = Dict()
    best_obj_vec = []
    max_vehicle = read_Solomon()[name]["NV"] + 9

    # if localsearch
    #     local_search_function = local_search_new
    # else
    #     local_search_function = local_search_old
    # end

    # use old version of local search (moving and swapping)
    local_search_function = local_search_old

    # try mkdir("particle_swarm/$(objective_function)/new3/") catch nothing end
    # try mkdir("particle_swarm/$(objective_function)/new3/$(name)/") catch nothing end
    
    location = "particle_swarm/$(objective_function)/new3/$(name)/$(num_particle)/$(seed)"


    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    # initial
    start_num, end_num = pull_random_particle(name, 0, num_particle=num_particle, seed=seed, max_vehicle=max_vehicle)
    for i in 1:num_particle
        # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        particles[i] = vehicle_to_particle(read_txt2(name, "particle_swarm/$(objective_function)/initial/$name/$seed", iter=i))
        append!(best_obj_vec, objective_function(particles[i]))

        objective_value[1][i] = Dict()
        objective_value[1][i]["obj"] = best_obj_vec[end]
        objective_value[1][i]["method"] = "initial"
        
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    current_best_p = deepcopy(particles[best_index])
    current_best_obj = best_obj_vec[best_index]
    current_best_obj_save = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    iter = 1
    random = 1
    remove = 1
    two_opt_count = 1
    out = 1
    terminate = false
    khoo = Khoo()[name]

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search_function(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
            else
                # local search
                particles[i] = local_search_function(particles[i], objective_function, best_route=[])
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        # save the best particle
        current_best_obj_save = current_best_obj
        if best_objective_value < current_best_obj
            current_best_p = deepcopy(particles[best_index])
            current_best_obj = best_objective_value
        end

        if abs(current_best_obj_save-current_best_obj) < 1e-4
            random += 1
            remove += 1
            two_opt_count += 1
            out += 1
        else
            random = 1
            remove = 1
            two_opt_count = 1
            out = 1
        end
        
        # apply 2 opt
        if two_opt_count == 10
            two_opt_count = 1
            iter += 1

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                particles[i] = two_opt_new3(particles[i], objective_function, best_route=best_route)

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "2-opt"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end


        # generate new particles
        if random == 30 && generate
            random = 1
            iter += 1

            # objective value
            objective_value[iter] = Dict()

            sort_obj = sortperm(best_obj_vec, rev=true)
            for j in sort_obj[1:(Int(floor(num_particle/2)))]
                particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
                best_obj_vec[j] = objective_function(particles[j])
            end

            # collect objective value
            for i in 1:num_particle
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "random"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end

        if out == 50
            terminate = true
        end
    
        if remove == 5 && cut_car
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
                    obj_before = best_obj_vec[i]
                    particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)

            # save the best particle
            current_best_obj_save = current_best_obj
            if best_objective_value < current_best_obj
                current_best_p = deepcopy(particles[best_index])
                current_best_obj = best_objective_value
            end
        end

        # save
        im = open("$location/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), iter: $iter, new3, Khoo: $(khoo), current_best: $(@sprintf("%.2f", current_best_obj)) best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        # println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), Khoo: $(khoo) best objective value: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("\n$name iter: $iter, new3, Khoo: $(khoo), current best: $(@sprintf("%.2f", current_best_obj)), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        ig = open("$location/save-$(name)-$(num_save).txt", "w")
        vehicle = find_vehicle(particles[best_index])
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)
        end
        iter += 1
    end

    return particles[best_index], objective_value
end


function generate_initial(name, num; seed=1, max_vehicle=25, objective_function=total_distance)
    try mkdir("particle_swarm/$objective_function/initial/$name") catch e; nothing end
    try mkdir("particle_swarm/$objective_function/initial/$name/$seed") catch e; nothing end
    all_name = glob("$name*.txt", "particle_swarm/$objective_function/initial/$name/$seed/")
    a = length(all_name)
    for i in (a+1):(a+num)
        io = open("particle_swarm/$objective_function/initial/$name/$seed/$name-$i.txt", "w")
        particle = generate_particle(name, max_vehicle=max_vehicle)
        vehicle = find_vehicle(particle)
        for v in 1:length(vehicle)
            for j in vehicle[v]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)
    end
end


function pull_random_particle(name, set; num_particle=15, seed=1, max_vehicle=25, objective_function=total_distance)
    all_name = glob("$name*.txt", "particle_swarm/$objective_function/initial/$name/$seed/")
    a = length(all_name)
    if set == 0
        start_number = 1
        last_number = num_particle
    else
        start_number = (num_particle+1) + (num_particle-1)*(set-1)
        last_number = num_particle +      (num_particle-1)*set
    end

    if a < last_number
        generate_initial(name, last_number-a, seed=seed, max_vehicle=max_vehicle, objective_function=objective_function)
    end

    println("start: $start_number")
    println("end: $last_number")
    return start_number, last_number
end


function particle_swarm_ruin(name::String, objective_function::Function; num_particle=15, max_iter=150)
    particles = Dict()
    best_obj_vec = []
    max_vehicle = read_Solomon()[name]["NV"] + 15

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    for i in 1:num_particle
        particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        append!(best_obj_vec, objective_function(particles[i]))

        objective_value[1][i] = Dict()
        objective_value[1][i]["obj"] = best_obj_vec[end]
        objective_value[1][i]["method"] = "initial"
        
    end
    
    # index of min objective value
    best_index = argmin(best_obj_vec)
    # best_particle = deepcopy(particles[best_index])
    best_obj1 = best_obj_vec[best_index]
    best_objective_value = best_obj_vec[best_index]
    
    iter = 1
    random = 1
    remove = 1
    terminate = false
    khoo = try Khoo()[name] catch e; nothing end

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # time
    while iter <= max_iter && terminate == false
        @time begin

        objective_value[iter] = Dict()
        
        best_obj_vec = []
        
        # find best route for path relinking
        best_vehicle = find_vehicle(particles[best_index])
        random_vehicle = rand(1:length(best_vehicle))
        best_route = best_vehicle[random_vehicle]

        for i in 1:num_particle
            particles[i].max_vehicle = length(findall(x -> x == 0, particles[i].route)) + 1


            if i != best_index
                # path relinking
                particles[i] = path_relinking(particles[i], best_route, objective_function)
            
                # local search
                particles[i].route = fix_missing_vehicle(particles[i].route)
                particles[i] = local_search(particles[i], objective_function, best_route=best_route)
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "path, local"
            else
                # local search
                particles[i] = local_search(particles[i], objective_function, best_route=[])
                append!(best_obj_vec, objective_function(particles[i]))

                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "local"
            end
            
        end
        
        # find new best solution
        best_index = argmin(best_obj_vec)
        append!(best_index_save, best_index)
        append!(best_obj_save, best_objective_value)
        best_objective_value = best_obj_vec[best_index]
        mean_obj = mean(best_obj_vec)

        if abs(best_obj_save[end]-best_obj_save[end-1]) < 1e-4
            random += 1
            remove += 1
        else
            random = 1
            remove = 1
        end
        
        if random == 40
            random = 1
            iter += 1

            # objective value
            objective_value[iter] = Dict()

            sort_obj = sortperm(best_obj_vec, rev=true)
            for j in sort_obj[1:(Int(floor(num_particle/2)))]
                particles[j] = generate_particle(name, max_vehicle=max_vehicle, best_route=best_route)
                best_obj_vec[j] = objective_function(particles[j])
            end

            # collect objective value
            for i in 1:num_particle
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[i]
                objective_value[iter][i]["method"] = "random"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            append!(best_obj_save, best_objective_value)
            best_objective_value = best_obj_vec[best_index]
            mean_obj = mean(best_obj_vec)
        end

        if iter > 50
            if abs(mean(best_obj_save[end-50:end]) - best_obj_save[end]) < 1e-4
                terminate = true
            end
        end
    
        if remove == 5
            remove = 1
            iter += 1
            # best_obj_vec = []

            # objective value
            objective_value[iter] = Dict()

            for i in 1:num_particle
                if i != best_index
                    random_number = rand(1:length(particles[i].u))
                    obj_before = best_obj_vec[i]
                    particles[i] = ruin(particles[i], random_number)
                    best_obj_vec[i] =  objective_function(particles[i])
                    println("particle $i ruin: $random_number jobs, $obj_before => $(best_obj_vec[i])")
                else
                    best_obj_vec[i] = objective_function(particles[i])
                end
                    
                # collect objective value
                objective_value[iter][i] = Dict()
                objective_value[iter][i]["obj"] = best_obj_vec[end]
                objective_value[iter][i]["method"] = "remove"
            end

            # find new best solution
            best_index = argmin(best_obj_vec)
            append!(best_index_save, best_index)
            best_objective_value = best_obj_vec[best_index]
            append!(best_obj_save, best_objective_value)
            mean_obj = mean(best_obj_vec)
        end

        println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), Khoo: $(khoo), obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        end
        iter += 1
    end

    return particles[best_index], objective_value
end


function run_all_particle(objective_function::Function, num_times::Int64; start=1, stop=56)
    for name in Full_Name()[start:stop]
        save_name = "particle_swarm/$(objective_function)/$(num_times)/$(name).txt"
        best_particle = particle_swarm(name, objective_function, max_iter=20000, num_particle=20, save_name=save_name)
        vehicle = find_vehicle(best_particle)
        io = open(save_name, "w")
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)
    end
end


function run_particle_old(name::String, objective_function::Function, num_times::Int64; max_iter=200, inititla=false, folder="fix_route")
    khoo = Khoo()[name]
    iter = 1
    save_name = "particle_swarm/$(objective_function)/$(num_times)/$(name).txt"
    new_obj = khoo + 1
    while iter < 2 && new_obj > khoo
        best_particle, objective_value = particle_swarm(name, objective_function, max_iter=max_iter, num_particle=15, save_name=nothing, inititial=initial)
        new_obj = objective_function(best_particle)
        vehicle = find_vehicle(best_particle)

        # define directory
        dir = "particle_swarm/$(objective_function)/$(folder)"

        if isempty(glob("$name.txt", dir))
            io = open("$dir/$(name).txt", "w")
            for i in 1:length(vehicle)
                for j in vehicle[i]
                    write(io, "$j ")
                end
                write(io, "\n")
            end
            close(io)
        else
            origin_vehicle = read_txt2(name, dir)
            origin_obj = objective_function(origin_vehicle)
            if new_obj < origin_obj
                io = open("$dir/$(name).txt", "w")
                for i in 1:length(vehicle)
                    for j in vehicle[i]
                        write(io, "$j ")
                    end
                    write(io, "\n")
                end
                close(io)
            end
        end
        iter += 1
    end
end


function find_number_of_vehicle(particle::Particle)
    return length(findall(x -> x == 0, particle.route)) + 1
end


function run_particle(name::String, objective_function::Function; max_iter=200, save_dir="fix_route", max_iter_while=1, f=particle_swarm::Function, localsearch=false, cut_car=false, generate=false, num_particle=15, random_set=false, seed=1)
    khoo = Khoo()[name]
    iter = 1
    new_obj = khoo + 1
    # try mkdir("particle_swarm/$(objective_function)/$save_dir/") catch nothing end
    # try mkdir("particle_swarm/$(objective_function)/$save_dir/$(name)/") catch nothing end
    # location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/"
    # try mkdir("$location") catch nothing end
    location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/$seed/"
    # try mkdir("$location") catch nothing end
    #while iter <= max_iter_while && new_obj > khoo
    while iter <= max_iter_while
        # length files
        num_files = length(glob("$name*.txt", "$location")) + 1
        
        best_particle, objective_value = f(name, objective_function, max_iter=max_iter, num_particle=num_particle, localsearch=localsearch, cut_car=cut_car, generate=generate, num_save=num_files, save_dir=save_dir, random_set=random_set, seed=seed)
        new_obj = objective_function(best_particle)
        vehicle = find_vehicle(best_particle)
        
        # write best particle
        io = open("$location/$(name)-$(num_files).txt", "w")
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)

        # export to json
        open("$location/$(name)-$(num_files).json", "w") do f
            JSON.print(f, objective_value)
        end

        iter += 1
    end
end


function run_particle_case_study(name::String, objective_function::Function; max_iter=200, save_dir="fix_route", max_iter_while=1, f=particle_swarm::Function, localsearch=false, cut_car=false, generate=false, num_particle=15, random_set=false, seed=1, start_iter=1)
    khoo = 1000000000000000
    iter = 1
    new_obj = khoo + 1
    location = "particle_swarm/$(objective_function)/$save_dir/$(name)/$(num_particle)/$seed/"
    while iter <= max_iter_while && new_obj > khoo

        # length files
        num_files = length(glob("$name*.txt", "$location")) + 1
        
        best_particle, objective_value = f(name, objective_function, max_iter=max_iter, num_particle=num_particle, localsearch=localsearch, cut_car=cut_car, generate=generate, num_save=num_files, save_dir=save_dir, random_set=random_set, seed=seed, start_iter=start_iter)
        new_obj = objective_function(best_particle)
        vehicle = find_vehicle(best_particle)
        
        # write best particle
        io = open("$location/$(name)-$(num_files).txt", "w")
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)

        # export to json
        open("$location/$(name)-$(num_files).json", "w") do f
            JSON.print(f, objective_value)
        end

        iter += 1
    end
end


function run_particle_ruin(name::String, objective_function::Function; max_iter=1000, save_dir="ruin", max_iter_while=1)
    khoo = try Khoo()[name] catch e; 1e6 end
    iter = 1
    new_obj = khoo + 1
    while iter <= max_iter_while && new_obj > khoo
        best_particle, objective_value = particle_swarm_ruin(name, objective_function, max_iter=max_iter, num_particle=15)
        new_obj = objective_function(best_particle)
        vehicle = find_vehicle(best_particle)

        # write best particle
        num_files = length(glob("*.txt", "particle_swarm/$(objective_function)/$save_dir/$(name)"))
        io = open("particle_swarm/$(objective_function)/$save_dir/$(name)/$(name)-$(num_files+1).txt", "w")
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)

        # export to json
        open("particle_swarm/$(objective_function)/$save_dir/$name/$(name)-$(num_files+1).json", "w") do f
            JSON.print(f, objective_value)
        end

        iter += 1
    end
end


function run_case_study_particle(i::Int64, case_size::Int64, num::Int64, objective_function::Function; num_particle=15, while_iter=1, seed=1, max_iter=50, start_iter=nothing)

    name = "case_study-$case_size-$num"
    location = "particle_swarm/$objective_function/case$i/$(name)/$(num_particle)/$seed/"

    # create subfolders
    try mkdir("particle_swarm/$objective_function/case$i") catch e; nothing end
    try mkdir("particle_swarm/$objective_function/case$i/$name") catch e; nothing end
    try mkdir("particle_swarm/$objective_function/case$i/$name/$num_particle") catch e; nothing end
    try mkdir(location) catch e; nothing end

    # run 
    # Case(i, name=name, num_particle=num_particle, while_iter=while_iter, seed=seed, objective_function=objective_function, max_iter=max_iter)
    run_particle_case_study(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case16", max_iter_while=while_iter, f=particle_swarm_fix_case_study, localsearch=true,  cut_car=true,  generate=true, start_iter=start_iter) 

    # record 
    io = open("particle_swarm/$objective_function/run.txt", "a")
    a = length(glob("$name*.txt", location))
    write(io, "$(date_txt()), name: $name-$a, Alg: $i, #particle: $num_particle, seed: $seed\n")
    close(io)

    # sent email
    sent_email("finished $name case$i seed $seed", Objective_value_txt(name, dir="case$i", num_particle=num_particle, seed=seed, objective_function=objective_function))
end


function read_case_study(case_size, num, dir)

    file_location = "$(dir)/case_study-$(case_size)-$(num).txt"
    p, d, low_d, demand, service, distance_matrix, solomon_demand = import_case_study(case_size, num)


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

            # calculate processing time
            processing_time = []
            # for iteration 1
            append!(processing_time, p[current_sch[1], current_sch[1]])
            for i in 2:length(current_sch)
                append!(processing_time, p[current_sch[i - 1], current_sch[i]])
            end

            vehicle[i]["ProcessingTime"] = processing_time
        end
    end
    vehicle["num_vehicle"] = num_vehicle
    vehicle["name"] = "case_study"
    vehicle["case_size"] = case_size
    vehicle["num"] = num
    vehicle["dir"] = file_location
    return vehicle
end


function read_txt2(name::String, dir::String; iter=nothing, return_type="vehicle")
    if isnothing(iter)
        file_location = "$dir/$name.txt"
    else
        file_location = "$dir/$name-$iter.txt"
    end

    p, d, low_d, demand, solomon_demand, distance_matrix, service = load_data_solomon(name)

    if return_type == "vehicle"
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
                    append!(processing_time, p[current_sch[i - 1], current_sch[i]])
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
    elseif return_type == "particle"
        nothing
    end
end


function read_txt3(file_location::AbstractString, name::AbstractString)

    p, d, low_d, demand, solomon_demand, distance_matrix, service = load_data_solomon(name)

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
                append!(processing_time, p[current_sch[i - 1], current_sch[i]])
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




function vehicle_to_particle(vehicle::Dict; max_vehicle=100)::Particle
    new_vehicle = Dict()
    name = vehicle["name"]
    p, d, low_d, demand, max_capacity, distance_matrix, service = load_data_solomon(name)
    for i in 1:vehicle["num_vehicle"]
        new_vehicle[i] = vehicle[i]["sch"]
    end
    new_vehicle = convert_vehicle_to_list(new_vehicle)
    particle = Particle(new_vehicle, p, low_d, d, demand, max_capacity, distance_matrix, service, max_vehicle, name)
    return particle
end


function conclusion_particle_swarm_distance(;num=1)
    io = open("conclusion_particle_swarm_total_distance.csv", "w")
    write(io, "Name,Solomon,Heuristic(phase2),ParticleSwarm\n")
    for name in Full_Name()
        vehicle_benchmark = read_txt2(name, pre_dir="solutions_benchmark")
        vehicle_particle = try read_txt2(name, "particle_swarm/total_distance/$(num)/") catch e; nothing end
        vehicle_heuristic = read_txt2(name, alg="clustering-heuristic/", phase_2="swap_all_no_update-sort_processing_matrix")

        obj_benchmark = distance_solomon_all(vehicle_benchmark, name)
        obj_particle = try distance_solomon_all(vehicle_particle, name) catch e; nothing end
        obj_heuristic = distance_solomon_all(vehicle_heuristic, name)

        write(io, "$(name),$(obj_benchmark),$(obj_heuristic),$(obj_particle)\n")
    end
    close(io)

end


function conclusion_particle_swarm_distance_min(num)
    head = "Name"
    for n in num
        head = head * ",$n"
    end
    io = open("conclusion_particle_swarm_total_distance_num.csv", "w")
    write(io, "$head\n")
    for name in Full_Name()
        
        
        text = "$name"
        for n in num
            vehicle_particle = try read_txt2(name, "$(n)") catch e; nothing end
            obj_particle = try distance_solomon_all(vehicle_particle, name) catch e; nothing end
            text = text * ",$obj_particle"
        end

        write(io, "$text\n")
    end
    close(io)

end


function conclusion_particle_swarm_completion_time(;num=1)
    io = open("conclusion_particle_swarm_total_completion_time.csv", "w")
    write(io, "Name,Solomon_Com,Heuristic_Com,Particle_Com,Solomon_Dis,Heuristic_Dis,Particle_Dis\n")
    for name in Full_Name()
        vehicle_benchmark = read_txt2(name, pre_dir="solutions_benchmark")
        vehicle_particle = read_txt2(name, "particle_swarm/total_completion_time/$(num)/")
        # vehicle_heuristic = read_txt2(name, alg="clustering-heuristic/", phase_2="swap_all_no_update-sort_processing_matrix")

        # total distance
        dis_benchmark = distance_solomon_all(vehicle_benchmark)
        dis_particle = distance_solomon_all(vehicle_particle)
        dis_heuristic = minimum(phase3_makespan(name, pre_dir="phase1_completion_time", objective_function=distance_solomon_all))


        # total completion time
        com_benchmark = total_completion_time(vehicle_benchmark)
        com_particle = total_completion_time(vehicle_particle)
        com_heuristic = minimum(phase3_makespan(name, pre_dir="phase1_completion_time", objective_function=total_completion_time))

        write(io, "$(name),$(com_benchmark),$(com_heuristic),$(com_particle),$(dis_benchmark),$(dis_heuristic),$(dis_particle)\n")
    end
    close(io)
    
end


function conclusion_particle_swarm_distance_khoo()
    io = open("conclusion_particle_swarm_total_distance_khoo.csv", "w")
    write(io, "Name,Solomon_Dis,Khoo_Dis,Particle_1\n")
    for name in Full_Name()
    
        # total distance
        dis_benchmark = distance_solomon_all(read_txt2(name, pre_dir="solutions_benchmark"))
        # dis_particle_best = try distance_solomon_all(read_txt2(name, "particle_swarm/total_distance/best_solution/")) catch e; nothing end
        dis_particle_1 = try distance_solomon_all(read_txt2(name, "particle_swarm/total_distance/1/")) catch e; nothing end
    
        write(io, "$(name),$(dis_benchmark),$(Khoo()[name]),$(dis_particle_1)\n")
    end
    close(io)
end


function conclusion_particle_swarm_distance_min_transpose()
    type = [1, 2, 3]
    for (i, name) in enumerate(Full_Name())
        dis = [try read_txt2(name, "particle_swarm/total_distance/$(i)")["TotalDistance"] catch e; 10000.0 end for i in type]
        if i == 1
            global A = dis
        else
            A = [A dis]
        end
    end
    df = DataFrame(A)
    rename!(df, [name for name in Full_Name()])
    return df
end


function conclusion_particle_swarm_distance_min_describe()
    dis_4_better_khoo = []
    dis_best_better_khoo = []
    dis_best_better_4 = []
    dis_4_better_best = []
    dis_min_better_khoo = []
    for name in Full_Name()
        dis_4 = try read_txt2(name, "particle_swarm/total_distance/4")["TotalDistance"] catch e; nothing end
        dis_best = try read_txt2(name, "particle_swarm/total_distance/best_solution/")["TotalDistance"] catch e; nothing end
        dis_min = try minimum([dis_4, dis_best]) catch e; nothing end
        dis_khoo = Khoo()[name]
        if isnothing(dis_4) == false

            if dis_4 < dis_khoo
                append!(dis_4_better_khoo, [name])
            end

            if dis_4 < dis_best
                append!(dis_4_better_best, [name])
            else
                append!(dis_best_better_4, [name])
            end

        end


        if isnothing(dis_min) == false

            if dis_min < dis_khoo
                append!(dis_min_better_khoo, [name])
            end
        end

        if dis_best < dis_khoo
            append!(dis_best_better_khoo, [name])
        end
    end
    println("old  better than Khoo $(length(dis_4_better_khoo))    : $(dis_4_better_khoo)")
    println("old  better than best $(length(dis_4_better_best))    : $(dis_4_better_best)")
    println("best better than old  $(length(dis_best_better_4))    : $(dis_best_better_4)")
    println("best better than Khoo $(length(dis_best_better_khoo))   : $(dis_best_better_khoo)")
    println("min better than Khoo $(length(dis_min_better_khoo))   : $(dis_min_better_khoo)")
end

            

function run_all1(num::Int64)
    if num == 1
        for name in ["r101", "r102", "r103", "r104", "r105"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 2
        for name in ["r108", "r109", "r110", "r111", "r112"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 3
        for name in ["r203", "r204", "r205", "r206", "r207", "r106"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 4 
        for name in ["r210", "r211", "rc203", "rc204", "r209"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 5
        for name in ["rc106", "rc204", "rc205", "r202", "r208"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 6
        for name in ["rc101", "rc102", "rc103", "rc104", "rc105"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 7
        for name in ["rc107", "rc108", "rc201", "rc202", "rc203"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 8
        for name in ["rc107", "rc108", "rc201", "rc202", "r201"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    elseif num == 9
        for name in ["r107", "rc205", "rc206", "rc207", "rc208"]
            run_particle(name, total_distance, save_dir="1", max_iter=150)
        end
    end
end


function Khoo()
    x = [1613.59,
        1454.68,
        1213.62,
        974.24,
        1360.78,
        1239.37,
        1072.12,
        938.2,
        1151.84,
        1072.41,
        1053.5,
        953.63,
        1144.48,
        1034.35,
        874.87,
        735.8,
        954.16,
        879.89,
        797.99,
        705.33,
        859.39,
        905.21,
        753.15,
        828.94,
        828.94,
        828.07,
        824.78,
        828.94,
        828.94,
        828.94,
        828.94,
        828.94,
        591.56,
        591.56,
        591.17,
        590.6,
        588.88,
        588.49,
        588.29,
        588.32,
        1623.58,
        1461.23,
        1261.67,
        1135.52,
        1518.58,
        1371.69,
        1212.83,
        1117.53,
        1134.91,
        1095.64,
        926.82,
        786.38,
        1157.55,
        1054.61,
        966.08,
        778.93,
    ]
    y = Dict()
    for (i, name) in enumerate(Full_Name())
        y[name] = x[i]
    end
    z = Dict(name => read_Solomon()[name]["Distance"] for name in keys(read_Solomon()))
    t = merge(z, y)
    return t
end


function run1(N)
    for n in N
        run_particle(n, total_distance, 7, max_iter=5000)
    end
end

function plot_each_iteration(name::String, iter::Int64, dir; max_iter=nothing)
    d = JSON.parsefile("particle_swarm/total_distance/$dir/$name/$name-$iter.json")
    
    # parameters
    num_iteration = length(d)
    num_particle = length(d["1"])
    
    if isnothing(max_iter) == false
        num_iteration = max_iter
    end

    particles = 1
    p1 = Plots.scatter()
    for p in 1:num_particle
        obj = []
        for i in 1:num_iteration
            append!(obj, d["$i"]["$p"]["obj"])
        end
        # p1 = Plots.scatter!(1:num_iteration, obj, legend = false, xlims=(1, num_iteration), xticks=1:num_iteration, size=(2000, 700))
        if num_iteration <= 150
            p1 = Plots.scatter!(1:num_iteration, obj, legend = :outerright, xlims=(1, num_iteration), xticks=1:3:num_iteration, size=(2000, 700))
        elseif num_iteration <= 200
            p1 = Plots.scatter!(1:num_iteration, obj, legend = :outerright, xlims=(1, num_iteration), xticks=1:5:num_iteration, size=(2500, 1000))
        elseif num_iteration <= 300
            p1 = Plots.scatter!(1:num_iteration, obj, legend = :outerright, xlims=(1, num_iteration), xticks=1:5:num_iteration, size=(2500, 1000))
        else
            p1 = Plots.scatter!(1:num_iteration, obj, legend = :outerright, xlims=(1, num_iteration), xticks=1:5:num_iteration, size=(3000, 1500))
        end

    end
    savefig(p1, "particle_swarm/total_distance/plot_iteration/obj-$name-$iter.pdf")
    
    p2 = Plots.scatter()
    for p in 1:num_particle
        method = []
        for i in 1:num_iteration
            append!(method, ["$(d["$i"]["$p"]["method"])"])
        end
        p2 = Plots.scatter!(1:num_iteration, method, legend = :outerright, xlims=(1, num_iteration), xticks=1:5:num_iteration, size=(2000, 700))
    end
    savefig(p2, "particle_swarm/total_distance/plot_iteration/method-$name-$iter.pdf")
end


function Objective_value(name::String, case::String, num_particle::Int64, seed::Int64)
    println("*-------------------------------------------*")
    location = "particle_swarm/total_distance/$case/$name/$num_particle/$seed"
    num_files = length(glob("$name*.txt", location))
    obj_vec = [read_txt2(name, location, iter=i)["TotalDistance"] for i in 1:num_files]
    NV_vec = [read_txt2(name, location, iter=i)["num_vehicle"] for i in 1:num_files]

    

    for (iter, value) = enumerate(obj_vec)
        d = JSON.parsefile("$location/$name-$iter.json")
        println("$location $name-$(@sprintf("%2d", iter)), ojb value: $(@sprintf("%.2f", value)) iter: $(length(d)) NV: $(NV_vec[iter])")
    end
    arg_min = argmin(obj_vec)
    println("min: $name-$(arg_min) $(@sprintf("%.2f", obj_vec[arg_min])) Khoo: $(Khoo()[name])")
    return obj_vec[arg_min]
end


function Objective_value(name::String; max_iter=nothing, dir="fix_route")
    println("*-------------------------------------------*")
    num_files = length(glob("$name*.txt", "particle_swarm/total_distance/$dir/$name/"))
    obj_vec = [read_txt2(name, "particle_swarm/total_distance/$dir/$name/", iter=i)["TotalDistance"] for i in 1:num_files]
    NV_vec = [read_txt2(name, "particle_swarm/total_distance/$dir/$name/", iter=i)["num_vehicle"] for i in 1:num_files]

    

    for (iter, value) = enumerate(obj_vec)
        d = JSON.parsefile("particle_swarm/total_distance/$dir/$name/$name-$iter.json")
        println("$dir $name-$(@sprintf("%2d", iter)), ojb value: $(@sprintf("%.2f", value)) iter: $(length(d)) NV: $(NV_vec[iter])")
    end
    arg_min = argmin(obj_vec)
    println("min: $name-$(arg_min) $(@sprintf("%.2f", obj_vec[arg_min])) Khoo: $(Khoo()[name])")
    return obj_vec[arg_min]
end


function Objective_value_txt(name::String; max_iter=nothing, dir="fix_route", num_particle=15, seed=1, objective_function=total_distance)
    # t = "*-------------------------------------------*\n"
    # println("*-------------------------------------------*")
    t = "$name -- $dir -- $num_particle -- $seed\n"

    location = "particle_swarm/$objective_function/$dir/$(name)/$(num_particle)/$seed/"
    num_files = length(glob("$name*.txt", location))
    obj_vec = [read_txt2(name, location, iter=i)["TotalDistance"] for i in 1:num_files]


    

    for (iter, value) = enumerate(obj_vec)
        d = JSON.parsefile("$location/$name-$iter.json")
        # t = t * "$dir $name-$(@sprintf("%2d", iter)), ojb value: $(@sprintf("%.2f", value)) iter: $(length(d))\n"
        println("$dir $name-$(@sprintf("%2d", iter)), ojb value: $(@sprintf("%.2f", value)) iter: $(length(d))")
    end
    
    if isempty(obj_vec)
        return "nothing"
    else
        arg_min = argmin(obj_vec)
        t *= "min: $name-$(arg_min) $(@sprintf("%.2f", obj_vec[arg_min])) Khoo: $(Khoo()[name])\n"
        println("min: $name-$(arg_min), number particle: $num_particle, $(@sprintf("%.2f", obj_vec[arg_min])) Khoo: $(Khoo()[name])")
        return t
    end
end


function Objective_value_txt(name::String, case::String, num_particle::Int64, seed::Int64, objective_function=total_distance)
    t = "*-------------------------------------------*\n"
    println("*-------------------------------------------*")

    location = "particle_swarm/$objective_function/$case/$name/$num_particle/$seed"
    num_files = length(glob("$name*.txt", location))
    obj_vec = [vehicle_to_particle(read_txt2(name, location, iter=i)["TotalDistance"]) for i in 1:num_files]
    obj_vec = [read_txt2(name, location, iter=i)["TotalDistance"] for i in 1:num_files]


    

    for (iter, value) = enumerate(obj_vec)
        d = JSON.parsefile("$location/$name-$iter.json")
        t = t * "$location $name-$(@sprintf("%2d", iter)), ojb value: $(@sprintf("%.2f", value)) iter: $(length(d))\n"
        println("$location $name-$(@sprintf("%2d", iter)), ojb value: $(@sprintf("%.2f", value)) iter: $(length(d))")
    end
    
    if isempty(obj_vec)
        return t
    else
        arg_min = argmin(obj_vec)
        t *= "min: $name-$(arg_min) $(@sprintf("%.2f", obj_vec[arg_min])) Khoo: $(Khoo()[name])\n"
        println("min: $name-$(arg_min), number particle: $num_particle, $(@sprintf("%.2f", obj_vec[arg_min])) Khoo: $(Khoo()[name])")
        return t
    end
end


function Case(case::Int64; name="r101", while_iter=5, num_particle=15, seed=1, objective_function=total_distance, max_iter=150)
    if     case == 1;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case1",  max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=false, generate=false)
    elseif case == 2;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case2",  max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=false, generate=false)
    elseif case == 3;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case3",  max_iter_while=while_iter, f=particle_swarm,     localsearch=true,  cut_car=false, generate=false)
    elseif case == 4;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case4",  max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=true,  generate=false)
    elseif case == 5;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case5",  max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=false, generate=true)
    elseif case == 6;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case6",  max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=false, generate=false)
    elseif case == 7;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case7",  max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=true,  generate=false)
    elseif case == 8;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case8",  max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=false, generate=true)
    elseif case == 9;  run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case9",  max_iter_while=while_iter, f=particle_swarm    , localsearch=true,  cut_car=true,  generate=false) 
    elseif case == 10; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case10", max_iter_while=while_iter, f=particle_swarm    , localsearch=true, cut_car=false,  generate=true) 
    elseif case == 11; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case11", max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=true,  generate=true)
    elseif case == 12; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case12", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=true,  generate=false)
    elseif case == 13; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case13", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=false, generate=true) 
    elseif case == 14; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case14", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=true,  generate=true) 
    elseif case == 15; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case15", max_iter_while=while_iter, f=particle_swarm,     localsearch=true,  cut_car=true,  generate=true)
    elseif case == 16; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="case16", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=true,  generate=true) 
    end
end


function Case(case::String; name="r101", while_iter=5, num_particle=15, seed=1, objective_function=total_distance, max_iter=150)
    if     case == "random1"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=false, generate=false, random_set=true)
    elseif case == "random2"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=false, generate=false, random_set=true)
    elseif case == "random3"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm,     localsearch=true,  cut_car=false, generate=false, random_set=true)
    elseif case == "random4"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=true,  generate=false, random_set=true)
    elseif case == "random5"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=false, generate=true,  random_set=true)
    elseif case == "random6"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=false, generate=false, random_set=true)
    elseif case == "random7"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=true,  generate=false, random_set=true)
    elseif case == "random8"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=false, generate=true,  random_set=true)
    elseif case == "random9"; run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm    , localsearch=true,  cut_car=true,  generate=false, random_set=true) 
    elseif case == "random10";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm    , localsearch=true,  cut_car=false, generate=true,  random_set=true) 
    elseif case == "random11";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm,     localsearch=false, cut_car=true,  generate=true,  random_set=true)
    elseif case == "random12";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=true,  generate=false, random_set=true)
    elseif case == "random13";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=false, generate=true,  random_set=true) 
    elseif case == "random14";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=false, cut_car=true,  generate=true,  random_set=true) 
    elseif case == "random15";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm,     localsearch=true,  cut_car=true,  generate=true,  random_set=true)
    elseif case == "random16";run_particle(name, objective_function, seed=seed, max_iter=max_iter, num_particle=num_particle, save_dir="$case", max_iter_while=while_iter, f=particle_swarm_fix, localsearch=true,  cut_car=true,  generate=true,  random_set=true) 
    end
end


function print_all_case(name::String)
    for i in 1:16
        try Objective_value(name, dir="case$i") catch e; nothing end
    end
end


function create_folder_case()
    for i in 1:16
        try mkdir("particle_swarm/total_distance/case$i/") catch nothing end
    end
end


function create_folder()
    for name in Full_Name()
        for case in 1:16
            try mkdir("particle_swarm/total_distance/case$case/$name") catch nothing end
        end
    end
end


function create_folder_initial()
    for name in Full_Name()
        try mkdir("particle_swarm/total_distance/initial/$name") catch nothing end
    end
end


function create_markdown(;outname="README.md", name_case=["r101", "r201", "rc101", "rc201", "r102", "r202", "rc102", "rc202", "r103", "r203", "rc103", "rc203", "r104"], seed=1, num_particle=15)
    check_mark = ":heavy_check_mark:"
    fix = [k == 1 ? "$check_mark" : "" for k in [        0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1]]
    localsearch = [k == 1 ? "$check_mark" : "" for k in [0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1]]
    cut = [k == 1 ? "$check_mark" : "" for k in [        0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1]]
    gen = [k == 1 ? "$check_mark" : "" for k in [        0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1]]

    A = Dict()
    for name in name_case
        # A["$name"] = [isnothing(k) ? "" : "$(@sprintf("%.2f", k))" for k in [try Objective_value("$(name)", dir="case$i") catch e; nothing end for i in 1:16]]
        A["$name"] = [isnothing(k) ? "" : "$(@sprintf("%.2f", k))" for k in [try Objective_value(name, "case$i", num_particle, seed) catch e; nothing end for i in 1:16]]
    end

    io = open(outname, "w")
    write_txt = "|Alg|Fix|Local|Cut|New|"
    for name in name_case
        write_txt = write_txt * "$name-$(Khoo()["$name"])|"
    end
    write(io, "$write_txt\n")
    new_txt = "|" * "---|"^(5+length(name_case))
    write(io, "$new_txt\n")
    for i in 1:16
        write_txt = "|$i|$(fix[i])|$(localsearch[i])|$(cut[i])|$(gen[i])|"
        for name in name_case
            write_txt = write_txt * "$(A["$name"][i])|"
        end
        write(io, "$write_txt\n")
    end
    close(io)
end


function glob_folder(location::String)
    num_particle = first(walkdir("particle_swarm/total_distance/case1/r101"))[2]
end


function conclusion_average(; seed=1, num_particle=15)
    io = open("particle_swarm/conclusion_average.csv", "w")
    write(io, "case,c1,c2,r1,r2,rc1,rc2\n")
    for case in 1:16
        line_value = "$case"
        for list_name in ["c1", "c2", "r1", "r2", "rc1", "rc2"]
            value = []
            for name in Full_Name(list_name)
                location = "particle_swarm/total_distance/case$case/$name/$num_particle/$seed"
                name_files = glob("$name*.txt", location)
                if isempty(name_files)
                    continue
                else
                    obj_value = [read_txt3(n, name)["TotalDistance"] for n in name_files]
                    append!(value, minimum(obj_value))
                end
            end
            line_value *= ",$(mean(value))"
        end
        write(io, "$line_value\n")
    end
    close(io)
end


function create_markdown(name_case::String; focus=false)
    if focus
        create_markdown_p(outname="README2-$name_case.md", name_case=Full_Name(name_case))
    else
        create_markdown(outname="README-$name_case.md", name_case=Full_Name(name_case))
    end
end


function create_markdown_p(;outname="README2.md", name_case=["r101", "r201", "rc101", "rc201", "r102", "r202", "rc102", "rc202", "r103", "r203", "rc103", "rc203", "r104", "c101", "c201", "c102", "c202", "c103", "c203", "c104", "c204", "c105", "c205", "c106", "c206", "c107", "c207", "c108", "c208"])
    num_case = [5, 8, 10, 11, 13, 14, 15, 16]
    check_mark = ":heavy_check_mark:"
    fix = [k == 1 ? "$check_mark" : "" for k in [        0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1]]
    localsearch = [k == 1 ? "$check_mark" : "" for k in [0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1]]
    cut = [k == 1 ? "$check_mark" : "" for k in [        0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1]]
    gen = [k == 1 ? "$check_mark" : "" for k in [        0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1]]

    A = Dict()
    for name in name_case
        A["$name"] = [isnothing(k) ? "" : "$(@sprintf("%.2f", k))" for k in [try Objective_value("$(name)", dir="case$i") catch e; nothing end for i in num_case]]
    end

    io = open(outname, "w")
    write_txt = "|Alg|Fix|Local|Cut|"
    for name in name_case
        write_txt = write_txt * "$name-$(Khoo()["$name"])|"
    end
    write(io, "$write_txt\n")
    new_txt = "|" * "---|"^(4+length(name_case))
    write(io, "$new_txt\n")
    for (j, i) in enumerate(num_case)
        write_txt = "|$i|$(fix[i])|$(localsearch[i])|$(cut[i])|"
        for name in name_case
            write_txt = write_txt * "$(A["$name"][j])|"
        end
        write(io, "$write_txt\n")
    end
    close(io)
end


function find_obj(name::Array, folder::Array)
    location = []
    save_name = []
    case_num = split.(folder, "/")
    for i in name
        for (n, j) in enumerate(folder)
            if length(case_num[n]) == 2
                append!(location, ["particle_swarm/total_distance/$(case_num[n][1])/$(i)/$(case_num[n][2])/"])
                append!(save_name, [i])
            else
                append!(location, ["particle_swarm/total_distance/$(j)/$(i)/"])
                append!(save_name, [i])
            end
        end
    end

    obj = []

    for (new_name, l) in zip(save_name, location)
        files = glob("$(new_name)-*.txt", l)
        obj_vec = [total_distance(read_txt3(ll, new_name)) for ll in files]
        append!(obj, [obj_vec])
        println("$l, $obj_vec")
    end
    return location, obj
end


function find_obj(name::String, folder::Array; num_particle::Int64, seed::Int64)
    location = []
    save_name = []
    case_num = split.(folder, "/")
    for (n, j) in enumerate(folder)
        if length(case_num[n]) == 2
            append!(location, ["particle_swarm/total_distance/$(case_num[n][1])/$(name)/$(case_num[n][2])/$(num_particle)/$(seed)"])
            append!(save_name, [name])
        else
            append!(location, ["particle_swarm/total_distance/$(j)/$(name)/$(num_particle)/$(seed)"])
            append!(save_name, [name])
        end
    end

    obj = []

    for (new_name, l) in zip(save_name, location)
        files = glob("$(new_name)-*.txt", l)
        obj_vec = [total_distance(read_txt3(ll, new_name)) for ll in files]
        append!(obj, [obj_vec])
        println("$l, $obj_vec")
    end
    return location, obj
end


function find_obj(name::String, case::Int)
    location, obj = find_obj([name], ["case$case/5", "case$case/10", "case$case", "case$case/20", "case$case/25", "case$case/30", "case$case/35", "case$case/50", "case$case/70", "case$case/100"])
    return 0
end


function find_min_obj(name::Array, folder::Array)
    location, obj = find_obj(name, folder)
    return location, [try minimum(k) catch e; nothing end for k in obj]
end


function run_case(i::Int64, name_case::Array; num_particle=15, while_iter=5, seed=1, objective_function=total_distance::Function)
    for name in name_case
        # location
        location = "particle_swarm/$objective_function/case$i/$(name)/$(num_particle)/$seed/"

        # create subfolders
        try mkdir("particle_swarm/$objective_function/case$i") catch e; nothing end
        try mkdir("particle_swarm/$objective_function/case$i/$name") catch e; nothing end
        try mkdir("particle_swarm/$objective_function/case$i/$name/$num_particle") catch e; nothing end
        try mkdir(location) catch e; nothing end

        # run 
        Case(i, name=name, num_particle=num_particle, while_iter=while_iter, seed=seed)

        # record 
        io = open("particle_swarm/$objective_function/run.txt", "a")
        a = length(glob("$name*.txt", location))
        write(io, "$(date_txt()), name: $name-$a, Alg: $i, #particle: $num_particle, seed: $seed\n")
        close(io)

        # sent email
        sent_email("finished $name case$i seed $seed", Objective_value_txt(name, dir="case$i", num_particle=num_particle, seed=seed))
    end
end


function run_case(i::String, name_case::Array; num_particle=15, while_iter=5, seed=1)
    for name in name_case
        # save main location
        location = "particle_swarm/total_distance/$i/$(name)/$(num_particle)/$seed/"

        # create subfoldes
        try mkdir("particle_swarm/total_distance/$i") catch e; nothing end
        try mkdir("particle_swarm/total_distance/$i/$name") catch e; nothing end
        try mkdir("particle_swarm/total_distance/$i/$name/$num_particle") catch e; nothing end
        try mkdir(location) catch e; nothing end
        
        # run
        Case(i, name=name, num_particle=num_particle, while_iter=while_iter, seed=seed)

        # record
        io = open("particle_swarm/total_distance/run.txt", "a")
        a = length(glob("$name*.txt", location))
        write(io, "$(date_txt()), name: $name-$a, Alg: $i, #particle: $num_particle seed: $seed\n")
        close(io)

        # sent email
        sent_email("finished $name $i seed $seed", Objective_value_txt(name, dir="$i", num_particle=num_particle, seed=seed))
    end
end


using SMTPClient
function sent_email(subject::String, massage::String)
    username = "payakorn.sak@gmail.com"
    opt = SendOptions(
    isSSL = true,
    username = "payakorn.sak@gmail.com",
    passwd = "daxdEw-kyrgap-2bejge")
    #Provide the message body as RFC5322 within an IO
    body = IOBuffer(
    # "Date: Fri, 18 Oct 2013 21:44:29 +0100\r\n" *
    "From: You <$username>\r\n" *
    "To: payakornn@gmail.com\r\n" *
    "Subject: $subject\r\n" *
    "\r\n" *
    "$massage\r\n")
    url = "smtps://smtp.gmail.com:465"
    rcpt = ["<payakornn@gmail.com>"]
    from = "<$username>"
    resp = send(url, rcpt, from, body, opt)
end


function print_num_case(name)
    A = hcat([name], [length(glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")) for num_case in 1:16]')
    for name in Full_Name()
        A = vcat(A, hcat([name], [length(glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")) for num_case in 1:16]'))
    end
    t = pretty_table(String, A, append!(["name"], ["$i" for i in 1:16]), tf=tf_compact)
    return t
end


function print_num_case_new(name)
    A = hcat([name], [length(glob("$name*.txt", "particle_swarm/total_distance/new$num_case/$name")) for num_case in 1:3]')
    for name in Full_Name()[2:end]
        A = vcat(A, hcat([name], [length(glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")) for num_case in 1:3]'))
    end
    t = pretty_table(String, A, append!(["name"], ["$i" for i in 1:3]), tf=tf_compact)
    return t
end


function minimum_obj_all_case(name)
    min_obj = 10000
    for i in 1:16
        name_run = glob("$name*.txt", "particle_swarm/total_distance/case$i/$name")
        if isempty(name_run)
            continue
        else
            current_min = minimum([total_distance(read_txt3(dir, name)) for dir in name_run])
            if current_min < min_obj
                min_obj = current_min
            end
        end
    end
    if min_obj == 10000
        return nothing
    else
        return min_obj
    end
end



function run_case_c(name::String, num_case::Int64)
    name_run = glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")
    if length(name_run) > 0
        min_obj = minimum([total_distance(read_txt3(dir, name)) for dir in name_run])
    else
        min_obj = 10000
    end

    less_than5 = true
    
    if abs(min_obj - Khoo()[name]) >= 1e-1 && length(name_run) < 5
        Case(num_case, name=name, while_iter=(5-length(name_run)))
        less_than5 = false
    end

    # sent conclusions email
    name_run = glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")
    min_obj = minimum([total_distance(read_txt3(dir, name)) for dir in name_run])
    massage = "Complete $name, case: $num_case with $(5-length(name_run)) iterations (already have $(length(name_run)))\n
    min total distance in case$num_case = $(min_obj)\n
    min total distance in all cases = $(minimum_obj_all_case(name))\n
    Khoo=$(Khoo()[name])\n
    $(print_num_case(name))"
    sent_email("Complete $name, case: $num_case", massage)
end


function run_case_new(name::String, num_case::Int64; seed=1, num_particle=15)
    # main location
    location = "particle_swarm/total_distance/new$num_case/$name/$(num_particle)/$(seed)"

    # create subfolders
    try mkdir("particle_swarm/total_distance/new$num_case") catch e; nothing end
    try mkdir("particle_swarm/total_distance/new$num_case/$name/") catch e; nothing end
    try mkdir("particle_swarm/total_distance/new$num_case/$name/$(num_particle)") catch e; nothing end
    try mkdir(location) catch e; nothing end

    # find all files in main location
    name_run = glob("$name*.txt", location)
    if length(name_run) > 0
        min_obj = minimum([total_distance(read_txt3(dir, name)) for dir in name_run])
    else
        min_obj = 10000
    end

    less_than5 = true
    
    # if abs(min_obj - Khoo()[name]) < 1e-3 && length(name_run) < 5
    #     Case(num_case, name=name, while_iter=(5-length(name_run)))
    #     less_than5 = false
    # end
    best_particle, best_obj = particle_swarm_fix_new3(name, total_distance, num_particle=num_particle, max_iter=5000, localsearch=true, cut_car=true, generate=true, save_dir="new3", num_save=length(name_run)+1, seed=seed)

    ig = open("$location/$(name)-$(length(name_run)+1).txt", "w")
        vehicle = find_vehicle(best_particle)
        for i in 1:length(vehicle)
            for j in vehicle[i]
                write(ig, "$j ")
            end
            write(ig, "\n")
        end
        close(ig)

    # sent conclusions email
    name_run = glob("$name*.txt", location)
    min_obj = minimum([total_distance(read_txt3(dir, name)) for dir in name_run])
    # d = JSON.parsefile("/$location/$name-$(length(name_run)).json")
    massage = "Complete $name, new: $num_case (already have $(length(name_run)))\n
    min total distance in case$num_case = $(min_obj)\n"
    sent_email("Complete $name, case: $num_case", massage)
end


focus_cases = [5, 8, 10, 11, 13, 14, 15, 16]


function Focus_cases(name)
    A = hcat([name], [length(glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")) for num_case in focus_cases]')
    for name in Full_Name()
        A = vcat(A, hcat([name], [length(glob("$name*.txt", "particle_swarm/total_distance/case$num_case/$name")) for num_case in focus_cases]'))
    end
    t = pretty_table(String, A, append!(["name"], ["$i" for i in focus_cases]), tf=tf_compact)
    return t
end


function create_conclusion_number_particle()
    io = open("particle_swarm/total_distance/run.csv", "w")
    for i in focus_cases
        nothing
    end
end


function date_txt()
    return "$(Dates.format(now(), "mm-dd at HH:MM:SS"))"
end


function move_all_files(case, name)
    items = glob("*.*", "particle_swarm/total_distance/$case/$name/")
    try mkdir("particle_swarm/total_distance/$case/$name/15") catch e;nothing end
    try mkdir("particle_swarm/total_distance/$case/$name/15/1") catch e;nothing end
    items_name = [split(item, "/")[end] for item in items]
    for (item, item_name) in zip(items, items_name)
        mv(item, "particle_swarm/total_distance/$case/$name/15/1/$item_name")
    end
end


function create_csv_seed_case(seed::Int64, num_particle::Int64)
    io = open("particle_swarm/total_distance/conclusion_seed/seed$seed-case.csv", "w")
    
    head = "name"
    for i in 1:16
        head *= ",case$i"
    end
    write(io, "$head\n")
    
    for name in Full_Name()
        tex = "$name"
        for i in 1:16
            location = "particle_swarm/total_distance/case$i/$name/$num_particle/$seed"
            items = glob("$name*.txt", location)
            num_items = length(items)
            if num_items > 0
                tex *= ",$num_items"
            else
                tex *= ","
            end
        end
        write(io, "$tex\n")
    end

    close(io)

end


function create_csv_seed_random(num_particle::Int64)
    io = open("particle_swarm/total_distance/conclusion_seed/all-seed-random-$num_particle.csv", "w")
    
    head = "name"
    for i in 1:16
        head *= ",random$i"
    end
    write(io, "$head\n")
    
    for name in Full_Name()
        tex = "$name"
        for i in 1:16
            num_items = 0
            for s in 1:length(glob("*", "particle_swarm/total_distance/random$i/$name/$num_particle"))
                location = "particle_swarm/total_distance/random$i/$name/$num_particle/$s"
                items = glob("$name*.txt", location)
                num_items += length(items)
            end
            if num_items > 0
                tex *= ",$num_items"
            else
                tex *= ","
            end
        end
        write(io, "$tex\n")
    end

    close(io)

end


function create_csv_seed_new(num_particle::Int64)
    io = open("particle_swarm/total_distance/conclusion_seed/all-seed-new-$num_particle.csv", "w")
    
    head = "name"
    for i in 1:3
        head *= ",new$i"
    end
    write(io, "$head\n")
    
    for name in Full_Name()
        tex = "$name"
        for i in 1:3
            num_items = 0
            for s in 1:length(glob("*", "particle_swarm/total_distance/new$i/$name/$num_particle"))
                location = "particle_swarm/total_distance/new$i/$name/$num_particle/$s"
                items = glob("$name*.txt", location)
                num_items += length(items)
            end
            if num_items > 0
                tex *= ",$num_items"
            else
                tex *= ","
            end
        end
        write(io, "$tex\n")
    end

    close(io)

end


function create_csv_min_all_distance()
    all_cases = ["case$i" for i in 1:16]
    append!(all_cases, ["random$i" for i in 1:16])
    append!(all_cases, ["new1", "new2", "new3"])

    io = open("conslusion_min_all_distance.csv", "w")

    write(io, "Name,Khoo,NV,Min,Alg,Num_par\n")

    for name in Full_Name()
        min_value = 100000
        NV = 100
        alg = nothing
        num_par = nothing

        for case in all_cases
            list_particle = try first(walkdir("particle_swarm/total_distance/$case/$name"))[2] catch e; continue end
            for num_particle in list_particle
                num_seed = first(walkdir("particle_swarm/total_distance/$case/$name/$num_particle"))[2]
                for seed in num_seed
                    num_files = glob("$name*.txt", "particle_swarm/total_distance/$case/$name/$num_particle/$seed")
                    for file in num_files
                        vehicle = read_txt3(file, name)
                        dis = total_distance(vehicle)
                        if dis < min_value
                            min_value = dis
                            NV = vehicle["num_vehicle"]
                            alg = case
                            num_par = num_particle
                        end
                    end
                end
            end
        end
        write(io, "$name,$(Khoo()[name]),$NV,$min_value,$alg,$num_par\n")
    end
    close(io)
end


function create_record_table()
    df = DataFrame(start=[], stop=[], duration=[], name=String[], no=Int[], alg=String[], num_particle=Int[], seed=Int[], num_vehicle=Int[], total_dis=Real[], iter=Int[])
    all_cases = ["case$i" for i in 1:16]
    append!(all_cases, ["random$i" for i in 1:16])
    append!(all_cases, ["new1", "new2", "new3"])

    for name in Full_Name()

        for case in all_cases
            list_particle = try first(walkdir("particle_swarm/total_distance/$case/$name"))[2] catch e; continue end
            for num_particle in list_particle
                num_seed = first(walkdir("particle_swarm/total_distance/$case/$name/$num_particle"))[2]
                for seed in num_seed
                    num_files = glob("$name*.txt", "particle_swarm/total_distance/$case/$name/$num_particle/$seed")
                    l1 = length(num_files)
                    l2 = length(glob("save*.csv", "particle_swarm/total_distance/$case/$name/$num_particle/$seed"))
                    for file in num_files
                        vehicle = read_txt3(file, name)
                        total_dis = total_distance(vehicle)
                        num_vehicle = vehicle["num_vehicle"]
                        if l1 == l2
                            csv_name = split(split(file, "/")[end], ".")[1]
                            no = parse(Int, split(csv_name, "-")[end])
                            if isfile("particle_swarm/total_distance/$case/$name/$num_particle/$seed/save-$csv_name.csv")
                                dd = CSV.File("particle_swarm/total_distance/$case/$name/$num_particle/$seed/save-$csv_name.csv")

                                list_date_start = split(dd[1][1])
                                start_date = parse.(Int, split(list_date_start[2], "-"))
                                start_time = parse.(Int, split(list_date_start[4], ":"))
                                start = DateTime(2021, start_date[1], start_date[2], start_time[1], start_time[2], start_time[3])

                                list_date_end = split(dd[end][1])
                                end_date = parse.(Int, split(list_date_end[2], "-"))
                                end_time = parse.(Int, split(list_date_end[4], ":"))
                                stop = DateTime(2021, end_date[1], end_date[2], end_time[1], end_time[2], end_time[3])
                                iter = parse(Int, split(dd[end][2])[end])
                                push!(df, (start, stop, round(Millisecond(stop-start), Minute).value, name, no, case, parse(Int, num_particle), parse(Int, seed), num_vehicle, total_dis, iter))
                            end
                        else
                            nothing
                            # push!(df, (missing, missing, missing))
                        end
                    end
                end
            end
        end
    end
    CSV.write("report.csv", df)
    return df
end


function add_record(name, case, num_particle, seed, start, stop)
    nothing
end


function fix_save_name()
    all_cases = ["case$i" for i in 1:16]
    append!(all_cases, ["random$i" for i in 1:16])
    append!(all_cases, ["new1", "new2", "new3"])

    for name in Full_Name()

        for case in all_cases
            list_particle = try first(walkdir("particle_swarm/total_distance/$case/$name"))[2] catch e; continue end
            for num_particle in list_particle
                num_seed = first(walkdir("particle_swarm/total_distance/$case/$name/$num_particle"))[2]
                for seed in num_seed
                    num_files_csv = glob("save*.csv", "particle_swarm/total_distance/$case/$name/$num_particle/$seed")
                    num_files_main = glob("$name*.txt", "particle_swarm/total_distance/$case/$name/$num_particle/$seed")
                    if length(num_files_csv) == length(num_files_main)
                        files_num = []
                        for (i, file_csv) in enumerate(num_files_csv)
                            println(i)
                            append!(files_num, parse(Int, (split(file_csv, "/")[end])[end-4]))
                        end
                        for (j, i) in enumerate(files_num)
                            if i != j
                                mv("particle_swarm/total_distance/$case/$name/$num_particle/$seed/save-$name-$j.txt", "particle_swarm/total_distance/$case/$name/$num_particle/$seed/save-$name-$i.txt", force=true)
                                num_files_txt = glob("save*.txt", "particle_swarm/total_distance/$case/$name/$num_particle/$seed")
                            end
                        end
                    end
                end
            end
        end
    end
    CSV.write("report.csv", df)
    return df
end


function check_feasible(dir::String)
    files = readdir(dir)
    for file in files
        name = string(split(file, ".")[1])
        vehicle = read_txt3("$dir/$file", name)
        particle = vehicle_to_particle(vehicle)
        println("file name: $(@sprintf("%5s", name)) => feasibility: $(@sprintf("%5s", check_feasible(particle))) => distance: $(@sprintf("%5.2f", total_distance(particle)))")
    end
end


function look(name::String, alg::String)
    num_par = try first(walkdir("particle_swarm/total_distance/$alg/$name"))[2] catch e; nothing end
    
    if isnothing(num_par) == false
        for num_particle in num_par
            num_seed = try first(walkdir("particle_swarm/total_distance/$alg/$name/$num_particle"))[2] catch e; nothing end
            for seed in num_seed
                files = glob("$name*.txt", "particle_swarm/total_distance/$alg/$name/$num_particle/$seed")
                for file in files
                    vehicle = read_txt3(file, name)
                    println("$file, $(vehicle["num_vehicle"]), $(@sprintf("%.2f", vehicle["TotalDistance"])), Khoo: $(Khoo()[name]), $(@sprintf("%.2f", (-Khoo()[name]+vehicle["TotalDistance"])/Khoo()[name]*100))%")
                end
            end
        end
    end
end

function summerized(vehicle::Dict)
    num_vehicle = vehicle["num_vehicle"]
    num_jobs = [length(vehicle[i]["sch"]) for i in 1:num_vehicle]

    # completion time
    completion_time_all = [vehicle[i]["CompletionTime"][end] for i in 1:num_vehicle]./3600
    
    min_com = minimum(completion_time_all)
    println("min_com: $min_com")
    max_com = maximum(completion_time_all)
    println("max_com: $max_com") 
    avg_com = mean(completion_time_all)
    println("avg_com: $avg_com")
    # distance
    distance_all = [vehicle[i]["Distance"] for i in 1:num_vehicle]
    
    min_dis = minimum(distance_all)
    println("min_dis: $min_dis")
    max_dis = maximum(distance_all)
    println("max_dis: $max_dis")
    avg_dis = mean(distance_all)
    println("avg_dis: $avg_dis")


    # number of jobs
    println("number of vehicle: $num_vehicle")
    min_jobs = minimum(num_jobs)
    println("min_jobs: $min_jobs")
    max_jobs = maximum(num_jobs)
    println("max_jobs: $max_jobs")
    avg_jobs = mean(num_jobs)
    println("avg_jobs: $avg_jobs")
end


function vehicel_to_lat_long(vehicle::Dict)
    csv_data = CSV.File("/Users/payakornsaksuriya/OneDrive - Chiang Mai University/Ph.D/Project scheduling/อบรม QGIS-20210418T133322Z-001/project/latlong.csv")
    lat0 = 18.79092404
    long0 = 98.97405151

    for i in 1:vehicle["num_vehicle"]
        io = open("case_study_lat_long_csv/route$i.csv", "w")
        write(io, "j,lat,long\n")
        write(io, "0,$lat0,$long0\n")
        for (k, j) in enumerate(vehicle[i]["sch"])
            write(io, "$k,$(csv_data[j][2]),$(csv_data[j][3])\n")
        end
        close(io)
    end
end


function load_distance_data(name, case1; num_particle=15, seed=1)
    location1 = "particle_swarm/total_distance/case$case1/$name/$num_particle/$seed"
    return [read_txt3("$location1/$name-$i.txt", name)["TotalDistance"] for i in 1:length(glob("$name-*.txt", location1))]
end


function write_json(data::Dict, out_name::String)
    json_string = JSON.json(data)
    open(out_name,"w") do f
        JSON.print(f, json_string)
      end
end


function create_json_conclusion(out_name::String; num_particle=15, seed=1)
    data = Dict()
    for case in 1:16
        data["$case"] = Dict()
        for name in Full_Name()
            data["$case"][name] = load_distance_data(name, case, num_particle=num_particle, seed=seed)
        end
    end
    write_json(data, out_name)
end


function run_case_to_name(name::String, case::Int64, num_particle::Int64, seed::Int64, to_num::Int64)
    location = "particle_swarm/total_distance/case$case/$name/$num_particle/$seed"
    total_num = length(glob("$name*.txt", location))
    if to_num > total_num
        run_case(case, [name], num_particle=num_particle, while_iter=to_num-total_num, seed=seed)
    end
end


function run_case_to(name_class::String, case::Int64, num_particle::Int64, seed::Int64, to_num::Int64)
    names = Full_Name(name_class)
    for name in names
        run_case_to_name(name, case, num_particle, seed, to_num)
    end
end
