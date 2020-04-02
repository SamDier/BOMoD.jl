#import Base: *,+,push!,split


"""
Abstract type for a moduele of type T

"""
abstract type AbstractMod{T} end

"""
Structure to store a specific module fo type{T}
"""

# problem input as array in unique gives an error if dims = 2 not added... ne
struct Mod{T} <: AbstractMod{T}
    m::T
end


struct Group_Mod{N <: Mod{T} where T} <: AbstractMod{N}
    m::Array{N}
    Group_Mod(m) = m |> unique! |> sort! |> (y -> new{eltype(m)}(y))
end
Base.isless(mod1::Mod, mod2::Mod) = isless(mod1.m,mod2.m)
group_mod(input::Array{T} where T) = Group_Mod([Mod(newmod) for newmod in input])

#=
Base.:+(m1::Mod{T} where T,m2::Mod{T} where T) = Group_Mod([m1 ,m2])
Base.:+(m1::Group_Mod ,m2::Mod{T} where T) = Group_Mod([m1.m...  , m2])
Base.:+(m2::Mod{T} where T , m1::Group_Mod) = Group_Mod([m1.m... ,  m2])
Base.:+(m1::Group_Mod,m2::Group_Mod) = Group_Mod([m1.m...,  m2.m...])
Base.:+(m1::AbstractMod,m2::AbstractMod...) = +(m1,+(m2...))
=#
Base.:+(m1::Mod{T} where T,m2::Mod{T} where T) = Group_Mod([m1 ,m2])
Base.:+(m1::Group_Mod ,m2::Mod{T} where T) = Group_Mod([m1.m; m2])
Base.:+(m2::Mod{T} where T , m1::Group_Mod) = Group_Mod([m1.m;  m2])
Base.:+(m1::Group_Mod,m2::Group_Mod) = Group_Mod([m1.m;  m2.m])
Base.:+(m1::AbstractMod,m2::AbstractMod...) = +(m1,+(m2...))


struct Group_Moduel_Pos{T} <: AbstractMod{T}
    pos::Int
    m::T
    Group_Moduel_Pos(m) = m |> unique! |> sort! |> (y -> new{typeof(m)}(pos,y))
end

Base.length(mod::Group_Mod) = length(mod.m)
Base.length(m::Mod) = 1



#Base.push!(m1::Moduels{T} where T <: AbstractArray ,m2::Moduels{T} where T ) = push!(m1.m,m2.m) |> Moduels
#split(m::Moduels{T} where T <: AbstractArray) = reshape([Moduels(i) for i in m.m],length(m),1);
