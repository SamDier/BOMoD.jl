using Documenter, BOMoD,
using DocumenterLaTeX

makedocs(sitename="BoMoD.jl",
        authors = "Sam Dierickx")

deploydocs(
        repo = "https://github.com/SamDier/BOMoD.jl",
        )
