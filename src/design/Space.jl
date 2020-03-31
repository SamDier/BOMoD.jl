import Base: getindex,iterate
using Random: AbstractRNG

abstract type AbstractSpace{T} end


struct Multi_Space{T} <: AbstractSpace{T}
    space::Array{T}
end
Base.length(d::Multi_Space) = length(d.space)

function Base.iterate(d::Multi_Space, state = [1 1])
    if state[1] > length(d)
        return
    end
    current_space = d.space[state[1]]
    if state[2] < _length(current_space,nothing)
        i = current_space[state[2]]
        state[2] += 1
        return (i, state)
    else
        j = current_space[state[2]]
        state[1] +=1
        state[2] = 1
        return (j,state)
    end
end
Base.eltype(::Multi_Space) =  AbstractConstruct
# special length, prevent printing of the warning
Base.size(d::Multi_Space) = (length(d), map(x -> length(x,nothing),d.space) |> sum )


function getindex(d::Multi_Space,index::Int , state = 1)
    controle = _length(d.space[state],nothing)
    if controle >= index
        @inbounds return d.space[state][index]
    else
        getindex(d,index-controle,state+=1)
    end
end

"""
Frame to generated effienct random Construct form the design space. If possible the given constrains are taken into account.
This are indexalbe object to obtain repoduceble resultes every run.
The full design space isn't constucted explisitly. The Eff frame space suggest that a effient way is used to allow constrains in the space
"""

abstract type Eff_Space{T}  <: AbstractSpace{T} end

"""
Struct for ordered space without contrains to allow
"""
struct Full_Ordered_space{T}<: Eff_Space{T}
    space::T
end
Base.eltype(::Type{Eff_Space{T}}) where {T} = eltype(T)
"""
If the full design space is generated, Construct saved in AbstractArray
"""
struct Computed_Space{T} <: Eff_Space{T}
    space::T
end

Base.getindex(space::Eff_Space,i::Int) = space.space[i]
Base.eltype(::Eff_Space) = Ordered_Construct{T} where T
Base.length(space::Eff_Space) = length(space.space)

function Base.iterate(space::Eff_Space, state = 1 )
    if  state <= length(space)
        construct = space[state]
        state += 1
        return (construct,state)
    else
        return
    end
end

function StatsBase.sample!(rng::AbstractRNG, space::Eff_Space,x::AbstractArray; with_index::Bool = false , replace::Bool=true, ordered::Bool=false)
    index = sample!(rng,1:length(space),x;replace=replace,ordered=ordered)
    if with_index
        return [[space.space[i] for i in index]  index]
    else
        return ([space.space[i] for i in index])
    end
end

StatsBase.sample!(a::Eff_Space, x::AbstractArray; with_index::Bool = false, replace::Bool=true, ordered::Bool=false) =
    sample!(Random.GLOBAL_RNG, a, x; whit_index = with_index, replace=replace, ordered=ordered)

function StatsBase.sample(rng::AbstractRNG, a::Eff_Space, n::Integer; with_index::Bool = false,
                replace::Bool=true, ordered::Bool=false)
    sample!(rng, a, Vector{Int}(undef, n); with_index = with_index, replace=replace, ordered=ordered)
end

StatsBase.sample(a::Eff_Space, n::Integer;with_index::Bool = false, replace::Bool=true, ordered::Bool=false) =
    sample(Random.GLOBAL_RNG, a, n; whit_index = with_index, replace=replace, ordered=ordered)


"""
Frame to generated  random Construct form the design space. Constrains are taken into account. This are indexalbe object to obtain repoduceble resultes every run.
The full design space isn't constucted explisitly. No effiencent way is used to do this so form most functialitys a Comuted space object is generated and used.
"""
struct Frame_Space{T} <: AbstractSpace{T}
    space::T
end

getindex(space::Frame_Space ,i::Int) = space.space[i]
Base.iterate(space::Frame_Space, state = 1 ) = @warn "no effieciet iteration, first use getspace function to generated the full space"

function Base.length(space::Frame_Space)
      y = length(space.space)
      @info " $y is the maximual length (no constrains) , no effienct length calculation, generated construct for exact length"
      return length(space.space)
end





"""
internal lenght, no warning printed
"""
_length(space::AbstractSpace) = length(space.space)
