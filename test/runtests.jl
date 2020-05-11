using Test
using BOMoD
using BOMoD: filterconstraint, Combination, ComposeConstructConstraints
using Random
using StatsBase
include("test_functions.jl")

@testset "BOMod" begin
    include("./design_test/Mod_test.jl")
    include("./design_test/Filter_test.jl")
    include("./design_test/Space_test.jl")
    include("./design_test/Constraint_test.jl")
    include("./design_test/Combination_test.jl")
    include("./design_test/Constructs_test.jl")
    include("./BO/Kernel_test.jl")
end
