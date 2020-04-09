abstract type Combinatroics{T} <: AbstractArray{T,1} end



#Base.IndexStyle(::Type{<:Combinatroics}) = IndexCartesian()
"""
Structure to generated all Combinations of the given moduels with given lenght

"""
struct Combination{T} <: Combinatroics{T}
    mod::T
    len::Int
end
Base.length(c::Combination) = binomial(length(c.mod),c.len);
Base.size(c::Combination) = (length(c),1);
Base.eltype(K::Combination{T}) where {T} = T;


"""
Base.iterate(c::Combination{T} where T, state = [i for i in c.len:-1:1])
Iterater for Combinations, printed in lexicografical order.
"""
function Base.iterate(c::Combination{T} where T, state = [i for i in c.len:-1:1])
    max = length(c.mod)

    if c.len == 1 # special case len = 1
        if state[1] <= max
            construct = [c.mod[state[1]]]
            state[1] +=1
            return (Unordered_Construct(construct),state)
        else
            return
        end
    end
    # check when done

    if state[1] > max
        return nothing
    end
    # make the construct
    construct = sum(c.mod[state])
    # update the state
    # i start at the last index, length of the construct
    i = c.len
    #evaluated if the difference between the last and the next is higher than 1 ( still a construct that can be made)
    # if not than lower the index with one. i>1 prevents error
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
_restate(state,i)
 Update state at index i and rest all values behind to lower values.
 use iterater for combinations
"""
function _restate(state,i)
    state[i] +=1;
    state[(i+1):end] = collect(length(state)-i:-1:1);
    return state
end

"""
Base.getindex(Combination,pos)

Index based on rank Combination.
https://en.wikipedia.org/wiki/Combinatorial_number_system
"""
function getindex(c::Combination,pos::Int,pos2=1)
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
