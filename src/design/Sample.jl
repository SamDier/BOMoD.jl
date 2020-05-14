###
# Sampler is currently implemented equally for  UnorderedDesign and OrderedDesign base on index.
# Can be improved, special for UnorderedDesign but for small space it should be oke
###

####
# implementaiton base on the StatsBase version [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
####
"""
    sample!(rng::AbstractRNG, space::EffSpace,x::AbstractArray;
                withindex::Bool = false , replace::Bool=false, ordered::Bool=false)

function to sample for a`EffSpace`.
Using the default settings, It fills `x` with unique samples from the `EffSpace`.
It returns a vector with the corresponding samples.
If withindex = true, corresponding indexes returned together with the sampled constructs.

For more information see [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
"""

function StatsBase.sample!(rng::AbstractRNG, space::EffSpace,x::AbstractArray;
            with_index::Bool = false , replace::Bool=false, ordered::Bool=false)
            
    index = sample!(rng,1:length(space),x;replace=replace,ordered=ordered)
    if with_index
        return ([space.space[i] for i in index] , index)
    else
        return ([space.space[i] for i in index])
    end
end

# if no RNG object is given
StatsBase.sample!(a::EffSpace, x::AbstractArray; with_index::Bool = false, replace::Bool=false, ordered::Bool=false) =
    sample!(Random.GLOBAL_RNG, a, x; whit_index = with_index, replace=replace, ordered=ordered)


"""
    sample(rng::AbstractRNG, a::EffSpace, n::Integer; with_index::Bool = false,
                            replace::Bool=false, ordered::Bool=false)

function to sample for a`EffSpace`.
Using the default settings,  It draws `n` unique constructs form the `EffSpace`.
It returns a vector with the corresponding samples.
If with_index = true, corresponding indexes are returned together with the
sampled constructs.

For more information see [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
"""
function StatsBase.sample(rng::AbstractRNG, a::EffSpace, n::Integer; with_index::Bool = false,
                replace::Bool=false, ordered::Bool=false)
    sample!(rng, a, Vector{Int}(undef, n); with_index = with_index, replace=replace, ordered=ordered)
end

# if no RNG object is given
StatsBase.sample(a::EffSpace, n::Integer;with_index::Bool = false, replace::Bool=false, ordered::Bool=false) =
    sample(Random.GLOBAL_RNG, a, n; with_index = with_index, replace=replace, ordered=ordered)


"""
    sample(rng::AbstractRNG,space::FrameSpace,n::Int)

Return an Array with dimension (n x 2). The function samples `n` constructs from
the input `space`, these are stored in the first column. The second column returns
the corresponding indices of the construct in the closest efficient design space.
These are not the correct indexes in the constrained space.
Currently not sure if returning them is useful. The `with_index = true` is to be
similar to the other sampler, has no influence on the output

The sampling is based on a recursive function with a reject the unwanted constructs.
These are the constructs which are not allowed based on the given constraints.
For design space with many constraints, it is not efficient, and explicit calculation
of the design space may be a better alternative using
`getspace(Frame Space, full = true) `
"""
function StatsBase.sample(rng::AbstractRNG,space::FrameSpace,n::Int; withindex = true)
    samplereject!(rng,space.space,n,space.con,Array{Int}(undef, 0, 1),  Array{eltype(space)}(undef, 0, 2))
end

"""
    samplereject!(rng::AbstractRNG,space::EffSpace,n::Int,con,save_index::Array,
                    check_constructs::Array)

Return Array with dimension (n x 2).  The function samples `n` constructs from the
input `space` and corresponding indexes.
These constructs are added to the  `check_constructs` array containing the
previously sampled constructs. The `save_index` contains al previous evaluated
constructs and prevents resampling  and the revaluation of an unwanted constructs.

The sampling is based on a recursive function which rejects the unwanted constructs.
These are the constructs which are not allowed based on the given constraints.
For design space with many constraints, it is not efficient, and explicit
calculation of the design space may be a better alternative using
`getspace(Frame Space, full = true) `

[`sample(rng::AbstractRNG,space::FrameSpace,n::Int)`]@ref

"""
function samplereject!(rng::AbstractRNG, space::EffSpace,n::Int, con,
                    save_index::Array, check_constructs::Array)
            # number of started constructs
            n_start = size(check_constructs)[1]
            #make new samples
            new_sample = sample(rng,space,n,with_index = true) |> x -> [x[1] x[2]]
            #check if draw before
            new_sample = _filter_sample!(new_sample,save_index)
            #updated check indexes
            save_index = [save_index;new_sample[:,2]]
            #check constrain
            new_sample = _filter_sample!(new_sample,con)
            #updata approved constructs
            check_constructs = [check_constructs;new_sample]
            #number of constructs ad the end
            n_stop = size(check_constructs)[1]
            # evaluated if their where rejections,
            # if not return else resample for the remaining open positions
            if  n_stop-n_start == n
                return (check_constructs[:,1] , convert(Vector{Int},check_constructs[:,2]))

            else
                delta = n - (n_stop - n_start)
                samplereject!(rng,space,delta,con,save_index,check_constructs)
            end
end

"""
    _filter_sample!(new_sample,con::ConstructConstraints)

Internal function to sample_reject!. Evaluates all samples based on the given
constraints and removes the unallowed constructs.
"""
_filter_sample!(new_sample,con::ConstructConstraints) = map(y -> !filterconstraint(y,con),new_sample[:,1]) |> (y -> new_sample[y,:])

"""
    _filter_sample!(new_sample,saved_index::Array)

Evaluates is all samples were sampled or evaluated before and remove them if
this is true
"""
_filter_sample!(new_sample,saved_index::Array) = map((y -> y ∉ saved_index),new_sample[:,2]) |> (y -> new_sample[y,:])



"""
    sampleStatsBase.sample(rng::AbstractRNG, space::Multi_Space, n::Integer; with_index::Bool = true)

Returns an Array with dimension (n x 2).  The function samples `n` unique constructs
from the input `space` and corresponding indexes.
The function sampless from the underlying space that constructs the `Multi_space`.


**note**: For `MultiSpace{FrameSpace}` these indexes are form the whole design
space with considering the constraints.
The sampling is based on a recursive function which rejects the unwanted constructs.
These are the constructs which are not allowed based on the given constraints.
For design space with many constraints, it is not efficient, and explicit calculation
 of the design space may be a better alternative using
`getspace(Frame Space, full = true) `

[`sample(rng::AbstractRNG,space::FrameSpace,n::Int)`](@ref)
[sample(rng::AbstractRNG,space::EffSpace,n::Int)](@ref)

"""
function StatsBase.sample(rng::AbstractRNG, space::MultiSpace, n::Integer; with_index::Bool = true)

    #set weigths of the sampler
    w,max_n = [length(s) for s in space.space] |> x ->(FrequencyWeights(x),sum(x))
    @assert n < max_n  "can only sample $max_n points"

    #prelocated
    samples = Array{T where T,2}(undef,n,2)
    # one point,two samplers are used, the first selects which space is chosen, this is weighted based on the length of individual spaces
    # sampler two samples form the selected space.
    samples[1,:] = sample(rng,collect(1:_nspace(space)), w,1)  |> x -> space.space[x[1]] |> y -> (sample(rng,y,1,withindex = true)) |> x -> [x[1] x[2]]
    #sampels form whole the design space n times

    if n == 1
         return samples
    end

    for i in 2:n
        new_point = sample(rng,collect(1:_nspace(space)), w,1) |> x -> space.space[x[1]] |> y -> (sample(rng,y,1,withindex = true)) |> x -> [x[1] x[2]]
        # select n unique sample, evaluated if draw before

        while  new_point[2] in samples[1:i-1,2]
            new_point = sample(rng,collect(1:size(space)[2]), w,1) |> x -> space.space[x[1]] |> y -> (sample(rng,y,1,with_index = true)) |> x -> [x[1] x[2]]
        end

        samples[i,:] = new_point
    end

    return (samples[:,1], convert(Vector{Int},samples[:,2]))
end
