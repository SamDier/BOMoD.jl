#FIXME: names! `Eff_Space` => `EffSpace`

abstract type AbstractSpace{T} end

"""
    Eff_Space{T}  <: AbstractSpace{T}

`Eff_Space{T}` is a type for efficient design spaces.
This means that they implement the functions  `size`, `length`, `sample`,
`getindex` can be used without the construction of all possible constructs in the
space. Explicit calculation of all constructs is still possible.
"""
abstract type Eff_Space{T}  <: AbstractSpace{T} end


"""
    getindex(space::Eff_Space,i::Int)

Returns the construct on the i-th possition in the design space.
"""

Base.getindex(space::Eff_Space,i::Int) = space.space[i]
"""
    getindex(space::Eff_Space,A::Array)

Returns a vector of constructs out of `space` corresponding to the indices in `A`.
"""
Base.getindex(space::Eff_Space,A::Array) = map(i -> space.space[i], A)

"""
    length(space::Eff_Space)

Returns the number of constructs in the `space`.
"""
Base.length(space::Eff_Space) = length(space.space)

#NOTE: see my remarks on the need of `size`
"""
    size(space::Eff_Space)

Returns a tuple with first the number of constructs in the `space` and second
value 1.
"""
Base.size(space::Eff_Space) = (length(space.space),1)


"""
    iterate(space::Eff_Space, state = 1)

Creates an iterater object for an `Eff_Space`.
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

#FIXME: names!
"""
    Full_Ordered_space{T}

`Eff_Space{T}` space type for space filled with `Ordered_Construct` and without any constraints.
"""
struct Full_Ordered_space{T}<: Eff_Space{T}
    space::KroneckerPower{T}
end

"""
    eltype(::Type{Full_Ordered_space)

Returns the type of `Full_Ordered_space{T}` if they are collected.
"""
Base.eltype(::Type{Full_Ordered_space{T}}) where {T} = Ordered_Construct{T}

#FIXME: names
"""
    Full_Unordered_space{T}

`Eff_Space{T}` space type for space filled with `Unordered_Construct` and without any constraints
"""
struct Full_Unordered_space{T}<: Eff_Space{T}
    space::Combination{T}
end


"""
    eltype(::Type{Full_Unordered_space{T}}) where {T}

Returns the type of `Full_Unordered_space{T}` if they are collected.
"""
Base.eltype(::Type{Full_Unordered_space{T}}) where {T} = Unordered_Construct{T}

#FIXME: names!
"""
    Computed_Space{T}

`Eff_Space{T}` space type for space where all constructs are explicitly generated.
"""
struct Computed_Space{T} <: Eff_Space{T}
    space::T
end

# QUESTION: should be 'when they are collected'?
"""
    eltype(::Type{Computed_Space)

Return the type of `Computed_Space` if they are collected.
"""
Base.eltype(::Type{Computed_Space{T}}) where {T} = eltype(T)


"""
    Frame_Space{T, Tc <: Construct_Constrains}

Structure generated for a space where no efficient alterative is implented currently.
The closed efficient design space is stored together with the uncheck constrains.
"""
struct Frame_Space{Ts <: Eff_Space{T} where T, Tc <: Construct_Constrains} <: AbstractSpace{Ts}
    space::Ts
    con::Tc
end

#NOTE: not sure if you use `@warn` correctly, please check!
# getindex seem not very usefull in this case
getindex(space::Frame_Space ,i::Int) = @warn "no efficient indexing, first use getspace function to generated the full space"

"""
    iterate(space::Frame_Space, state = 1)

Creates iterater object for an `Frame_Space`. Filters the not allowed constructs
"""
function Base.iterate(space::Frame_Space, state = 1 )
    # make costruct

    if  state > length(space.space)
        return
    end

    construct = space.space[state]

    #evaluated constrains
    while filter_constrain(construct, space.con) == true
        state += 1
        if state > length(space.space)
            return
        end

        construct = space.space[state]
    end
    #update state
    state += 1

    return (construct,state)

end

"""
    length(space::Frame_Space)

Fallback to calculate the length Frame_Space.
Inefficient calculation has tot iterated overall allowed constructs.
"""

function Base.length(space::Frame_Space)
    #NOTE: not sure if you use `@warn` correctly, please check!
    @warn "No efficient calculation iterate to all allowed options to get the length"
    len = 0
    for i in space
        len +=1
    end

    return len
end

"""
    eltype(K::Frame_Space)

Returns the type of `Frame_Space{T}` if they are collected.
"""
Base.eltype(K::Frame_Space{T}) where {T} = eltype(K.space)

#FIXME: name
struct Multi_Space{T} <: AbstractSpace{T}
    space::Array{T}
    Multi_Space(space::Array) = promote_type([typeof(i) for i in space]...) |> x -> new{x}(space)
end

Base.eltype(::Multi_Space{T}) where {T} = eltype(T)

"""
    length(space::Multi_Space)

Returns the number of constructs in the `space`.
"""
Base.length(space::Multi_Space) = map(x -> length(x),space.space) |> sum

"""
    _nspace(space::Multi_Spac)

Return the number of single space that are used to construct the whole `space`
"""


_nspace(space::Multi_Space) = length(space.space)

"""
    Base.size(space::Multi_Space)

Returns a tuple of two numbers, the first position contains the number of
constructs in the whole `space`. The second number is the number of single space
that are construct the entire design space
"""
Base.size(space::Multi_Space) = (length(space), _nspace(space))

# chained the signal iterators, can be done with Base.Iterators.flatten(space.space) but less consistent with other spaces.

"""
    Base.iterate(space::Multi_Space)

Returns a tuple of two numbers, the first position contains the number of
constructs in the `space`. The second number is the number of `sing` that are
used to construct the entire design space
"""
function Base.iterate(space::Multi_Space, state = [1 1])

    temp = iterate(space.space[state[1]],state[2])

    if temp == nothing
        state[1] += 1
        if (state[1] <= _nspace(space))
            temp = iterate(space.space[state[1]],1)
            state[2] = temp[2]
            return (temp[1],state)
        else
            return
        end


    else
        state[2] = temp[2]
        return (temp[1],state )
    end
end

# special length, prevent printing of the warning



function getindex(space::Multi_Space,i::Int)
    @assert typeintersect(eltype(space), Frame_Space) !=
                    eltype(space) "Framespace don't have efficient indexing"
    @assert length(space) >= i  "BoundsError index is to high "
    return  _getindex(space,i, 1)
end

function _getindex(space::Multi_Space,index::Int, state = 1)
    controle = length(space.space[state])
    if controle >= index
        @inbounds return space.space[state][index]
    else
        _getindex(space,index-controle,state+=1)
    end
end
