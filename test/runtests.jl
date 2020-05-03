using Test
using BOMoD
using BOMoD: filter_constrain, Combination, Compose_Construct_Constrains
using Random
using StatsBase
include("test_functions.jl")

@testset "BOMod" begin
    include("Mod_test.jl")
    include("Filter_test.jl")
    include("Space_test.jl")
    include("Constraint_test.jl")
    include("Combination_test.jl")
    include("Constructs_test.jl")
    include("Kernel_test.jl")
end
