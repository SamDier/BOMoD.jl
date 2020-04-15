#import Base: *,+,push!,split


"""
    AbstractMod{T}

Abstract type for all Modueles of type T

"""
abstract type AbstractMod{T} end

"""
    Mod{T} <: AbstractMod{T}

Structure to store one specific modules of type{T}

"""

# problem input as array in unique gives an error if dims = 2 not added... ne
struct Mod{T} <: AbstractMod{T}
    m::T
end

# some base base function for the new type
"""
    isless(mod1::Mod, mod2::Mod)

Extationtions of ``Base.isless`` for modules of type Mod
for more infromation [see](https://docs.julialang.org/en/v1/base/base/)
"""
Base.isless(mod1::Mod, mod2::Mod) = isless(mod1.m,mod2.m)

"""
    isequal(mod1::Mod, mod2::Mod)

Extationtions of ``Base.isequal`` for modules of type ``Mod``
for more infromation [see](https://docs.julialang.org/en/v1/base/base/)
"""
Base.isequal(mod1::Mod, mod2::Mod) = isequal(mod1.m,mod2.m)

"""
    Group_Mod{N <: Mod{T} where T} <: AbstractMod{N}

Structure to group multiple modules.
The input values are first filtered to prevent duplicated modules.
Afterwards, the modules are sorted to give consistent results even if modules are load in a different order.
"""

struct Group_Mod{N <: Mod{T} where T} <: AbstractMod{N}
    m::Array{N}
    Group_Mod(m) =  m |> Set |> collect |> sort |> (y -> new{eltype(m)}(y))
end

"""
    group_mod(input::Array{T} where T)

A Function to facilitate the input of multiple modules. It returns a "Group_mod" structure.
The input is an array containing the data that needs to be transformed to an ``Mod`` and grouped afterwards. See
[`Group_mod`](@ref)

```jldoctest
Mods = [:a,:b,:c]
grouped_mods = group_mod(Mods)
isa(grouped_mods,Group_Mod)

# output

true
```
"""
group_mod(input::Array{T} where T) = Group_Mod([Mod(newmod) for newmod in input])

"""
    Base.iterate(Group::Group_Mod,state =1 )

Extationtions of ``Base.iterate`` for modules of type Mod
for more infromation [see](https://docs.julialang.org/en/v1/manual/interfaces/)
"""
function Base.iterate(Group::Group_Mod,state =1 )
    if  state <= length(Group.m)
        mod = Group.m[state]
        state += 1
        return (mod,state)
    else
        return
    end
end
