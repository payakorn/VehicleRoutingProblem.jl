"""
    tabulation_group_opt_solomon(name_type::String)

Find the group by the number of customers (25, 50, 100) of solomon instances

Return 3 groups of isntances gb[1], gb[2], gb[3]
Each group will contain all instrnce of name_type 

For example if name_type is `r1` each group will have r101, r102, ..., r112
"""
function tabulation_group_opt_solomon(name_type::String)
    location = joinpath(@__DIR__, "..", "opt_solomon", "$name_type.csv")
    df = read_csv_to_dataframe(location)
    gb = groupby(df, :Num_customer)
    return gb
end


function create_conclution_opt_solomon()
    name_types = ["r1", "r2", "c1", "c2", "rc1", "rc2"]
    num_customer = [25, 50, 100]
    for name_type in name_types[1:2]
        location = joinpath(@__DIR__, "..", "data", "opt_solomon", name_type)

        # check dir
        if ispath(location) == false
            mkdir(location)
        end

        # load group of dataframes
        gb = tabulation_group_opt_solomon(name_type)

        # write csv
        for (df, num_customer) in zip(gb, num_customer)
            CSV.write(joinpath(location, "$name_type-$num_customer.csv"), df)
        end

    end
end