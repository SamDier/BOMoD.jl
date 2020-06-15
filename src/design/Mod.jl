

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


Evaluates the order of two modules based on the input characters,
needed to allow sorting.
How sorting is done isn't important for the model;
it only assures a specific rank between different modules.
For more information on how the different inputs are sorted exactly
[see](https://docs.julialang.org/en/v1/base/base/)
"""
isless(mod1::Mod, mod2::Mod) = isless(mod1.m,mod2.m)

"""
    isequal(mod1::Mod, mod2::Mod)

Evaluates if two modules are equal
for more infromation [see](https://docs.julialang.org/en/v1/base/base/)
"""
isequal(mod1::Mod, mod2::Mod) = isequal(mod1.m,mod2.m)

"""
    length(mod1::Mod)

length of module, is 1
"""

Base.length(mod1::Mod) = 1

"""
    GroupMod{N <: Mod{T} where T}

Structure to group multiple modules.
The input values are first filtered to prevent duplicated modules.
Afterwards, the modules are sorted to give consistent results even if modules are
oad in a different order.
"""
struct GroupMod{N <: Mod{T} where T} <: AbstractMod{N}
    m::Array{N}
    GroupMod(m) =  m |> Set |> collect |> sort |> (y -> new{eltype(m)}(y))
end

"""
    group_mod(input::Array{T} where T)

A Function to facilitate the input of multiple modules. It returns a "Group_mod"
structure. The input is an array containing the data that needs to be transformed
to an ``Mod`` and grouped afterwards. See [`Group_mod`](@ref)

"""
groupmod(input::Array{T} where T) = GroupMod([Mod(newmod) for newmod in input])

"""
    iterate(Group::GroupMod,state =1 )

Extensions of ``Base.iterate`` for modules of type ``Group_Mod``
for more infromation [see](https://docs.julialang.org/en/v1/manual/interfaces/)
"""
function Base.iterate(Group::GroupMod,state =1 )
    if  state <= length(Group.m)
        mod = Group.m[state]
        state += 1
        return (mod,state)
    else
        return
    end
end

"""
    length(m::GroupMod)

Returns the number of `Mod` in `m`.
"""
Base.length(m::GroupMod) = length(m.m)

"""
    eltype(m::GroupMod)

Returns the type of the iterator.
"""
Base.eltype(::GroupMod{T}) where {T} = T

"""

"""
Base.getindex(m::GroupMod,i) = m.m[i]

function Base.show(io::IO,m::GroupMod)
    s = [mi.m for mi in m.m]
    s = replace(string(s), "[" => "{") |> x->  replace(x, "]" => "}")
    print(io,"{GroupMod}$s")
end
