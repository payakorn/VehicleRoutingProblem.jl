"""
    generate_one_initial(name, num; seed=1, max_vehicle=25, objective_function=total_distance)
"""
function generate_one_initial_particle(name, num; max_vehicle=25, objective_function=total_distance, Q=Q)
    all_name = glob("$name*.txt", location_particle_swarm_initial(name))
    a = length(all_name)
    for i in (a+1):(a+num)
        io = open("$(location_particle_swarm_initial(name, objective_function=objective_function))/$name-$i.txt", "w")
        particle = generate_particles(name, max_vehicle=max_vehicle, Q=Q)
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


"""
    generate_initial_particles(name, set; num_particle=15, seed=1, max_vehicle=25, objective_function=total_distance)

name = name of instance

set = the number of set (devide the initial particle into multiple sets)
"""
function generate_initial_particles(name, set; num_particle=15, max_vehicle=25, objective_function=total_distance, Q=Q)
    # defind the directory
    location = joinpath(@__DIR__, "..", "data", "simulations", "particle_swarm", "$objective_function", "name", "initial")
    location = location_particle_swarm_initial(name, objective_function=objective_function)
    if !(isfile(location))
        mkpath(location)
    end

    all_name = glob("$name*.txt", location)
    a = length(all_name)
    if set == 0
        start_number = 1
        last_number = num_particle
    else
        start_number = (num_particle+1) + (num_particle-1)*(set-1)
        last_number = num_particle +      (num_particle-1)*set
    end

    if a < last_number
        generate_one_initial_particle(name, last_number-a, max_vehicle=max_vehicle, objective_function=objective_function, Q=Q)
    end

    println("start: $start_number")
    println("end: $last_number")
    return start_number, last_number
end


"""
    generate_one_particle(name::String; max_vehicle=25, best_route=[])
"""
function generate_particles(name::String; max_vehicle=25, best_route=[], Q=Q)
    p, d, low_d, demand, max_capacity, distance_matrix, service = read_data_solomon(name)
    return generate_particle(p, d, low_d, demand, max_capacity, distance_matrix, service, max_vehicle, name, best_route=best_route, Q=Q)
end


function load_particle_from_file(file_location::String, instance_name::String; Q=Q::Matrix)
    p, d, low_d, demand, max_capacity, distance_matrix, service = read_data_solomon(instance_name)
    route = read_route(file_location) 
    max_vehicle = total_route(route) 
    route = route[2:end-1] # in particle swarm there is no zero at index 1 and last index
    return Particle(route, p, low_d[2:end], d[2:end], demand[2:end], max_capacity, distance_matrix, service[2:end], max_vehicle, instance_name, Q)
end


function swap2(particle::Particle, objective_function::Function; best_route=[]::Array)
    
    # remove best route from particle
    # particle = remove_best_route(particle, best_route)

    # define list
    list = two_opt_list2(length(particle.route))
    # list = shuffle(sort_processing_matrix(particle.p, best_route=best_route))
    first_obj = objective_function(particle)

    for (iter, (position1, position2)) in enumerate(list)
        swap_particle = deepcopy(particle)
        
        swap_particle.route[position1], swap_particle.route[position2] = swap_particle.route[position2], swap_particle.route[position1]
        if objective_function(swap_particle) < objective_function(particle) && check_feasible(swap_particle)
            particle = deepcopy(swap_particle)
        end
    end

    # last_objective = objective_function(particle)

    # add the removed route to particle
    # if isnothing(best_route) == false
    #     append!(particle.route, 0)
    #     append!(particle.route, best_route)
    # end
    
    return particle
end


function move2(particle::Particle, objective_function::Function)
    # list = shuffle(sort_processing_matrix(particle.p, best_route=best_route))
    list = two_opt_list2(length(particle.route))
    original_obj = objective_function(particle)
    for (iter, (position1, position2)) in enumerate(list)
        swap_particle = deepcopy(particle)
        first_obj = objective_function(swap_particle)
        
        # position1 = findfirst(x -> x == i, swap_particle.route)
        # position2 = findfirst(x -> x == j, swap_particle.route)
        
        # # move
        if position1 < position2
            job = try splice!(swap_particle.route, position2) catch e; continue end
            insert!(swap_particle.route, position1, job)
        else
            # job = splice!(swap_particle.route, position2)
            job = try splice!(swap_particle.route, position2) catch e; continue end
            insert!(swap_particle.route, position1-1, job)
        end

        
        if objective_function(swap_particle) < objective_function(particle) && check_feasible(swap_particle)

            swap_particle.route = fix_missing_vehicle(swap_particle.route)

            # set to best vehicle
            particle = deepcopy(swap_particle)
        end
    end
    # last_objective = objective_function(particle)

    # # second round
    # original_obj = objective_function(particle)
    # for (iter, (position2, position1)) in enumerate(list)
    #     swap_particle = deepcopy(particle)
    #     first_obj = objective_function(swap_particle)
        
    #     # position1 = findfirst(x -> x == i, swap_particle.route)
    #     # position2 = findfirst(x -> x == j, swap_particle.route)
        
    #     # # move
    #     if position1 < position2
    #         job = splice!(swap_particle.route, position2)
    #         insert!(swap_particle.route, position1, job)
    #     else
    #         job = splice!(swap_particle.route, position2)
    #         insert!(swap_particle.route, position1-1, job)
    #     end
        
    #     if objective_function(swap_particle) < objective_function(particle) && check_feasible(swap_particle)

    #         swap_particle.route = fix_missing_vehicle(swap_particle.route)

    #         # set to best vehicle
    #         particle = deepcopy(swap_particle)
    #     end
    # end
    # last_objective = objective_function(particle)
    return  particle
end


function two_opt_list2(length_of_route::Int64)
    return shuffle!(collect(combinations(1:length_of_route, 2)))
end


function two_opt2(particle::Particle, objective_function::Function)
    test_particle = deepcopy(particle)
    original_obj = objective_function(particle)
    List = two_opt_list2(length(particle.route))
    # test_particle = remove_best_route(test_particle, best_route)
    # length_route = length(test_particle.route)
    # List = two_opt_list2(length_route)
    # @show test_particle.route
    # @show List
    for list in List
        new_test_particle = deepcopy(test_particle)
        left_sch = new_test_particle.route[1:list[1]]
        right_sch = new_test_particle.route[list[2]:end]
        middle_sch = new_test_particle.route[list[1]+1:list[2]-1]
        new_test_particle.route = vcat(right_sch, middle_sch, left_sch)
        if (check_feasible(new_test_particle) == true) && (objective_function(new_test_particle) < objective_function(test_particle))
            # println("2-opt $(@sprintf("%.2f", original_obj)) => $(@sprintf("%.2f", objective_function(new_test_particle))) check: $(check_particle(new_test_particle, 100))")
            return new_test_particle
        end
    end
    return particle
end


function local_search2(particle::Particle, objective_function::Function; best_route=[])
    # list = two_opt_list2(length(particle.route))
    particle = two_opt2(particle, objective_function)
    particle.route = fix_missing_vehicle(particle.route)
    particle = swap2(particle, objective_function)
    particle.route = fix_missing_vehicle(particle.route)
    particle = move2(particle, objective_function)
    return particle
end

"""
    run particle swarm function
"""
function particle_swarm_fix2(name::String, objective_function::Function; num_particle=15, max_iter=100, localsearch=false, cut_car=false, generate=false, num_save=nothing, random_set=false, seed=1, Q=Q)
    particles = Dict()
    best_obj_vec = []
    # if name[1] == 'r'
    #     max_vehicle = 25
    # else
    #     max_vehicle = 15
    # end
    num_v = size(Q, 1)
    max_v = size(Q, 2)
    # max_vehicle = size(Q, 2)
    max_vehicle = size(Q, 2)
    
    # add new row for Q
    # QQ = [Q;ones(size(Q, 2) - max_v, size(Q, 2))] 
    QQ = ones(max_v, max_v)
    QQ[1:num_v, :] = Q
    Q = deepcopy(QQ)
    println("size Q: $(size(Q))")


    
    location = location_particle_swarm(name, objective_function=objective_function)

    if localsearch
        local_search_function = local_search2
    else
        local_search_function = local_search_old
    end
        

    # save obejctive value
    objective_value = Dict()
    objective_value[1] = Dict()

    # initial
    start_num, end_num = generate_initial_particles(name, 0, num_particle=num_particle, max_vehicle=max_vehicle, objective_function=objective_function, Q=Q)
    for i in 1:num_particle
        # particles[i] = generate_particle(name, max_vehicle=max_vehicle)
        particles[i] = load_particle_from_file("$(location_particle_swarm_initial(name))/$name-$i.txt", name, Q=Q)
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
    # khoo = Khoo()[name]

    # store best index
    best_index_save = []
    best_obj_save = []
    append!(best_index_save, best_index)
    append!(best_obj_save, best_objective_value)

    # generate list
    # list = shuffle(sort_processing_matrix(particles[1].p))

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
                # particles[i].route = fix_missing_vehicle(particles[i].route)
                # println("route: $(particles[i].route)")
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
        
        # # generate new particles
        # if random == 5 && generate
        #     random_count += 1
        #     random = 1
        #     iter += 1

        #     start_num, end_num = generate_initial_particles(name, random_count, num_particle=num_particle, max_vehicle=max_vehicle, objective_function=objective_function, Q=Q)

        #     # objective value
        #     objective_value[iter] = Dict()

        #     sort_obj = sortperm(best_obj_vec, rev=true)
        #     if random_set
        #         for (j, random_num) in zip(sort_obj[1:end-1], start_num:end_num)
        #             particles[j] = load_particle_from_file("$(location_particle_swarm_initial(name, objective_function=objective_function))/$name-$j.txt", name, Q=Q)
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

        if out == 50
            terminate = true
        end
    
        # if remove == 5 && cut_car
        #     remove = 1
        #     iter += 1
        #     # best_obj_vec = []

        #     # objective value
        #     objective_value[iter] = Dict()

        #     for i in 1:num_particle
        #         if i != best_index
        #             random_number = rand(1:(length(findall(x -> x == 0, particles[i].route))+1))
        #             obj_before = best_obj_vec[i]
        #             particles[i] = remove_vehicle_and_apply_heuristic(particles[i], random_number)
        #             best_obj_vec[i] =  objective_function(particles[i])
        #             println("particle $i random vehicle: $random_number, $obj_before => $(best_obj_vec[i])")
        #         else
        #             best_obj_vec[i] = objective_function(particles[i])
        #         end
                    
        #         # collect objective value
        #         objective_value[iter][i] = Dict()
        #         objective_value[iter][i]["obj"] = best_obj_vec[end]
        #         objective_value[iter][i]["method"] = "remove"
        #     end

        #     # find new best solution
        #     best_index = argmin(best_obj_vec)
        #     append!(best_index_save, best_index)
        #     best_objective_value = best_obj_vec[best_index]
        #     append!(best_obj_save, best_objective_value)
        #     mean_obj = mean(best_obj_vec)
        # end

        # save
        im = open("$location/save-$(name)-$(num_save).csv", "a")
        write(im, "Date: $(Dates.format(now(), "mm-dd at HH:MM:SS")), particle: $num_particle, iter: $iter, fix: false, local: $(localsearch), cut car: $cut_car, new generate: $generate, best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))\n")
        close(im)

        println("\n$name iter: $iter, feasible: $(check_feasible(particles[best_index])), best objective value: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))) mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        # println("\n$name, #particle: $num_particle, iter: $iter, fix: true, local: $(localsearch), cut car: $cut_car, new generate: $generate, Khoo: $(khoo), best obj: $(@sprintf("%.2f", best_objective_value))($(find_number_of_vehicle(particles[best_index]))), mean: $(@sprintf("%.2f", mean_obj)), max: $(@sprintf("%.2f", maximum(best_obj_vec)))")
        # println("Dates: $(Dates.format(now(), "mm-dd at HH:MM:SS"))")

        # write save best particle
        # ig = open("$location/save-$(name)-$(num_save).txt", "w")
        # vehicle = find_vehicle(particles[best_index])
        # for i in 1:length(vehicle)
        #     for j in vehicle[i]
        #         write(ig, "$j ")
        #     end
        #     write(ig, "\n")
        # end
        # close(ig)
        end
        iter += 1
    end

    return particles[best_index], objective_value
end



function run_particle2(name::String, objective_function::Function; max_iter=200, max_iter_while=1, localsearch=false, cut_car=false, generate=false, num_particle=15, random_set=false, seed=1, Q=Q)
    iter = 1
    location = location_particle_swarm(name, objective_function=objective_function)
    while iter <= max_iter_while
        # length files
        num_files = length(glob("$name*.txt", "$location")) + 1
        
        best_particle, objective_value = particle_swarm_fix2(name, objective_function, max_iter=max_iter, num_particle=num_particle, localsearch=localsearch, cut_car=cut_car, generate=generate, num_save=num_files, random_set=random_set, seed=seed, Q=Q)
        # new_obj = objective_function(best_particle)
        
        # # write best particle
        write_solution_to_txt(best_particle, "$(location_particle_swarm(name))/$name-$num_files.txt")

        # # export to json
        open("$location/$(name)-$(num_files).json", "w") do f
            JSON.print(f, objective_value)
        end

        iter += 1
    end
end

function run_case2(name_case::Array; num_particle=15, while_iter=1, seed=1, objective_function=total_distance::Function, Q=nothing)
    for name in name_case
        # location
        # # create subfolders
        # try mkdir("particle_swarm/$objective_function/case$i") catch e; nothing end
        # try mkdir("particle_swarm/$objective_function/case$i/$name") catch e; nothing end
        # try mkdir("particle_swarm/$objective_function/case$i/$name/$num_particle") catch e; nothing end
        # try mkdir(location) catch e; nothing end
        location = location_particle_swarm(name, objective_function=objective_function)
        num_run = while_iter - length((glob("$(name)*.txt", location)))
        
        # run 
        if num_run > 0
            run_particle2(name, objective_function; max_iter=200, max_iter_while=num_run, localsearch=true, cut_car=true, generate=true, num_particle=15, random_set=true, seed=1, Q=Q)

            # record 
            io = open("$(location)/run.txt", "a")
            a = length(glob("$name*.txt", location))
            write(io, "$(date_txt()), name: $name-$a, Alg: 16, particle: $num_particle, \n")
            close(io)
    
            # sent email
            sent_email("finished $name", obj_email_text(name))
        end
    end
end


function obj_email_text(name::String)
    t = ""
    t *= "-----------------\n"
    location = location_particle_swarm(name)
    file_name = glob("$name-*.txt", location)
    for i in 1:length(file_name)
        t *= "$name-$i => Objective value: $(total_distance(read_solution(file_name[i], name)))\n"
    end
    return t
end


function generate_run_name()
    run_names = []
    for num_customer = [25, 50, 75]
        for name in Full_Name()
            append!(run_names, ["$name-$num_customer"])
        end
    end
    return run_names
end


