module BOMoD

    using Kronecker
    using StatsBase
    using Stheno
    using LinearAlgebra

    import Base: +, *, getindex,length, eltype
    import Stheno: ew, pw,Kernel

    export Mod, Group_Mod , group_mod
    export construct_ordered_design
    export No_Constrain, Ordered_Constrain, UnOrdered_Constrain, Possition_Constrain
    export Ordered_Construct, Unordered_Construct
    export Frame_Space,Computed_Space,Full_Ordered_space
    export GP_optimised
    export thompson_sampling, save_thompson_sampling



    # include construction of space
    include(joinpath("design", "Mod.jl"))
    include(joinpath("design", "Constrains.jl"))
    include(joinpath("design", "Space.jl"))
    include(joinpath("design", "Construct.jl"))
    include(joinpath("BO", "Hyper_opt.jl"))
    include(joinpath("BO", "Kernels.jl"))
    include(joinpath("BO", "TS_sampeling.jl"))

end # module
