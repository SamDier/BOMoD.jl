using Documenter
using BOMoD

makedocs(sitename="BOMoD.jl",
        authors = "Sam Dierickx",
        format = Documenter.HTML(),
       modules = [BOMoD])

deploydocs(
        repo = "github.com/SamDier/BOMoD.jl.git",
        )
