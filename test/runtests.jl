
using Test
using BOMoD

@testset "BoMod" begin
    include("Mod_test.jl")
    include("Filter_test.jl")
    include("Space_test.jl")
    include("Constrain_test.jl")
end
