using Test
using Random
using StatsBase
using Stheno
using StringDistances
using Distances
using Stheno: ew, pw
using BOMoD
using BOMoD: filterconstraint, Combination,  ComposedConstructConstraints,
    Mod,GroupMod, _word2vec, degree, laplacian,norm_laplacian, _len1,_creatGP

include("./BO_test/test_functions.jl")

@testset "BOMod" begin
    include("./design_test/Mod_test.jl")
    include("./design_test/Filter_test.jl")
    include("./design_test/Space_test.jl")
    include("./design_test/Constraint_test.jl")
    include("./design_test/Combination_test.jl")
    include("./design_test/Constructs_test.jl")
    include("./BO_test/Kernel_test.jl")
    include("./BO_test/graph_test.jl")
    include("./BO_test/GP_test.jl")
end
