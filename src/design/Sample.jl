


function StatsBase.sample!(rng::AbstractRNG, space::Eff_Space,x::AbstractArray; with_index::Bool = false , replace::Bool=false, ordered::Bool=false)
    index = sample!(rng,1:length(space),x;replace=replace,ordered=ordered)
    if with_index
        return [[space.space[i] for i in index]  index]
    else
        return ([space.space[i] for i in index])
    end
end

StatsBase.sample!(a::Eff_Space, x::AbstractArray; with_index::Bool = false, replace::Bool=false, ordered::Bool=false) =
    sample!(Random.GLOBAL_RNG, a, x; whit_index = with_index, replace=replace, ordered=ordered)


"""
sample(rng::AbstractRNG, a::Eff_Space, n::Integer; with_index::Bool = false,
                replace::Bool=false, ordered::Bool=false)
take random sample without replacement out of the space of contructs
"""
function StatsBase.sample(rng::AbstractRNG, a::Eff_Space, n::Integer; with_index::Bool = false,
                replace::Bool=false, ordered::Bool=false)
    sample!(rng, a, Vector{Int}(undef, n); with_index = with_index, replace=replace, ordered=ordered)
end

StatsBase.sample(a::Eff_Space, n::Integer;with_index::Bool = false, replace::Bool=false, ordered::Bool=false) =
    sample(Random.GLOBAL_RNG, a, n; whit_index = with_index, replace=replace, ordered=ordered)


"""
sample_reject(rng::AbstractRNG,space,n::Int,con; with_index::Bool = true)
take random sample without replacement out of the space of contructs
    """
function sample_reject(rng::AbstractRNG,space,n::Int,con; with_index::Bool = true)
    sample_reject!(rng,Full_Ordered_space(space.space),n,con,Array{Int}(undef, 0, 1),  Array{Any}(undef, 0, 2))
end



function sample_reject!(rng::AbstractRNG,space::Frame_Space,n::Int,con,save_index::Array,check_constructs::Array ;
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
                sample_reject!(space,delta,con,save_index,check_constructs)
            end
end


filter_sample!(new_sample,con::Construct_Constrains) = map(y -> !filter_constrain(y,con),new_sample[:,1]) |> (y -> new_sample[y,:])
filter_sample!(new_sample,saved_index::Array) = map((y -> y ∉ saved_index),new_sample[:,2]) |> (y -> new_sample[y,:])
