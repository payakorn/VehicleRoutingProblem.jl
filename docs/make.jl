using Documenter, VehicleRoutingProblems

makedocs(sitename="Vehicle Routing Problems",
        format = Documenter.HTML(
            prettyurls = get(ENV, "CI", nothing) == "true"
        ))

