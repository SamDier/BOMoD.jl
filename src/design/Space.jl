#import Base: getindex,iterate
#using Random: AbstractRNG

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

Base.eltype(::Type{Eff_Space{T}}) where {T} = eltype(T)
Base.getindex(space::Eff_Space,i::Int) = space.space[i]
Base.getindex(space::Eff_Space,A::Array) = map(i -> space.space[i], A)
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


"""
Struct for ordered space without contrains to allow
"""
struct Full_Ordered_space{T}<: Eff_Space{T}
    space::T
end


"""
Struct for Unordered space without contrains to allow
"""
struct Full_Unordered_space{T}<: Eff_Space{T}
    space::T
end



"""
If the full design space is generated, Construct saved in AbstractArray
"""
struct Computed_Space{T} <: Eff_Space{T}
    space::T
end







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
