abstract type AbstractSpace{T} end


"""
    Base.eltype(::Eff_Space{T}) where {T}

Return the type of `AbstractSpace{T}` if they are collected
"""

Base.eltype(::AbstractSpace{T}) where {T} = eltype(T)

"""
    Eff_Space{T}  <: AbstractSpace{T}

`Eff_Space{T}` are efficient design spaces.
This means that implement function  `size`, `length`, `sample`, `getindex` can be used without the construction of all possible constructs in the space.
Explicit calculation of al constructs is still possible.
"""

abstract type Eff_Space{T}  <: AbstractSpace{T} end



"""
    Base.getindex(space::Eff_Space,i::Int)

Returns the construct on the i-th possition in the design space.
"""

Base.getindex(space::Eff_Space,i::Int) = space.space[i]
"""
    Base.getindex(space::Eff_Space,A::Array)

Returns a vector of constructs out of `space` corresponding to the indices in `A`.
"""
Base.getindex(space::Eff_Space,A::Array) = map(i -> space.space[i], A)

"""
    Base.length(space::Eff_Space)

Returns the number of constructs in the `space`.
"""
Base.length(space::Eff_Space) = length(space.space)

"""
    Base.size(space::Eff_Space)

Returns a tuple with first the number of constructs in the `space` and second value 1.
"""
Base.size(space::Eff_Space) = (length(space.space),1)


"""
    Base.iterate(space::Eff_Space, state = 1)

Creates iterater object for an `Eff_Space`.
"""
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
    Full_Ordered_space{T}

`Eff_Space{T}` space type for space filled with `Ordered_Construct` and without any constraints.
"""
struct Full_Ordered_space{T}<: Eff_Space{T}
    space::T
end


"""
    Full_Unordered_space{T}

`Eff_Space{T}` space type for space filled with `Unordered_Construct` and without any constraints
"""
struct Full_Unordered_space{T}<: Eff_Space{T}
    space::T
end


"""
    Computed_Space{T}

`Eff_Space{T}` space type for space where all constructs are explicitly generated.
"""
struct Computed_Space{T} <: Eff_Space{T}
    space::T
end

"""
    Frame_Space{T, Tc <: Construct_Constrains}

Structure generated for a space where no effiecent alterative is implented currently.
The closed efficient design space is stored together with the uncheck constrains.
"""

struct Frame_Space{T, Tc <: Construct_Constrains} <: AbstractSpace{T}
    space::T
    con::Tc
end

# getindex seem not very usefull in this case
getindex(space::Frame_Space ,i::Int) = @warn "no efficient indexing, first use getspace function to generated the full space"

"""
    Base.iterate(space::Eff_Space, state = 1)

Creates iterater object for an `Frame_Space`. Fitlers the no allow constructs
"""

function Base.iterate(space::Frame_Space, state = 1 )
    # make costruct
    construct = space.space[state]

    #evaluated constrains
    while filter_constrain(construct, space.con) == true && state < length(space.space)
        state += 1
        construct = space.space[state]
    end
    #update state
    state += 1

    if  state <= length(space.space)
        return (construct,state)
    else
        return
    end
end

"""
    Base.length(space::Frame_Space)

Fallback to calculate the length Frame_Space.
Inefficient calculation has tot iterated overall allowed constructs.
"""

function Base.length(space::Frame_Space)
    @warn "No efficient calculation iterate to all allowed options to get the lenght"
    len = 0
    for i in space
        len +=1
    end

    return len
end


"""
internal lenght, no warning printed
"""
#_length(space::AbstractSpace) = length(space.space)




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
