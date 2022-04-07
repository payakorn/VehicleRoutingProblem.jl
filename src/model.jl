# using JuMP, GLPK, DelimitedFiles
# include("model2.jl")
# try 
#     using JuMP, Gurobi
#     global Solver_name = "Gurobi"
# catch e;
#     using JuMP, CPLEX 
#     global Solver_name = "CPLEX"
# end
using Random, JuMP, CPLEX, SMTPClient, Printf

num_vehicle = 5
num_node = 25

for k in 1:num_node
    num_compat = rand(4:num_vehicle)
    if k > 1
        pp = hcat(pp, vcat(zeros(num_vehicle-num_compat), ones(num_compat))[randcycle(num_vehicle)])
    else
        global pp = vcat(zeros(num_vehicle-num_compat), ones(num_compat))[randcycle(num_vehicle)]
    end
end

Q3 = [
    1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0;
    1.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0  1.0  1.0;
    0.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0;
]

Q5 = [
    1.0  1.0  1.0  1.0  0.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  1.0;
    1.0  1.0  1.0  0.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  0.0  1.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0;
    1.0  0.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0  0.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0  1.0;
    1.0  1.0  1.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  1.0  0.0  0.0  0.0  1.0  1.0;
    0.0  1.0  1.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  1.0  0.0  0.0  0.0  1.0  1.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0  1.0  1.0;
]

Q8 = [
    1.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  1.0  0.0  1.0  1.0  1.0  0.0;
    1.0  1.0  0.0  0.0  0.0  1.0  1.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0  0.0  0.0;
    1.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  0.0  0.0  0.0  1.0  1.0  0.0  1.0  0.0  1.0;
    0.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  1.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0  0.0  0.0;
    1.0  0.0  1.0  0.0  1.0  1.0  1.0  0.0  0.0  1.0  0.0  0.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0  1.0  0.0  1.0  1.0  1.0  0.0;
    1.0  1.0  0.0  1.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  0.0  0.0;
    0.0  1.0  0.0  0.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  1.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  1.0  0.0  1.0  1.0  1.0  0.0;
    1.0  1.0  0.0  0.0  1.0  1.0  1.0  0.0  1.0  0.0  1.0  0.0  1.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  0.0  1.0;
    ]

function find_opt(file_name, num_vehicle; Solver_name=Solver_name, Q=Q)

    data = read_data_solomon_dict(file_name)
    d = data["upper"]
    low_d = data["lower"]
    demand = data["demand"]
    solomon_demand = data["capacity"]
    distance_matrix = data["distance_matrix"]
    service = data["service"]

    # number of node
    n = length(d) - 1

    # m = Model(with_optimizer(Cbc.Optimizer, logLevel=1))
    # m = try Model(Gurobi.Optimizer) catch e Model(CPLEX.Optimizer) end
    m = Model(Solver_name.Optimizer)
    try set_optimizer_attribute(m, "TimeLimit", 1200) catch e set_optimizer_attribute(m, "CPX_PARAM_TILIM", 1200) end
    # set_optimizer_attribute(m, "Presolve", 0)
    # n = length(d)
    # n = 100
    # num_vehicle = 20
    K = 1:num_vehicle
    M = n*1000

    # add compatibility
    # Q = rand(num_vehicle, n) .> 0.5

    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i!=j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])


    # conpatibility constraint
    for j in 1:n
        for k in K
            @constraint(m, sum(x[i, j, k] for i in 1:n if i!=j) <= Q[k, j])
        end
    end


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
        for j in 0:n
            if i != j
                for k in K
                    @constraint(m, t[i] + service[i+1] + distance_matrix[i+1, j+1] - M*(1-x[i, j, k]) <= t[j] )
                end
            end
        end
    end

    # subtour elimination constraints
    @variable(m, demand[i+1] <= u[i=1:n] <= solomon_demand)
    for i in 1:n
        for j in 1:n
            for k in K
                if i!=j
                    @constraint(m, u[i] - u[j] + demand[j+1] <= solomon_demand*(1 - x[i, j, k]))
                end
            end
        end
    end

    @objective(m, Min, sum(distance_matrix[i+1, j+1]*x[i, j, k] for i in 0:n for j in 0:n for k in K if i != j))

    optimize!(m)

    if JuMP.has_values(m)
        text_route = show_opt_solution(x, n, num_vehicle, file_name)

        tx = "($(solution_summary(m))\n\n*---------*\n$(text_route)"
        sent_email("Optimal for $file_name-$n-$num_vehicle", "$(tx)")
        return text_route, JuMP.objective_value(m), solve_time(m), relative_gap(m), Solver_name, m
    else
        text_route = "No Solution"
        sent_email("No Solution -- Solver: $(Solver_name) $file_name-$num_vehicle", "$(text_route)")
        return text_route, nothing, nothing, nothing, Solver_name, m
    end
end

