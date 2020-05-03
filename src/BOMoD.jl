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
    using Distances
    using StringDistances
    #using BayesianLinearRegressors: BayesianLinearRegressor, rand, posterior, marginals



    import Base: +, *, == ,getindex,length, eltype,isequal,isless,push!,in,show
    import Stheno: ew,pw,Kernel
    import LinearAlgebra: norm, eigvals!, Diagonal,dot
    import Optim: minimizer
    import StatsBase: sample



    export Mod, GroupMod , groupmod ,getspace
    export constructdesign
    export NoConstrain, OrderedConstrain, UnOrderedConstrain, PossitionConstrain
    export OrderedConstruct, UnorderedConstruct
    export FrameSpace,ComputedSpace,FullOrderedspace
    export GPoptimised,gpoptimised
    export thompsonsampling, savethompsonsampling
    export LevStehnoexp


    # include construction of space
    include(joinpath("design", "Mod.jl"))
    include(joinpath("design", "Combinatroics.jl"))
    include(joinpath("design", "Constraints.jl"))
    include(joinpath("design", "Space.jl"))
    include(joinpath("design", "Construct.jl"))
    include(joinpath("design", "Designspace.jl"))
    include(joinpath("design", "Sample.jl"))
    #BO
    include(joinpath("BO", "Hyperopt.jl"))
    include(joinpath("BO", "Kernels.jl"))
    include(joinpath("BO", "TSsampeling.jl"))
    #linearmodel
    include(joinpath("linearmodel", "linearmodel.jl"))

end # module
