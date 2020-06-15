using Documenter
using BOMoD
using BOMoD: Mod
makedocs(sitename="BOMoD.jl",
        authors = "Sam Dierickx",
        format = Documenter.HTML(),
       modules = [BOMoD])

deploydocs(
        repo = "https://github.com/SamDier/BOMoD.jl.git",
        )
