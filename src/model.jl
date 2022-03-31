# using JuMP, GLPK, DelimitedFiles
# include("model2.jl")
# try 
#     using JuMP, Gurobi
#     global Solver_name = "Gurobi"
# catch e;
#     using JuMP, CPLEX 
#     global Solver_name = "CPLEX"
# end
# using JuMP, Gurobi
# load data
# file_name = "r101"

function find_opt(file_name, n, num_vehicle; Solver_name=Solver_name)
    # cd("DrProject\\src\\")
    p, d, low_d, demand, solomon_demand, distance_matrix, service = load_data_solomon(file_name)
    # m = Model(with_optimizer(Cbc.Optimizer, logLevel=1))
    # m = try Model(Gurobi.Optimizer) catch e Model(CPLEX.Optimizer) end
    m = Model(Solver_name.Optimizer)
    try set_optimizer_attribute(m, "TimeLimit", 3600) catch e set_optimizer_attribute(m, "CPX_PARAM_TILIM", 3600) end
    # set_optimizer_attribute(m, "Presolve", 0)
    # n = length(d)
    # n = 100
    # num_vehicle = 20
    K = 1:num_vehicle
    M = n*1000

    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # service time
    # service = append!([0], service)
    # low_d = append!([0], low_d)
    # d = append!([M], d)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i!=j], Bin)
    @variable(m, low_d[i] <= t[i=1:n] <= d[i])



    for k in K
        @constraint(m, sum(x[0, j, k] for j in 1:n) == 1)
        @constraint(m, sum(x[i, 0, k] for i in 1:n) == 1)
    end

    for i = 1:n
        @constraint(m, sum(x[j, i, k] for j in 0:n for k in K if i != j) == 1)
        @constraint(m, sum(x[i, j, k] for j in 0:n for k in K if i != j) == 1)
    end

    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 0:n if i != j) - sum(x[j, l, k] for l in 0:n if j != l) == 0)
        end
    end

    # time windows
    for k in K
        # fix(t[0,k], 0, force=true)
        for j in 1:n
            @constraint(m, distance_matrix[1, j+1] <= t[j]+ M*(1-x[0, j, k]))
        end
    end

    for i in 1:n
        for j in 1:n
            if i != j
                for k in K
                    @constraint(m, t[i] + service[i] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) <= t[j] )
                end
            end
        end
    end

    # subtour elimination constraints
    @variable(m, demand[i] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i!=j
                    @constraint(m, u[i] - u[j] + demand[j] <= solomon_demand*(1 - x[i, j, k]))
                end
            end
        end
    end

    @objective(m, Min, sum(distance_matrix[i+1, j+1]*x[i, j, k] for i in 0:n for j in 0:n for k in K if i != j))

    optimize!(m)

    if has_values(m)
        text_route = show_opt_solution(x, n, num_vehicle, file_name)

        tx = "($(solution_summary(m))\n\n*---------*\n$(text_route)"
        sent_email("Optimal for $file_name-$n-$num_vehicle", "$(tx)")
        return text_route, JuMP.objective_value(m), solve_time(m), relative_gap(m), Solver_name, m
    else
        text_route = "No Solution"
        sent_email("No Solution -- Solver: $(Solver_name) $file_name-$n-$num_vehicle", "$(text_route)")
        return text_route, nothing, nothing, nothing, Solver_name, m
    end

    # cd("C:\\Users\\payakorn_sak\\OneDrive - Chiang Mai University\\Ph.D\\ProjectWatsan")

end
# objective_value(m)

# all_variables(m)

# termination_status(m)

# value(x[1, 2])

# value.(U)

# value.(C)

# t = value.(C)
# t = [round(x) for x in t]

# findall(x -> x == 2.0, t)
# job = zeros(n)

# first_job_vector = [value.(x[0, j]) for j in 1:n]
# job[1] = findall(a -> a == 1.0, first_job_vector)[1]
# last_job_vector = [value.(z[j]) for j in 1:n]
# job[n] = findall(a -> a == 1.0, last_job_vector)[1]
# for i in 2:n-1
#     job[i] = findfirst(a -> a == 1.0, [value.(x[i, j]) for j in 1:n, i!=j])[1]
# end

# findall(x -> x == 1.0, [value.(x[0, j]) for j=1:n])

# for i=1:n
#     println(value.(x[0, i]))
# end

# using JLD2, FileIO
# save = false
# version = 1
# while save != true
#     name = "job-$n-$version.jld2"
#     if isfile(name)
#         version += 1
#     else
#         print(name)
#         @save name D d
#         save = true
#     end
# end

