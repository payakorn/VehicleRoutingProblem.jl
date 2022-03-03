using Documenter, VehicleRoutingProblems

makedocs(sitename="Vehicle Routing Problems",
        format = Documenter.HTML(
            prettyurls = get(ENV, "CI", nothing) == "true"
        ))

# run by `python -m http.server --bind localhost`