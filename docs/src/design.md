## Generated Design space

The setup of a modular design problem requires the construction of the design space containing all differnt combinations.
Using the BOMoD package, this can be done in a few easy steps:

![]("overvieuwpicture_A.jpg")

In this manual, an elaborated explanation for every step is given.
To have a quick start with the package one can take a look a the different examples that are given in every section or take a look at
the ``Quickstart`` section.

## 1. Set design inputs
To start a BOMoD.jl project the package has to be loaded in

````julia
julia> using BOMoD;

````






Afterwarod three obligatory arguments need to be defined.
a) Modules
b) Length
c) Order

### Input Modules

Every combinatorial design problems start with the given input modules.
These are the individual building blocks that are used to make all different combinations.
First an custum type `Mod{T} where T <: Any` is design to store a single module element.
As example a single module can be introduced as

````julia
julia> using BOMoD: Mod

julia>     md_Symbol = Mod(:sym4)
BOMoD.Mod{Symbol}(:sym4)

julia>     md_String = Mod("a")
BOMoD.Mod{String}("a")

````




Because multiple modules are needed to obtaine different combination an new type `Groupmod` is introduced to group different modules.
````julia
julia> using BOMoD: GroupMod

julia>     md_group = GroupMod([Mod("a"),Mod("b"),Mod("c"),Mod("d"),Mod("e")]);

````




As indicated `GroupMod` and `Mod` types are not directly exported for the BOMoD Module.
Thise is because a function `groupmod` is availble to facilitate the input of the different modules.
This function takes as argument a `Vector{T}` with all elements that will be used as modules.
Additionally, the function avoids the duplication of the same modules and sort the inputs alphabetically they get reproducible results
````julia
julia> md_group3 = groupmod(["a", "b", "c", "d","e"])
GroupMod: {"a", "b", "c", "d", "e"} 

julia> md_group4 = groupmod(["b", "c", "a", "d","e","e"])
GroupMod: {"a", "b", "c", "d", "e"} 

````




As user of the package it is advised to use the `groupmod` function.

### The Length
The length is an integer value representing the number of modules that are used to make a single combination.
Multiple lengths are possible by combining different design setups, see the design section below for more infromation.
As example below the all construct will contain 3 moduels.
````julia
julia> l = 3;

````





### Order

The `order` argument is boolean; it can be `true` or `false`.  This argument is used to determine which construct types are desired.
Every construct has his specific combinatorial properties.
Currently, the package supports two different construct types:
1) `OrderedConstruct`: order = true
2) `UnorderedConstruct`:  order = false

`OrderedConstruct` are constructs where the relative position of different modules influences the performance of the product.
This has two consequences:
First, the combinations with the same modules but in a different order have a different activity and will be seen as two different configurations.
e.g. ["a","b","c"], ["b","c","a"] are seen as to differt combinations.
Secondly, The construct is allowed to have the same module multiple times in one variant e.g ["a", "a", "c"].
The different moduels are seen as independed and the occurrence of the model on one possition has no effect on the modules allowed on the other possitions.
These setting are mathematically equivalent to permutations with replacements.

`UnorderedConstruct` in these constructs the individual moduels do not have a relative position to one other.
As a result, every combination containing the same modules are equal, and only a single combination is generated.
In this setting, it is not useful to evaluate constructs containing the same module multiple times.
This setting is mathematically equivalent to combinations without replacements.

To contine the example the order is set to true




## 2.Constrains
The input of constrains is optional.
Constraints are used to remove specific combinations that are forbidden in the design space.
Many constraints are possible; currently, two types are implemented `UnOrderedConstraint` and  `OrderedConstraint`.
The `UnOrderedConstraint` has only an Array of modules as input, the occurrence of all these modules in one construct is forbidden.
The `OrderedConstraint` has two inputs, one is the position index, and the second one are the corresponding modules, which are forbidden on the given possition.
Both  constraint types are group under the `SingleConstructConstraints` abstract type.

To illustred the different constrains, differnt examples are given.
A construct can be evaluated with the internal `filterconstraint(construct, constraint)` function
The function gives `true` if the construct is forbidden, given the constraint and false when allowed.

First the examples contructs are mad


**illustration of UnOrderedConstraint**

````julia
julia> # removes the construct containing Mod("a") and Mod("b");
con_unorder = UnOrderedConstraint([m1,m2]);

julia> 
filterconstraint(c1,con_unorder)
true

julia> # evaluate true, contains Mod("a") and Mod("b"), will be removed

filterconstraint(c2,con_unorder)
true

julia> # evaluate true, contains Mod("a") and Mod("b"), will be removed

filterconstraint(c3,con_unorder)
false

julia> # evaluate false, only contains Mod("a"), will be kept

````





**illustration of OrderedConstraint**

````julia
julia> #  Mod("a") can not be on possition 1 and m2 cannot be on possition Mod("b")
con_order = OrderedConstraint([1,2],[m1,m2]);

julia> 
# evaluate true, contains Mod("a") at index 1 and Mod("b") ad index 2
# the construct  will be removed
filterconstraint(c1,con_order)
true

julia> 

# evaluate false, contains Mod("a") and ("b") but not at the forbidden index
# the construct  will be kept
filterconstraint(c2,con_order)
false

julia> 
# evaluate false, contains only Mod("a"), will be kept
filterconstraint(c3,con_order)
false

````





Muliple constrain can be combined in a single design setup after summation.
This results in a `ComposeConstructConstraints`.
If the given construct is forbidden based on one of concatend constraints the costruct is removed

**illustrion of ComposeConstructConstraints**
````julia
julia> using BOMoD: ComposeConstructConstraints;

julia> con_unorder = UnOrderedConstraint([m1,m2]);

julia> con_under2 = UnOrderedConstraint([m1,m3]);

julia> # combine constrains
compose = con_under2 + con_unorder;

julia> 
#  true, rejected by the firt constraint
filterconstraint(c1,compose)
true

julia> 
# true, rejected by the second constraint
filterconstraint(c3,compose)
true

````






## The Design

Different designs are possible in the package. For careful integration of all the different options, various types were created.
As a result, the following hierarchy was obtained:
1) Abstractdesign
    a) SingleDesign{T}
        i) OrderedDesign
        ii) UnorderedDesign
    b) MultiDesign{T}


At the top is the `Abstractdesign` type which is used for all designs.
Then two new types are defined: `SingleDesign` and `MultiDesign` which requires some additional explanation.
First, the Single design is explained and afterwards, the MultiDesign setting.

### SingleDesign

Al different  `SingleDesign` types are obtained with one function: `constructdesign`
The function requires three input arguments, as discused in "Set inputs":
the input modules (m), the lenght(l) and the order(order).
````julia
julia> m = groupmod(["a", "b", "c", "d","e"]);

julia> design = constructdesign(m,l,order = order);

````




If needed contraints can be intgreted in the function easly:
````julia
julia> m1 = Mod("a");

julia> m2 = Mod("b");

julia> con_unorder = UnOrderedConstraint([m1,m2]);

julia> design = constructdesign(m,l,con_unorder,order = order);

````




The output of this function results in an `OrderedDesign` or `UnorderedDesign`.
Where an `OrderedDesign` is generated when the `order` option is `true`. The design will then produce ordered constructs.
The opposite holds for an `UnorderDesign`, which creates `UnorderedConstruct` and is enabled when order = `false.`
Still, the underlining structure of both types is equal; they both contain four different fields:

| name  | type  |explantions|
|---|---|---|
| mod | AbstractMod | The used modules in the design  |
| len | Int  | The allowed length of the constructs   |
| con | AbstractConstraints | The constraints of the design space  |
| space:  | AbstractSpace  | Closed efficient design space containing all constructs|

The first three fields are the input parameters, and are use to verify the inputs of given design.
If no constraints were given as input, the `con` field will be filled with `NoConstraint(nothing)` by default.
All three inputs are used to construct the `space` object.
All two `SingleDesign` structure can be simply seen as data containers to allow well-organised data flow in the package.
It is the `space` object that absorbs all given input and stores the desired output.
Different `space` types were implemented to understand them correctly; some additional explanation is required.

The `space` argument of a `SingleDesign` holds all different combinations, without the explicit creation of all possible combination.
This is an essential concept in the philosophy of the BOMoD package.
The construction and storage of all combinations would be in many cases not trivial due to a large number of possibilities.
The make this possible; the package uses some custom implemented mathematical operations between modules to generated construct efficiently on the fly.

The multiplication of different modules results in an `OrderedConstruct` of given modules.
The squared bracktes "[]" indicates that the given construct are in an array, the possitions of the modules are important, which is the characeristic of an `Orderonstruct`.
````julia
julia> Mod("a") * Mod("b") *  Mod("c")
["a", "b", "c"]

````





The summation of the different construct results in an `UnorderedConstruct`.
The currently brackets "{}" indicates that the output construct is a set, the position of individual modules is not important,
which is the characeristic of an `UnorderedConstruct`.

````julia
julia> Mod("a") +  Mod("b") +  Mod("c")
{"a", "b", "c"}

````





More information regarding the differnt space types is given in the section: "getspace"

### MultiDesign

The `MultiDesign` type allows the combination of different `SingleDesign`, which is mainly useful to obtain design spaces of different lengths.
The structures store the different individual designs and treated them ass if they were one.
Multiple designs can be obtained simply with the summation of different `SingleDesign`.
For example to generate all combinations of lenght of 2 ,3 and 4:

````julia
julia> design_len2 = constructdesign(m,2,order = order);

julia> design_len3 = constructdesign(m,3,order = order);

julia> design_len4 = constructdesign(m,4,order = order);

julia> t = design_len2 + design_len3  + design_len4
Number of single designs: 3 

Used modules : GroupMod: {"a", "b", "c", "d", "e"} 
allowed length : 2
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace 
 spacetype| BOMoD.FullOrderedspace{BOMoD.Mod{String}} 
 generted constructs| BOMoD.OrderedConstruct{BOMoD.Mod{String}} 
 n_consturcts| 25

Used modules : GroupMod: {"a", "b", "c", "d", "e"} 
allowed length : 3
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace 
 spacetype| BOMoD.FullOrderedspace{BOMoD.Mod{String}} 
 generted constructs| BOMoD.OrderedConstruct{BOMoD.Mod{String}} 
 n_consturcts| 125

Used modules : GroupMod: {"a", "b", "c", "d", "e"} 
allowed length : 4
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace 
 spacetype| BOMoD.FullOrderedspace{BOMoD.Mod{String}} 
 generted constructs| BOMoD.OrderedConstruct{BOMoD.Mod{String}} 
 n_consturcts| 625


````






### getspace

As indicated, the Design structure is mainly a data container that is implemented as a safety step to see if all input arguments are correct.
A special function: `getspace` is made to get acces to the `space` object.
Additionally, one can choose to obtain all construct explicitly, which results in a `ComputedSpace` structure.

````julia
julia> design = constructdesign(m,l,order = order);

julia> # get the space object from the design
space = getspace(design)
 spacetype| BOMoD.FullOrderedspace{BOMoD.Mod{String}} 
 generted constructs| BOMoD.OrderedConstruct{BOMoD.Mod{String}} 
 n_consturcts| 125

julia> # get all differnt construct explicitly
space_full = getspace(design, full = true)
 spacetype| BOMoD.ComputedSpace{Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}} 
 generted constructs| BOMoD.OrderedConstruct{BOMoD.Mod{String}} 
 n_consturcts| 125

````





The current implementation has still some limitations,
specially in the case where constraints are used , is the obtained space is not that efficient as for the non-constrained case.
Because constrained and non-constrained spaces have to be treated differenly, various space types where made.
All non-constrained spaces have the abstract type  `Effspace`.
There are two types of   `Effspace`: `FullOrderedspace`, `FullUnorderedspace`, respectively referring to the fact if the space object contains `OrderedConstruct` or `Unordered Constructs.`
In the case that constraints are added, an additional space type was introduced:  `FrameSpace`.
This ` FrameSpace` type has two argumetns, one stores the given constraints , the other the closest `Effspace`, which is the space that would be obtained if no constraints where given.
This space type is less efficient than the `Effspace` because for every construct it needs to check if it is allowed given the constraints.

For all  `Effspace` on can use this `space` object as if all construct where generated in a vector.
All the below functions work without the real need of the vector containing all combinations;
only the desired constructs  are created on the fly, which is an important accomplishment of the BOMoD package.
The length of the given space is calculated using well-known formulas from the field of combinatorics.

````julia
julia> using StatsBase

julia> using Random

julia> # indexing,
space[1]
["a", "a", "a"]

julia> # number of constructs
n_total = length(space)
125

julia> # iterator over the whole space
space_iter = [i for i in space]
125-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 ["a", "a", "a"]
 ["a", "a", "b"]
 ["a", "a", "c"]
 ["a", "a", "d"]
 ["a", "a", "e"]
 ["a", "b", "a"]
 ["a", "b", "b"]
 ["a", "b", "c"]
 ["a", "b", "d"]
 ["a", "b", "e"]
 ⋮
 ["e", "d", "b"]
 ["e", "d", "c"]
 ["e", "d", "d"]
 ["e", "d", "e"]
 ["e", "e", "a"]
 ["e", "e", "b"]
 ["e", "e", "c"]
 ["e", "e", "d"]
 ["e", "e", "e"]

julia> # collect the space in a vector
space_full = collect(space)
125-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 ["a", "a", "a"]
 ["a", "a", "b"]
 ["a", "a", "c"]
 ["a", "a", "d"]
 ["a", "a", "e"]
 ["a", "b", "a"]
 ["a", "b", "b"]
 ["a", "b", "c"]
 ["a", "b", "d"]
 ["a", "b", "e"]
 ⋮
 ["e", "d", "b"]
 ["e", "d", "c"]
 ["e", "d", "d"]
 ["e", "d", "e"]
 ["e", "e", "a"]
 ["e", "e", "b"]
 ["e", "e", "c"]
 ["e", "e", "d"]
 ["e", "e", "e"]

julia> # sample random 5 constructs
rng = MersenneTwister()
Random.MersenneTwister(UInt32[0xbe430a68, 0xd5e6e805, 0x421d7739, 0x933a253c], Random.DSFMT.DSFMT_state(Int32[-499933521, 1072741470, -1433288599, 1073311681, -310308404, 1073285409, -748091931, 1073562606, 711927543, 1073008691  …  1541405144, 1073650577, -1210139374, 1072756913, -974343083, 1414883164, -1193470874, 531246273, 382, 0]), [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], UInt128[0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000  …  0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000, 0x00000000000000000000000000000000], 1002, 0)

julia> random_sample = sample(rng,space,5)
5-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 ["e", "b", "c"]
 ["c", "c", "e"]
 ["b", "b", "e"]
 ["b", "e", "c"]
 ["c", "a", "b"]

````





Currently, if constraints are added to the design and a `Framespace` object is returned, which has not all above functionalities without explicit construction of the design space.
Indexing is no longer possible. The length calculation is done inefficient. Instead of using a formula, every construct is evaluated to the given constraints to obtain the number of allowed combinations.
The random sampler of n construct of the space work based on the rejection of the forbidden construct; as a result, it works good for n  << length design and the number constraints is not too high.
If many constraints are used, it is advised to collect the entire design space.


A special space type,`MultiSpace`is introduced for space orginating for multipledesign.
The use of MultiDesign and MultiSpace should by almost identical than for SingleDesign variant.


**Note**
Most of all types explained above are given automacily with in the BOMoD pipline, See  the "Quick start" packag to get a more practical overvieuw of the package.
