using Test
using BOMoD
using Random
using StatsBase

@testset "BoMod" begin
    include("Mod_test.jl")
    include("Filter_test.jl")
    include("Space_test.jl")
    include("Constrain_test.jl")
    include("Combination_test.jl")
    include("Constrain_test.jl")
end
