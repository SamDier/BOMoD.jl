using Documenter
using BOMoD

makedocs(sitename="BOMoD.jl",
        authors = "Sam Dierickx"
        format = :html,
       modules = [BOMoD])

deploydocs(
        repo = "https://github.com/SamDier/BOMoD.jl",
        )
