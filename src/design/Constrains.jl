import Base: +

abstract type AbstractConstrains{T} end

"""
Constrains with effect on the element that are allow in the constructs
"""
abstract type Element_Constrains{T} <: AbstractConstrains{T} end

"""
If no constrain is given
"""

struct No_Constrain{T} <: Element_Constrains{T}
    con :: T
end



"""
space contrains has effect on how the space is repesanted without real evaluation of the constructs
"""

abstract type Space_Constrains{T} <: Element_Constrains{T} end

"""
Single possition constrain. If allow = 1 it indicaces that only these construcst are allow.
if allow = 0is false thes models aren't allowed on this possition, for non position specific constrain pos = 0
"""

struct Compose_Space_Constrain{Ts <: Space_Constrains{T} where T} <: Space_Constrains{Ts}
    space_con::AbstractArray{Ts}
end

abstract type Single_Space_Constrains{T} <: Space_Constrains{T} end

struct Possition_Constrain{T} <: Single_Space_Constrains{T}
    pos::Int
    mod::T
end

# add two  space Constrains
Base.:+(con1::N  ,con2::N ) where N <: Single_Space_Constrains{T} where T = Compose_Space_Constrain([con1,con2])
# add to compose constrainse
Base.:+(con1::Compose_Space_Constrain,con2::Single_Space_Constrains) = Compose_Space_Constrain([con1.space_con;con2])
Base.:+(con1::Single_Space_Constrains,con2::Compose_Space_Constrain) = Compose_Space_Constrain([con2.space_con;con1])

Base.:+(con1::Compose_Space_Constrain,con2::Compose_Space_Constrain)  = Compose_space_Constrains([con1.space_con;con2.space_con])


abstract type Construct_Constrains{T} <: Element_Constrains{T} end

struct Compose_Construct_Constrains{T} <: Construct_Constrains{T}
    construct_con :: AbstractArray{T}
end

abstract type Single_Construct_Constrains{T} <: Construct_Constrains{T} end

struct UnOrdered_Constrain{T} <: Single_Construct_Constrains{T}
    combination::Array{T}
end


struct Ordered_Constrain{T} <: Single_Construct_Constrains{T}
    pos::Array{Int}
    combination::Array{T}
end


Base.:+(con1::Single_Construct_Constrains,con2::Single_Construct_Constrains) = Compose_Construct_Constrains([con1,con2])
Base.:+(con1::Compose_Construct_Constrains{T} where T, con2::N where N <: Single_Construct_Constrains) = Compose_Construct_Constrains([con1.construct_con;con2])
Base.:+(con1::Single_Construct_Constrains,con2::Compose_Construct_Constrains) = +(con2,con1)
Base.:+(con1::Compose_Construct_Constrains{T} where T, con2::Compose_Construct_Constrains{N} where N) = Compose_Construct_Constrains([con1.construct_con;con2.construct_con;])


#+(con1::Construct_Constrains,con2::Construct_Constrains...) = +(con1,+(con2...))

#promote_rule(::Type{Ordered_Constrain}, ::Type{UnOrdered_Constrain{T}}) = Construct_Constrains



"""
Group all elementconstrains
"""

struct Multipe_constrain{T<:Any, Ts<:Space_Constrains, Tc<:Construct_Constrains}  <: Element_Constrains{T}
    space_con:: Ts
    construct_con:: Tc
    function Multipe_constrain(space_con::Space_Constrains{T}, construct_con::Construct_Constrains{V}) where {T, V}
        return new{promote_type(T, V),typeof(space_con),typeof(construct_con)}(space_con,construct_con)
    end
end

Base.:+(con1:: Space_Constrains, con2:: Construct_Constrains) = Multipe_constrain(con1,con2)
Base.:+(con1:: Construct_Constrains, con2:: Space_Constrains) = Multipe_constrain(con2,con1)


Base.:+(con1::Multipe_constrain,con2::Construct_Constrains) = Multipe_constrain(con1.space_con, +(con1.construct_con,con2))
Base.:+(con1::Multipe_constrain,con2::Space_Constrains) = Multipe_constrain(+(con1.space_con,con2),con1.construct_con)

Base.:+(con1::Construct_Constrains,con2::Multipe_constrain) = Multipe_constrain(con2,con1)
Base.:+(con1::Space_Constrains,con2::Multipe_constrain) =  Multipe_constrain(con2,con1)

Base.:+(con1::Multipe_constrain,con2::Multipe_constrain) =  Multipe_constrain(con1.space_con + con2.space_con, con1.construct_con + con2.construct_con)

# fucntion(con1::Multipe_constrain,con2::Space_Constrains)

Base.:+(con1::Element_Constrains,con2::Element_Constrains...) = +(con1,+(con2...))

"""
Group length and constrains to one object
"""
abstract type Full_Constrain{T} <: AbstractConstrains{T} end


"""
Gives an specific lenth to given constrains
"""

struct Len_Constrain{T} <: Full_Constrain{T}
    len::Int
    el_con::Element_Constrains{T}
end


struct Group_Len_Constrain{T} <: Full_Constrain{T}
    group::Tuple{T}
end

group_len_constrain(con1::Len_Constrain,con2::Len_Constrain) = Group_Len_Constrain(Tuple(con1,con2))
group_len_constrain(con1::Len_Constrain,con2::Len_Constrain...) = Group_Len_Constrain(Tuple(con1,Tuple(con2...)))
