# include("benchmark.jl")
# using Printf
# include("problemC104.jl")
# input sch and return the number of tardy job and the completion time of the last job
function job_late(sch; p=p, d=d, low_d=[], demand=zeros(length(d)), solomon_demand=1000)

    # println("call job_late with name=$name")
    if isempty(sch)
        return 0, 0, true
    end

    if isempty(low_d) == false
        starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
    else
        completion_time = CompletionTime(sch, p, starting_time=[])
    end
    late = [i > j for (i, j) in zip(completion_time, d[sch])]
    last_completiontime = completion_time[end]

    meet_demand = sum(demand[sch]) <= solomon_demand
    return (late, last_completiontime, meet_demand)
end

# input:  sch, processing time, lower bound of time windows
# return: an array of completion time of each job
# starting_time is an array of starting time og each job
function CompletionTime(sch, p; starting_time=[])

    # parameters
    N = length(sch)

    # variables
    completion_time = []
    # if isempty(sch) == true
    #     return []
    # end

    if isempty(starting_time) == true

        append!(completion_time,  p[sch[1], sch[1]])

        for i in 2:N
            append!(completion_time, completion_time[end] + p[sch[i - 1], sch[i]])
        end
    else
        append!(completion_time, starting_time[1] + p[sch[1], sch[1]])
        for i in 2:N
            append!(completion_time, starting_time[i] + p[sch[i - 1], sch[i]])
        end
    end
    return completion_time
end


# input sch and return the completion time of the last job
function LastCompletionTime(sch, p; starting_time=[])
    return CompletionTime(sch, p, starting_time=starting_time)[end]
end

function StartingAndCompletion(sch, p, low_d)
    N = length(sch)
    if low_d[sch[1]] <= p[sch[1], sch[1]]
        starting_time = [0.0]
    else
        different = low_d[sch[1]] -  p[sch[1], sch[1]]
        # starting_time = [low_d[sch[1]]]
        starting_time = [different]
    end

    completion_time = [starting_time[1] + p[sch[1], sch[1]]]
    
    for i in 2:N
        if completion_time[i - 1] + p[sch[i - 1], sch[i]] >= low_d[sch[i]]
            append!(starting_time, completion_time[i - 1])
            append!(completion_time, starting_time[i] + p[sch[i - 1], sch[i]])
        else
            different = low_d[sch[i]] - (completion_time[i - 1] + p[sch[i - 1], sch[i]])
            append!(starting_time, completion_time[i - 1] + different)
            append!(completion_time, starting_time[i] + p[sch[i - 1], sch[i]])
        end
    end
    return starting_time, completion_time
end

function Check_lower(sch, p, low_d)
# return [0] if satisfy
# compute starting time vector for jobs in sch
    starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
    # check wheather starting time is within the time interval
    return [i > j for (i, j) in zip(low_d[sch], completion_time)]
end


# subsection of heuristic
# input : assigned sch, incomming job
# the input schedulue must satisfies sum(late) = 0
function job_in_out(sch::Any, job_in::Int; p=p, d=d, low_d=[], fix=false, demand=zeros(length(d)), solomon_demand=1000)

    # println("call job in out with $name")
    
    if isempty(sch) == true
        job_sch   = [job_in]
        # completiontime = p[job_in, job_in]
        starting_time, completion_time = StartingAndCompletion(job_sch, p, low_d)
        late, last_completiontime, meet = job_late(job_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        if sum(late) == 1 || sum(Check_lower(job_sch, p, low_d)) == 1 || meet == false
            job_out = job_in
            best_sch = []
        else
            job_out = []
            best_sch = deepcopy(job_sch)
        end
    elseif fix == true
        # this is not complete yet
        best_sch = []
        job_out       = []
        println("fix is true now")
    else
        testlate, testcomp, testmeet = job_late(vcat(sch, job_in), p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        if testmeet == false
            # println("Test meet: false")
            return sch, job_in
        end
    
        if isempty(low_d) == true
            low_d = zeros(length(d))
        end

        # step 1
        # REMARK put job_in in the last position
        job_sch = deepcopy(sch)
        append!(job_sch, job_in)
        (late, last_completiontime, meet) = job_late(job_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)

        if sum(Check_lower(job_sch, p, low_d)) != 0 || meet == false
            # store best sch
            best_sch = deepcopy(sch)
            (late, last_completiontime, meet) = job_late(best_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            best_late = sum(late)
            job_out = [job_in]
            best_completiontime = last_completiontime
        else
            best_late =  sum(late)
            if best_late == 0
                best_sch = deepcopy(job_sch)
                best_completiontime = deepcopy(last_completiontime)
                job_out = []
            else
                # REMARK this is the case that job_in is late when process in the last position
                # REMARK best late more than zero (=1) 
                job_out = [job_in]
                best_sch = setdiff(job_sch, job_out)
                # TODO check why best_schedule is empty 
                # TODO beacause this must be left at lease one elements in job_schedule
                best_completiontime = deepcopy(last_completiontime)
            end
        end

        # step 2
        # put the job_in in between all positions
        # println("step: 2")
        # global best_completiontime
        for i = 1:length(sch)
            job_sch = deepcopy(sch[1:end - i])
            append!(job_sch, job_in)
            append!(job_sch, sch[end - i + 1:end])
            (late, last_completiontime, meet) = job_late(job_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            sum_lower_check = sum(Check_lower(job_sch, p, low_d))
            if sum_lower_check == 0 && meet
                # println("sum lower = 0")
                if best_late == 0
                    if sum(late) == 0 && best_completiontime > last_completiontime
                        best_sch = deepcopy(job_sch)
                        best_completiontime = deepcopy(last_completiontime)
                    end
                else
                    if sum(late) == 0
                        best_sch = deepcopy(job_sch)
                        best_completiontime = deepcopy(last_completiontime)
                        # best_late = 0
                        job_out = []
                    elseif sum(late) == 1
                        job_out_test = job_sch[late]
                        job_sch = setdiff(job_sch, job_out_test)

                        # this fix job_sch empty when run multiple_heuristic(), Check_lower will error
                        if isempty(job_sch) == true
                            continue
                        end

                        sum_lower_check = sum(Check_lower(job_sch, p, low_d))
                        if sum_lower_check == 0
                            late, last_completiontime = job_late(job_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                            if best_completiontime > last_completiontime
                                best_completiontime = deepcopy(last_completiontime)
                                best_sch = deepcopy(job_sch)
                                job_out = deepcopy(job_out_test)
                            end
                        end
                    end
                end
            end
        end
    end
    return (best_sch, job_out)
end

# single vehicle heuristic (completed)
# sch is assigned schedule
function heuristic(;p=p, d=d, all_job=1:length(d), sch=[], full=false, low_d=[], demand=zeros(length(d)), solomon_demand=1000)
    n = length(d)
    sch_out = []

    # global low_d
    if isempty(low_d)  == true
        low_d = zeros(n)
    end

    # global low_d

    for job_in in all_job
        (sch, job_out) = job_in_out(sch, job_in, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        if isempty(job_out) == false
            append!(sch_out, job_out)
        end

        # # update Jw (this is bad than not update)
        # sch_out_test = deepcopy(sch_out)
        # for j in sch_out_test
        #     (sch, job_out) = job_in_out(sch, j, p, d)
        #     if isempty(job_out) == false
        #         sch_out = setdiff(sch_out, j)
        #         append!(sch_out, job_out)
        #     end
        # end
        # # end update section

    end

    sch_out_test = deepcopy(sch_out)

    for j in sch_out_test
        # global low_d
        (sch, job_out) = job_in_out(sch, j, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        if isempty(job_out) == false
            sch_out = setdiff(sch_out, j)
            append!(sch_out, job_out)
        else
            ind = findfirst(isequal(j), sch_out)
            deleteat!(sch_out, ind)
        end
    end

    # number_late = n - length(sch)
    # println("type = ", typeof(sch_out))
    if full == false
        return (sch, sch_out)
    else
        return append!(sch, sch_out)
    end
end

# the heuristic for multiple vehicles using heuristic for single vehicle (completed)
function heuristic_multi(; p=p, d=d, low_d=zeros(length(d)), name=false, duedate=true, low_duedate=false, demand=zeros(length(d)), solomon_demand=1000)
    # TODO write the explanation!!
    # println("\n-----Strat heuristic for multiple vehicles----")

    data = benchmark(duedate=duedate, low_duedate=low_duedate)
    
    n = length(d)

    # println("the number of job = ", n, "\n")

    iter = 1
    stop = false
    num_remaining_job = length(d)

    # println("iteration : ", iter)

    # for save number of late and last completion time
    save_late = []
    save_comp = []
    save_comp_solomon = []

    (sch, sch_out) = heuristic(p=p, d=d, all_job=[i for i in 1:n], low_d=low_d, demand=demand, solomon_demand=solomon_demand)
    (late_save, last_com_save, meet) = job_late(sch; p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
    check_lower = Check_lower(sch, p, low_d)
    per = data[name]["per"]
    reper_sch = per[sch]
    # reper_sch = solomon100[name]["per"][sch]
    completion_time = distance_solomon(sch, name, sort=true)
    completion_time_nosort = distance_solomon(reper_sch, name, sort=false)
    append!(save_comp_solomon, completion_time)
    println("completion sort = $(completion_time) == completion time unsort = $(completion_time_nosort)")


    # save data
    append!(save_late, sum(late_save))
    append!(save_comp, last_com_save)


    # println("sch     = ", sch)
    # println("sch_out = ", sch_out, "\n")

    if name  != false
        if duedate == true
            alg = 1
        elseif low_duedate == true
            alg = 7
        end
        io = open("heuristic_multiple/Alg$(alg)-$(name).txt", "w")
        write(io, "vehicle $(iter): $(reper_sch)\ncompletion time: $(last_com_save)\nsum distance Solomon: $(completion_time)\nsum late: $(sum(late_save))\ncheck  lower: $(sum(check_lower))\n\n")
        ig = open("heuristic_multiple/only_sch/Alg$(alg)-$(name).txt", "w")
        for i in reper_sch
            write(ig, "$(i) ")
        end
        write(ig, "\n")
    end

    if length(sch_out) == 0

        return 1, 0, last_completiontime
    end

    max_iteration = 100

    while isempty(sch_out) == false && iter < max_iteration && isempty(sch) == false && stop == false
        iter += 1
        # (late, last_completiontime) = job_late(sch; p=p, d=d, low_d=low_d)
        # append!(save_late, sum(late))
        # append!(save_comp, last_completiontime)
        (sch, sch_out) = heuristic(p=p, d=d, all_job=sch_out, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        # println("sch = $(sch)")


        if name != false
            if isempty(sch) == false
                (late_save, last_com_save, meet) = job_late(sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                check_lower = Check_lower(sch, p, low_d)
            else
                late_save     = 0
                last_com_save = 0
                check_lower   = 0
            end
            completion_time = distance_solomon(sch, name, sort=true)
            # completion_time = sum(completion_time)
            append!(save_comp_solomon, completion_time)
            per = data[name]["per"]
            reper_sch = per[sch]
            # reper_sch = solomon100[name]["per"][sch]
            write(io, "vehicle $(iter): $(reper_sch)\ncompletion time: $(last_com_save)\nsum distance Solomon: $(completion_time)\nsum late: $(sum(late_save))\ncheck  lower: $(sum(check_lower))\n\n")
            for i in reper_sch
                write(ig, "$(i) ")
            end
            write(ig, "\n")
        end

        # save data
        # (late, last_completiontime) = job_late(sch; p=p, d=d)
        # append!(save_late, sum(late))
        # append!(save_comp, last_completiontime)

        if length(sch_out) == num_remaining_job || length(sch_out) == 0
            stop = true
            println("remaining sch: $(sch_out)")
        else
            num_remaining_job = length(sch_out)
        end
        # println("sch     = ", sch)
        # println("sch_out = ", sch_out, "\n")
    end
    # println("---Summary---")
    # println("the number of vehicles       = ", iter - 1)
    # println("the number of unassigned job = ", length(sch_out), "\n")
    # println("completion time = $(save_comp)")
    # println("max completion time = $(maximum(save_comp))")

    if name != false
        write(io, "the number of vehicle   = $(iter)\n")
        per = data[name]["per"]
        reper_sch_out = per[sch_out]
        # reper_sch_out = solomon100[name]["per"][sch_out]
        write(io, "the remaining job       = $(reper_sch_out)\n")
        write(io, "the remaining job low d = $(low_d[sch_out])\n")
        write(io, "the remaining job comp  = $([p[i, i] for i in sch_out])\n")
        write(io, "the remaining job d     = $(d[sch_out])\n")
        close(io)
        close(ig)
    end
    return (iter, length(sch_out), sum(save_comp_solomon))
end


# New idea for single and multiple
# new heuristic for multiple vehicles (test), called by heuristic_multi_min
"""try to rearrenge sch by processing time.
  input::
  if all_jobs is [] means condidates are 1, 2, ..., n
Returns:
    array -- sch that can not be processed in time.
"""
function heuristic_single_min(;remain_sch=[], p=p, d=d, all_job=1:length(d), disp=false, full=false, low_d=[], demand=zeros(length(d)), solomon_demand=1000)
    # TODO write the explanation!!
    if disp == true
        println("\n-------Start heuristic_single_min------")
    end

    if isempty(low_d) == true
        low_d = zeros(length(d))
    end

    # define parameters
    # solo_p, solo_d, solo_low_d, demand = load_solomon(name)
    # per = sortperm(solo_d)
    # demand = demand[per]
    demand = demand[all_job]
    p = p[all_job, all_job]
    d = d[all_job]
    low_d = low_d[all_job]
    n = length(d)
    current_sch = []
    current_cap = 0

    # BUG always get 2 vehicles when run multiple vehicles
    first_comp = [p[i, i] for i in 1:n]

    # if isempty(remain_sch)
    #     first_comp = [p[i, i] for i in 1:n]
    # else
    #     last_comp = LastCompletionTime(remain_sch, p, d)
    #     first_comp = p[remain_sch[end], setdiff(remain_sch, remain_sch[end])] .+ last_comp # + all by last completion time
    # end

    # the_sort_order = sortperm(first_comp) # sort p[i, i] for all i
    L = []
    for i in 1:n
        starting_time, completion_time = StartingAndCompletion([i], p, low_d)
        append!(L, completion_time[end] <= d[i])
    end
    # L = [low_d[the_sort_order][i] <= first_comp[the_sort_order][i] <= d[the_sort_order][i] for i = 1:length(first_comp)] # return 1 if the job is not late when it is the first processed job
    position_first = findall(L) # find non late job

    # The case that all jobs are late
    if isempty(position_first)
        return [], all_job
    end

    # Then find the next candidate jobs
    candidate = deepcopy(position_first)

    # print initial step information
    if disp == true
        println("----initial step----")
        # println("sort order                                           = ", the_sort_order)
        # println("sort order completion time                           = ", first_comp[the_sort_order])
        # println("due date of jobs in sort order                       = ", d[the_sort_order])
        println("position that can be process in the first position   = ", position_first)
        println("jobs can be processed at the first position          = ", candidate)
    end

    # define parameters for while loop
    out = false
    i = 1

    while out == false
        num_possible_job = length(candidate) # the possible number of vehicles

        for iter = 1:num_possible_job
            # sch = [job_first[iter]]
            sch = deepcopy(current_sch)
            append!(sch, candidate[iter])
            cap = current_cap
            cap += demand[candidate[iter]]
            remain_job = setdiff(1:n, sch) # 1:n is not all job
            starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
            comp_time = completion_time[end]
            # REMARK remain_job = setdiff(1:n, sch) or setdiff(all_jobs, sch)
            pro_time = p[sch[end], remain_job] # row of matrix
            comp_time_new = []
            for j in 1:length(remain_job)
                if comp_time < low_d[remain_job][j]
                    append!(comp_time_new, low_d[remain_job][j] + pro_time[j])
                else
                    append!(comp_time_new, comp_time + pro_time[j])
                end
            end

            if iter > 1
                if comp_time > best_final_comp
                    if disp == true
                        println("completion time $(comp_time) is more than best completion time $(best_final_comp)")
                    end
                    continue # skip to next iteration
                end
            end

            # comp_time_new = [comp_time + i for i in pro_time] # vertor of completion time
            L = [comp_time_new[i] <= d[remain_job][i] for i = 1:length(comp_time_new)]
            job_avaiable = remain_job[findall(L)]
            comp_avaiable = comp_time_new[findall(L)]

            if isempty(job_avaiable) == false
                job_min_comp = job_avaiable[argmin(comp_avaiable)]
                min_comp = minimum(comp_avaiable)

                if iter == 1
                    global best_final_comp, best_sch
                    best_final_comp = deepcopy(min_comp)
                    best_sch = deepcopy(sch)
                    append!(best_sch, job_min_comp)
                else
                    if min_comp < best_final_comp
                        best_final_comp = deepcopy(min_comp)
                        best_sch = deepcopy(sch)
                        append!(best_sch, job_min_comp)
                    end
                end
            else
                # REMARK this fix for the case that all jobs are late
                if iter == 1
                    if full == false
                        return all_job[sch], setdiff(all_job, all_job[sch])
                    else
                        return append!(all_job[sch], setdiff(all_job, all_job[sch]))
                    end
                end
                # REMARK actually, we can return now but we want to continue check disp
                job_min_comp = []
                min_comp = []
            end

            if disp == true
                println("sch        = ", sch)
                println("remaining job   = ", remain_job)
                println("completion time = ", comp_time)
                # println("processing time = ", pro_time)
                println("comp_time_new   = ", comp_time_new)
                println("L               = ", L)
                println("job avaiable    = ", job_avaiable)
                println("comp avaiable   = ", comp_avaiable)
                println("job min comp    = ", job_min_comp)
                println("final comp time = ", min_comp)
                println("best sch   = ", best_sch)
                println("best_final_comp = ", best_final_comp, " completed\n")
            end
        end

        if disp == true
            println("\ncurrent sch = $(best_sch), the completion time = $(best_final_comp) ")
        end

        # REMARK check this meaning!!
        current_sch = deepcopy(best_sch)
        # global remain
        remain = setdiff(1:n, current_sch)
        remain_number_current = length(remain)
        if i == 1
            global remain_number
            remain_number = remain_number_current
        else
            if remain_number == remain_number_current
                out = true
            else
                remain_number = remain_number_current
            end
        end

        # println("remaining job = ", remain, ", number of remaining job = ", remain_number_current)
        # println("number of remaining job = ", remain_number_current)
        pro_time = p[current_sch[end], remain]
        comp_time = []
        for j in 1:length(remain)
            if best_final_comp < low_d[remain][j]
                append!(comp_time, low_d[remain][j] + pro_time[j])
            else
                append!(comp_time, best_final_comp + pro_time[j])
            end
        end
        # comp_time = [best_final_comp + i for i in pro_time]
        # starting_time, completion_time = StartingAndCompletion(sch, p, low_d)
        # comp_time = completion_time[end]
        L = [comp_time[i] <= d[remain][i] for i = 1:length(comp_time)] # return 1 if these jobs is not late when it is the first processed job
        # the_sort_order = sortperm(pro_time) # sort p[i, i] for all i
        position_first = findall(L)
        candidate = remain[position_first]
        i += 1
    end
    global remain
    if full == false
        return all_job[best_sch], all_job[remain]
    else
        return append!(all_job[best_sch], all_job[remain])
    end
end


# Sort from Min to Max processing time first return schedule
function processingtime_min(all_sch; p=p, d=d, low_d=low_d, disp=false)
    @eval using LinearAlgebra # For using diagonal

    # Initial step
    sch = []
    sum_comp = 0
    p = p[all_sch, all_sch]
    d = d[all_sch]
    n = length(d)
    low_d = low_d[all_sch]
    all_job = [i for i in 1:n] # change index of all jobs to 1:n

    # First step find the smallest completion time for first job (on diagonal of p)
    diag_p = diag(p) # return diagonal element of matrix p

    # Find jobs that min processing time from depot to that job
    candidate = sortperm(diag_p)

    # First iteration
    for Job in candidate
        startingtime, completiontime = StartingAndCompletion([Job], p, low_d)
        if completiontime[end] <= d[Job]
            append!(sch, [Job])
            break
        end
    end
    
    # Next iteration (2,...,n)
    for i in 2:n
        # println("iteration: $(i)")
        current_sch = deepcopy(sch)
        startingtime, completiontime = StartingAndCompletion(current_sch, p, low_d)
        
        last_comp = completiontime[end]
        last_job = current_sch[end]
        remain = setdiff(all_job, current_sch)
        current_processing = p[last_job, :]
        # Candidate jobs
        candidate_job = sortperm(current_processing)
        setdiff!(candidate_job, last_job)
        setdiff!(candidate_job, current_sch)
        # Test input
        found_candidate = false
        for job in candidate_job
            # println("considering job: $(job)")
            test_sch = deepcopy(current_sch)
            
            if found_candidate == true
                println("found candidate")
                break
            end

            test_sch = vcat(test_sch, job)
            # startingtime, completiontime = StartingAndCompletion(test_sch, p, low_d)
            late, last_comp = job_late(test_sch, p=p, d=d, low_d=low_d)
            if sum(late) == 0
                append!(sch, job)
                found_candidate = true
                # println("sum late = 0")
                break
            else
                # println("sum late ≂̸ 0")
                continue
            end
        end
    end
    remain = setdiff(all_job, sch)
    # remain = all_sch[remain]
    return all_sch[sch], all_sch[remain]
end


function processingtime_min_multi(name)
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]
    have_late = true
    iteration = 1
    Dis_pro = 0
    global remain = [i for i in 1:100]
    io = open("processing_multi/Alg5-$(name).txt", "w")
    ig = open("processing_multi/only_sch/Alg5-$(name).txt", "w")

    while have_late == true && iteration <= 100
        global sch, remain = processingtime_min(remain, p=p, d=d, low_d=low_d)
        # println("iter       : $(iteration)")
        # println("sch        : $(sch)")
        current_sch = sch
        per = data[name]["per"]
        reper_current_sch = per[current_sch]
        # reper_current_sch = solomon100[name]["per"][current_sch]
        for job in reper_current_sch
            write(ig, "$(job) ")
        end
        write(ig, "\n")
        write(io, "vehicle: $(iteration)\n")
        write(io, "sch:$(reper_current_sch)\n")
        write(io, "distance:$(distance_solomon(sch, name, sort=true))\n")
        # println("num sch    : $(length(sch))")
        # println("remain     : $(remain)")
        # println("num remain : $(length(remain))")
        # println("dis Solomon: $(distance_solomon(sch, name, sort=true))")
        Dis_pro += distance_solomon(sch, name, sort=true)
        late, last_comp = job_late(sch, p=p, d=d, low_d=low_d)
        # println("late: $(sum(late))\n")
        if isempty(remain) == true
            have_late = false
        end
        iteration += 1
    end
    close(io)
    close(ig)
    println("Name          : $(name)")
    println("Total distance: $(Dis_pro)")
    num_vehicle = iteration - 1
    return num_vehicle, Dis_pro
end


function multiple_fixed_processingtime_min(name, num_vehicle)

    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]

    vehicle = Dict(i => Dict() for i in 1:num_vehicle)

    # add max completion time to all vehicles
    # and create empty list []
    # add completion time to all vehicles
    for i in 1:num_vehicle
        vehicle[i]["sch"] = []
        vehicle[i]["completiontime"] = 0.0
    end

    # main loop
    all_job = [i for i in 1:100]
    n = length(d)
    global sch = [i for i in 1:100]
    current_sch = deepcopy(sch)
    late_all_vehicle = false
    assigned_job = []

    # first iteration add a minimum processing time job to first the vehicle
    processingtime = [p[i, i] for i in 1:n]
    candidate = sortperm(processingtime)
    for j in 1:num_vehicle
        candidate = setdiff(candidate, assigned_job)
        for job in candidate
            starting, completion = StartingAndCompletion([job], p, low_d)
            late, last_completiontime = job_late([job], p=p, d=d, low_d=low_d)
            if sum(late) == 0
                append!(vehicle[j]["sch"], [job])
                vehicle[j]["sch"] = [job]
                vehicle[j]["completiontime"] = last_completiontime
                append!(assigned_job, [job])
                break
            end
        end
    end

    # 
    con = true
    iteration = 1

    # println(vehicle)
    while con && iteration <= n
        if late_all_vehicle == true
            break
        end

        # calculate last completion time for all vehicles
        last_completiontime = [vehicle[i]["completiontime"] for i in 1:num_vehicle]
        sort_completiontime = sortperm(last_completiontime)

        # consider each vehicles
        found = false
        for (num, i) in enumerate(sort_completiontime) # (index, value) = enumerate(something)
            arg_min = i
            candidate = setdiff(all_job, assigned_job)

            if isempty(candidate)
                con = false
                break
            elseif found
                break
            end

            candidate_processing = p[vehicle[arg_min]["sch"][end], :]
            candidate_processing = candidate_processing[candidate]
            per_candidate_procssing = sortperm(candidate_processing)
            candidate_sort_job = candidate[per_candidate_procssing]

            for job in candidate_sort_job
                new_sch = vcat(vehicle[arg_min]["sch"], [job])
                # starting, completion = StartingAndCompletion(new_sch, p, low_d)
                late, last_completiontime = job_late(new_sch, p=p, d=d, low_d=low_d)

                if sum(late) == 0
                    vehicle[arg_min]["sch"] = new_sch
                    vehicle[arg_min]["completiontime"] = last_completiontime
                    append!(assigned_job, job)
                    found = true
                    break
                end

                # if num == num_vehicle
                #     late_all_vehicle = true
                #     break
                # end
            end
        end
        iteration += 1
    end
    total_dis = sum([distance_solomon(vehicle[i]["sch"], name, sort=true) for i in 1:num_vehicle])
    io = open("processing_multi/Alg6-$(name).txt", "w")
    ig = open("processing_multi/only_sch/Alg6-$(name).txt", "w")
    write(io, "instance name: $(name)\n")
    write(io, "number of vehicles: $(num_vehicle)\n\n")
    for i in 1:length(keys(vehicle))
        current_sch = vehicle[i]["sch"]
        per = data[name]["per"]
        reper_current_sch = per[current_sch]
        # reper_current_sch = solomon100[name]["per"][current_sch]
        # for job in reper_current_sch
        #     write(ig, "$(job) ")
        # end
        if isempty(vehicle[i]["sch"]) == false
            write(io, "vehicle $(i): $(reper_current_sch)\n")
            lower = Check_lower(vehicle[i]["sch"], p, low_d)
            write(io, "distance: $(distance_solomon(vehicle[i]["sch"], name, sort=true))\n")
            demand = demand_solomon(vehicle[i]["sch"], name, sort=true)
            write(io, "total demand: $(sum(demand))\n")
            write(io, "check lower bound: $(sum(lower))\n\n")
        else
            write(io, "vehicle $(i): $(reper_current_sch)\n\n")
        end
        for job in reper_current_sch
            write(ig, "$(job) ")
        end
        write(ig, "\n")
    end
    close(ig)
    write(io, "\njob late = $(length(sch))\n")
    write(io, "distance: $(total_dis)\n")
    write(io, "total jobs: $(sum([length(vehicle[i]["sch"]) for i in 1:length(keys(vehicle))]))")
    close(io)
    return setdiff(all_job, assigned_job), total_dis
end


function heuristic_multi_min(;p=p, d=d, disp=true, low_d=[], name=false, duedate=true, low_duedate=false, demand=zeros(length(d)), solomon_demand=1000)
    # TODO write the explanation!!
    # TODO complete this!!

    data = benchmark(duedate=duedate, low_duedate=low_duedate)

    if disp == true
        println("-----Start heuristic mulitiple vahicles min-----")
        println("the number of job = ", length(d))
        println("minimum due date  = ", minimum(d))
        println("maximum due date  = ", maximum(d))
    end

    if name != false
        if duedate == true
            alg = 2
        elseif low_duedate == true
            alg = 8
        end
        io = open("heuristic_multiple/Alg$(alg)-$(name).txt", "w")
        ig = open("heuristic_multiple/only_sch/Alg$(alg)-$(name).txt", "w")
    end

    # initial step
    n = length(d)
    remain = 1:n
    stop = false
    iter = 1
    save_late = []
    save_comp = []
    save_comp_solomon = []
    # 
    while stop == false && iter < n
        current_sch, remain = heuristic_single_min(all_job=remain, p=p, d=d, low_d=low_d, disp=disp, demand=demand, solomon_demand=solomon_demand)



        if isempty(current_sch)
            if disp == true
                println("\n---- stop heuristic_multi_min at iteration $(iter), remain = $(length(remain)) jobs------\n")
            end
            # (late, last_completiontime) = job_late(current_sch; p=p, d=d)
            # append!(save_late, sum(late))
            # append!(save_comp, last_completiontime)
            if name != false
                completion_time = distance_solomon(current_sch, name, sort=true)
                # completion_time = sum(completion_time)
                append!(save_comp_solomon, completion_time)
                per = data[name]["per"]
                reper_current_sch = per[current_sch]
                # reper_current_sch = solomon100[name]["per"][current_sch]
                write(io, "vehicle $(iter): $(reper_current_sch)\ncompletion time:$(sum(save_comp))\ncompletion time Solomon: $(completion_time)\nsum late:$(length(remain))\ncheck  lower:$(0)\ncheck check\n\n")
                write(io, "the number of vehicle   = $(iter - 1)\n")
                reper_remain = per[remain]
                # reper_remain = solomon100[name]["per"][remain]
                write(io, "the remaining job       = $(reper_remain)\n")
                write(io, "the remaining job low d = $(low_d[reper_remain])\n")
                write(io, "the remaining job comp  = $([p[i, i] for i in reper_remain])\n")
                write(io, "the remaining job d     = $(d[reper_remain])\n")
                close(io)
                for i in reper_current_sch
                    write(ig, "$(i) ")
                end
                write(ig, "\n")
                close(ig)
            end
            return iter - 1, length(remain), sum(save_comp_solomon)
        end

        # print("current = ", current_sch)
        (late, last_completiontime, meet) = job_late(current_sch; p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        append!(save_late, sum(late))
        append!(save_comp, last_completiontime)

        if name != false
            check_lower = Check_lower(current_sch, p, low_d)
            completion_time = distance_solomon(current_sch, name, sort=true)
            # completion_time = sum(completion_time)
            append!(save_comp_solomon, completion_time)
            per = data[name]["per"]
            reper_current_sch = per[current_sch]
            # reper_current_sch = solomon100[name]["per"][current_sch]
            write(io, "vehicle $(iter): $(reper_current_sch)\ncompletion time:$(sum(save_comp))\ncompletion time Solomon: $(completion_time)\nsum late:$(sum(late))\ncheck  lower:$(sum(check_lower))\n\n")
            for i in reper_current_sch
                write(ig, "$(i) ")
            end
            write(ig, "\n")
        end

        # check current_sch
        # println("sche   of itertion $(iter) = $(current_sch)")
        # println("remain of itertion $(iter) = $(remain)")
        bool_late, current_comp, meet = job_late(current_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        # println("late of iteration $(iter) = $(sum(bool_late))")


        current_remain = length(remain)

        if iter == 1
            global previous_remain
            previous_remain = length(remain)
        else
            if previous_remain == current_remain
                stop = true

                if disp == true
                    println("\n-----stop heuristic_multi_min at iteration $(iter), remain = $(current_remain) jobs------\n")
                end

                if name != false
                    completion_time = distance_solomon(current_sch, name, sort=true)
                    completion_time = sum(completion_time)
                    append!(save_comp_solomon, completion_time)
                    per = data[name]["per"]
                    reper_current_sch = per[current_sch]
                    # reper_current_sch = solomon100[name]["per"][current_sch]
                    write(io, "vehicle $(iter): $(reper_current_sch)\ncompletion time:$(sum(save_comp))\ncompletion time Solomon: $(save_comp_solomon)\nsum late:$(length(remain))\ncheck  lower:$(0)\n\n")
                    write(io, "the number of vehicle   = $(iter - 1)\n")
                    reper_remain = Reverse_permutation(remain)
                    write(io, "the remaining job       = $(reper_remain)\n")
                    write(io, "the remaining job low d = $(low_d[reper_remain])\n")
                    write(io, "the remaining job comp  = $([p[i, i] for i in reper_remain])\n")
                    write(io, "the remaining job d     = $(d[reper_remain])\n")
                    close(io)
                    for i in sch
                        write(ig, "$(i) ")
                    end
                    write(ig, "\n")
                    close(ig)
                end
            else
                previous_remain = current_remain
            end
        end
        iter += 1
    end
    num_vehicle = iter - 1

    if name != false
        per = data[name]["per"]
        reper_previos_remain = per[previous_remain]
        # reper_previos_remain = solomon100[name]["per"][previous_remain]
        write(io, "the number of vehicle   = $(num_vehicle)\n")
        write(io, "the remaining job       = $(reper_previos_remain)\n")
        write(io, "the remaining job low d = $(low_d[reper_previos_remain])\n")
        write(io, "the remaining job comp  = $([p[i, i] for i in reper_previos_remain])\n")
        write(io, "the remaining job d     = $(d[reper_previos_remain])\n")
        close(io)
        # for i in 
        #     write(ig, "$(i) ")
        # end
        # write(ig, "\n")
        # close(ig)
    end

    return (num_vehicle, previous_remain, sum(save_comp_solomon))
end

function mix_min_heuristic(;p=p, d=d, number=true)
    # first run heuristic_multi and then run heuristic on the return sch
    # number = true : return only the number of tardy jobs
    # number = false: return the final sch and the reamaining jobs
    (sch, sch_out) = heuristic_single_min(p=p, d=d)
    # println("Run heuristic single min")
    # println("The number of tardy job (single min) is $(length(sch_out))")
    out1 = length(sch_out)
    # println("sch: $(length(sch))  sch out: $(length(sch_out))")
    # println("Then run heuristic")
    (sch, sch_out) = heuristic(sch=sch, all_job=sch_out, p=p, d=d)
    # println("The number of tardy job (heuristic) is $(length(sch_out))")
    # println("sch: $(length(sch))  sch out: $(length(sch_out))")
    out2 = length(sch_out)
    if number == true
        return (out1, out2)
    else
        return (sch, sch_out)
    end
end

# used for algorithm returning sch
function sch_tree(
    ;before_position=position,
    level_step=level_step,
    level=level,
    p=p,
    d=d,
    )
    # TODO not complete need to reconsider!!
    sch = []
    if level_step == 1
        println("level step = 1")
        append!(sch, before_position)
    else
        for i = level_step:-1:2
            println("level step = $(level_step - i)")
            current_job = level[i][before_position][2]
            before_position = level[i][before_position][3]
            append!(sch, before_position)
            println("level    = $(level[i])")
            println("position = $(before_position)")
        end
    end
    return sch
end

function algorithm(;p=p, d=d)
    # TODO this is similar to the branch and bound algorithm (not complete)
    n = length(d)
    max_late = n
    level = Dict()

    for i = 1:n
        level[i] = Dict()
    end

    current_min = 0
    current_position = 1

    # level 1
    late1 = []

    for k = 1:n
        append!(late1, sum([d[i] < p[k,k] for i = 1:n]))
    end

    level[1] = Dict(i => [i, 0, 0, p[i, i], late1[i]] for i = 1:n)
    level_step = 1
    stop = false
    deep = 2
    iter = 1

    while (stop == false) && (iter <= 10)
        # stop = true
        println("\n@@@iteration: $(iter) @@level_step: $(level_step)\n")
        println("level5 = ", [level[level_step][i][5] == current_min for i in keys(level[level_step])])
        branch_position = findall([level[level_step][i][5] == current_min for i in keys(level[level_step])])
        println("branch_position = $(branch_position)")

        if isempty(branch_position)
            level_step -= 1
        else
            for position in branch_position
                println("position = $(position)")
                job = level[level_step][position][1]
                println("job      = $(job)")
                sch = sch_tree(before_position=position, level_step=level_step, level=level)
                println("sch tree = ", sch)
                level_step += 1
                level[level_step] = Dict()
                remaining_job = setdiff(1:n, sch)
                println("remaining_job = $(remaining_job)")

                for i in remaining_job
                    println("i = $(i)")
                    completion_time = level[level_step - 1][job][4] + p[job, i]
                    late = sum(job_late(sch, p, d)[1]) + sum(d[k] < completion_time for k in remaining_job)
                    level[level_step][i] = [i, job, position, completion_time, late]
                    println("level_step = $(level[level_step][i])")
                end

                # println("position = $(position)")
                # vector_late = [level[level_step][i][5] == current_min for i=1:length(level[level_step])]
                # println("vector_late = $(vector_late)")
            end
        end

        # if current_min > max_late
        #     level_step -= 1
        #     println("level_step down")
        # end

        iter += 1
    end
    # branch_position = []
    println("level = $(level[2])")
end


function multiple_fixed_vehicle(sch, p, d, low_d, num_vehicle; name=false)
    vehicle = Dict(i => Dict() for i in 1:num_vehicle)

    # add max completion time to all vehicles
    # and create empty list []
    # add completion time to all vehicles
    for i in 1:num_vehicle
        vehicle[i]["sch"] = []
        vehicle[i]["completiontime"] = Int(0)
    end

    # main loop
    global sch = [i for i in 1:100]
    current_sch = deepcopy(sch)
    late_all_vehicle = false

    for job in current_sch
        if late_all_vehicle == true
            break
        end

        completiontime = [vehicle[i]["completiontime"] for i in 1:num_vehicle]
        sort_completiontime = sortperm(completiontime)

        for (n, i) in enumerate(sort_completiontime) # (index, value) = enumerate(something)
            arg_min = i
            new_sch = vcat(vehicle[arg_min]["sch"], [job])
            starting, completion = StartingAndCompletion(new_sch, p, low_d)
            late, last_completiontime = job_late(new_sch, p=p, d=d, low_d=low_d)

            if sum(late) == 0
                vehicle[arg_min]["sch"] = new_sch
                vehicle[arg_min]["completiontime"] = last_completiontime
                setdiff!(sch, job)
                break
            end

            if n == num_vehicle
                late_all_vehicle = true
            end
        end
    end

    # this work when called from test_new_alg in run_benchmark.jl
    # for i in 1:num_vehicle
    #     println("vehicle $(i): $(vehicle[i]["sch"])")
    #     println("vehicle $(i) completion time: $(distance_solomon(vehicle[i]["sch"], name, sort=true))")
    # end
    total_dis = sum([distance_solomon(vehicle[i]["sch"], name, sort=true) for i in 1:num_vehicle])
    # println("total completion time: $(total_dis)")

    if name != false
        io = open("multiple_vehicle/Alg3-$(name).txt", "w")
        ig = open("multiple_vehicle/only_sch/Alg3-$(name).txt", "w")
        write(io, "instance name: $(name)\n")
        write(io, "number of vehicles: $(num_vehicle)\n\n")
    
        for i in 1:length(keys(vehicle))
            current_sch = vehicle[i]["sch"]
            per = data[name]["per"]
            reper_current_sch = per[current_sch]
            # reper_current_sch = solomon100[name]["per"][current_sch]
            if isempty(current_sch) == false
                write(io, "vehicle $(i): $(reper_current_sch)\n")
                
                lower = Check_lower(current_sch, p, low_d)
                write(io, "distance: $(distance_solomon(current_sch, name, sort=true))\n")
                demand = demand_solomon(current_sch, name, sort=true)
                write(io, "total demand: $(sum(demand))\n")
                write(io, "check lower bound: $(sum(lower))\n\n")
            else
                write(io, "vehicle $(i): $(current_sch)\n\n")
            end

            for job in reper_current_sch
                write(ig, "$(job) ")
            end
            write(ig, "\n")
        end
        write(io, "\njob late = $(length(sch))\n")
        write(io, "distance: $(total_dis)\n")
        write(io, "total jobs: $(sum([length(vehicle[i]["sch"]) for i in 1:length(keys(vehicle))]))\n")
        close(io)
        close(ig)
    end
    return sch, total_dis
end


function multiple_fixed_heuristic(sch, p, d, low_d, num_vehicle; name=false)
    global vehicle = Dict(i => Dict() for i in 1:num_vehicle)

    # add max completion time to all vehicles
    # and create empty list []
    # add completion time to all vehicles
    for i in 1:num_vehicle
        vehicle[i]["sch"] = []
        vehicle[i]["completiontime"] = Int(0)
    end
    # println("initial step")

    # print initial step
    # for i in 1:num_vehicle
    #     println("now  vehicle $i = $(vehicle[i]["sch"])")
    #     println("comp vehicle $i = $(vehicle[i]["completiontime"])\n")
    # end

    # main
    global sch_remaining = [i for i in 1:length(d)]


    # println("remaining schedule = $(sch_remaining)")
    
    
    iteration = 1
    while isempty(sch_remaining) == false && iteration <= 100

        # println("iteration: $iteration")

        current_job = sch_remaining[1]
        # println("current job: $(current_job)")

        vehicle_completiontime = [vehicle[i]["completiontime"] for i in 1:num_vehicle]
        sort_vehicle_completiontime = sortperm(vehicle_completiontime)

        for j in 1:num_vehicle
            sch_new, job_out = job_in_out(vehicle[sort_vehicle_completiontime[j]]["sch"], current_job, p=p, d=d, low_d=low_d)
            if isempty(sch_new) == false
                start, completion = StartingAndCompletion(sch_new, p, low_d)
                late, last_comp = job_late(sch_new, p=p, d=d, low_d=low_d)
            end

            if isempty(job_out)
                if sum(late) == 0
                    vehicle[sort_vehicle_completiontime[j]]["sch"] = sch_new
                    vehicle[sort_vehicle_completiontime[j]]["completiontime"] = completion[end]
                    setdiff!(sch_remaining, current_job)
                    break
                else
                    continue
                end
            elseif job_out == current_job
                continue
            else
                setdiff!(sch_remaining, current_job)
                sch_remaining = vcat(job_out, sch_remaining)
                break
            end
        end
        iteration += 1
    end


    total_dis = sum([distance_solomon(vehicle[i]["sch"], name, sort=true) for i in 1:num_vehicle])

    # output
    io = open("multiple_vehicle/Alg4-$(name).txt", "w")
    ig = open("multiple_vehicle/only_sch/Alg4-$(name).txt", "w")
    write(io, "instance name: $(name)\n")
    write(io, "number of vehicles: $(num_vehicle)\n\n")
    for i in 1:length(keys(vehicle))
        current_sch = vehicle[i]["sch"]
        per = data[name]["per"]
        reper_current_sch = per[current_sch]
        # reper_current_sch = solomon100[name]["per"][current_sch]
        if isempty(current_sch) == false
            write(io, "vehicle $(i): $(reper_current_sch)\n")
            lower = Check_lower(vehicle[i]["sch"], p, low_d)
            write(io, "distance: $(distance_solomon(vehicle[i]["sch"], name, sort=true))\n")
            demand = demand_solomon(vehicle[i]["sch"], name, sort=true)
            write(io, "total demand: $(sum(demand))\n")
            write(io, "check lower bound: $(sum(lower))\n\n")
        else
            write(io, "vehicle $(i): $(reper_current_sch)\n\n")
        end
        for job in reper_current_sch
            write(ig, "$(job) ")
        end
        write(ig, "\n")
    end
    close(ig)
    write(io, "\njob late = $(length(sch_remaining))\n")
    write(io, "distance: $(total_dis)\n")
    write(io, "total jobs: $(sum([length(vehicle[i]["sch"]) for i in 1:length(keys(vehicle))]))")
    close(io)
    return sch_remaining, total_dis
end


function multiple_vehicle(name::String, f::Function; duedate=true, low_duedate=false)
    # parameters
    data = benchmark(duedate=duedate, low_duedate=low_duedate)
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]
    have_late = true
    num_vehicle = 1
    sch = [i for i in 1:100]
    while have_late && num_vehicle <= 100
        global sch_late, total_dis = f(sch, p, d, low_d, num_vehicle, name=name)
        # global sch_late, total_dis = multiple_fixed_vehicle(sch, p, d, low_d, num_vehicle, name=name)
        if length(sch_late) > 0 
            # println("iteration: $(num_vehicle)")
            # println("still late $(length(sch_late)) jobs")
            num_vehicle += 1
        else
            # println("iteration: $(num_vehicle)")
            # println("the number of late = $(length(sch_late))")
            have_late = false
        end
    end
    println("$(name): number of vehicle: $(num_vehicle)")
    return num_vehicle, total_dis
end


function multiple_processingtime(name)
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]
    have_late = true
    num_vehicle = 1
    sch = [i for i in 1:100]
    while have_late && num_vehicle <= 100
        global sch_late, total_dis = multiple_fixed_processingtime_min(name, num_vehicle)
        # global sch_late, total_dis = multiple_fixed_vehicle(sch, p, d, low_d, num_vehicle, name=name)
        if length(sch_late) > 0 
            # println("iteration: $(num_vehicle)")
            # println("still late $(length(sch_late)) jobs")
            num_vehicle += 1
        else
            # println("iteration: $(num_vehicle)")
            # println("the number of late = $(length(sch_late))")
            have_late = false
        end
    end
    println("$(name): number of vehicle: $(num_vehicle)")
    return num_vehicle, total_dis
end


function pair_completion_time(last_completiontime, candidate)
    nothing
end


function choose_job_inout()
    nothing
end


function heuristic_pair(all_job, name)
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]

    function can_com(last_job, candidate_comp)
        N = length(candidate_comp)
        completiontime = []
        for i in 1:N
            if last_job == 0
                append!(completiontime, p[candidate_comp[i][1], candidate_comp[i][1]] + p[candidate_comp[i][1], candidate_comp[i][2]])
            else
                append!(completiontime, p[last_job, candidate_comp[i][1]] + p[candidate_comp[i][1], candidate_comp[i][2]])
            end
        end
        return sortperm(completiontime)
    end


    # initial step create all 100 choose 2 vectors
    
    # sch
    sch = []
    
    con = true
    iteration = 1 
    while con && iteration <= 100

        # if isempty(all_job)
        #     break
        # end

        candidate = []
        for i in all_job
            for j in all_job
                if i != j
                    append!(candidate, [[i, j]])
                end
            end
        end
        if iteration == 1
            per_candidate = can_com(0, candidate)
        else
            per_candidate = can_com(sch[end], candidate)
        end

        sort_candidate = candidate[per_candidate]
        num_candidate = length(sort_candidate)

        for (iter, pair) in enumerate(sort_candidate)
            # println("pair = $(pair)")
            new_sch = vcat(sch, pair)
            starting, completion = StartingAndCompletion(new_sch, p, low_d)
            late, last_completiontime = job_late(new_sch, p=p, d=d, low_d=low_d)
            if sum(late) == 0
                append!(sch, pair)
                setdiff!(all_job, pair)
                setdiff!(candidate, [pair])
                iteration += 1
                break
            end
            if iter == num_candidate
                con = false
            end
        end
        iteration += 1
    end
    return sch, all_job
end


function heuristic_pair_multi(name)
    have_late = true
    iteration = 1
    global save_comp_solomon = []
    global remain = [i for i in 1:100]
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]
    io = open("pair_multiple/Alg9-$(name).txt", "w")
    ig = open("pair_multiple/only_sch/Alg9-$(name).txt", "w")
    while have_late && iteration <= 100
        sch, remain = heuristic_pair(remain, name)

        if isempty(sch)
            write(io, "vehicle $(iteration): $([])\ncompletion time Solomon: $(0)\nsum late:$(0)\ncheck  lower:$(0)\n")
            write(ig, "\n")
            break
        end

        if name != false
            completion_time = distance_solomon(sch, name, sort=true)
            # completion_time = sum(completion_time)
            append!(save_comp_solomon, completion_time)
            per = data[name]["per"]
            reper_current_sch = per[sch]
            check_lower = Check_lower(sch, p, low_d)
            late, last_com = job_late(sch, p=p, d=d, low_d=low_d)
            write(io, "vehicle $(iteration): $(reper_current_sch)\ncompletion time Solomon: $(completion_time)\nsum late:$(sum(late))\ncheck  lower:$(check_lower)\n")
            write(io, "the number of vehicle   = $(iteration)\n")
            reper_remain = per[remain]
            # reper_remain = solomon100[name]["per"][remain]
            write(io, "the remaining job       = $(reper_remain)\n")
            write(io, "the remaining job low d = $(low_d[reper_remain])\n")
            write(io, "the remaining job comp  = $([p[i, i] for i in reper_remain])\n")
            write(io, "the remaining job d     = $(d[reper_remain])\n")
            for i in reper_current_sch
                write(ig, "$(i) ")
            end
            write(ig, "\n")
        end
        
        if isempty(remain)
            break
        end
        
        println("iteration: $iteration")
        println("remaining sch = $(length(remain))")
        if isempty(remain)
            have_late == false
        end
        iteration += 1
    end
    close(io)
    close(ig)
    num_vehicle9 = iteration
    total_dis9 = sum(save_comp_solomon)
    return num_vehicle9, total_dis9, remain
end

# full version of all diff idea
# version 1 == algorithm10
function heuristic_diff(all_job::Array, name::String; version=1)
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]

    function can_diff(current_sch, candidate_comp)
        N = length(candidate_comp)
        diff_comp = []
        # last_job = current_sch[end]
        for i in 1:N
            new_sch = vcat(current_sch, candidate_comp[i])
            start, comp = StartingAndCompletion(new_sch, p, low_d)

            # different algorithm
            # version 1: use -> last completion time - before last
            # version 2: use -> the weighted sum of starting time and processing time
            if version == 1
                if length(comp) == 1
                    append!(diff_comp, comp[end])
                else
                    append!(diff_comp, comp[end] - comp[end - 1])
                end
            elseif version == 2
                if length(comp) == 1
                    append!(diff_comp, 0.2 * start[1] + 0.8 * p[new_sch[1], new_sch[1]])
                else
                    append!(diff_comp, 0.2 * start[end] + 0.8 * p[new_sch[end - 1], new_sch[end]])
                end
            elseif version == 3
                # use release time + processing time
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[1]] + p[new_sch[1], new_sch[1]])
                else
                    append!(diff_comp, low_d[new_sch[end]] + p[new_sch[end - 1], new_sch[end]])
                end
            elseif version == 4
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[end]] + p[new_sch[end], new_sch[end]])
                else
                    t = low_d[new_sch[end]] - comp[end - 1]
                    if t >= 0
                        append!(diff_comp, t + p[new_sch[end - 1], new_sch[end]])
                    else
                        append!(diff_comp, p[new_sch[end - 1], new_sch[end]])
                    end
                end
            elseif version == 5
                # min different between lastest competion time and duedate
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[end]] + d[new_sch[end]] + p[new_sch[1], new_sch[1]])
                else
                    append!(diff_comp, low_d[new_sch[end]] + d[new_sch[end]] + p[new_sch[end - 1], new_sch[end]])
                end
            elseif version == 6
                # min lastest completion time
                if length(comp) == 1
                    append!(diff_comp, comp[end])
                else
                    append!(diff_comp, comp[end])   
                end
            elseif version == 7
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[end]])
                else
                    append!(diff_comp, low_d[new_sch[end]])   
                end
            elseif version == 8
                if length(comp) == 1
                    append!(diff_comp, comp[end] - p[new_sch[end], new_sch[end]])
                else
                    append!(diff_comp, comp[end] - comp[end - 1] - p[new_sch[end], new_sch[end]])   
                end
            end
        end
        return sortperm(diff_comp)
    end


    # initial step create all 100 choose 2 vectors
    
    # sch
    sch = []
    
    con = true
    iteration = 1 
    while con && iteration <= 100

        # if isempty(all_job)
        #     break
        # end

        candidate = deepcopy(all_job)
        per_candidate = can_diff(sch, candidate)

        sort_candidate = candidate[per_candidate]
        num_candidate = length(sort_candidate)

        for (iter, pair) in enumerate(sort_candidate)
            new_sch = vcat(sch, pair)
            starting, completion = StartingAndCompletion(new_sch, p, low_d)
            late, last_completiontime = job_late(new_sch, p=p, d=d, low_d=low_d)
            if sum(late) == 0
                append!(sch, pair)
                setdiff!(all_job, pair)
                setdiff!(candidate, [pair])
                iteration += 1
                break
            end
            if iter == num_candidate
                con = false
            end
        end
        iteration += 1
    end
    return sch, all_job
end

# difference input
function heuristic_diff(all_job::Array, p::Array, d::Array, low_d::Array, demand::Array, solomon_demand::Int; version=1)
    # data = benchmark()
    # p = data[name]["p"]
    # d = data[name]["d"]
    # low_d = data[name]["low_d"]

    function can_diff(current_sch, candidate_comp)
        N = length(candidate_comp)
        diff_comp = []
        # last_job = current_sch[end]
        for i in 1:N
            new_sch = vcat(current_sch, candidate_comp[i])
            start, comp = StartingAndCompletion(new_sch, p, low_d)

            # different algorithm
            # version 1: use -> last completion time - before last
            # version 2: use -> the weighted sum of starting time and processing time
            if version == 1
                if length(comp) == 1
                    append!(diff_comp, comp[end])
                else
                    append!(diff_comp, comp[end] - comp[end - 1])
                end
            elseif version == 2
                if length(comp) == 1
                    append!(diff_comp, 0.2 * start[1] + 0.8 * p[new_sch[1], new_sch[1]])
                else
                    append!(diff_comp, 0.2 * start[end] + 0.8 * p[new_sch[end - 1], new_sch[end]])
                end
            elseif version == 3
                # use release time + processing time
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[1]] + p[new_sch[1], new_sch[1]])
                else
                    append!(diff_comp, low_d[new_sch[end]] + p[new_sch[end - 1], new_sch[end]])
                end
            elseif version == 4
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[end]] + p[new_sch[end], new_sch[end]])
                else
                    t = low_d[new_sch[end]] - comp[end - 1]
                    if t >= 0
                        append!(diff_comp, t + p[new_sch[end - 1], new_sch[end]])
                    else
                        append!(diff_comp, p[new_sch[end - 1], new_sch[end]])
                    end
                end
            elseif version == 5
                # min different between lastest competion time and duedate
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[end]] + d[new_sch[end]] + p[new_sch[1], new_sch[1]])
                else
                    append!(diff_comp, low_d[new_sch[end]] + d[new_sch[end]] + p[new_sch[end - 1], new_sch[end]])
                end
            elseif version == 6
                # min lastest completion time
                if length(comp) == 1
                    append!(diff_comp, comp[end])
                else
                    append!(diff_comp, comp[end])   
                end
            elseif version == 7
                if length(comp) == 1
                    append!(diff_comp, low_d[new_sch[end]])
                else
                    append!(diff_comp, low_d[new_sch[end]])   
                end
            elseif version == 8
                if length(comp) == 1
                    append!(diff_comp, comp[end] - p[new_sch[end], new_sch[end]])
                else
                    append!(diff_comp, comp[end] - comp[end - 1] - p[new_sch[end], new_sch[end]])   
                end
            end
        end
        return sortperm(diff_comp)
    end


    # initial step create all 100 choose 2 vectors
    
    # sch
    sch = []
    
    con = true
    iteration = 1 
    while con && iteration <= 100

        # if isempty(all_job)
        #     break
        # end

        candidate = deepcopy(all_job)
        per_candidate = can_diff(sch, candidate)

        sort_candidate = candidate[per_candidate]
        num_candidate = length(sort_candidate)

        for (iter, pair) in enumerate(sort_candidate)
            new_sch = vcat(sch, pair)
            starting, completion = StartingAndCompletion(new_sch, p, low_d)
            late, last_completiontime, meet_demand = job_late(new_sch, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            if sum(late) == 0 && meet_demand == true
                append!(sch, pair)
                setdiff!(all_job, pair)
                setdiff!(candidate, [pair])
                iteration += 1
                break
            end
            if iter == num_candidate
                con = false
            end
        end
        iteration += 1
    end
    return sch, all_job
end


function heuristic_diff_multi(name; disp=false, version=1, alg=10)
    # alg = version + 9
    have_late = true
    iteration = 1
    global save_comp_solomon = []
    global remain = [i for i in 1:100]
    data = benchmark()
    p, d, low_d, demand, solomon_cap = load_all_data(name)
    io = open("diff_multiple/Alg$(alg)-$(name).txt", "w")
    ig = open("diff_multiple/only_sch/Alg$(alg)-$(name).txt", "w")
    while have_late && iteration <= 100
        # sch, remain = heuristic_diff(remain, name, version=version)
        sch, remain = heuristic_diff(remain, p, d, low_d, demand, solomon_cap, version=version)

        if isempty(sch)
            write(io, "vehicle $(iteration): $([])\ncompletion time Solomon: $(0)\nsum late:$(0)\ncheck  lower:$(0)\n")
            write(ig, "\n")
            break
        end

        if name != false
            completion_time = distance_solomon(sch, name, sort=false)
            # completion_time = sum(completion_time)
            append!(save_comp_solomon, completion_time)
            # per = data[name]["per"]
            # reper_current_sch = per[sch]
            check_lower = Check_lower(sch, p, low_d)
            late, last_com = job_late(sch, p=p, d=d, low_d=low_d, solomon_demand=solomon_cap)
            write(io, "vehicle $(iteration): $(sch)\ncompletion time Solomon: $(completion_time)\nsum late:$(sum(late))\ncheck  lower:$(check_lower)\n")
            write(io, "the number of vehicle   = $(iteration)\n")
            # reper_remain = per[remain]
            # reper_remain = solomon100[name]["per"][remain]
            # write(io, "the remaining job       = $(reper_remain)\n")
            # write(io, "the remaining job low d = $(low_d[reper_remain])\n")
            # write(io, "the remaining job comp  = $([p[i, i] for i in reper_remain])\n")
            # write(io, "the remaining job d     = $(d[reper_remain])\n")
            write(io, "the remaining job       = $(remain)\n")
            write(io, "the remaining job low d = $(low_d)\n")
            write(io, "the remaining job d     = $(d)\n")
            for i in sch
                write(ig, "$(i) ")
            end
            write(ig, "\n")
        end
        
        # if no job left, break this loop.
        if isempty(remain)
            break
        end

        # print solution
        if disp == true
            println("iteration: $iteration")
            println("remaining sch = $(length(remain))")
        end

        if isempty(remain)
            have_late == false
        end
        iteration += 1
    end
    close(io)
    close(ig)
    num_vehicle10 = iteration
    total_dis10 = sum(save_comp_solomon)
    return num_vehicle10, total_dis10, remain
end


function multiple_fixed_diff(sch, p, d, low_d, num_vehicle; name=false)
    data = benchmark()

    function can_diff(current_sch, candidate_comp)
        N = length(candidate_comp)
        diff_comp = []
        # last_job = current_sch[end]
        for i in 1:N
            start, comp = StartingAndCompletion(vcat(current_sch, candidate_comp[i]), p, low_d)
            if length(comp) == 1
                append!(diff_comp, comp[end])
            else
                append!(diff_comp, comp[end] - comp[end - 1])
            end
        end
        return sortperm(diff_comp)
    end

    vehicle = Dict(i => Dict() for i in 1:num_vehicle)

    # add max completion time to all vehicles
    # and create empty list []
    # add completion time to all vehicles
    for i in 1:num_vehicle
        vehicle[i]["sch"] = []
        vehicle[i]["completiontime"] = Int(0)
    end

    # main loop
    global sch = [i for i in 1:100]
    all_job = deepcopy(sch)
    late_all_vehicle = false
    cont = true

    while cont

        if isempty(sch)
            break
        end

        completiontime = [vehicle[i]["completiontime"] for i in 1:num_vehicle]
        sort_completiontime = sortperm(completiontime)
        found = false

        for (n, i) in enumerate(sort_completiontime) # (index, value) = enumerate(something)
            if found == true
                break
            end
            current_sch = vehicle[i]["sch"]
            candidate = deepcopy(sch)
            per_candidate = can_diff(current_sch, candidate)
            sort_candidate = candidate[per_candidate]
            num_candidate = length(sort_candidate)
            for job in sort_candidate
                new_sch = vcat(current_sch, [job])
                starting, completion = StartingAndCompletion(new_sch, p, low_d)
                late, last_completiontime = job_late(new_sch, p=p, d=d, low_d=low_d)

                if sum(late) == 0
                    vehicle[i]["sch"] = new_sch
                    vehicle[i]["completiontime"] = last_completiontime
                    setdiff!(sch, job)
                    found = true
                    break
                end

            end
            if n == num_vehicle
                cont = false
            end
        end
    end

    # this work when called from test_new_alg in run_benchmark.jl
    # for i in 1:num_vehicle
    #     println("vehicle $(i): $(vehicle[i]["sch"])")
    #     println("vehicle $(i) completion time: $(distance_solomon(vehicle[i]["sch"], name, sort=true))")
    # end
    total_dis = sum([distance_solomon(vehicle[i]["sch"], name, sort=true) for i in 1:num_vehicle])
    # println("total completion time: $(total_dis)")

    if name != false
        io = open("multiple_diff/Alg10-$(name).txt", "w")
        ig = open("multiple_diff/only_sch/Alg10-$(name).txt", "w")
        write(io, "instance name: $(name)\n")
        write(io, "number of vehicles: $(num_vehicle)\n\n")
    
        for i in 1:length(keys(vehicle))
            current_sch = vehicle[i]["sch"]
            per = data[name]["per"]
            reper_current_sch = per[current_sch]
            # reper_current_sch = solomon100[name]["per"][current_sch]
            if isempty(current_sch) == false
                write(io, "vehicle $(i): $(reper_current_sch)\n")
                
                lower = Check_lower(current_sch, p, low_d)
                write(io, "distance: $(distance_solomon(current_sch, name, sort=true))\n")
                demand = demand_solomon(current_sch, name, sort=true)
                write(io, "total demand: $(sum(demand))\n")
                write(io, "check lower bound: $(sum(lower))\n\n")
            else
                write(io, "vehicle $(i): $(current_sch)\n\n")
            end

            for job in reper_current_sch
                write(ig, "$(job) ")
            end
            write(ig, "\n")
        end
        write(io, "\njob late = $(length(sch))\n")
        write(io, "distance: $(total_dis)\n")
        write(io, "total jobs: $(sum([length(vehicle[i]["sch"]) for i in 1:length(keys(vehicle))]))\n")
        close(io)
        close(ig)
    end
    return sch, total_dis
end


function multiple_diff(name; disp=false)
    # load data 
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]
    sch = [i for i in 1:length(d)]

    num_vehicle10, total_dis10, remain = heuristic_diff_multi(name)

    println("number of vehicle: $num_vehicle10")
    println("total distance: $total_dis10")
    println("num remaining: $(length(remain))")
    
    remain11, total_dis11 = multiple_fixed_diff(sch, p, d, low_d, num_vehicle10; name=name)
    println("\nnumber of vehicle: $num_vehicle10")
    println("total distance: $total_dis11")
    println("num remaining: $(length(remain11))")
    # save = Dict()
    # for i in 0:5
    #     save[i] = Dict()
    #     remain_sch, total_dis = multiple_fixed_diff(sch, p, d, low_d, num_vehicle10-i; name=name)
    #     save[i]["sch"] = remain_sch
    #     save[i]["totaldis"] = total_dis
    # end
    # return save
    num_vehicle11 = num_vehicle10
    return num_vehicle11, total_dis11, remain11
end


# Compare between arrange one by one vahicle and arrange multiple vehicles in the same time.
# We want to use the solution of single and then reduce or increse the number of vehicle.
# But the problem is the minimum number of vehicle of multiple is always more than the number of single.
function multiple_diff2(name)
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]
    have_late = true
    num_vehicle = 1
    sch = [i for i in 1:100]
    while have_late && num_vehicle <= 100
        global sch_late, total_dis = multiple_fixed_diff(sch, p, d, low_d, num_vehicle, name=name)
        # global sch_late, total_dis = multiple_fixed_vehicle(sch, p, d, low_d, num_vehicle, name=name)
        if length(sch_late) > 0 
            # println("iteration: $(num_vehicle)")
            # println("still late $(length(sch_late)) jobs")
            num_vehicle += 1
        else
            # println("iteration: $(num_vehicle)")
            # println("the number of late = $(length(sch_late))")
            have_late = false
        end
    end
    num_vehicle10, total_dis10, remain = heuristic_diff_multi(name)
    println("$(name): number of vehicle(single): $(num_vehicle10)")
    println("$(name): number of vehicle(multiple): $(num_vehicle)")
    return num_vehicle, total_dis
end

# new algorithm sort all elements in matrix and then try to create a route
function return_index_matrix(value, dim_matrix; best_route=[])
    all_col = Int.(ceil.(value / dim_matrix))
    row = []
    col = []
    for (c, v) in enumerate(value)
        if mod(v, dim_matrix) == 0
            if (dim_matrix in best_route) == false && (mod(all_col[c], dim_matrix) in best_route) == false
                append!(row, dim_matrix)
                append!(col, all_col[c])
            end
        else
            if (mod(v, dim_matrix) in best_route) == false && (mod(all_col[c], dim_matrix) in best_route) == false
                append!(row, mod(v, dim_matrix))
                append!(col, all_col[c])
            end
        end
    end
    coordinate_matrix = [(i, j) for (i, j) in zip(row, col)]
    return coordinate_matrix
end


function sort_processing_matrix(matrix::Array; best_route=[])
    dim = size(matrix, 1)
    vector = reshape(matrix, :)
    sort_per_vector = sortperm(vector)
    return sort_coor = return_index_matrix(sort_per_vector, dim, best_route=best_route) 
end

function sort_processing_matrix(vehicle::Dict)
    name = vehicle["name"]
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    return sort_processing_matrix(p)
end


function swap(x::Array, position::Tuple)
    x[position[1]], x[position[2]] = x[position[2]], x[position[1]]
    return x
end


function swap_between_vehicle(vehicle::Dict, position1::Array, position2::Array)
    vehicle[position1[1]]["sch"][position1[2]], vehicle[position2[1]]["sch"][position2[2]] = vehicle[position2[1]]["sch"][position2[2]], vehicle[position1[1]]["sch"][position1[2]]
    return vehicle
end


function min_matrix(name, num_vehicle)
    # load data
    data = benchmark()
    p = data[name]["p"]
    d = data[name]["d"]
    low_d = data[name]["low_d"]

    # find sort coordinate 
    sort_coor = sort_processing_matrix(p)
    
    # find element depart from origin
    from_origin = findall(x -> x[1] == x[2], sort_coor)
    
    # select first n jobs that near their processing time
    vehicle = Dict()
    for i in 1:num_vehicle
        vehicle[i] = Dict()
        vehicle[i]["sch"] = [sort_coor[from_origin][i]]
        vehicle[i]["sch"] = [sort_coor[from_origin][i]]
        # vehicle[i]["distance"] = p[sort_coor[from_origin][i][1], sort_coor[from_origin][i][2]]
        vehicle[i]["distance"] = distance_solomon([sort_coor[from_origin][i][1]], name, sort=true)
        vehicle[i]["low_d"] = low_d[sort_coor[from_origin][i][1]]
        vehicle[i]["d"] = d[sort_coor[from_origin][i][1]]
    end
    return vehicle
end

# use min release time + processing time
# use min (release time - last completion time) + (due date - processing time + starting time)
# starting time = lastest completion time + waiting time + processing time


# phase 2
function find_vehicle_position(vehicle, coor)
    num_vehicle = vehicle["num_vehicle"]
    vehicle1 = []
    vehicle2 = []
    for i in 1:num_vehicle
        find1 = findall(x -> x == coor[1], vehicle[i]["sch"])
        find2 = findall(x -> x == coor[2], vehicle[i]["sch"])
        if isempty(find1) == false && coor[1] != coor[2] && isempty(find2) == false
            vehicle1 = [i, find1[1]]
            vehicle2 = [i, find2[1]]
        elseif isempty(find1) == false
            vehicle1 = [i, find1[1]]
        elseif isempty(find2) == false
            vehicle2 = [i, find2[1]]
        end
    end
    # return (vehicle number, position)
    return vehicle1, vehicle2
end


function distance_solomon_all(vehicle::Dict, name::AbstractString)
    distance = 0
    for i in 1:vehicle["num_vehicle"]
        if isempty(vehicle[i]["sch"]) == false
            distance += distance_solomon(vehicle[i]["sch"], name, sort=false)
        end
    end
    return distance
end


function distance_solomon_all(vehicle::Dict)
    return distance_solomon_all(vehicle, vehicle["name"])
end


function total_distance(vehicle::Dict)
    return distance_solomon_all(vehicle, vehicle["name"])
end
    

function reper_vehicle(vehicle::Dict, per::Array)
    for i in 1:vehicle["num_vehicle"]
        vehicle[i]["sch"] = per[vehicle[i]["sch"]]
    end
    return vehicle
end


# function swap_all_no_update(vehicle::Dict, name::String; alg=nothing::Int, phase=2, phase_2=nothing, iteration=nothing, type=nothing, disp=true, to_txt=false, sort_function=sort_processing_matrix::Function)
#     # load data (must be unsort)
#     solomon = read_Solomon()
#     data = benchmark()
    
#     p, d, low_d, demand = load_solomon(name)
#     solomon_demand = solomon_capacity(name)
#     original_dis = distance_solomon_all(vehicle, name)
#     # find sort coordinate 
#     sort_coor = sort_function(vehicle)

#     for coor in sort_coor
#         position1, position2 = find_vehicle_position(vehicle, coor)

#         # this fix the case when job not process in any vehicle
#         if isempty(position1)
#             continue
#         end

#         if isempty(position2)
#             # means min occure when processed in at the first position
#             # println("coor: $(coor), position1: $(position1)")
#             if position1[2] != 1 # the job is not in the first position
#                 first_position_job = [vehicle[i]["sch"][1] for i in 1:vehicle["num_vehicle"]]
#                 for (i, position) in enumerate(first_position_job)
#                     distance_before_swap = distance_solomon_all(vehicle, name)

#                     ### swap to the first job position
#                     swap_between_vehicle(vehicle, [i, 1], position1)
#                     distance_after_swap_first = distance_solomon_all(vehicle, name)
                    
#                     # the first swap sch
#                     new_sch1 = deepcopy(vehicle[i]["sch"])
#                     new_sch2 = deepcopy(vehicle[position1[1]]["sch"])
                    
#                     ### swap to the last job position
#                     swap_between_vehicle(vehicle, [i, 1], position1) ## need to swap back before swap to the end position
#                     the_end_position = length(vehicle[i]["sch"])
#                     swap_between_vehicle(vehicle, [i, the_end_position], position1)
#                     distance_after_swap_end = distance_solomon_all(vehicle, name)
                    
#                     # the second swap sch
#                     new_sch3 = deepcopy(vehicle[i]["sch"])
#                     new_sch4 = deepcopy(vehicle[position1[1]]["sch"])
                    
#                     # swap back
#                     swap_between_vehicle(vehicle, [i, the_end_position], position1)

                    
#                     late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
#                     late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
#                     late3, latest_comp3, meet3 = job_late(new_sch3, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
#                     late4, latest_comp4, meet4 = job_late(new_sch4, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    
#                     if distance_before_swap <= distance_after_swap_first && distance_before_swap <= distance_after_swap_end
#                         # swap back to original schedule
#                         continue
#                     elseif distance_before_swap > distance_after_swap_first && distance_before_swap > distance_after_swap_end
#                         # this is the case distance reduced
#                         if sum(late1) == 0 && sum(late2) == 0 && sum(late3) == 0 && sum(late4) == 0 && meet1 && meet2 && meet3 && meet4
#                             # print_vehicle(vehicle, name)
#                             # if all schedule are not late
#                             if distance_after_swap_first <= distance_after_swap_end ## choose first position
#                                 swap_between_vehicle(vehicle, [i, 1], position1)
#                                 # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (first)      $(@sprintf("%.2f", distance_after_swap_first)), ::Solomon: $(solomon[name]["Distance"])")
#                             else ## choose last position
#                                 swap_between_vehicle(vehicle, [i, the_end_position], position1)
#                                 # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (end)        $(@sprintf("%.2f", distance_after_swap_end)), ::Solomon: $(solomon[name]["Distance"])")
#                             end
#                             break
#                         end
#                     elseif distance_before_swap > distance_after_swap_first && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
#                         swap_between_vehicle(vehicle, [i, 1], position1)
#                         # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (first only) $(@sprintf("%.2f", distance_after_swap_first)), ::Solomon: $(solomon[name]["Distance"])")
#                         # println("swap in vehicle $i and $(position1[1])")
#                         # println("sum late1 = $(sum(late1))")
#                         # println("sum late2 = $(sum(late2))")
#                         # late, comp = job_late(vehicle[i]["sch"], p=p, d=d, low_d=low_d)
#                         # println("late in vehicle $i = $(sum(late))")
#                         # print_vehicle(vehicle, name)
#                         break
#                     elseif distance_before_swap > distance_after_swap_end && sum(late3) == 0 && sum(late4) == 0 && meet3 && meet4
#                         swap_between_vehicle(vehicle, [i, the_end_position], position1)
#                         # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (end only)   $(@sprintf("%.2f", distance_after_swap_end)), ::Solomon: $(solomon[name]["Distance"])")
#                         break
#                     end
#                 end
#             end
#         else
#             # there are the cases that position is in the begining or the last
#             the_last_position = position1[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
#             # the_first_position = vehicle[position2[1]]["sch"][1]
#             the_first_position = position2[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
#             num_first_vehicle = length(vehicle[position1[1]]["sch"])
#             num_second_vehicle = length(vehicle[position2[1]]["sch"])
#             if the_last_position != num_first_vehicle && the_first_position != num_second_vehicle
#                 position1_new = deepcopy(position1)
#                 position1_new[2] = position1_new[2] + 1 

#                 distance_before_swap = distance_solomon_all(vehicle, name)
                
#                 swap_between_vehicle(vehicle, position1_new, position2)
                
#                 distance_after_swap = distance_solomon_all(vehicle, name)

#                 new_sch1 = deepcopy(vehicle[position1_new[1]]["sch"])
#                 new_sch2 = deepcopy(vehicle[position2[1]]["sch"])
                
#                 swap_between_vehicle(vehicle, position1_new, position2)
                
#                 late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
#                 late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                
#                 if distance_before_swap > distance_after_swap && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
#                     swap_between_vehicle(vehicle, position1_new, position2)
#                     # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (not first or last) $(@sprintf("%.2f", distance_after_swap)), ::Solomon: $(solomon[name]["Distance"])")
#                 end
#             end
#         end
#     end
#     dis_final = distance_solomon_all(vehicle, name)
#     if disp == true
#         println("Problem: $name reduce from $(@sprintf("%.2f", original_dis)) to $(@sprintf("%.2f", dis_final)) which is $(@sprintf("%.2f", (original_dis-dis_final)/original_dis*100))%  diff: $(@sprintf("%.2f", dis_final-solomon[name]["Distance"]))")
#     end

#     # export to txt
#     if to_txt
#         save_to_txt(vehicle, "phase$(phase)/$(sort_function)", alg=alg, phase=phase, phase_2=phase_2, type=type)
#     end
#     return original_dis, dis_final, vehicle
# end


function swap_all(vehicle::Dict, name::String; alg=nothing::Int, phase=2, phase_2=nothing, iteration=nothing, type=nothing, disp=true, to_txt=false, sort_function=sort_processing_matrix::Function, distance_function=nothing::Function)
    # load data (must be unsort)
    solomon = read_Solomon()
    data = benchmark()

    if isnothing(distance_function)
        distance_function = distance_solomon_all
    else
        distance_function = total_completion_time
    end
    
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    original_dis = distance_functi(vehicle, name)

    # find sort coordinate 
    considered = []
    sort_coor = sort_function(vehicle)
    n = length(sort_coor)
    iter = 1

    while isempty(sort_coor) == false && iter <= n

        iter += 1

        sort_coor = sort_function(vehicle)
        setdiff!(sort_coor, considered)

        coor = sort_coor[1]
        append!(considered, [coor])

        position1, position2 = find_vehicle_position(vehicle, coor)

        # this fix the case when job not process in any vehicle
        if isempty(position1)
            continue
        end

        if isempty(position2)
            # means min occure when processed in at the first position
            # println("coor: $(coor), position1: $(position1)")
            if position1[2] != 1 # the job is not in the first position
                first_position_job = [vehicle[i]["sch"][1] for i in 1:vehicle["num_vehicle"]]
                for (i, position) in enumerate(first_position_job)
                    distance_before_swap = distance_functi(vehicle, name)

                    ### swap to the first job position
                    swap_between_vehicle(vehicle, [i, 1], position1)
                    distance_after_swap_first = distance_functi(vehicle, name)
                    
                    # the first swap sch
                    new_sch1 = deepcopy(vehicle[i]["sch"])
                    new_sch2 = deepcopy(vehicle[position1[1]]["sch"])
                    
                    ### swap to the last job position
                    swap_between_vehicle(vehicle, [i, 1], position1) ## need to swap back before swap to the end position
                    the_end_position = length(vehicle[i]["sch"])
                    swap_between_vehicle(vehicle, [i, the_end_position], position1)
                    distance_after_swap_end = distance_functi(vehicle, name)
                    
                    # the second swap sch
                    new_sch3 = deepcopy(vehicle[i]["sch"])
                    new_sch4 = deepcopy(vehicle[position1[1]]["sch"])
                    
                    # swap back
                    swap_between_vehicle(vehicle, [i, the_end_position], position1)

                    
                    late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late3, latest_comp3, meet3 = job_late(new_sch3, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late4, latest_comp4, meet4 = job_late(new_sch4, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    
                    if distance_before_swap <= distance_after_swap_first && distance_before_swap <= distance_after_swap_end
                        # swap back to original schedule
                        continue
                    elseif distance_before_swap > distance_after_swap_first && distance_before_swap > distance_after_swap_end
                        # this is the case distance reduced
                        if sum(late1) == 0 && sum(late2) == 0 && sum(late3) == 0 && sum(late4) == 0 && meet1 && meet2 && meet3 && meet4
                            # print_vehicle(vehicle, name)
                            # if all schedule are not late
                            if distance_after_swap_first <= distance_after_swap_end ## choose first position
                                swap_between_vehicle(vehicle, [i, 1], position1)
                                # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (first)      $(@sprintf("%.2f", distance_after_swap_first)), ::Solomon: $(solomon[name]["Distance"])")
                            else ## choose last position
                                swap_between_vehicle(vehicle, [i, the_end_position], position1)
                                # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (end)        $(@sprintf("%.2f", distance_after_swap_end)), ::Solomon: $(solomon[name]["Distance"])")
                            end
                            break
                        end
                    elseif distance_before_swap > distance_after_swap_first && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
                        swap_between_vehicle(vehicle, [i, 1], position1)
                        # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (first only) $(@sprintf("%.2f", distance_after_swap_first)), ::Solomon: $(solomon[name]["Distance"])")
                        # println("swap in vehicle $i and $(position1[1])")
                        # println("sum late1 = $(sum(late1))")
                        # println("sum late2 = $(sum(late2))")
                        # late, comp = job_late(vehicle[i]["sch"], p=p, d=d, low_d=low_d)
                        # println("late in vehicle $i = $(sum(late))")
                        # print_vehicle(vehicle, name)
                        break
                    elseif distance_before_swap > distance_after_swap_end && sum(late3) == 0 && sum(late4) == 0 && meet3 && meet4
                        swap_between_vehicle(vehicle, [i, the_end_position], position1)
                        # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (end only)   $(@sprintf("%.2f", distance_after_swap_end)), ::Solomon: $(solomon[name]["Distance"])")
                        break
                    end
                end
            end
        else
            # there are the cases that position is in the begining or the last
            the_last_position = position1[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
            # the_first_position = vehicle[position2[1]]["sch"][1]
            the_first_position = position2[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
            num_first_vehicle = length(vehicle[position1[1]]["sch"])
            num_second_vehicle = length(vehicle[position2[1]]["sch"])
            if the_last_position != num_first_vehicle && the_first_position != num_second_vehicle
                position1_new = deepcopy(position1)
                position1_new[2] = position1_new[2] + 1 

                distance_before_swap = distance_functi(vehicle, name)
                
                swap_between_vehicle(vehicle, position1_new, position2)
                
                distance_after_swap = distance_functi(vehicle, name)

                new_sch1 = deepcopy(vehicle[position1_new[1]]["sch"])
                new_sch2 = deepcopy(vehicle[position2[1]]["sch"])
                
                swap_between_vehicle(vehicle, position1_new, position2)
                
                late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                
                if distance_before_swap > distance_after_swap && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
                    swap_between_vehicle(vehicle, position1_new, position2)
                    # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (not first or last) $(@sprintf("%.2f", distance_after_swap)), ::Solomon: $(solomon[name]["Distance"])")
                end
            end
        end
    end
    dis_final = distance_functi(vehicle, name)
    if disp == true
        println("Problem: $name reduce from $(@sprintf("%.2f", original_dis)) to $(@sprintf("%.2f", dis_final)) which is $(@sprintf("%.2f", (original_dis - dis_final) / original_dis * 100))%  diff: $(@sprintf("%.2f", dis_final - solomon[name]["Distance"]))")
    end

    # export to txt
    if to_txt
        save_to_txt("phase$(phase)/$(sort_function)", vehicle=vehicle, alg=alg, phase=phase, phase_2=phase_2, type=type)
    end
    return original_dis, dis_final, vehicle
end


function swap_all_no_update(vehicle::Dict, name::String; alg=nothing::Int, phase=2, phase_2=nothing, iteration=nothing, type=nothing, disp=true, to_txt=false, sort_function=sort_processing_matrix::Function)
    # load data (must be unsort)
    solomon = read_Solomon()
    data = benchmark()
    
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    original_dis = distance_solomon_all(vehicle, name)

    # find sort coordinate 
    sort_coor = sort_function(vehicle)

    for coor in sort_coor
        position1, position2 = find_vehicle_position(vehicle, coor)

        # this fix the case when job not process in any vehicle
        if isempty(position1)
            continue
        end

        if isempty(position2)
            # means min occure when processed in at the first position
            # println("coor: $(coor), position1: $(position1)")
            if position1[2] != 1 # the job is not in the first position
                first_position_job = [vehicle[i]["sch"][1] for i in 1:vehicle["num_vehicle"]]
                for (i, position) in enumerate(first_position_job)
                    distance_before_swap = distance_solomon_all(vehicle, name)

                    ### swap to the first job position
                    swap_between_vehicle(vehicle, [i, 1], position1)
                    distance_after_swap_first = distance_solomon_all(vehicle, name)
                    
                    # the first swap sch
                    new_sch1 = deepcopy(vehicle[i]["sch"])
                    new_sch2 = deepcopy(vehicle[position1[1]]["sch"])
                    
                    ### swap to the last job position
                    swap_between_vehicle(vehicle, [i, 1], position1) ## need to swap back before swap to the end position
                    the_end_position = length(vehicle[i]["sch"])
                    swap_between_vehicle(vehicle, [i, the_end_position], position1)
                    distance_after_swap_end = distance_solomon_all(vehicle, name)
                    
                    # the second swap sch
                    new_sch3 = deepcopy(vehicle[i]["sch"])
                    new_sch4 = deepcopy(vehicle[position1[1]]["sch"])
                    
                    # swap back
                    swap_between_vehicle(vehicle, [i, the_end_position], position1)

                    
                    late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late3, latest_comp3, meet3 = job_late(new_sch3, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late4, latest_comp4, meet4 = job_late(new_sch4, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    
                    if distance_before_swap <= distance_after_swap_first && distance_before_swap <= distance_after_swap_end
                        # swap back to original schedule
                        continue
                    elseif distance_before_swap > distance_after_swap_first && distance_before_swap > distance_after_swap_end
                        # this is the case distance reduced
                        if sum(late1) == 0 && sum(late2) == 0 && sum(late3) == 0 && sum(late4) == 0 && meet1 && meet2 && meet3 && meet4
                            # print_vehicle(vehicle, name)
                            # if all schedule are not late
                            if distance_after_swap_first <= distance_after_swap_end ## choose first position
                                swap_between_vehicle(vehicle, [i, 1], position1)
                                # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (first)      $(@sprintf("%.2f", distance_after_swap_first)), ::Solomon: $(solomon[name]["Distance"])")
                            else ## choose last position
                                swap_between_vehicle(vehicle, [i, the_end_position], position1)
                                # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (end)        $(@sprintf("%.2f", distance_after_swap_end)), ::Solomon: $(solomon[name]["Distance"])")
                            end
                            break
                        end
                    elseif distance_before_swap > distance_after_swap_first && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
                        swap_between_vehicle(vehicle, [i, 1], position1)
                        # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (first only) $(@sprintf("%.2f", distance_after_swap_first)), ::Solomon: $(solomon[name]["Distance"])")
                        # println("swap in vehicle $i and $(position1[1])")
                        # println("sum late1 = $(sum(late1))")
                        # println("sum late2 = $(sum(late2))")
                        # late, comp = job_late(vehicle[i]["sch"], p=p, d=d, low_d=low_d)
                        # println("late in vehicle $i = $(sum(late))")
                        # print_vehicle(vehicle, name)
                        break
                    elseif distance_before_swap > distance_after_swap_end && sum(late3) == 0 && sum(late4) == 0 && meet3 && meet4
                        swap_between_vehicle(vehicle, [i, the_end_position], position1)
                        # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (end only)   $(@sprintf("%.2f", distance_after_swap_end)), ::Solomon: $(solomon[name]["Distance"])")
                        break
                    end
                end
            end
        else
            # there are the cases that position is in the begining or the last
            the_last_position = position1[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
            # the_first_position = vehicle[position2[1]]["sch"][1]
            the_first_position = position2[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
            num_first_vehicle = length(vehicle[position1[1]]["sch"])
            num_second_vehicle = length(vehicle[position2[1]]["sch"])
            if the_last_position != num_first_vehicle && the_first_position != num_second_vehicle
                position1_new = deepcopy(position1)
                position1_new[2] = position1_new[2] + 1 

                distance_before_swap = distance_solomon_all(vehicle, name)
                
                swap_between_vehicle(vehicle, position1_new, position2)
                
                distance_after_swap = distance_solomon_all(vehicle, name)

                new_sch1 = deepcopy(vehicle[position1_new[1]]["sch"])
                new_sch2 = deepcopy(vehicle[position2[1]]["sch"])
                
                swap_between_vehicle(vehicle, position1_new, position2)
                
                late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                
                if distance_before_swap > distance_after_swap && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
                    swap_between_vehicle(vehicle, position1_new, position2)
                    # println("distance reduce from $(@sprintf("%.2f", distance_before_swap)) to (not first or last) $(@sprintf("%.2f", distance_after_swap)), ::Solomon: $(solomon[name]["Distance"])")
                end
            end
        end
    end
    dis_final = distance_solomon_all(vehicle, name)
    if disp == true
        println("Problem: $name reduce from $(@sprintf("%.2f", original_dis)) to $(@sprintf("%.2f", dis_final)) which is $(@sprintf("%.2f", (original_dis - dis_final) / original_dis * 100))%  diff: $(@sprintf("%.2f", dis_final - solomon[name]["Distance"]))")
    end

    # export to txt
    if to_txt
        save_to_txt("phase$(phase)/$(sort_function)", vehicle=vehicle, alg=alg, phase=phase, phase_2=phase_2, type=type)
    end
    return original_dis, dis_final, vehicle
end


function swap_all_no_update_case_study(vehicle::Dict; disp=true, to_txt=false, sort_function=sort_processing_matrix::Function, distance_function=total_completion_time::Function)
    # load data
    case_size = vehicle["case_size"]
    num = vehicle["num"]
    p, d, low_d, demand, service, distance_matrix, solomon_demand = load_all_data("case_study", case_size=case_size, num=num)
    original_dis = distance_function(vehicle)

    # find sort coordinate 
    # num_use = Int(case_size^2/10)
    num_use = Int(case_size^2/5)
    sort_coor = sort_function(vehicle)

    i = 0

    for coor in sort_coor[1:num_use]
        i += 1
        println("case study $(case_size)-$(num) iteration: $(i)")
        position1, position2 = find_vehicle_position(vehicle, coor)

        # this fix the case when job not process in any vehicle
        if isempty(position1)
            continue
        end

        if isempty(position2)
            # means min occure when processed in at the first position
            if position1[2] != 1 # the job is not in the first position
                first_position_job = [vehicle[i]["sch"][1] for i in 1:vehicle["num_vehicle"]]
                for (i, position) in enumerate(first_position_job)
                    distance_before_swap = total_completion_time(vehicle)

                    ### swap to the first job position
                    swap_between_vehicle(vehicle, [i, 1], position1)
                    distance_after_swap_first = total_completion_time(vehicle)
                    
                    # the first swap sch
                    new_sch1 = deepcopy(vehicle[i]["sch"])
                    new_sch2 = deepcopy(vehicle[position1[1]]["sch"])
                    
                    ### swap to the last job position
                    swap_between_vehicle(vehicle, [i, 1], position1) ## need to swap back before swap to the end position
                    the_end_position = length(vehicle[i]["sch"])
                    swap_between_vehicle(vehicle, [i, the_end_position], position1)
                    distance_after_swap_end = total_completion_time(vehicle)
                    
                    # the second swap sch
                    new_sch3 = deepcopy(vehicle[i]["sch"])
                    new_sch4 = deepcopy(vehicle[position1[1]]["sch"])
                    
                    # swap back
                    swap_between_vehicle(vehicle, [i, the_end_position], position1)
                    
                    late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late3, latest_comp3, meet3 = job_late(new_sch3, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    late4, latest_comp4, meet4 = job_late(new_sch4, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                    
                    if distance_before_swap <= distance_after_swap_first && distance_before_swap <= distance_after_swap_end
                        # swap back to original schedule
                        continue
                    elseif distance_before_swap > distance_after_swap_first && distance_before_swap > distance_after_swap_end
                        # this is the case distance reduced
                        if sum(late1) == 0 && sum(late2) == 0 && sum(late3) == 0 && sum(late4) == 0 && meet1 && meet2 && meet3 && meet4
                            # if all schedule are not late
                            if distance_after_swap_first <= distance_after_swap_end ## choose first position
                                swap_between_vehicle(vehicle, [i, 1], position1)
                            else ## choose last position
                                swap_between_vehicle(vehicle, [i, the_end_position], position1)
                            end
                            break
                        end
                    elseif distance_before_swap > distance_after_swap_first && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
                        swap_between_vehicle(vehicle, [i, 1], position1)
                        break
                    elseif distance_before_swap > distance_after_swap_end && sum(late3) == 0 && sum(late4) == 0 && meet3 && meet4
                        swap_between_vehicle(vehicle, [i, the_end_position], position1)
                        break
                    end
                end
            end
        else
            # there are the cases that position is in the begining or the last
            the_last_position = position1[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
            the_first_position = position2[2] # vehicle[position1[1]]["sch"][end] # we don't want position1 at the last position
            num_first_vehicle = length(vehicle[position1[1]]["sch"])
            num_second_vehicle = length(vehicle[position2[1]]["sch"])
            if the_last_position != num_first_vehicle && the_first_position != num_second_vehicle
                position1_new = deepcopy(position1)
                position1_new[2] = position1_new[2] + 1 

                distance_before_swap = total_completion_time(vehicle)
                
                swap_between_vehicle(vehicle, position1_new, position2)
                
                distance_after_swap = total_completion_time(vehicle)

                new_sch1 = deepcopy(vehicle[position1_new[1]]["sch"])
                new_sch2 = deepcopy(vehicle[position2[1]]["sch"])
                
                swap_between_vehicle(vehicle, position1_new, position2)
                
                late1, latest_comp1, meet1 = job_late(new_sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, latest_comp2, meet2 = job_late(new_sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                
                if distance_before_swap > distance_after_swap && sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
                    swap_between_vehicle(vehicle, position1_new, position2)
                end
            end
        end
        if to_txt
            dir = "case_study_solutions/phase2_all_iterations/casestudy$(case_size)-$(num)-$(distance_function)_clustering_swap-iter$(i).txt"
            io = open(dir, "w")
            for i in 1:vehicle["num_vehicle"]
                for j in vehicle[i]["sch"]
                    write(io, "$j ")
                end
                write(io, "\n")
            end
            close(io)
        end
    end
    dis_final = distance_function(vehicle)

    # export to txt
    if to_txt == true
        dirr = "case_study_solutions/casestudy$(case_size)-$(num)-$(distance_function)_clustering_swap.txt"
        io = open(dirr, "w")
        for i in 1:vehicle["num_vehicle"]
            for j in vehicle[i]["sch"]
                write(io, "$j ")
            end
            write(io, "\n")
        end
        close(io)
    end
    return original_dis, dis_final, vehicle
end


function move_job(vehicle::Dict; disp=true, sort_function=sort_processing_matrix::Function, distance_function=nothing::Function)
    name = vehicle["name"]  
    num_vehicle = vehicle["num_vehicle"]
    solomon = read_Solomon()
    data = benchmark()

    if isnothing(distance_function)
        distance_function = distance_solomon_all
    end

    p, d, low_d, demand, solomon_demand = load_all_data(name)

    original_dis = distance_function(vehicle, name)

    # # find sort coordinate 
    # sort_coor = sort_function(vehicle)  

    # save
    best_dis = vehicle["TotalDistance"]
    best_vehicle = deepcopy(vehicle)



    considered = []
    sort_coor = sort_function(vehicle)
    n = length(sort_coor)
    iter = 1

    while isempty(sort_coor) == false && iter <= n

        # println("iter: $iter")

        iter += 1

        sort_coor = sort_function(vehicle)
        setdiff!(sort_coor, considered)

        coor = sort_coor[1]
        append!(considered, [coor])

        position1, position2 = find_vehicle_position(vehicle, coor)

    # for coor in sort_coor
        
        current_vehicle = deepcopy(best_vehicle)
        position1, position2 = find_vehicle_position(current_vehicle, coor)
        if isempty(position2)
            
            # add job in first position
            for i in 1:num_vehicle
                
                new_vehicle = deepcopy(current_vehicle)
                job_out = splice!(new_vehicle[position1[1]]["sch"], position1[2])
                insert!(new_vehicle[i]["sch"], 1, job_out)
                
                # check distance
                late1, comp1, meet_demand1 = job_late(new_vehicle[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, comp2, meet_demand2 = job_late(new_vehicle[i]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                new_dis = distance_solomon_all(new_vehicle, name)
                
                if best_dis > new_dis && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                    best_dis = deepcopy(new_dis)
                    best_vehicle = deepcopy(new_vehicle)
                    # println("(first) best dis: $best_dis")
                    # println("best dis: $best_dis -> new dis: $new_dis")
                end
            end
            
            # add job in last position
            for i in 1:num_vehicle
                
                new_vehicle = deepcopy(current_vehicle)
                job_out = splice!(new_vehicle[position1[1]]["sch"], position1[2])
                push!(new_vehicle[i]["sch"], job_out)
                
                # check distance
                new_dis = distance_solomon_all(new_vehicle, name)
                late1, comp1, meet_demand1 = job_late(new_vehicle[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, comp2, meet_demand2 = job_late(new_vehicle[i]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                
                if best_dis > new_dis && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                    best_dis = deepcopy(new_dis)
                    best_vehicle = deepcopy(new_vehicle)
                    # println("(last) best dis: $best_dis")
                    # println("best dis: $best_dis -> new dis: $new_dis")
                end
            end
        else
            
            new_vehicle = deepcopy(current_vehicle)
            position1, position2 = find_vehicle_position(new_vehicle, coor)
            job_in = coor[2]
            if position1[1] == position2[1]
                if position1[2] < position2[2]
                    splice!(new_vehicle[position2[1]]["sch"], position2[2])
                    insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                else
                    insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                    splice!(new_vehicle[position2[1]]["sch"], position2[2])
                end
            else
                insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                splice!(new_vehicle[position2[1]]["sch"], position2[2])
            end

            
            # check distance
            new_dis = distance_solomon_all(new_vehicle, name)
            late1, comp1, meet_demand1 = job_late(new_vehicle[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            late2, comp2, meet_demand2 = job_late(new_vehicle[position2[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            
            if best_dis > new_dis && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                # println("(late1late2) new dis: $(new_dis), best dis: $best_dis best vehicle == new_vehicle: $(best_vehicle == new_vehicle)")
                best_vehicle = deepcopy(new_vehicle)
                best_dis = deepcopy(new_dis)
                # println("best dis: $best_dis -> new dis: $new_dis")
            end
        end
    end
    solomon = read_Solomon()
    solomon = solomon[name]
    # println("best vehicle total distance: $(distance_solomon_all(best_vehicle, best_vehicle["name"]))")
    if disp
        println("Name: $name, original dis: $original_dis, best_dis = $(best_dis)($(solomon["Distance"])), diff: $(best_dis - solomon["Distance"])")
    end
    return best_vehicle
end


function move_job_no_update(vehicle::Dict; sort_function=sort_processing_matrix::Function, distance_function=nothing)

    name = vehicle["name"]  
    num_vehicle = vehicle["num_vehicle"]
    solomon = read_Solomon()
    data = benchmark()

    p, d, low_d, demand, solomon_demand = load_all_data(name)

    original_dis = distance_function(vehicle, name)
    # find sort coordinate 
    sort_coor = sort_function(vehicle)

    # save
    best_dis = distance_function(vehicle, name)
    best_vehicle = deepcopy(vehicle)

    for coor in sort_coor
        
        current_vehicle = deepcopy(best_vehicle)
        position1, position2 = find_vehicle_position(current_vehicle, coor)
        if isempty(position2)
            
            # add job in first position
            for i in 1:num_vehicle
                
                new_vehicle_first = deepcopy(current_vehicle)
                new_vehicle_last = deepcopy(current_vehicle)
                job_out = splice!(new_vehicle_first[position1[1]]["sch"], position1[2])
                job_out = splice!(new_vehicle_last[position1[1]]["sch"], position1[2])
                # add to first position
                insert!(new_vehicle_first[i]["sch"], 1, job_out)
                # add to last position
                push!(new_vehicle_last[i]["sch"], job_out)
                
                # check distance
                late1, comp1, meet_demand1 = job_late(new_vehicle_first[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, comp2, meet_demand2 = job_late(new_vehicle_first[i]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                new_dis_first = distance_function(new_vehicle_first, name)
                
                late3, comp3, meet_demand3 = job_late(new_vehicle_last[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late4, comp4, meet_demand4 = job_late(new_vehicle_last[i]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                new_dis_last = distance_function(new_vehicle_last, name)

                if best_dis >= new_dis_first && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2 && best_dis >= new_dis_last && sum(late3) == 0 && sum(late4) == 0 && meet_demand3 && meet_demand4
                    if new_dis_first <= new_dis_last
                        best_dis = deepcopy(new_dis_first)
                        best_vehicle = deepcopy(new_vehicle_first)
                    else
                        best_dis = deepcopy(new_dis_last)
                        best_vehicle = deepcopy(new_vehicle_last)
                    end
                elseif best_dis >= new_dis_first && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                    best_dis = deepcopy(new_dis_first)
                    best_vehicle = deepcopy(new_vehicle_first)
                elseif best_dis >= new_dis_last && sum(late3) == 0 && sum(late4) == 0 && meet_demand3 && meet_demand4
                    best_dis = deepcopy(new_dis_last)
                    best_vehicle = deepcopy(new_vehicle_last)
                end
            end
            
        else
            
            new_vehicle = deepcopy(current_vehicle)
            position1, position2 = find_vehicle_position(new_vehicle, coor)
            job_in = coor[2]
            if position1[1] == position2[1]
                if position1[2] < position2[2]
                    splice!(new_vehicle[position2[1]]["sch"], position2[2])
                    insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                else
                    insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                    splice!(new_vehicle[position2[1]]["sch"], position2[2])
                end
            else
                insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                splice!(new_vehicle[position2[1]]["sch"], position2[2])
            end

            
            # check distance
            new_dis = distance_function(new_vehicle, name)
            late1, comp1, meet_demand1 = job_late(new_vehicle[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            late2, comp2, meet_demand2 = job_late(new_vehicle[position2[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            
            if best_dis >= new_dis && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                best_vehicle = deepcopy(new_vehicle)
                best_dis = deepcopy(new_dis)
                # println("best dis: $best_dis -> new dis: $new_dis")
            end
        end
    end
    solomon = read_Solomon()
    solomon = solomon[name]
    if isnothing(distance_function)
        solomon_dis = solomon["Distance"]
    else
        try 
            vehicle_benchmark = read_txt2(name, dir="solutions_benchmark")
            solomon_dis = distance_solomon_all(vehicle_benchmark, name)
        catch e
            solomon_dis = solomon["Distance"]
        end
    end

    println("Name: $name, original dis: $original_dis, best_dis = $(best_dis)($(solomon_dis)), diff: $(best_dis - solomon_dis)")

    return best_vehicle
end


function move_job_no_update_case_study(vehicle::Dict; sort_function=sort_processing_matrix::Function, distance_function=total_completion_time::Function, to_txt=false::Bool, disp=true::Bool)

    name = vehicle["name"]
    case_size = vehicle["case_size"]
    num_vehicle = vehicle["num_vehicle"]
    num = vehicle["num"]

    p, d, low_d, demand, service, distance_matrix, solomon_demand = load_all_data("case_study", case_size=case_size, num=num)

    original_dis = distance_function(vehicle)

    # find sort coordinate 
    sort_coor = sort_function(vehicle)

    # save
    best_dis = distance_function(vehicle)
    best_vehicle = deepcopy(vehicle)

    # stop criterier
    num_use = Int(case_size^2/5)

    for (i, coor) in enumerate(sort_coor[1:num_use])
        
        current_vehicle = deepcopy(best_vehicle)
        position1, position2 = find_vehicle_position(current_vehicle, coor)
        if isempty(position2)
            
            # add job in first position
            for i in 1:num_vehicle
                
                new_vehicle_first = deepcopy(current_vehicle)
                new_vehicle_last = deepcopy(current_vehicle)
                job_out = splice!(new_vehicle_first[position1[1]]["sch"], position1[2])
                job_out = splice!(new_vehicle_last[position1[1]]["sch"], position1[2])
                # add to first position
                insert!(new_vehicle_first[i]["sch"], 1, job_out)
                # add to last position
                push!(new_vehicle_last[i]["sch"], job_out)
                
                # check distance
                late1, comp1, meet_demand1 = job_late(new_vehicle_first[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late2, comp2, meet_demand2 = job_late(new_vehicle_first[i]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                new_dis_first = distance_function(new_vehicle_first)
                
                late3, comp3, meet_demand3 = job_late(new_vehicle_last[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                late4, comp4, meet_demand4 = job_late(new_vehicle_last[i]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
                new_dis_last = distance_function(new_vehicle_last)

                if best_dis >= new_dis_first && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2 && best_dis >= new_dis_last && sum(late3) == 0 && sum(late4) == 0 && meet_demand3 && meet_demand4
                    if new_dis_first <= new_dis_last
                        best_dis = deepcopy(new_dis_first)
                        best_vehicle = deepcopy(new_vehicle_first)
                    else
                        best_dis = deepcopy(new_dis_last)
                        best_vehicle = deepcopy(new_vehicle_last)
                    end
                elseif best_dis >= new_dis_first && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                    best_dis = deepcopy(new_dis_first)
                    best_vehicle = deepcopy(new_vehicle_first)
                elseif best_dis >= new_dis_last && sum(late3) == 0 && sum(late4) == 0 && meet_demand3 && meet_demand4
                    best_dis = deepcopy(new_dis_last)
                    best_vehicle = deepcopy(new_vehicle_last)
                end
            end
            
        else
            
            new_vehicle = deepcopy(current_vehicle)
            position1, position2 = find_vehicle_position(new_vehicle, coor)
            job_in = coor[2]
            if position1[1] == position2[1]
                if position1[2] < position2[2]
                    splice!(new_vehicle[position2[1]]["sch"], position2[2])
                    insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                else
                    insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                    splice!(new_vehicle[position2[1]]["sch"], position2[2])
                end
            else
                insert!(new_vehicle[position1[1]]["sch"], position1[2] + 1, job_in)
                splice!(new_vehicle[position2[1]]["sch"], position2[2])
            end

            
            # check distance
            new_dis = distance_function(new_vehicle)
            late1, comp1, meet_demand1 = job_late(new_vehicle[position1[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            late2, comp2, meet_demand2 = job_late(new_vehicle[position2[1]]["sch"], p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            
            if best_dis >= new_dis && sum(late1) == 0 && sum(late2) == 0 && meet_demand1 && meet_demand2
                best_vehicle = deepcopy(new_vehicle)
                best_dis = deepcopy(new_dis)
            end
        end

        # print information
        if disp
            println("iteration $i, $(distance_function): $(best_dis)")
        end

        # export to txt
        if to_txt
            dirr = "case_study_solutions/casestudy$(case_size)-$(num)_clustering_move.txt"
            io = open(dirr, "w")
            for i in 1:vehicle["num_vehicle"]
                for j in vehicle[i]["sch"]
                    write(io, "$j ")
                end
                write(io, "\n")
            end
            close(io)
        end
    end
    return best_vehicle
end


function phase5(name::AbstractString; alg=10, phase=1, type=nothing, phase_2=1, iteration=1, to_txt=false, sort_function=sort_processing_matrix::Function, pre_dir=nothing)

    vehicle = read_txt2(name, alg=alg)
    original_dis = distance_solomon_all(vehicle, name)
    vehicle = move_job(vehicle, sort_function=sort_function)
    final_dis = distance_solomon_all(vehicle, name)

    while original_dis != final_dis
        original_dis = deepcopy(final_dis)
        vehicle = move_job(vehicle, sort_function=sort_function)
        final_dis = distance_solomon_all(vehicle, name)
    end

    # save to txt
    if to_txt
        save_to_txt(vehicle, alg=alg, phase_2="move_all-$(sort_function)", pre_dir=pre_dir)
    end

    return vehicle
end


function phase5_no_update(name::AbstractString; alg=10, phase=1, type=nothing, phase_2=1, iteration=1, to_txt=false, sort_function=sort_processing_matrix::Function, distance_function=nothing, pre_dir=nothing)

    if isnothing(distance_function)
        distance_function = distance_solomon_all
    end

    vehicle = read_txt2(name, alg=alg)
    original_dis = distance_function(vehicle, name)
    vehicle = move_job_no_update(vehicle, sort_function=sort_function, distance_function=distance_function)
    final_dis = distance_function(vehicle, name)

    while original_dis != final_dis
        original_dis = deepcopy(final_dis)
        vehicle = move_job_no_update(vehicle, sort_function=sort_function, distance_function=distance_function)
        final_dis = distance_function(vehicle, name)
    end

    # save to txt
    if to_txt
        save_to_txt(vehicle, alg=alg, phase_2="move_all_no_update-$(sort_function)", pre_dir=pre_dir)
    end
    return vehicle
end


# for printing information of vehicle
function print_vehicle(vehicle::Dict, name::String)
    xcoor = solomon100[name]["xcoor"]
    ycoor = solomon100[name]["ycoor"]
    p = ProcessingTimeMatrix(xcoor, ycoor, name)
    d = solomon100[name]["duedate"]
    d = [d[i] for i in 1:length(d) - 1]
    low_d = solomon100[name]["readytime"]
    low_d = [low_d[i] for i in 1:length(low_d) - 1]
    
    for i in 1:vehicle["num_vehicle"]
        late, comp = job_late(vehicle[i]["sch"], p=p, d=d, low_d=low_d)
        println("vehicle $i: late: $(sum(late))")
    end
end


function clustering_job(result, all_job, num_vehicle)
    cluster = Dict()
    for i in 1:num_vehicle
        cluster_assignment = findall(x -> x == i, result.assignments)
        cluster[i] = all_job[cluster_assignment]
    end
    return cluster
end


function hclustering_job(z, all_job, num_vehicle)
    cluster = Dict()
    for i in 1:num_vehicle
        cluster_assignment = findall(x -> x == i, z)
        cluster[i] = all_job[cluster_assignment]
    end
    return cluster
end


function kmeans_multiple(feature, num_cluster, iteration)
    result = kmeans(feature, num_cluster)
    for i in 1:iteration - 1
        current_result = kmeans(feature, num_cluster)
        if current_result.totalcost < result.totalcost
            result = current_result
        end
    end
    return result
end


function clustering(name::AbstractString, num_vehicle::Int; Alg=heuristic::Function)
    # load data 
    solomon = read_Solomon()
    data = benchmark()
    xcoor = solomon100[name]["xcoor"]
    ycoor = solomon100[name]["ycoor"]
    p, d, low_d, demand, solomon_demand = load_all_data(name)

    # create feature matrix from xcoor and ycoor
    num_jobs = solomon100[name]["num_jobs"]
    xcoor = [xcoor[i] for i in 0:num_jobs]
	ycoor = [ycoor[i] for i in 0:num_jobs]
    feature = hcat(xcoor, ycoor)'
    feature = feature[:, 2:end] # cut off origin node

    # clustering
    result = kmeans_multiple(feature, num_vehicle, 150)

    # assignments
    all_job = [i for i in 1:length(d)]
    cluster = clustering_job(result, all_job, num_vehicle)

    # find route for each cluster
    sch_out = []
    vehicle = Dict()
    can_schedule = false
    i = 1
    cluster_i = 1
    while i <= num_vehicle
        # println("vehicle: $i")
        if String(Symbol(Alg)) == "heuristic"
            (sch, sch_out) = Alg(p=p, d=d, all_job=cluster[cluster_i], sch=[], full=false, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        elseif String(Symbol(Alg)) == "heuristic_diff"
            (sch, sch_out) = Alg(all_job, p, d, low_d, demand, solomon_demand, version=1)
        end
        setdiff!(all_job, sch)
        if isempty(sch_out) && isempty(sch)
            remain_feature = feature[:, all_job]
            result = kmeans_multiple(remain_feature, num_vehicle - i, 150)
            # println("total cost: $(result.totalcost)")
            cluster = clustering_job(result, all_job, num_vehicle - i)
        elseif isempty(sch_out)
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            i += 1
            cluster_i += 1
        elseif num_vehicle == i
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            break
        else
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            remain_feature = feature[:, all_job]
            result = kmeans_multiple(remain_feature, num_vehicle - i, 150)
            # println("total cost: $(result.totalcost)")
            cluster = clustering_job(result, all_job, num_vehicle - i)
            i += 1
            cluster_i = 1
        end
    end
    if isempty(all_job)
        can_schedule = true
    end

    # use try to fix the case when we don't have benchmark data
    try 
        println("Problem: $name, number of vehicle: $num_vehicle($(solomon[name]["NV"])), can schedule: $can_schedule")
    catch e
        println("Problem: $name, number of vehicle: $num_vehicle, can schedule: $can_schedule")
    end

    # add parameters
    vehicle["name"] = "case_study"
    vehicle["num_vehicle"] = num_jobs

    return vehicle, can_schedule
end


function clustering_case_study(p, d, low_d, demand, service, distance_matrix, solomon_demand, num_vehicle::Int; Alg=heuristic::Function)
    # load data 
    # solomon = read_Solomon()
    # data = benchmark()
    # xcoor = solomon100[name]["xcoor"]
    # ycoor = solomon100[name]["ycoor"]

    # create feature matrix from xcoor and ycoor
    num_jobs = size(p, 1)
    # xcoor = [xcoor[i] for i in 0:num_jobs]
	# ycoor = [ycoor[i] for i in 0:num_jobs]
    # feature = hcat(xcoor, ycoor)'
    feature = distance_matrix[2:end, 2:end] # cut off origin node
    # clustering
    result = kmeans_multiple(feature, num_vehicle, 150)

    # assignments
    all_job = [i for i in 1:length(d)]
    cluster = clustering_job(result, all_job, num_vehicle)

    # find route for each cluster
    sch_out = []
    vehicle = Dict()
    can_schedule = false
    i = 1
    cluster_i = 1
    while i <= num_vehicle
        # println("vehicle: $i")
        if String(Symbol(Alg)) == "heuristic"
            (sch, sch_out) = Alg(p=p, d=d, all_job=cluster[cluster_i], sch=[], full=false, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        elseif String(Symbol(Alg)) == "heuristic_diff"
            (sch, sch_out) = Alg(all_job, p, d, low_d, demand, solomon_demand, version=1)
        end
        setdiff!(all_job, sch)
        if isempty(sch_out) && isempty(sch)
            remain_feature = feature[all_job, all_job]
            result = kmeans_multiple(remain_feature, num_vehicle - i, 150)
            # println("total cost: $(result.totalcost)")
            cluster = clustering_job(result, all_job, num_vehicle - i)
        elseif isempty(sch_out)
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            i += 1
            cluster_i += 1
        elseif num_vehicle == i
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            break
        else
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            remain_feature = feature[all_job, all_job]
            result = kmeans_multiple(remain_feature, num_vehicle - i, 150)
            # println("total cost: $(result.totalcost)")
            cluster = clustering_job(result, all_job, num_vehicle - i)
            i += 1
            cluster_i = 1
        end
    end
    if isempty(all_job)
        can_schedule = true
    end

    # use try to fix the case when we don't have benchmark data
    println("Problem: case study, number of vehicle: $num_vehicle, can schedule: $can_schedule")

    # add parameters
    vehicle["name"] = "case_study"
    vehicle["num_vehicle"] = num_jobs

    return vehicle, can_schedule
end


# main of clustering
function clustering(name::AbstractString;
                 f=clustering::Function, 
                 Alg=heuristic::Function, 
                 to_txt=true, 
                 distance_function=total_completion_time::Function, 
                 case_study_size=200, 
                 case_study_num=1)

    if name != "case_study"
        solomon = read_Solomon()
    else
        p, d, low_d, demand, service, distance_matrix, solomon_demand = import_case_study(case_study_size, case_study_num)
    end

    global can_schedule = false
    global num_vehicle = 1
    global vehicle = Dict()

    vehicle = Dict()

    while can_schedule == false

        if name == "case_study"
            vehicle, can_schedule = clustering_case_study(p, d, low_d, demand, service, distance_matrix, solomon_demand, num_vehicle, Alg=Alg)
        else
            vehicle, can_schedule = clustering(name, num_vehicle, Alg=Alg)
        end
        num_vehicle += 1
    end
    # for calculate distance
    vehicle["num_vehicle"] = num_vehicle - 1

    # print distance
    if name == "case_study"
        vehicle["case_size"] = case_study_size
        vehicle["num"] = case_study_num
        println("total completion time: $(total_completion_time(vehicle))")
    else
        println("distance(solomon): $(distance_function(vehicle, name))($(solomon[name]["Distance"]))")
    end

    # export to txt
    vehicle["name"] = name
    num_vehicle = vehicle["num_vehicle"]
    if to_txt
        if name == "case_study"
            num_case = length(glob("*.txt", "case_study_solutions/"))
            io = open("case_study_solutions/casestudy$(case_study_size)-$(case_study_num)-$(distance_function)_clustering.txt", "w")
            for i in 1:num_vehicle
                for j in vehicle[i]["sch"]
                    write(io, "$j ")
                end
                write(io, "\n")
            end
            close(io)
        else
            save_to_txt(vehicle, alg="$(f)-$(Alg)")
        end
    end
    return vehicle
end


function hclustering(name::AbstractString, num_vehicle::Int)
    solomon = read_Solomon()
    data = benchmark()
    feature, d, low_d, demand, solomon_demand = load_all_data(name)

    # clustering
    result = hclust(feature, linkage=:single)
    z = cutree(result, k=num_vehicle)
    # assignments
    all_job = [i for i in 1:length(d)]
    cluster = hclustering_job(z, all_job, num_vehicle)

    # find route for each cluster
    sch_out = []
    vehicle = Dict()
    can_schedule = false
    i = 1
    cluster_i = 1

    while i <= num_vehicle
        # println("vehicle: $i")
        (sch, sch_out) = heuristic(p=p, d=d, all_job=cluster[cluster_i], sch=[], full=false, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        setdiff!(all_job, sch)
        if isempty(sch_out) && isempty(sch)
            remain_feature = p[all_job, all_job]
            result = hclust(remain_feature, linkage=:single)
            z = cutree(result, k=num_vehicle - i)
            # println("total cost: $(result.totalcost)")
            cluster = kclustering_job(z, all_job, num_vehicle - i)
        elseif isempty(sch_out)
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            i += 1
            cluster_i += 1
        elseif num_vehicle == i
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            break
        else
            vehicle[i] = Dict()
            vehicle[i]["sch"] = sch
            remain_feature = feature[all_job, all_job]
            result = hclust(remain_feature, linkage=:single)
            z = cutree(result, k=num_vehicle - i)
            # println("total cost: $(result.totalcost)")
            cluster = hclustering_job(z, all_job, num_vehicle - i)
            i += 1
            cluster_i = 1
        end
    end
    if isempty(all_job)
        can_schedule = true
    end
    println("Problem: $name, number of vehicle: $num_vehicle($(solomon[name]["NV"])), can schedule: $can_schedule")
    return vehicle, can_schedule
    
end

function phase4(name::AbstractString, alg::Int; version=1, max_iter=100, sort_function=sort_processing_matrix)
    # choose 1 vehicle and suffle all job, then run phase 2.
    vehicle = read_txt(name, alg=alg, phase=3)
    num_vehicle = vehicle["num_vehicle"]
    best_dis = distance_solomon_all(vehicle, name)

    origi = []
    new = []
    final = []
    
    for i in 1:100
        new_vehicle = deepcopy(vehicle)

        new_dis = distance_solomon_all(new_vehicle, name)

        if version == 1
            shuffle!(new_vehicle[rand(1:num_vehicle)]["sch"])
            original_dis, final_dis, new_vehicle = swap_all(new_vehicle, name, alg=alg, phase=4, iteration=i, disp=false, sort_function=sort_function)
        elseif version == 2
            v1 = rand(1:num_vehicle)
            v2 = rand(1:num_vehicle)
            r1 = rand(1:length(vehicle[v1]["sch"]))
            r2 = rand(1:length(vehicle[v2]["sch"]))
            position1 = [v1, r1]
            position2 = [v2, r2]
            swap_between_vehicle(vehicle, position1, position2)
        end

        append!(origi, original_dis)
        append!(new, new_dis)
        append!(final, final_dis)
        println("iter:$(@sprintf("%3d", i)), original dis: $(@sprintf("%.2f", new_dis)), rand dis: $(@sprintf("%.2f", original_dis)), final dis: $(@sprintf("%.2f", final_dis))")

        if final_dis <= new_dis
            vehicle = deepcopy(new_vehicle)
        end

    end
    return (origi, new, final)
end


function swap_after_job(vehicle::Dict, position1::Array, position2::Array)
    # input: vehicle, position of job1 and job2
    # process: swap all jobs that processed after job1 and job2
    # return vehicle

    # position1, position2 = find_vehicle_position(vehicle, coor)

    # job1 and job2 must process in different vehicle
    if position1[1] != position2[1]

        current_vehicle = deepcopy(vehicle)

        # job 1
        sch1 = current_vehicle[position1[1]]["sch"]
        num_job1 = length(sch1)

        # job 2
        sch2 = current_vehicle[position2[1]]["sch"]
        num_job2 = length(sch2)

        if num_job1 == position1[2]
            sch_left1 = sch1
            sch_right1 = []
        else
            sch_left1 = sch1[1:position1[2]]
            sch_right1 = sch1[position1[2] + 1:end]
        end

        if num_job2 == position2[2]
            sch_left2 = []
            sch_right2 = sch2
        else
            sch_left2 = sch2[1:position2[2] - 1]
            sch_right2 = sch2[position2[2]:end]
        end

        vehicle[position1[1]]["sch"] = append!(sch_left1, sch_right2)
        vehicle[position2[1]]["sch"] = append!(sch_left2, sch_right1)
    end
    return vehicle
end


function swap_all_after_job(vehicle, name)
    # load data (must be unsort)
    solomon = read_Solomon()
    data = benchmark()
    
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    original_dis = distance_solomon_all(vehicle, name)
    # find sort coordinate 
    sort_coor = sort_processing_matrix(p)

    for coor in sort_coor
        current_vehicle = deepcopy(vehicle)
        current_dis = distance_solomon_all(current_vehicle, name)
        position1, position2 = find_vehicle_position(current_vehicle, coor)
        if isempty(position2) == false
            new_vehicle = swap_after_job(current_vehicle, position1, position2)
            new_dis = distance_solomon_all(new_vehicle, name)

            sch1 = current_vehicle[position1[1]]["sch"]
            sch2 = current_vehicle[position2[1]]["sch"]

            late1, comp1, meet1 = job_late(sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            late2, comp2, meet2 = job_late(sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)

            if current_dis >= new_dis && meet1 && meet2 && sum(late1) == 0 && sum(late2) == 0
                vehicle = deepcopy(new_vehicle)
            end
        end
    end
    return vehicle
end


function phase6(name::AbstractString; alg=10, phase=1, phase_2=1, iteration=1, disp=true, to_txt=false)
    solomon = read_Solomon()
    if iteration == 1
        vehicle = read_txt(name, alg=alg, phase=phase)
    elseif itearation == 2
        vehicle = read_txt(name, alg=alg, phase=phase, phase_2=phase_2)
    end

    original_dis = distance_solomon_all(vehicle, name)
    current_dis = deepcopy(original_dis)
    vehicle = swap_all_after_job(vehicle, name)
    final_dis = distance_solomon_all(vehicle, name)
    while current_dis != final_dis
        current_dis = deepcopy(final_dis)
        vehicle = swap_all_after_job(vehicle, name)
        final_dis = distance_solomon_all(vehicle, name)
        if disp == true
            println("Problem: $name reduce from $(@sprintf("%.2f", original_dis)) to $(@sprintf("%.2f", final_dis)) which is $(@sprintf("%.2f", (original_dis - final_dis) / original_dis * 100))%  diff: $(@sprintf("%.2f", final_dis - solomon[name]["Distance"]))")
        end
    end

    # save to txt
    if to_txt
        if iteration == 1
            if typeof(phase) == Int
                if phase == 1
                    dirr = "phase6/Alg$alg-$(name).txt"
                else
                    dirr = "phase6/Alg$alg-$(name)-P-$(phase).txt"
                end
            else
                dirr = "phase6/$name-phase$(phase)-iter1.txt"
            end
        else
            if typeof(phase) == Int
                if phase == 1
                    dirr = "phase6/Alg$alg-$(name).txt"
                else
                    dirr = "phase6/Alg$alg-$(name)-P-$(phase)-iter$iteration.txt"
                end
            else
                dirr = "phase6/$name-phase$(phase)-iter$(iteration).txt"
            end
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
end


function random_swap_after_job(vehicle)

    num_vehicle = vehicle["num_vehicle"]
    
    # random 
    v1 = rand(1:num_vehicle)
    v2 = rand(1:num_vehicle)

    sch_length1 = length(vehicle[v1]["sch"])
    sch_length2 = length(vehicle[v2]["sch"])
    
    # fix when we get the same vehicle
    if v1 == v2 && sch_length1 <= 3 && sch_length2 <= 3
        while v1 == v2 || sch_length1 <= 3 || sch_length2 <= 3
            v1 = rand(1:num_vehicle)
            v2 = rand(1:num_vehicle)
            sch_length1 = length(vehicle[v1]["sch"])
            sch_length2 = length(vehicle[v2]["sch"])
        end
    end

    if sch_length1 <= 3 || sch_length2 <= 3
        sch1 = false
        sch2 = false
        can_swap = false
    else
        min_length = minimum([length(vehicle[v1]["sch"]), length(vehicle[v2]["sch"])])

        r1 = rand(2:min_length - 1)
        position1 = [v1, r1]
        position2 = [v2, r1]
        # vehicle = swap_between_vehicle(vehicle, position1, position2)
        vehicle = swap_after_job(vehicle, position1, position2)

        sch1 = vehicle[position1[1]]["sch"]
        sch2 = vehicle[position2[1]]["sch"]
        
        can_swap = true
    end

    return vehicle, sch1, sch2, can_swap
end


function phase7(name::AbstractString; alg=10, phase=1, phase_2=1, iteration=1, disp=true, sort_function=sort_processing_matrix::Function)
    
    vehicle = read_txt(name, alg=alg, phase=phase, phase_2=phase_2)
    original_dis = distance_solomon_all(vehicle, name)
    best_dis = deepcopy(original_dis)
    best_vehicle = deepcopy(vehicle)
    
    # load data (must be unsort)
    solomon = read_Solomon()
    data = benchmark()
    
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    
    for i in 1:100
        
        current_vehicle = deepcopy(vehicle)
        if disp == true
            println("iter: $i, origin dis: $original_dis, best_dis: $best_dis")
        end

        current_vehicle, sch1, sch2, can_swap = random_swap_after_job(vehicle)

        if can_swap == false
            continue
        end

        late1, comp1, meet1 = job_late(sch1, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        late2, comp2, meet2 = job_late(sch2, p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        
        if sum(late1) == 0 && sum(late2) == 0 && meet1 && meet2
            random_dis = distance_solomon_all(current_vehicle, name)
            vehicle = move_job(current_vehicle, disp=disp, sort_function=sort_function)
            final_dis = distance_solomon_all(current_vehicle, name)

            if disp == true
                println("iter: $i, origin dis: $original_dis, random dis: $random_dis, final_dis: $final_dis")
            end

            if final_dis <= best_dis
                best_dis = deepcopy(final_dis)
                vehicle = deepcopy(current_vehicle)
                best_vehicle = deepcopy(current_vehicle)
            end
        end
    end
    return vehicle, original_dis, best_dis
end


function alg_phase2_phase5(name::String; alg=10, phase=1, phase_2=1, type=nothing, sort_function=sort_processing_matrix::Function)
    # load all data
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    # load vehicle
    vehicle = read_txt(name, alg=alg, phase=phase, phase_2=phase_2, type=type)

    # check number of job
    sum_jobs = 0
    for i in 1:vehicle["num_vehicle"]
        sum_jobs += length(vehicle[i]["sch"])
    end
    println("the number of jobs: $sum_jobs")

    for i in 1:4
        println("<===iteration: $i===>")
        # run phase 2 (swap all jobs)
        original_dis, dis_final, vehicle = swap_all(vehicle, name, alg=alg, to_txt=false, disp=true, sort_function=sort_function)
        original_dis, dis_final, vehicle = swap_all(vehicle, name, alg=alg, to_txt=false, disp=true, sort_function=sort_function)

        # run phase 5 (move all jobs)
        vehicle = move_job(vehicle, disp=true, sort_function=sort_function)
        println("pass move jobs")
        vehicle = fix_missing_vehicle(vehicle)
        final_dis = distance_solomon_all(vehicle, name)

        if dis_final == final_dis
            break
        end
    end
end


function find_remaining_job(vehicle::Dict; num_of_all_job=100)
    jobs = []
    for i in 1:vehicle["num_vehicle"]
        append!(jobs, vehicle[i]["sch"])
    end

    all_jobs = [i for i in 1:num_of_all_job]

    # remaining jobs
    setdiff!(all_jobs, jobs)
    return all_jobs
end


function insert_job(vehicle::Dict; num_of_all_job=100, disp=false)

    current_vehicle = deepcopy(vehicle)
    # check number of job
    sum_jobs = 0
    for i in 1:current_vehicle["num_vehicle"]
        sum_jobs += length(current_vehicle[i]["sch"])
    end
    if disp
        println("the number of jobs: $sum_jobs")
    end
    # find remaining job in vehicle
    jobs = find_remaining_job(current_vehicle, num_of_all_job=num_of_all_job)
    
    if disp
        println("original dis: $(distance_solomon_all(current_vehicle, current_vehicle["name"]))")
    end
    
    # name
    name = current_vehicle["name"]
    
    # load all solomon data
    p, d, low_d, demand, solomon_demand = load_all_data(name)
    
    for i in 1:current_vehicle["num_vehicle"]
        con = true
        iter = 1
        while con && iter <= 100
            # println("iteration: $iter")
            
            if isempty(jobs)
                break # while loop
            end
            
            for job_in in jobs
                current_vehicle[i]["sch"], job_out = job_in_out(current_vehicle[i]["sch"], job_in; p=p, d=d, low_d=low_d, fix=false, demand=demand, solomon_demand=solomon_demand)
                if isempty(job_out)
                    # println("job out empty")
                    setdiff!(jobs, [job_in])
                elseif job_in == job_out[1]
                    continue
                else
                    # println("job in != job out")
                    setdiff!(jobs, [job_in])
                    append!(jobs, job_out)
                    break # break for loop
                end
            end
            iter += 1
        end
    end
    
    # check number of job
    sum_jobs = 0
    for i in 1:current_vehicle["num_vehicle"]
        sum_jobs += length(current_vehicle[i]["sch"])
    end
    if disp
        println("the number of jobs: $sum_jobs")
    end
    
    i = current_vehicle["num_vehicle"] + 1
    current_vehicle["num_vehicle"] += 1
    current_vehicle[i] = Dict()
    current_vehicle[i]["sch"] = Dict()

    # println("next section")
    while true
        
        # println("jobs: $jobs")
        current_vehicle[i]["sch"], sch_out = heuristic(p=p, d=d, all_job=jobs, sch=[], full=false, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
        # println("sch_out: $sch_out")
        
        new_sum_jobs = 0
        for j in 1:current_vehicle["num_vehicle"]
            new_sum_jobs += length(current_vehicle[j]["sch"])
        end

        if disp
            println("the number of jobs: $new_sum_jobs")
        end

        if isempty(sch_out)
            break
        else
            current_vehicle["num_vehicle"] += 1
            setdiff!(jobs, current_vehicle[i]["sch"])
            # append!(jobs, sch_out)
            i += 1
            current_vehicle[i] = Dict()
            current_vehicle[i]["sch"] = Dict()
        end
    end
    if disp
        println("final dis: $(distance_solomon_all(current_vehicle, current_vehicle["name"]))")
    end
    return current_vehicle
end

function compute_vehicle_information(vehicle::Dict)
    name = vehicle["name"]
    v = Dict()
    p, d, low_d, demand, solomon_demand = load_all_data(name)

    for i in 1:vehicle["num_vehicle"]
        starting, completion = StartingAndCompletion(vehicle[i]["sch"], p, low_d)
        for (j, job) in enumerate(vehicle[i]["sch"])
            v[job] = Dict()
            v[job]["starting"] = starting[j]
            v[job]["completion"] = completion[j]
            v[job]["d"] = d[job]
            v[job]["low_d"] = low_d[job]
        end
    end
    return v
end

function compute_vehicle_information(vehicle::Dict, p::Array, d::Array, low_d::Array, demand::Array, solomon_demand::Int)
    name = vehicle["name"]
    v = Dict()
    # p, d, low_d, demand, solomon_demand = load_all_data(name)

    for i in 1:vehicle["num_vehicle"]
        starting, completion = StartingAndCompletion(vehicle[i]["sch"], p, low_d)
        for (j, job) in enumerate(vehicle[i]["sch"])
            v[job] = Dict()
            v[job]["starting"] = starting[j]
            v[job]["completion"] = completion[j]
            v[job]["d"] = d[job]
            v[job]["low_d"] = low_d[job]
        end
    end
    return v
end

function pull_out(vehicle::Dict)
    name = vehicle["name"]
    # v = Dict()
    p, d, low_d, demand, solomon_demand = load_all_data(name)

    # for i in 1:vehicle["num_vehicle"]
    #     starting, completion = StartingAndCompletion(vehicle[i]["sch"], p, low_d)
    #     for (j, job) in enumerate(vehicle[i]["sch"])
    #         v[job] = Dict()
    #         v[job]["starting"] = starting[j]
    #         v[job]["completion"] = completion[j]
    #         v[job]["d"] = d[job]
    #         v[job]["low_d"] = low_d[job]
    #     end
    # end

    v = compute_vehicle_information(vehicle, p, d, low_d, demand, solomon_demand)
    
    job_out = []
    for i in 1:vehicle["num_vehicle"]
        sch = deepcopy(vehicle[i]["sch"])
        current_sch = deepcopy(sch)
        j = 1
        num_out = 0
        
        # sort d - completion time
        current_d = d[current_sch]
        current_c = [v[jj]["completion"] for jj in current_sch]
        diff = current_d - current_c
        sort_sch_perm = sortperm(diff)
        while j < length(current_sch) && num_out < 3
            current_sch = deepcopy(sch)
            
            j_out = splice!(current_sch, sort_sch_perm[j])
            late, comp, meet = job_late(current_sch; p=p, d=d, low_d=low_d, demand=demand, solomon_demand=solomon_demand)
            
            if sum(late) == 0
                current_d = d[current_sch]
    
                starting, current_c = StartingAndCompletion(current_sch, p, low_d)
    
                diff = current_d - current_c
                sort_sch_perm = sortperm(diff)
                
                append!(job_out, j_out)
                sch = deepcopy(current_sch)
                num_out += 1
                continue
            else
                j += 1
            end
        end
        vehicle[i]["sch"] = deepcopy(sch)
    end

    return vehicle, job_out
end


function sort_completion_time(vehicle::Dict; n=100)
    # output: in the form [(i, j), ...]

    # load data
    name = vehicle["name"]
    p, d, low_d, demand, solomon_demand = load_all_data(name)

    # main
    coor = []
    value = []

    for i in 1:n
        starting, completion = StartingAndCompletion([i], p, low_d)
        append!(coor, [(i, i)])
        append!(value, completion)
    end

    for job in 1:n
        position1, position2 = find_vehicle_position(vehicle, [job, job])
        sch = vehicle[position1[1]]["sch"][1:position1[2]]
        for j in setdiff(1:n, job)
            current_sch = deepcopy(sch)
            append!(coor, [(job, j)])
            append!(current_sch, j)
            starting, competion = StartingAndCompletion(current_sch, p, low_d)
            append!(value, competion[position1[2] + 1])
        end
    end

    # sort
    sort_perm_completion = sortperm(value)
    coor = coor[sort_perm_completion]
    return coor
end


function random_swap(vehicle::Dict; num_swap::Int=2)
    vehicle = fix_missing_vehicle(vehicle)
    num_vehicle = vehicle["num_vehicle"]
    vehicle_current = deepcopy(vehicle)
    for i in 1:num_swap
        # random vehicle
        random_vehicle1 = rand(1:num_vehicle)
        random_vehicle2 = rand(1:num_vehicle)

        # random job position
        position_job1 = rand(1:length(vehicle[random_vehicle1]["sch"]))
        position_job2 = rand(1:length(vehicle[random_vehicle2]["sch"]))

        # swap 2 jobs
        position1 = [random_vehicle1, position_job1]
        position2 = [random_vehicle2, position_job2]
        vehicle_current = swap_between_vehicle(vehicle_current, position1, position2)

        # println("position1: $position1")
        # println("position1: $position2")

    end
    return vehicle_current
end