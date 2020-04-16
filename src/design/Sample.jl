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
    sample_reject(rng::AbstractRNG,space,n::Int,con; with_index::Bool = true)

take random sample without replacement out of the space of contructs
"""
function sample_reject(rng::AbstractRNG,space::Frame_Space,n::Int)
    sample_reject!(rng,Full_Ordered_space(space.space),n,space.con,Array{Int}(undef, 0, 1),  Array{eltype(Frame_Space)}(undef, 0, 2))
end



function sample_reject!(rng::AbstractRNG,space::Eff_Space,n::Int,con,save_index::Array,check_constructs::Array ;
    with_index::Bool = true, replace::Bool=false, ordered::Bool=false)

            n_start = size(check_constructs)[1]
            #make new samples
            new_sample = sample(rng,space,n,with_index = true)
            #check if draw before
            new_sample = filter_sample!(new_sample,save_index)
            #updated check indexes
            save_index = [save_index;new_sample[:,2]]
            #check constrain
            new_sample = filter_sample!(new_sample,con)
            #updata approved constructs
            check_constructs = [check_constructs;new_sample]
            n_stop = size(check_constructs)[1]

            if  n_stop-n_start == n
                return (check_constructs)

            else
                delta = n - (n_stop - n_start)
                sample_reject!(rng,space,delta,con,save_index,check_constructs)
            end
end


filter_sample!(new_sample,con::Construct_Constrains) = map(y -> !filter_constrain(y,con),new_sample[:,1]) |> (y -> new_sample[y,:])
filter_sample!(new_sample,saved_index::Array) = map((y -> y ∉ saved_index),new_sample[:,2]) |> (y -> new_sample[y,:])
