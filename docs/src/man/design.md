
# Constructing design space

The setup of a modular design problem requires the construction of the design space containing all different combinations.
Using the BOMoD package, this can be done in a few easy steps.

## Set design inputs

To start a BOMoD project the package has to be loaded:
````julia
julia> using BOMoD;

````





Afterwards three mandatory arguments need to be defined:
1) Input modules
2) Length of the construct
3) Desired construct type


### Input modules

Every combinatorial design problem starts with the given input modules.
These are the individual building blocks that are used to make all different combinations.
First, a custom type `Mod{T} where T <: Any` is implemented to store a single module element.
For example, a single module `:sym4` can be introduced as:

````julia
julia> using BOMoD: Mod

julia>     md_symbol = Mod(:sym4)
BOMoD.Mod{Symbol}(:sym4)

julia>     md_string = Mod("a")
BOMoD.Mod{String}("a")

````





Of course, multiple modules are needed to obtain different combinations and a new type `Groupmod` is introduced to group different modules.


````julia
julia> using BOMoD: GroupMod

julia> md_group = GroupMod([Mod("a"), Mod("b"), Mod("c"), Mod("d"), Mod("e")]);
{GroupMod}{"a", "b", "c", "d", "e"}

````






As indicated, `GroupMod` and `Mod` types are not directly exported from the BOMoD module.
This is because a function `groupmod` is available to facilitate the input of the different modules.
This function takes as argument a `Vector{T}` with all elements that should be transformed into the module type.
Additionally, the function avoids the duplication of the same modules and sorts out the inputs alphabetically to get reproducible results.

````julia
julia> md_group3 = groupmod(["a", "b", "c", "d", "e"])
{GroupMod}{"a", "b", "c", "d", "e"}

julia> md_group4 = groupmod(["b", "c", "a", "d", "e", "e"])
{GroupMod}{"a", "b", "c", "d", "e"}

````





The user of the package is advised to use the `groupmod` function.

### Length of the construct

The length is an integer value representing the number of modules that are allowed to make a single construct.
Multiple lengths are possible by combining different design setups. See the design   below for more information.
The running example will contain three modules.

````julia
julia> l = 3;
3

````





### Desired construct type

Every construct type has its own specific combinatorial properties which are defined by using the `order` keyword argument.
Currently, the package supports two different construct types:
1) `OrderedConstruct`: `order=true`
2) `UnorderedConstruct` : `order=false`

`OrderedConstruct` is a construct where the relative position of different modules influences the performance of the product.
This has two consequences:
first, the combinations with the same modules but in a different order have a different activity and are seen as two different configurations.
e.g. `["a", "b", "c"], ["c", "b", "a"]` are seen as to different combinations.
Secondly, the construct is allowed to have the same module multiple times in one variant e.g. `["a", "a", "c"]`.
This setting is mathematically equivalent to permutations with replacements as seen in .

`UnorderedConstruct` is a construct type where the interaction between modules is independent from their order. This indicates that the order of the different modules has no physical meaning.
As a result, every combination containing the same modules is
seen equal, and only a single combination is generated, e.g. `["a", "b", "c"], ["c", "b", "a"]` are seen as the same combinations and only a single variant is generated. In BOMoD, the later is made because all combinations are constructed in decreasing lexicographical order, which facilitates their construction internally. Because there is no direct order among the modules, it is not useful to evaluate constructs containing the same module multiple times. This setting is mathematically equivalent to combinations without replacements as seen in.

To continue the example, the order is set to true

````julia
julia> order = true;
true

````





## Constraints

Constraints are used to remove specific combinations that are forbidden in the design space, the input of constraints is optional.\\
Many constraints are possible. Currently, two types are implemented: `UnOrderedConstraint` and `OrderedConstraint`.
The `UnOrderedConstraint` has only an array of modules as input and the occurrence of all these modules in one construct is forbidden.
The `OrderedConstraint` has two inputs, one are the position indices, and the second one represents the corresponding module that is forbidden on the given position.
Both constraint types are grouped under the `SingleConstructConstraints` abstract type.

To illustrate the different constraints, different examples are given.
A construct can be evaluated with the internal `filterconstraint(construct, constraint)` function.
The function returns `true` if the construct is forbidden and `false` when allowed.

To illustrate the various constraint types, some example constructs are made:

````julia
julia> using BOMoD: filterconstraint

julia> c1 = OrderedConstruct([Mod("a"), Mod("b"), Mod("c")]);
{OrderedConstruct}["a", "b", "c"]

julia> c2 = OrderedConstruct([Mod("a"), Mod("c"), Mod("b")]);
{OrderedConstruct}["a", "c", "b"]

julia> c3 = OrderedConstruct([Mod("a"), Mod("c"), Mod("a")]);
{OrderedConstruct}["a", "c", "a"]

````





### illustration of UnOrderedConstraint

````julia
julia> # removes the construct containing Mod("a") and Mod("b");
con_unorder = UnOrderedConstraint([Mod("a"), Mod("b")]);
BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])

julia>
# evaluate true, contains Mod("a") and Mod("b"), will be removed
filterconstraint(c1,con_unorder)
true

julia>
# evaluate true, contains Mod("a") and Mod("b"), will be removed
filterconstraint(c2,con_unorder)
true

julia>
# evaluate false, only contains Mod("a"), will be keptfilterconstraint(c3,con_unorder)

````






### illustration of OrderedConstraint

````julia
julia> #  Mod("a") cannot be on position 1 and Mod("b") cannot be on position 2
con_order = OrderedConstraint([1, 2],[Mod("a"), Mod("b")]);
BOMoD.OrderedConstraint{BOMoD.Mod{String}}([1, 2], BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])

julia>
# evaluates to true, contains Mod("a") at index 1 and Mod("b") ad index 2
# the construct  will be removed
filterconstraint(c1,con_order)
true

julia>

# evaluates to  false, contains Mod("a") and ("b") but not at the forbidden index
# the construct  will be kept
filterconstraint(c2,con_order)
false

julia>
# evaluates to  false, contains only Mod("a"), will be kept
filterconstraint(c3,con_order)
false

````






Multiple constraints can be combined in a single design setup after concatenation.
This results in a `ComposedConstructConstraints`.
If the given construct is forbidden based on one of the concatenated constraints, the construct is removed.

### illustration of ComposedConstructConstraints

````julia
julia> using BOMoD: ComposedConstructConstraints;

julia> con_unorder = UnOrderedConstraint([Mod("a") ,Mod("b")]);
BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])

julia> con_under2 = UnOrderedConstraint([Mod("a"), Mod("c")]);
BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("c")])

julia> # combine constrains
compose = con_under2 + con_unorder;
BOMoD.ComposedConstructConstraints{BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}}(BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}[BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("c")]), BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])])

julia>
#  true, rejected by the first constraint
filterconstraint(c1,compose)
true

julia>
# true, rejected by the second constraint
filterconstraint(c3,compose)
true

````






## Construct design

### Type hierarchy: design

Different designs are possible in the package. For careful integration of all the different options, various Julia types were created.
As a result, the following hierarchy was obtained:
1) `AbstractDesign`
     1) `SingleDesign`
         * `OrderedDesign`
         * `UnorderedDesign`
    2)`MultiDesign`

At the top, there is the `AbstractDesign` type which is used for all designs.
Then, two new types are defined: `SingleDesign` and `MultiDesign` which requires some additional explanation.
First, the `SingleDesign` type is explained, afterwards the `MultiDesign` type.

### Make SingleDesign

All different `SingleDesign` types can be obtained with a single function: `constructdesign`.
This function requires three input arguments, as discussed in  :
the input modules `m`, the length `l` and the design type `order`.

````julia
julia> m = groupmod(["a", "b", "c", "d", "e"]);
{GroupMod}{"a", "b", "c", "d", "e"}

julia> design = constructdesign(m, l, order=order);
Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 3
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125

````





If needed, constraints can be integrated in the function easily:

````julia
julia> con_unorder = UnOrderedConstraint([ Mod("a"), Mod("b")]);
BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])

julia> design = constructdesign(m, l, con_unorder, order=order);
Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 3
constraints : BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])
	 	 designspace
Effspace: spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125
constraint:BOMoD.UnOrderedConstraint{BOMoD.Mod{String}}(BOMoD.Mod{String}[BOMoD.Mod{String}("a"), BOMoD.Mod{String}("b")])

````






The output of this function results in an `OrderedDesign` or `UnorderedDesign`.
The function generates an `OrderedDesign` when the `order` argument is `true`. The design will then produce `OrderedConstruct`.
The opposite holds for an `UnorderedDesign`, which creates an `UnorderedConstruct` and is enabled when the order argument is `false`.
Still, the underlying structure of both types is similar. Both contain four different fields, the output is complex and the different fields are summarised in Table .



| name  | type  |explanation|
|---|---|---|
| `mod` | `AbstractMod` | The used modules in the design  |
| `len` | `Int`  | The allowed length of the constructs   |
| `con` | `AbstractConstraints` | The constraints of the design space  |
| `space` | `AbstractSpace`  | The design space containing all constructs|


The first three fields are the input parameters and they are stored to allow the user to verify which inputs were used.
If no constraints were given as input, the `con` field will be filled with `NoConstraint(nothing)` by default.
All three inputs are used to construct the `space` object.
All two `SingleDesign` structures can be seen as data containers to allow well-organised data flow in the package.
It is the `space` object that absorbs all given input and stores the desired output.
Different `space` types were implemented. To understand them correctly, some additional explanation is required.

The `space` argument of a `SingleDesign` holds all different combinations, without the explicit creation of all of them.
This is an elaborate concept in the philosophy of the BOMoD package.
The construction and storage of all combinations would not be trivial in many cases, due to the large number of possibilities.
To make this possible, the package uses some custom implemented mathematical operations between modules to generate constructs efficiently on the fly.

The multiplication of different modules results in an `OrderedConstruct` of the given modules.
The squared brackets "[]" indicate that the obtained construct is an array. The positions of the modules are important, a characteristic of an `OrderedConstruct`.

````julia
julia> Mod("a") * Mod("b") *  Mod("c")
{OrderedConstruct}["a", "b", "c"]

````





The concatenation of different constructs results in an `UnorderedConstruct`.
The curly brackets "{" indicates that the output construct is a set. The position of individual modules is not important, a characteristic of an `UnorderedConstruct`.


````julia
julia> Mod("a") +  Mod("b") +  Mod("c")
{UnorderedConstruct}{"a", "b", "c"}

````





More information regarding the different space types is given in the  .

### Make MultiDesign

The `MultiDesign` type allows the combination of different `SingleDesign` objects, which is mainly useful to obtain design spaces with variants of different lengths.
The structure stores different individual designs and treats them as if they were one.
`MultiDesign` type can be obtained with the concatenation of different `SingleDesign`.
For example, to generate all combinations of length 2, 3 and 4:

````julia
julia> design_len2 = constructdesign(m, 2, order=order);
Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 2
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 25

julia> design_len3 = constructdesign(m, 3, order=order);
Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 3
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125

julia> design_len4 = constructdesign(m, 4, order=order);
Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 4
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 625

julia> t = design_len2 + design_len3  + design_len4
Number of single designs: 3

Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 2
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 25

Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 3
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125

Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 4
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 625


````







## The space object

The design structure is mainly a data container that is implemented as a safety step to verify whether all input arguments are correct.
A special function: `getspace` is made to get access to the `space` object.
Additionally, one can choose to obtain all constructs explicitly, which results in a `ComputedSpace` structure.

````julia
julia> design = constructdesign(m, l, order=order);
Used modules : {GroupMod}{"a", "b", "c", "d", "e"}
allowed length : 3
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125

julia> # get the space object from the design
space = getspace(design);
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125

julia> # get all different construct explicitly
space_full = getspace(design, full = true)
 spacetype | BOMoD.ComputedSpace{Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 125

````





The current implementation has some limitations.
Especially when constraints are added, the obtained space is not that efficient as for the non-constrained case.
Because constrained and non-constrained spaces have to be treated differently, various space types were made.

### EffSpace

All non-constrained spaces have the same abstract type `EffSpace`.
There are two types of `EffSpace`: `FullOrderedSpace`, `FullUnorderedSpace`, respectively referring to the fact that the space object contains constructs of the type `OrderedConstruct` or `UnorderedConstruct`.

A `EffSpace` object can be handled as if all constructs were stored in a vector. As consequence many desired functions e.g. indexing, random sampling, etc. work without the need of constructing the array containing all combinations.
Only the desired constructs are created on the fly, which is an important accomplishment of the BOMoD package.
The length of the given space is calculated using well-known formulas from the field of combinatorics which were given in Table , .

````julia
julia> using StatsBase

julia> using Random

julia> # indexing,
space[1]
{OrderedConstruct}["a", "a", "a"]

julia> # number of constructs
n_total = length(space)
125

julia> # iterator over the whole space
space_iter = [i for i in space]
125-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "a"]
 {OrderedConstruct}["a", "a", "b"]
 {OrderedConstruct}["a", "a", "c"]
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["a", "a", "e"]
 {OrderedConstruct}["a", "b", "a"]
 {OrderedConstruct}["a", "b", "b"]
 {OrderedConstruct}["a", "b", "c"]
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "b", "e"]
 ⋮
 {OrderedConstruct}["e", "d", "b"]
 {OrderedConstruct}["e", "d", "c"]
 {OrderedConstruct}["e", "d", "d"]
 {OrderedConstruct}["e", "d", "e"]
 {OrderedConstruct}["e", "e", "a"]
 {OrderedConstruct}["e", "e", "b"]
 {OrderedConstruct}["e", "e", "c"]
 {OrderedConstruct}["e", "e", "d"]
 {OrderedConstruct}["e", "e", "e"]

julia> # collect the space in a vector
space_full = collect(space)
125-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "a"]
 {OrderedConstruct}["a", "a", "b"]
 {OrderedConstruct}["a", "a", "c"]
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["a", "a", "e"]
 {OrderedConstruct}["a", "b", "a"]
 {OrderedConstruct}["a", "b", "b"]
 {OrderedConstruct}["a", "b", "c"]
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "b", "e"]
 ⋮
 {OrderedConstruct}["e", "d", "b"]
 {OrderedConstruct}["e", "d", "c"]
 {OrderedConstruct}["e", "d", "d"]
 {OrderedConstruct}["e", "d", "e"]
 {OrderedConstruct}["e", "e", "a"]
 {OrderedConstruct}["e", "e", "b"]
 {OrderedConstruct}["e", "e", "c"]
 {OrderedConstruct}["e", "e", "d"]
 {OrderedConstruct}["e", "e", "e"]

julia> # sample random 5 constructs
rng = MersenneTwister();

julia> random_sample = sample(rng,space,5)
5-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["b", "d", "a"]
 {OrderedConstruct}["c", "d", "e"]
 {OrderedConstruct}["c", "e", "a"]
 {OrderedConstruct}["c", "b", "d"]
 {OrderedConstruct}["e", "e", "c"]

````





### FrameSpace

When constraints are added, an additional space type was introduced: `FrameSpace`.
This `FrameSpace` type has two arguments. The first argument stores the given constraints, the other one the closest `EffSpace` which is the space that would be obtained when no constraints were given.
The efficiency of this space type drops because the constraints forbid some of the constructs. There is no efficient way to obtain these spaces, and all combinations are evaluated, based on a match towards the given constraints. This matching process iteratively loops over the entire design space.
Indexing is no longer possible. The length calculation is done inefficiently. Instead of using a formula, every construct is evaluated for the given constraints to obtain the number of allowed combinations.
The uniformly random sampling algorithm of $n$ constructs is based on the rejection of the forbidden constructs. The sampler is hooked on the base sampling function of Julia to assure a correct sampling procedure.
As a result, it works well for $n$ $\ll$ length of the design space and if the number of constraints is not too high.
When using many constraints, it is advised to store the entire design space in an array.

A particular space type,`MultiSpace` is introduced for space originating from multiple designs. The space groups multiple `SingleSpace` and tries to mimic as they originate from one larger design object.

**Note**: Most of all types explained above are generated automatically within the BOMoD pipeline. See the quick-start section on github to get a more practical overview of the package.
