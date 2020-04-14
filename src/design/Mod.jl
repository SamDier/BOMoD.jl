#import Base: *,+,push!,split


"""
Abstract type for a moduele of type T

"""
abstract type AbstractMod{T} end

"""
Structure to store a specific modules fo type{T}
"""

# problem input as array in unique gives an error if dims = 2 not added... ne
struct Mod{T} <: AbstractMod{T}
    m::T
end

Base.isless(mod1::Mod, mod2::Mod) = isless(mod1.m,mod2.m)
Base.push!(mod1::Mod,s::Set) = push!(S,mod1)
Base.isequal(mod1::Mod, mod2::Mod) = isequal(mod1.m,mod2.m)

struct Group_Mod{N <: Mod{T} where T} <: AbstractMod{N}
    m::Array{N}
    Group_Mod(m) =  m |> Set |> collect |> sort |> (y -> new{eltype(m)}(y))
end

"""
group_mod(input::Array{T} where T)

function to input the user diffient moduels
"""
group_mod(input::Array{T} where T) = Group_Mod([Mod(newmod) for newmod in input])

function Base.iterate(Group::Group_Mod,state =1 )
    if  state <= length(Group.m)
        mod = Group.m[state]
        state += 1
        return (mod,state)
    else
        return
    end
end




struct Group_Moduel_Pos{T} <: AbstractMod{T}
    pos::Int
    m::T
    Group_Moduel_Pos(m) = m |> Set |> collect |> sort |> (y -> new{typeof(m)}(pos,y))
end

Base.length(mod::Group_Mod) = length(mod.m)
Base.length(m::Mod) = 1
