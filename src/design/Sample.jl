###
# Sampler is currently implemented equally for  Unordered_Design and Ordered_Design base on index.
# Can be improved, special for Unordered_Design but for small space it should be oke
###

####
# implementaiton base on the StatsBase version [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
####
"""
    StatsBase.sample!(rng::AbstractRNG, space::Eff_Space,x::AbstractArray; with_index::Bool = false , replace::Bool=false, ordered::Bool=false)

Extend the StatsBase.sample! function to sample for a`Eff_Space`.
Using the default settings, It fills `x` with unique samples from the `Eff_Space`. It returns a vector with the corresponding samples.
If with_index = true, corresponding indexes returned together with the sampled constructs.
For more information see [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
"""

function StatsBase.sample!(rng::AbstractRNG, space::Eff_Space,x::AbstractArray; with_index::Bool = false , replace::Bool=false, ordered::Bool=false)
    index = sample!(rng,1:length(space),x;replace=replace,ordered=ordered)
    if with_index
        return [[space.space[i] for i in index]  index]
    else
        return ([space.space[i] for i in index])
    end
end

# if no RNG object is given
StatsBase.sample!(a::Eff_Space, x::AbstractArray; with_index::Bool = false, replace::Bool=false, ordered::Bool=false) =
    sample!(Random.GLOBAL_RNG, a, x; whit_index = with_index, replace=replace, ordered=ordered)


"""
    StatsBase.sample(rng::AbstractRNG, a::Eff_Space, n::Integer; with_index::Bool = false,replace::Bool=false, ordered::Bool=false)

Extend the StatsBase.Sample function to sample for a`Eff_Space`.
Using the default settings,  It draws `n` unique constructs form the `Eff_Space`.
It returns a vector with the corresponding samples.
If with_index = true, corresponding indexes are returned together with the sampled constructs.
For more information see [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
"""
function StatsBase.sample(rng::AbstractRNG, a::Eff_Space, n::Integer; with_index::Bool = false,
                replace::Bool=false, ordered::Bool=false)
    sample!(rng, a, Vector{Int}(undef, n); with_index = with_index, replace=replace, ordered=ordered)
end

# if no RNG object is given
StatsBase.sample(a::Eff_Space, n::Integer;with_index::Bool = false, replace::Bool=false, ordered::Bool=false) =
    sample(Random.GLOBAL_RNG, a, n; whit_index = with_index, replace=replace, ordered=ordered)


"""
    sample(rng::AbstractRNG,space::Frame_Space,n::Int)

Return Array with dimension (n x 2).  The function samples `n` constructs from the input `space`, these are stored in the first collum.
The second column returns the corresponding indices of the construct in the closest efficient design space.
These are not the correct indexes in the constrained space.
Currently not sure if returning them is useful. The with_index = true is to be similar to the other sampler, has no influence on the output

The sampling is based on a recursive function with a reject the unwanted constructs.
These are the constructs which are not allowed based on the given constraints.
For design space with many constraints, it is not efficient, and explicit calculation of the design space may be a better alternative using
`getspace(Frame Space, full = true) `

"""
function StatsBase.sample(rng::AbstractRNG,space::Frame_Space,n::Int, with_index = true)
    sample_reject!(rng,space.space,n,space.con,Array{Int}(undef, 0, 1),  Array{eltype(space)}(undef, 0, 2))
end

"""
    sample_reject!(rng::AbstractRNG,space::Eff_Space,n::Int,con,save_index::Array,check_constructs::Array)

Return Array with dimension (n x 2).  The function samples `n` constructs from the input `space` and corresponding indexes.
These constructs are added to the  `check_constructs` array containing the previously sampled constructs.
The `save_index` contains al previous evaluated constructs and prevents resampling  and the revaluation of an unwanted constructs.

The sampling is based on a recursive function with a reject the unwanted constructs.
These are the constructs which are not allowed based on the given constraints.
For design space with many constraints, it is not efficient, and explicit calculation of the design space may be a better alternative using
`getspace(Frame Space, full = true) `

[`sample_reject`]@ref

"""
function sample_reject!(rng::AbstractRNG,space::Eff_Space,n::Int,con,save_index::Array,check_constructs::Array)


            # number of started constructs
            n_start = size(check_constructs)[1]
            #make new samples
            new_sample = sample(rng,space,n,with_index = true)
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
            # evaluated if their where rejections, if not return else resample for the remaining open positions
            if  n_stop-n_start == n
                return (check_constructs)

            else
                delta = n - (n_stop - n_start)
                sample_reject!(rng,space,delta,con,save_index,check_constructs)
            end
end

"""
    _filter_sample!(new_sample,con::Construct_Constrains)

Internal function to sample_reject!. Evaluates all samples based on the given constraints and removes the unallowed constructs.

"""
_filter_sample!(new_sample,con::Construct_Constrains) = map(y -> !filter_constrain(y,con),new_sample[:,1]) |> (y -> new_sample[y,:])

"""
    _filter_sample!(new_sample,saved_index::Array)

 Evaluates is all samples were sampled or evaluated before and remove them if this is true

"""
_filter_sample!(new_sample,saved_index::Array) = map((y -> y ∉ saved_index),new_sample[:,2]) |> (y -> new_sample[y,:])


"""
    StatsBase.sample(rng::AbstractRNG, space::Multi_Space, n::Integer; with_index::Bool = true)

Extend the StatsBase.sample function to sample for a `Multi_Space`.
Using the default settings, It fills `x` with unique samples from the `Multi_Space`. It returns a vector with the corresponding samples.
If with_index = true, corresponding indexes returned together with the sampled constructs.
For more information see [StatsBase](https://juliastats.org/StatsBase.jl/stable/sampling/)
"""


function StatsBase.sample(rng::AbstractRNG, space::Multi_Space, n::Integer; with_index::Bool = true)
    if isa(space,Frame_Space) == false
        index = sample(rng,1:length(space),n;replace=false)
        if with_index
            return [[space[i] for i in index]  index]
        else
            return ([space[i] for i in index])
        end
    end
end
