# using JuMP, GLPK, DelimitedFiles
# include("model2.jl")
# try 
#     using JuMP, Gurobi
#     global Solver_name = "Gurobi"
# catch e;
#     using JuMP, CPLEX 
#     global Solver_name = "CPLEX"
# end

function find_opt(file_name, num_vehicle; Solver_name=Solver_name)

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
    try set_optimizer_attribute(m, "TimeLimit", 3600) catch e set_optimizer_attribute(m, "CPX_PARAM_TILIM", 3600) end
    # set_optimizer_attribute(m, "Presolve", 0)
    # n = length(d)
    # n = 100
    # num_vehicle = 20
    K = 1:num_vehicle
    M = n*1000

    # test round distance (some papers truncate digits)
    distance_matrix = floor.(distance_matrix, digits=1)

    # add variables
    @variable(m, x[i=0:n, j=0:n, k=K; i!=j], Bin)
    @variable(m, low_d[i+1] <= t[i=0:n] <= d[i+1])



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

    if has_values(m)
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


# function vrptw_syn_pre(num_node, num_vehi, num_serv, a, r, d, mind, maxd, e, l, PRE, SYN)
#     # load parameters
#     # num_node = 11
#     # num_vehi = 3
#     # num_serv = 6
#     M = num_node*1000

#     # create set of indices
#     N = 1:(num_node)
#     N_c = 2:(num_node)
#     K = 1:num_vehi
#     S = 1:num_serv

#     # generate set of i, j in N with i != j
#     IJ = Iterators.filter(x -> x[1] != x[2], Iterators.product(N, N))
#     SS = Iterators.filter(x -> x[1] != x[2], Iterators.product(S, S))
#     KK = Iterators.filter(x -> x[1] != x[2], Iterators.product(K, K))

#     mind=[ 14,24,36,38,46,10,27,16,0,51,8,36];
#     maxd=[ 28,48,72,76,92,20,54,32,0,102,16,72]; 
#     e=[0,   345,268,247,393,254,184,434,46,298,148,0]; 
#     l=[600, 465,388,367,513,374,304,554,166,418,268,1000]; 

#     r=[
#         1 1 1 1 1 1;
#         0 0 0 1 0 0;
#         0 0 0 0 1 0;
#         0 1 0 0 0 0;
#         0 0 0 1 0 0;
#         0 0 1 0 0 0;
#         0 0 0 0 1 0;
#         0 0 1 0 0 0;
#         0 0 0 0 1 1;
#         1 0 0 1 0 0;
#         0 0 1 0 0 1;
#         1 1 1 1 1 1;
#     ];

#     r_syn = deepcopy(r)
#     Q = []
#     SYN = []
#     SYN_num = ones(num_node, num_serv)
#     for i in N_c
#         position = findall(x -> x == 1.0, r[i, :])
#         if mind[i] == 0 && maxd[i] == 0
#             push!(Q, (i, length(position)-1))
#             push!(SYN, (i, position[1]))
#             r_syn[i, position[1]] = 2.0
#             r_syn[i, position[2]] = 0.0
#             r[i, position[2]] = 0.0
#             SYN_num[i, position[1]] = 2.0
#             # delete syn points from SS
#             # delete!(SS, (position[1], position[2]))
#             # delete!(SS, (position[2], position[1]))
#         else
#             push!(Q, (i, length(position)))
#         end
#     end

#     const a = [ 1 1 1 0 0 0;
#                 0 0 0 0 1 1; #0 0 0 0 1 1;
#                 0 0 0 1 1 1;
#     ];
#     # const a = [ 1 1 1 1 1 1;
#     #             1 1 1 1 1 1; #0 0 0 0 1 1;
#     #             1 1 1 1 1 1;
#     # ];

#     DS = (11,10,9);

#     d = [
#         0.0 38.470768 34.88553 55.946404 7.28011 23.345236 71.470276 32.526913 13.038404 26.400757 88.88757 0.0;
#         38.470768 0.0 23.086792 21.400934 32.01562 31.827662 34.0 32.649654 45.276924 57.45433 56.859474 38.470768;
#         34.88553 23.086792 0.0 43.829212 27.784887 15.033297 53.037724 10.630146 46.615448 42.755116 54.91812 34.88553;
#         55.946404 21.400934 43.829212 0.0 50.606323 53.15073 17.029387 53.851646 59.22837 77.801025 59.64059 55.946404;
#         7.28011 32.01562 27.784887 50.606323 0.0 17.492855 65.551506 26.400757 19.104973 28.42534 81.608826 7.28011;
#         23.345236 31.827662 15.033297 53.15073 17.492855 0.0 65.0 9.219544 36.23534 27.89265 69.58448 23.345236;
#         71.470276 34.0 53.037724 17.029387 65.551506 65.0 0.0 63.63961 75.802376 91.416626 50.92151 71.470276;
#         32.526913 32.649654 10.630146 53.851646 26.400757 9.219544 63.63961 0.0 45.343136 34.0147 62.072536 32.526913;
#         13.038404 45.276924 46.615448 59.22837 19.104973 36.23534 75.802376 45.343136 0.0 35.22783 99.16148 13.038404;
#         26.400757 57.45433 42.755116 77.801025 28.42534 27.89265 91.416626 34.0147 35.22783 0.0 96.02083 26.400757;
#         88.88757 56.859474 54.91812 59.64059 81.608826 69.58448 50.92151 62.072536 99.16148 96.02083 0.0 88.88757;
#         0.0 38.470768 34.88553 55.946404 7.28011 23.345236 71.470276 32.526913 13.038404 26.400757 88.88757 0.;
#     ]; 

#     # processing time
#     p = zeros(Float64, num_vehi, num_serv)
#     for i in 2:num_node
#         global p
#         p = cat(p, 14.0*ones(Float64, num_vehi, num_serv), dims=3)
#     end
#     # p = cat(p, zeros(Float64, num_vehi, num_serv), dims=3)

#     # create PRE set
#     PRE = []
#     for i in N_c
#         xx = findall(x -> x == 1, r[i, :])
#         if length(xx) > 1
#             for j in 2:length(xx)
#                 push!(PRE, (i, xx[j-1], xx[j], mind[i], maxd[i]))
#             end
#         end
#     end

#     # precedence set 
#     # PRE = [ (2, 4, 3)
#     # (3, 2, 5)
#     # # (6, 1, 2)
#     # # (6, 2, 3)
#     # (6, 3, 5)
#     # (6, 5, 4)
#     # (9, 5, 6)
#     # (10, 1, 4)
#     # (11, 6, 3)]

#     # model
#     model = Model(Gurobi.Optimizer)
#     # set_optimizer_attribute(model, "Presolve", 0)

#     # variables
#     @variable(model, x[i=N, j=N, k=K; i!=j], Bin)
#     @variable(model, e[i]<=t[i=N, k=K]<=l[i])
#     @variable(model, ts[i=N, k=K, s=S] >= 0)
#     @variable(model, y[i=N_c, k=K, s=S], Bin)
#     # @variable(model, z[j=N_c, s1=S, s2=S]<=r[j, s2], Bin) # s1 is position of job, s2 is service
#     @variable(model, z[j=N_c, s1=S, s2=S], Bin) # s1 is position of job, s2 is service
#     @variable(model, zz[i=N, s=S] >= 0)
#     @variable(model, Tmax >= 0)
#     # constraints

#     # 1
#     for (i, j) in IJ
#         if j > 1
#             for k in K
#                 @constraint(model, x[i, j, k] <= sum(y[j, k, s] for s in S))
#             end
#         end
#     end

#     for k in K
#         for j in N_c
#             @constraint(model, sum(y[j, k, s] for s in S) <= M*sum(x[i, j, k] for i in N if i != j))
#         end
#     end

#     # 2, 3
#     for k in K
#         @constraint(model, sum(x[1, j, k] for j in N if 1 != j) == 1)
#         @constraint(model, sum(x[i, 1, k] for i in N if 1 != i) == 1)
#     end

#     # 4
#     for k in K
#         for j in N_c
#             @constraint(model, sum(x[i, j, k] for i in N if i != j) - sum(x[j, l, k] for l in N if j != l) == 0.0)
#         end
#     end

#     # subtour
#     # @variable(model, 1 <= u[i=N_c, k=K] <= num_node-1)
#     # for (i, j) in IJ
#     #     if i > 1 && j > 1
#     #         for k in K
#     #             @constraint(model, u[i, k] - u[j, k] + 1 <= M*(1 - x[i, j, k]))
#     #         end
#     #     end
#     # end

#     # 5
#     for s in S
#         for j in N_c
#             if r_syn[j, s] != 0.0
#                 @constraint(model, sum(a[k, s]*y[j, k, s] for k in K) == r_syn[j, s])
#             else
#                 @constraint(model, sum(y[j, k, s] for k in K) == 0)
#             end

#             # @constraint(model, sum(y[j, k, s] for k in K) == r[j, s])
#         end
#     end

#     6
#     for k in K
#         # fix(t[0,k], 0, force=true)
#         for j in N_c
#             @constraint(model, d[1, j] <= t[j, k]+ M*(1-x[1, j, k]))
#         end
#     end

#     for (i, j) in IJ
#         if i > 1
#             for k in K
#                 # @constraint(model, t[i, k] + sum(p[k, s, i]*y[i, k, s] for s in S) + d[i, j] - M*(1-x[i, j, k]) <= t[j, k])
#                 for s in S
#                     @constraint(model, ts[i, k, s] + p[k, s, i] + d[i, j] - M*(1-x[i, j, k]) <= t[j, k])
#                 end
#             end
#         end
#     end

#     # for j in N
#     #     for k in K
#     #         @constraint(model, e[j]*sum(x[i, j, k] for i in N if i != j) <= t[j, k])
#     #         @constraint(model, l[j]*sum(x[i, j, k] for i in N if i != j) >= t[j, k])
#     #     end
#     # end

#     for j in N_c
#         # test
#         for k in K
#             for s in S
#                 @constraint(model, e[j]*y[j, k, s] <= ts[j, k, s])
#                 @constraint(model, (l[j] + zz[j, s])*y[j, k, s] >= ts[j, k, s])
#             end
#         end
#     end

#     # Tmax
#     for i in N
#         for s in S
#             @constraint(model, Tmax >= zz[i, s])
#         end
#     end

#     # 7
#     for (i, s1, s2, min_d, max_d) in PRE
#         # @constraint(model, sum(ts[i, k, s1] for k in K) + sum(p[k, s1, i]*y[i, k, s1] for k in K) <= sum(ts[i, k, s2] for k in K) + M*(2-sum(y[i, k, s1] for k in K)-sum(y[i, k, s2] for k in K)))
#         @constraint(model, sum(ts[i, k, s1] for k in K) + min_d <= sum(ts[i, k, s2] for k in K) + M*(2-sum(y[i, k, s1] for k in K)-sum(y[i, k, s2] for k in K)))
#         @constraint(model, sum(ts[i, k, s2] for k in K) - max_d <= sum(ts[i, k, s1] for k in K) + M*(2-sum(y[i, k, s1] for k in K)-sum(y[i, k, s2] for k in K)))
#     end

#     for i in N_c
#         for k in K
#             for s in S
#                 @constraint(model, t[i, k] <= ts[i, k, s] + M*(1-y[i, k, s]))
#             end
#         end
#     end

#     # Synchronization
#     # SYN = [(11, 3, 1, 2)]
#     # for (i, s) in SYN
#     #     @constraint(model, sum(ts[i, k1, s]) == sum(ts[i, k2, s]))
#     # end
#     # @constraint(model, ts[11, 1, 3] == ts[11, 2, 3])

#     for (i, s) in SYN
#         for (k1, k2) in KK
#             @constraint(model, -M*(2-y[i, k1, s]-y[i, k2, s]) <= ts[i, k1, s] - ts[i, k2, s])
#             @constraint(model, ts[i, k1, s] - ts[i, k2, s] <= M*(2-y[i, k1, s]-y[i, k2, s]))
#         end
#     end
#     # new constraints z positions ()

#     for j in N_c
#         position = findall(x -> x != 1.0, r[j, :])
#         for i in 1:num_serv-length(position)
#             for l in position
#                 fix(z[j, i, l], 0, force=true)
#             end
#         end
        
#         for i in num_serv-length(position)+1:num_serv
#             for l in S
#                 fix(z[j, i, l], 0, force=true)
#             end
#         end
        
#     end

#     for (j, num_q) in Q
#         for i in 1:num_q
#             @constraint(model, sum(z[j, i, s2] for s2 in S) == 1)
#         end
#         for s in S
#             # @constraint(model, sum(z[j, i, s] for i in 1:num_q) == sum(y[j, k, s] for k in K))
#             @constraint(model, sum(z[j, i, s] for i in 1:num_q) == r[j, s])
#         end
#     end

#     for (s1, s2) in SS
#         for s in setdiff(S, 1)
#             for j in N_c
#                 # @constraint(model, sum(ts[j, k, s1] for k in K) + p[2, s1, j] - M*(2 - z[j, s-1, s1] - z[j, s, s2]) <= sum(ts[j, k, s2] for k in K))
#                 @constraint(model, sum(ts[j, k, s1] for k in K)/SYN_num[j, s1] + p[2, s1, j] - M*(2 - z[j, s-1, s1] - z[j, s, s2]) <= sum(ts[j, k, s2] for k in K)/SYN_num[j, s2])
#             end
#         end
#     end

#     # objective function
#     @objective(model, Min, 1/3*sum(d[i, j]*x[i, j, k] for i in N for j in N for k in K if i != j) + 1/3*Tmax + 1/3*sum(zz[i, s] for i in N for s in S))


#     # optimize
#     optimize!(model)

# end