#BoMod  Documentation
 Acitvated the package

 ```julia
using BOMoD
 ```

### Some Key concepts
Start of Combinatorial problem terms need to be clarified
1) **A module:** A single element with no given features
2) **A Construct:**  Made from combinations of modules.
3) **A constrain:** A specific combination of elements that isn't allowed in the construct.
4) **A Space:**

## Set up the design space:
A single module can is introduced as. Currentely modules are type String or type Symbol

### Group modules
Multiple modules are needed to make a construct and need to be grouped. The grouped modules are ordered to have reproducible results. Duplicated modules are removed.
Modules can be a group in different ways, all result are equal.

1) Group modules of an array of
    ´´´julia
    ´´´
2) sum different modules
3) group module function of array


abstract type Mod{T} end

"""
Structure to store the different modules that are used in the constructs. Only unique elements are kept.
"""

# problem input as array in unique gives an error if dims = 2 not added... ne
struct Moduel{T} <: Mod{T}
    m::T
end


struct Group_Moduels{Tm <: Moduels{T} where T} <: Mod{Tm}
    m::Array{Tm}
    Group_Moduels(m) = m |> unique! |> sort! |> (y -> new{typeof(m)}(y))
end

Base.:+(m1::Moduels{T} where T,m2::Moduels{T} where T) = Group_Moduels([m1 , m2])
Base.:+(m1::Group_Moduels ,m2::Moduels{T} where T) = Group_Moduels([m1.con... , m2]))
Base.:+(m2::Moduels{T} where T , m1::Group_Moduels) = Group_Moduels([m1.con... , m2]))
Base.:+(con1::Group_Moduels,con2::Group_Moduels) = Group_Moduels([m1.m..,m2.m...])
