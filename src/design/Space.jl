
abstract type AbstractSpace{T} end

"""
    EffSpace{T}  <: AbstractSpace{T}

`EffSpace{T}` is a type for efficient design spaces.
This means that they implement the functions  `size`, `length`, `sample`,
`getindex` can be used without the construction of all possible constructs in the
space. Explicit calculation of all constructs is still possible.
"""
abstract type EffSpace{T}  <: AbstractSpace{T} end

"""
  Base.summary(io::IO, a::EffSpace)

provoides a summary of `a`
"""
function Base.summary(io::IO, a::EffSpace)
    space_type,n = typeof(a),length(a)
    print(io,"$n-element $space_type")
end

function Base.show(io::IO,a::EffSpace)
    space_type,construct_type,n = typeof(a),eltype(a),length(a)
    print(io," spacetype| $space_type \n generted constructs| $construct_type \n n_consturcts| $n")
end

"""
    getindex(space::EffSpace,i::Int)

Returns the construct on the i-th possition in the design space.
"""

Base.getindex(space::EffSpace,i::Int) = space.space[i]
"""
    getindex(space::EffSpace,A::Array)

Returns a vector of constructs out of `space` corresponding to the indices in `A`.
"""
Base.getindex(space::EffSpace,A::Array) = map(i -> space.space[i], A)

"""
    length(space::EffSpace)

Returns the number of constructs in the `space`.
"""
Base.length(space::EffSpace) = length(space.space)


"""
    iterate(space::EffSpace, state = 1)

Creates an iterater object for an `EffSpace`.
"""
function Base.iterate(space::EffSpace, state = 1 )
    if  state <= length(space)
        construct = space[state]
        state += 1
        return (construct,state)
    else
        return
    end
end


"""
    FullOrderedspace{T}

`EffSpace{T}` space type for space filled with `OrderedConstruct` and without any constraints.
"""
struct FullOrderedspace{T}<: EffSpace{T}
    space::KroneckerPower{T}
end

"""
    _show(a::FullOrderedspace)

specific part of `show(io::IO,a::EffSpace)` for `FullOrderedspace`
"""
function _show(a::FullOrderedspace)
    print("order| true ")
    first_constructs = a[1:3]
    last_constructs = a[end]
    print("first_constructs| $first_constructs\n    .   \n    .   \n    . \n $last_constructs ")
end


"""
    eltype(::Type{FullOrderedspace)

Returns the type of `FullOrderedspace{T}` if they are collected.
"""
Base.eltype(::Type{FullOrderedspace{T}}) where {T} = OrderedConstruct{T}


"""
    FullUnorderedspace{T}

`EffSpace{T}` space type for space filled with `UnorderedConstruct` and without any constraints
"""
struct FullUnorderedspace{T}<: EffSpace{T}
    space::Combination{T}
end

"""
    _show(a::FullUnorderedspace)

specific part of `show(io::IO,a::EffSpace)` for `FullOrderedspace`
"""
function _show(a::FullOrderedspace)
    print("order: is true ν")
    first_constructs = a[1].c
    print("first construct is = $first_constructs")
end



"""
    eltype(::Type{FullUnorderedspace{T}}) where {T}

Returns the type of `FullUnorderedspace{T}` if they are collected.
"""
Base.eltype(::Type{FullUnorderedspace{T}}) where {T} = UnorderedConstruct{T}


function _show(a::FullOrderedspace)
    print("order: is true ν")
    first_construct = a[1].c
    print("first construct is = first_construct")
end

"""
    ComputedSpace{T}

`EffSpace{T}` space type for space where all constructs are explicitly generated.
"""
struct ComputedSpace{T} <: EffSpace{T}
    space::T
end

"""
    eltype(::Type{ComputedSpace)

Return the type of `ComputedSpace` when they are collected.
"""
Base.eltype(::Type{ComputedSpace{T}}) where {T} = eltype(T)


"""
    FrameSpace{T, Tc <: ConstructConstraints}

Structure generated for a space where no efficient alterative is implented currently.
The closed efficient design space is stored together with the uncheck Constraints.
"""
struct FrameSpace{Ts <: EffSpace{T} where T, Tc <: ConstructConstraints} <: AbstractSpace{Ts}
    space::Ts
    con::Tc
end



# getindex seem not very usefull in this case
getindex(space::FrameSpace ,i::Int) = @error "no efficient indexing, first use getspace function to generated the full space"

"""
    iterate(space::FrameSpace, state = 1)

Creates iterater object for an `FrameSpace`. Filters the not allowed constructs
"""
function Base.iterate(space::FrameSpace, state = 1 )
    # make costruct

    if  state > length(space.space)
        return
    end

    construct = space.space[state]

    #evaluated Constraints
    while filterconstraint(construct, space.con) == true
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
    length(space::FrameSpace)

Fallback to calculate the length FrameSpace.
Inefficient calculation has tot iterated overall allowed constructs.
"""

function Base.length(space::FrameSpace)
    #NOTE: not sure if you use `@warn` correctly, please check!
    @info "No efficient calculation iterate to all allowed options to get the length"
    len = 0
    for i in space
        len +=1
    end

    return len
end

"""
    eltype(K::FrameSpace)

Returns the type of `FrameSpace{T}` if they are collected.
"""
Base.eltype(K::FrameSpace{T}) where {T} = eltype(K.space)


struct MultiSpace{T} <: AbstractSpace{T}
    space::Array{T}
    MultiSpace(space::Array) = promote_type([typeof(i) for i in space]...) |> x -> new{x}(space)
end

Base.eltype(::MultiSpace{T}) where {T} = eltype(T)

"""
    length(space::MultiSpace)

Returns the number of constructs in the `space`.
"""
Base.length(space::MultiSpace) = map(x -> length(x),space.space) |> sum

"""
    nspace(space::MultiSpac)

Return the number of single space that are used to construct the whole `space`
"""


_nspace(space::MultiSpace) = length(space.space)

"""
    Base.size(space::MultiSpace)

Returns a tuple of two numbers, the first position contains the number of
constructs in the whole `space`. The second number is the number of single space
that are construct the entire design space
"""
Base.size(space::MultiSpace) = (length(space), _nspace(space))

# chained the signal iterators, can be done with Base.Iterators.flatten(space.space) but less consistent with other spaces.

"""
    Base.iterate(space::MultiSpace)

Returns a tuple of two numbers, the first position contains the number of
constructs in the `space`. The second number is the number of `sing` that are
used to construct the entire design space
"""
function Base.iterate(space::MultiSpace, state = [1 1])

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



function getindex(space::MultiSpace,i::Int)
    @assert typeintersect(eltype(space), FrameSpace) !=
                    eltype(space) "Framespace don't have efficient indexing"
    @assert length(space) >= i  "BoundsError index is to high "
    return  _getindex(space,i, 1)
end

function _getindex(space::MultiSpace,index::Int, state = 1)
    controle = length(space.space[state])
    if controle >= index
        @inbounds return space.space[state][index]
    else
        _getindex(space,index-controle,state+=1)
    end
end
