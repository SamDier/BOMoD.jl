module BOMoD

    using Kronecker
    using StatsBase
    using Stheno
    using Optim
    using Random
    using Statistics
    using Distributions
    using DataFrames
    using Plots
    using BayesianLinearRegressors: BayesianLinearRegressor, rand, posterior, marginals



    import Base: +, *, getindex,length, eltype
    import Stheno: ew,pw,Kernel
    import LinearAlgebra: norm, eigvals!, Diagonal
    import Optim: minimizer
    import StatsBase: sample


    export Mod, Group_Mod , group_mod ,getspace
    export construct_design
    export No_Constrain, Ordered_Constrain, UnOrdered_Constrain, Possition_Constrain
    export Ordered_Construct, Unordered_Construct
    export Frame_Space,Computed_Space,Full_Ordered_space
    export GP_optimised,gp_optimised
    export thompson_sampling, save_thompson_sampling
    export LevStehnoexp


    # include construction of space
    include(joinpath("design", "Mod.jl"))
    include(joinpath("design", "Combinatroics.jl"))
    include(joinpath("design", "Constrains.jl"))
    include(joinpath("design", "Space.jl"))
    include(joinpath("design", "Construct.jl"))
    include(joinpath("design", "Design_space.jl"))
    include(joinpath("design", "Sample.jl"))
    #BO
    include(joinpath("BO", "Hyper_opt.jl"))
    include(joinpath("BO", "Kernels.jl"))
    include(joinpath("BO", "TS_sampeling.jl"))
    #linear_model
    include(joinpath("linear_model", "linear_model.jl"))

end # module
