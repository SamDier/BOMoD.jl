using Test
using BOMoD
using BOMoD: filter_constrain, Combination, Compose_Construct_Constrains
using Random
using StatsBase

@testset "BOMod" begin
    include("Mod_test.jl")
    include("Filter_test.jl")
    include("Space_test.jl")
    include("Constrain_test.jl")
    include("Combination_test.jl")
    include("Constrain_test.jl")
end
