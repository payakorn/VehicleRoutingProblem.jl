"""
    dataframe_opt_solomon(name_type::String)


Find the group by the number of customers (25, 50, 100) of solomon instances
"""
function dataframe_opt_solomon(name_type::String)
    location = joinpath(@__DIR__, "..", "opt_solomon", "$name_type.csv")
    df = read_csv_to_dataframe(location)
    return df
end


"""
    dataframe_group_opt_solomon(df::DataFrames)


Find the group by the number of customers (25, 50, 100) of solomon instances

Return 3 groups of isntances gb[1], gb[2], gb[3]
Each group will contain all instrnce of name_type 

# For example:
     if name_type is `r1` each group will have r101, r102, ..., r112
"""
function dataframe_group_opt_solomon(df::DataFrame)
    gb = groupby(df, :Num_customer)
    return gb
end


"""
    create_conclution_opt_solomon()


Create the csv file contain all solomon instances r101-rc208
Output name: data/opt_solomon/`name_type(r1, r2, ...)`/`name`-`num_customer`
"""
function create_conclution_opt_solomon()
    name_types = ["r1", "r2", "c1", "c2", "rc1", "rc2"]
    num_customer = [25, 50, 100]
    for name_type in name_types
        location = joinpath(@__DIR__, "..", "data", "opt_solomon", name_type)
        
        # check dir
        if ispath(location) == false
            mkdir(location)
        end
        
        # load group of dataframes
        gb = dataframe_group_opt_solomon(dataframe_opt_solomon(name_type))
        
        # write csv
        for (df, num_customer) in zip(gb, num_customer)
            CSV.write(joinpath(location, "$name_type-$num_customer.csv"), df)
        end
        
    end
end


function add_our_best_to_dataframe()
    create_conclution_opt_solomon()
    df2 = read_csv_to_dataframe("Tables\\conslusion_min_all_distance.csv")
    index_name_types = [1:12, 13:23, 24:32, 33:40, 41:48, 49:56] 
    for (name_type, index_name_type) in zip(["r1", "r2", "c1", "c2", "rc1", "rc2"], index_name_types)
        df1 = read_csv_to_dataframe(joinpath(@__DIR__, "..", "data", "opt_solomon", name_type, "$name_type-100.csv"))
        # df1[index_name_type, :Our] = df2[!, :Min]
        # df1[index_name_type, :Our_floor] = df2[!, :Min_floor]
        df1 = hcat(df1, df2[index_name_type, :Min_floor],  makeunique=true )
        df1 = hcat(df1, df2[index_name_type, :Min],  makeunique=true )
        # DataFrames.names!(df1, Symbol.(["Problem", "Num_customer", "NV", "Opt", "Our", "Our_floor"])) 
        rename!(df1, :Distance => :Opt)
        rename!(df1, :x1 => :Our_floor)
        rename!(df1, :x1_1 => :Our)
        CSV.write(joinpath(@__DIR__, "..", "data", "opt_solomon", name_type, "$name_type-100.csv"), df1)
    end
end


function add_our_best_to_dataframe_25_50()
    for num_cus in [25, 50]
        for name_type in ["r1", "r2", "c1", "c2", "rc1", "rc2"]
            df1 = read_csv_to_dataframe(joinpath(@__DIR__, "..", "data", "opt_solomon", name_type, "$name_type-$num_cus.csv"))
            df2_1 = []
            df2_2 = []
            for i in 1:length(df1[:, :Problem])
                instance_name = "$(lowercase(df1[i, :Problem]))-$num_cus"
                location = location_particle_swarm(instance_name)
                min_solution_1 = minimum([total_distance(read_solution(location_name, instance_name), floor_digit=true) for location_name in glob("$instance_name*.txt", location)])
                min_solution_2 = minimum([total_distance(read_solution(location_name, instance_name), floor_digit=false) for location_name in glob("$instance_name*.txt", location)])
                push!(df2_1, min_solution_1)
                push!(df2_2, min_solution_2)
            end
            # @show df2_1
            # @show df2_2
            df1 = hcat(df1, df2_1,  makeunique=true)
            df1 = hcat(df1, df2_2,  makeunique=true)
            # DataFrames.names!(df1, Symbol.(["Problem", "Num_customer", "NV", "Opt", "Our", "Our_floor"])) 
            rename!(df1, :Distance => :Opt)
            rename!(df1, :x1 => :Our_floor)
            rename!(df1, :x1_1 => :Our)
            CSV.write(joinpath(@__DIR__, "..", "data", "opt_solomon", name_type, "$name_type-$num_cus.csv"), df1)
        end
    end
end