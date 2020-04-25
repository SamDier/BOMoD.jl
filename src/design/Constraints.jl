
#NOTE: Not immediately clear what this does...

#TODO: add explanations.
#import Base: +
"""
    AbstractConstraints{T}

Abstract type for all possible constructs.
"""
abstract type AbstractConstraints{T} end

# FIXME: using the style guide (https://docs.julialang.org/en/v1/manual/style-guide/index.html),
# one uses `ElementConstraints` no underscores for types.

"""
    ElementConstraints{T}

Abstract Constraints with effect on the element that are allow in the constructs.
"""
abstract type ElementConstraints{T} <: AbstractConstraints{T} end


"""
    NoConstraint{T}

If no constraint is given.
"""
struct NoConstraint{T} <: ElementConstraints{T}
    con :: T
end


"""
    ConstructConstraints{T}

Constraints that are applicable on a generated construct.
These can only be used in a filter with isn't very effiecent for large design
space.
"""
abstract type ConstructConstraints{T} <: ElementConstraints{T} end


"""
    SingleConstructConstraints{T}

Abstract type for one single constraint.
"""
abstract type SingleConstructConstraints{T} <: ConstructConstraints{T} end


"""
    UnOrderedConstraint{T<:Mod}

an unorderedConstraint is a group of modules that cannot co-occur in one construct.
These group is given as:  ``Array{T,1} where T <: Mod``
This constraint is unorder because the location of these models in the constructed
is not considered

For more information see [`filterconstrain`]@ref
"""
struct UnOrderedConstraint{T<:Mod} <: SingleConstructConstraints{T}
    combination::Array{T}
end


#FIXME: docstring not clear...
"""
    OrderedConstraint{T<:Mod}

Order Constraints a group of modules that can not co-occur in one construct if
these modules are in a specific position.
Order because the location of these models in the constructed is used in the
evaluation of the constraint.

These modules are given as ``Array{T} where T <: Mod``
The corresponding positions are ``Array{::Int}``, these are the forbidden indexes for the corresponding module.

For more information see [`filter_constrain`]@ref.

"""
struct OrderedConstraint{T<:Mod} <: SingleConstructConstraints{T}
    pos::Array{Int}
    combination::Array{T}
end


"""
    ComposeConstructConstraints{T}

Constraint that are applicable on a generated construct.
These can only be used in a filter that is not very efficient for large design
spaces.
"""
struct ComposeConstructConstraints{T <: SingleConstructConstraints} <: ConstructConstraints{T}
    constructcon :: Array{T}
end

Base.eltype(K::ComposeConstructConstraints{T}) where {T} = T


# concentration of multiple Constraints can be done using + sign

"""
    +(con1::SingleConstructConstraints,con2::SingleConstructConstraints)

Returns a `ComposeConstructConstraints` containing both Constraints `con1` and `con2`.
"""
Base.:+(con1::SingleConstructConstraints,con2::SingleConstructConstraints) = ComposeConstructConstraints([con1,con2])

"""
    Base.:+(con1::ComposeConstructConstraints{T} where T, con2::N where N <: SingleConstructConstraints)

Returns a `ComposeConstructConstraints` containing where `con2` is add to the `con1`
"""

Base.:+(con1::ComposeConstructConstraints{T} where T, con2::N where N <: SingleConstructConstraints) = ComposeConstructConstraints([con1.constructcon;con2])

"""
    Base.:+(con1::SingleConstructConstraints,con2::ComposeConstructConstraints)

Returns a `ComposeConstructConstraints` containing where `con1` is add to the `con2`
"""
Base.:+(con1::SingleConstructConstraints,con2::ComposeConstructConstraints) = +(con2,con1)

"""
    Base.:+(con1::ComposeConstructConstraints{T} where T, con2::ComposeConstructConstraints{N} where N)

Returns a `ComposeConstructConstraints` concatenation of `con1` and `con2`
"""
Base.:+(con1::ComposeConstructConstraints{T} where T, con2::ComposeConstructConstraints{N} where N) = ComposeConstructConstraints([con1.constructcon;con2.constructcon;])


##################################
# Code below has currently no application in the package, this will probably not change shortly
# The idea is that for some constraints, we can prevent that unwanted constructs are generated, instead of generational filtering afterwards.
# To allow this a special type was constructed and see how it good be implemented
# No need to check,
#################################

#=
"""
space contrains has effect on how the space is repesanted without real evaluation of the constructs
"""

abstract type Space_Constraints{T} <: ElementConstraints{T} end

"""
Single possition constrain. If allow = 1 it indicaces that only these construcst are allow.
if allow = 0is false thes models aren't allowed on this possition, for non position specific constrain pos = 0
"""

struct Compose_Space_Constrain{Ts <: Space_Constraints{T} where T} <: Space_Constraints{Ts}
    space_con::AbstractArray{Ts}
end

abstract type Single_Space_Constraints{T} <: Space_Constraints{T} end

struct Possition_Constrain{T} <: Single_Space_Constraints{T}
    pos::Int
    mod::T
end

# add two  space Constraints
Base.:+(con1::N  ,con2::N ) where N <: Single_Space_Constraints{T} where T = Compose_Space_Constrain([con1,con2])
# add to compose Constraintse
Base.:+(con1::Compose_Space_Constrain,con2::Single_Space_Constraints) = Compose_Space_Constrain([con1.space_con;con2])
Base.:+(con1::Single_Space_Constraints,con2::Compose_Space_Constrain) = Compose_Space_Constrain([con2.space_con;con1])

Base.:+(con1::Compose_Space_Constrain,con2::Compose_Space_Constrain)  = Compose_space_Constraints([con1.space_con;con2.space_con])

Base.:+(con1::Element_Constraints,con2::Element_Constraints...) = +(con1,+(con2...))
"""
Group all elementConstraints
"""

struct Multipe_constrain{T<:Any, Ts<:Space_Constraints, Tc<:Construct_Constraints}  <: Element_Constraints{T}
    space_con:: Ts
    construct_con:: Tc
    function Multipe_constrain(space_con::Space_Constraints{T}, construct_con::Construct_Constraints{V}) where {T, V}
        return new{promote_type(T, V),typeof(space_con),typeof(construct_con)}(space_con,construct_con)
    end
end

Base.:+(con1:: Space_Constraints, con2:: Construct_Constraints) = Multipe_constrain(con1,con2)
Base.:+(con1:: Construct_Constraints, con2:: Space_Constraints) = Multipe_constrain(con2,con1)


Base.:+(con1::Multipe_constrain,con2::Construct_Constraints) = Multipe_constrain(con1.space_con, +(con1.construct_con,con2))
Base.:+(con1::Multipe_constrain,con2::Space_Constraints) = Multipe_constrain(+(con1.space_con,con2),con1.construct_con)

Base.:+(con1::Construct_Constraints,con2::Multipe_constrain) = Multipe_constrain(con2,con1)
Base.:+(con1::Space_Constraints,con2::Multipe_constrain) =  Multipe_constrain(con2,con1)

Base.:+(con1::Multipe_constrain,con2::Multipe_constrain) =  Multipe_constrain(con1.space_con + con2.space_con, con1.construct_con + con2.construct_con)

# fucntion(con1::Multipe_constrain,con2::Space_Constraints)



"""
Group length and Constraints to one object
"""
abstract type Full_Constrain{T} <: AbstractConstraints{T} end


"""
Gives an specific lenth to given Constraints
"""

struct Len_Constrain{T} <: Full_Constrain{T}
    len::Int
    el_con::Element_Constraints{T}
end


struct Group_Len_Constrain{T} <: Full_Constrain{T}
    group::Tuple{T}
end

group_len_constrain(con1::Len_Constrain,con2::Len_Constrain) = Group_Len_Constrain(Tuple(con1,con2))
group_len_constrain(con1::Len_Constrain,con2::Len_Constrain...) = Group_Len_Constrain(Tuple(con1,Tuple(con2...)))
=#
