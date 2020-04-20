abstract type AbstractConstruct{T} end
######################################
# Base functionalities for AbstractConstruct
######################################

"""
    eltype(::AbstractConstruct)

Returns the type that is generated by the iterator on an `AbstractConstruct` structure
"""
Base.eltype(::AbstractConstruct{T}) where {T} = T

#CHANGED: in general, if you extend functions from Base or elsewhere, you don't
# have to put this in the docstring
"""
    getindex(Construct::AbstractConstruct,i::Int)

Returns the module on the i-th possition in the construct
Output of type `Mod`
"""
Base.getindex(c::AbstractConstruct,i::Int) = c.c[i]

#FIXME: don't understand this docstring...
"""
    getindex(Construct::AbstractConstruct,i::UnitRange)

Returns a subpart of the original construct using the indexes of the `UnitRange`
object. It is an extention to allow UnitRange indexing on a `AbstractConstruct`.
The type of output type is similar as the larger input construct.
"""
Base.getindex(c::AbstractConstruct,i::UnitRange) = c.c[i] |> typeof(c)

"""
    length(Construct::AbstractConstruct)

Returns the length of the input construct, i.e., the number of modules that are
used.
"""
Base.length(c::AbstractConstruct) = length(c.c)

"""
    lastindex(Construct::AbstractConstruct)

Returns the length of the input construct, the number of modules that are used.
"""
Base.lastindex(c::AbstractConstruct) =  last(eachindex(IndexLinear(), c.c))

#NOTE: again, `size` does not make sense to me, only `length`
#QUESTION: what is the deal with `end`? Not clear.
"""
    size(Construct::AbstractConstruct)

Returns the size a construct, a tuple of two dimensions. The first is the length
of the construct the second equals to one (1D constructs).
Allows to use of `end` when indexing on a construct to obtain the last module.
"""
Base.size(c::AbstractConstruct) = (length(c.c),1)

#QUESTION: does c1 == c2 work then?
"""
    isequal(c1::AbstractConstruct,c2::AbstractConstruct)

Evaluates if two constructs are equal. If the the type of to constructs differces
If the type of two constructs aren't equal, it returns `false`, even if the same modules are present.
"""
isequal(c1::AbstractConstruct,c2::AbstractConstruct) = typeof(c1) == typeof(c2) ? isequal(c1,c2) : false

"""
    iterate(Construct::AbstractConstruct,state=1)

Iterator to loop over all modules in a given construct.
"""
function Base.iterate(Construct::AbstractConstruct,state=1)
    if  state <= length(Construct)
        mod = Construct[state]
        state += 1
        return (mod,state)
    else
        return
    end
end


##################
#New structs
##################

#FIXME: name: OrderedConstruct (and elsewhere)
"""
    Ordered_Construct{T}  <: AbstractConstruct{T}

Structure that contains an ordered construct. In an ordered construct, the order
of the different modules is important.

For example: `Ordered_Construct([a,b,c])` is different compared to
`Ordered_Construct([c,b,a])`.
"""
struct Ordered_Construct{T<:Mod}  <: AbstractConstruct{T}
    c::Array{T}
end

"""
    isequal(c1::Ordered_Construct,c2::Ordered_Construct)

Evaluates if two Ordered_Construct constructs are equal.
"""
Base.isequal(c1::Ordered_Construct,c2::Ordered_Construct) = isequal(c1.c,c2.c)

"""
    *(m1::Mod, m2::Mod)

Returns a `Ordered_Construct` containing both modules `m1` and `m2`. The order of
the input argument is maintained in the returned construct.

To allow efficient on the fly calculation using Kronecker product, the `Base.*`
should be defined between two `Mod`.
"""
*(m1::Mod, m2::Mod) = Ordered_Construct([m1, m2])

#CHANGED: note that I try to limit the line length.
"""
    Base.*(c::Ordered_Construct , m::Mod)

Returns a new `Ordered_Construct` where the module `m` is concatenated to the
end of the input construct `c`.
"""
*(c::Ordered_Construct, m::Mod) = push!(c.c,m) |> Ordered_Construct

"""
    *(m::Mod, c::Ordered_Construct)

Returns a new `Ordered_Construct` where the module `m` is concatenated in front
of the input construct `c`.

Probably less efficient than `*(c::Ordered_Construct ,m::Mod)` because of a
`firstpush!`
"""
*(m::Mod, c::Ordered_Construct) = pushfirst!(c.c,m) |> Ordered_Construct

"""
    *(c1::Ordered_Construct,c2::Ordered_Construct)

Concatenated two ordered constructs `c1` and `c2`,
where the construct that is in the second argument position will be appended to the end of the construct in the first argument position

```jldoctest
m1 = Mod("a")
m2 = Mod("b")
m3 = Mod("c")
c1 = Ordered_Construct([m1,m2])
c2 = Ordered_Construct([m1,m3])
c1*c2

# output
Ordered_Construct([m1,m2,m1,m4])
```
"""

*(c1::Ordered_Construct ,c2::Ordered_Construct) = vcat(c1.c,c2.c) |> Ordered_Construct
"""
    Unordered_Construct{T} <: AbstractConstruct{T}

Structure that contains an unordered construct. In unordered construct, the
order of the different modules has no meaning.

For example: `Unordered_Construct([a,b,c])` is considered equal to
`Unordered_Construct([c,b,a])`.
"""
# currently the underlying structure is an array, a Set is can be a more logical alternative
# still for the first implementation and test, an array structure was preferred. An array can always be transformed Set where needed.
# The users shouldn't worry too much about this more to run everything smoothly internally

struct Unordered_Construct{T<:Mod} <: AbstractConstruct{T}
    c::Array{T}
end

"""
    +(m1::Mod,m2::Mod)

Returns a `Unordered_Construct` containing both modules `m1` and `m2`. Order of input argument is maintained in the returned construct.
The order of the modules doesn't have useful meaning, but it has some advantages internally to keep the order.
"""

+(m1::Mod,m2::Mod) = Unordered_Construct([m1,m2])

# FIXME: this docstring does not match
"""
    Base.*(c::Unordered_Construct ,m::Mod)

Returns a new `Unordered_Construct` where the module `m` is concatenated to the
end of the input construct `c`.
"""
+(c::Unordered_Construct, m::Mod) = push!(c.c,m) |> Unordered_Construct

# FIXME: this docstring does not match
"""
    Base.*(c::Ordered_Construct, m::Mod)

Returns a new `Unordered_Construct` where the module `m` is concatenated in front
of the input construct `c`
"""
+(m::Mod, c::Unordered_Construct) = pushfirst!(c.c,m) |> Unordered_Construct

# FIXME: this docstring does not match
"""
    *(c1::Unordered_Construct, c2::Unordered_Construct)

Concatenated two `Unordered_Construct` `c1` and `c2`,
where the construct that is in the second argument position will be appended to
the end of the construct in the first argument position
"""
+(c1::Unordered_Construct, c2::Unordered_Construct) = vcat(c1.c, c2.c) |> Unordered_Construct

"""
    Base.isequal(c1::Unordered_Construct, c2::Unordered_Construct)

Evaluates if two `Unordered_Construct` are equal.
"""
Base.isequal(c1::Unordered_Construct, c2::Unordered_Construct) = isequal(Set(c1.c),Set(c2.c))
