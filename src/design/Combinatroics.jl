
# FIXME: Combinatroics.jl => Combinatrorics.jl
# FIXME Combinatroics => Combinatroics elsewhere in the file as well

abstract type Combinatroics{T} <: AbstractArray{T,1} end


"""
    Combination{T} <: Combinatroics{T}

Structure to generate all combinations of the given modules with given length
low_level structure that a user do not need to use, normaly

Fields:
    - `mod`: Array with modulels or where combination can be generated from
    - `len`: lenght of the made constructs
"""
struct Combination{T} <: Combinatroics{T}
    mod::Array{T}
    len::Int
end

# base types of
Base.length(c::Combination) = binomial(length(c.mod),c.len);
Base.size(c::Combination) = (length(c),1);  #NOTE: I think size does not make sense for your purposes, consider removing
#NOTE: returning (n, 1) size also does not make sense....
#Base.eltype(K::Combination{T}) where {T} = Unordered_Construct{N} where N <: eltype(T) ;
Base.eltype(K::Combination{T}) where T = Unordered_Construct{T} ;

#REVIEW: this function is quite complex, maybe split?
"""
    iterate(c::Combination{T} where T, state = [i for i in c.len:-1:1])

Iterater for Combinations, printed in lexicographical order.
"""
function Base.iterate(c::Combination{T} where T, state = [i for i in c.len:-1:1])
    #FIXME: `max` is also a function, rather use `n`?
    max = length(c.mod)

    if c.len == 1 # special case len = 1 ( needed?)
        if state[1] <= max
            construct = [c.mod[state[1]]]
            state[1] +=1
            return (Unordered_Construct(construct), state)
        else
            return
        end
    end
    # check when done, last constructed is printed
    if state[1] > max
        return nothing
    end

    # make the current construct based on given state
    construct = sum(c.mod[state])

    # update the state
    # i start at the last index, length of the construct
    i = c.len
    #evaluated if the difference between the last and the next is higher than 1 (than their is still a construct that can be made)
    # if not than lower the index with one and recheck if the difference is 1 . i>1 prevents error
    while i > 1  && state[i-1] - state[i] == 1
        i -=1
    end
    # upate the state at position i and reset all higher index to lowest values
    if i < c.len
        state = _restate(state,i)
    else
        state[i] +=1
    end
    return (construct,state)
end;

"""
    _restate(state, i)

Update state at index i and reset all values behind to lowsted allow values.
function used in the Base.iterate(c::Combination{T} where T, state = [i for i in c.len:-1:1])
"""
function _restate(state, i)
    state[i] +=1;
    state[(i+1):end] = collect(length(state)-i:-1:1);
    return state
end

"""
    function getindex(c::Combination,pos::Int)

Get the index of `c` at position `pos`.

Index based on rank Combination.
https://en.wikipedia.org/wiki/Combinatorial_number_system
"""
function getindex(c::Combination,pos::Int)

    # spacial case of lenght is 1
    if c.len == 1
        return Unordered_Construct([c.mod[pos]])
    end
    # if not 1
    com = Array{Int}(undef, c.len, 1)
    for i in c.len:-1:1
        n = i-1
        b_val = binomial(n,i)
        while b_val < pos
            n += 1
            b_val = binomial(n,i)
        end
        pos -= binomial(n-1,i)
        com[c.len-i+1] = n-1
    end
    index =  com .+=1
    return (sum(c.mod[index]))
end;
