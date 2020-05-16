using Documenter, BOMoD
using BOMoD

makedocs(sitename="BoMoD.jl",
        authors = "Sam Dierickx")

deploydocs(
        repo = "https://github.com/SamDier/BOMoD.jl",
        )
