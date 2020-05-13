module BOMoD

    using Kronecker
    using StatsBase
    using Statistics
    using StringDistances
    using Distances
    using DataFrames
    using Random
    using LinearAlgebra
    using Optim
    using Stheno
    using Zygote: gradient
    using Distributions
    using Reexport


    import Base: +, *, getindex,length, eltype,isequal,isless,push!,in,summary,show,==
    import Stheno: ew,pw,  BaseKernel
    import LinearAlgebra: norm, eigvals!, Diagonal,dot
    import Optim: minimizer
    import Kronecker: KroneckerPower
    import StringDistances: QGramDistance


    export groupmod, getspace
    export constructdesign
    export OrderedConstraint, UnOrderedConstraint
    export OrderedConstruct, UnorderedConstruct
    export GPModel, GPpredict
    export fit_gp, predict_GP
    export ts_sampler_me,ts_sampler_stheno,ei_sampler,pi_sampler,gpucb_sampler
    export QgramKernel,EditDistancesKernel

    @reexport using Stheno: Kernel
    @reexport using StatsBase: sample



    # include construction of space
    include(joinpath("design", "Mod.jl"))
    include(joinpath("design", "Combinatroics.jl"))
    include(joinpath("design", "Constraints.jl"))
    include(joinpath("design", "Space.jl"))
    include(joinpath("design", "Construct.jl"))
    include(joinpath("design", "Designspace.jl"))
    include(joinpath("design", "Sample.jl"))
    #BO
    include(joinpath("BO", "util_graph.jl"))
    include(joinpath("BO", "Kernels.jl"))
    include(joinpath("BO", "GP_model.jl"))
    include(joinpath("BO", "batch_sample.jl"))


end # module
