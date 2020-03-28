## Step 1) Generated Design space

## Some Key concepts
Start of Combinatorial problem terms need to be clarified
1) **A module:** A single element with no given features
2) **A Construct:**  Made from combinations of modules.
3) **A constrain:** A specific combination of elements that is not allowed in the constructs.
4) **A Space:**: A container that contains all constructs that can be made form the given modules. Generally, a Space explicitly calculated and all allow constructs are made. In special case generation of all construct is not required.
5)** Lenght**: The length of all constructs in the space.
5)** Design** Groups the above features: A design consist of a specific group of moduels, constrains and has one given length. Given these futures, the "Design space" can be constructed with all allowed constructs

## Set up the design space:

### Moduels

#### Single moduels

A single module can is introduced.
 Currently, modules are type String or type Symbol
```
    md_Symbol = Mod(:sym4)
    md_String = Mod("a")
```
#### Group modules

Multiple modules are needed to make a constructs and can be grouped. T
Modules can be a group in different ways.  All result should be equal.

1) Group modules of an array of

```
    md_group = Group_Mod([Mod("a"),Mod("b"),Mod("c"),Mod("d"),Mod("e")])
```
2) sum different modules
```
    md_group2 = Mod("a") + Mod("b") + Mod("c") + Mod("d") + Mod("e")
```
3) group module function: Array{T} where T is an Symbol or String

```
    md_group3 = group_mod(["a", "b", "c", "d","e"])
```
Addionally the grouped modules are ordered to have reproducible results and Duplicated modules are removed. As example:

```
md_group4 = group_mod(["b", "c", "a", "d","e","e"])
```

All the above code will result in the same Groupstruct


```@example
    using BOMoD
    md_group4 = group_mod(["b", "c", "a", "d","e","e"])
    md_group = group_mod(["a", "b", "c", "d","e"])
```
### Constrains

The hierarchy used corresponds to the types of hierarchy in the packages.
1)**Construct constrains**
	a)**Single**
		** Ordered**
		**  Unordered **
	b) **Compese Constrain
2)**Space** constraints
	**Single Constrain**
		**Position**
    	**Compose Constrain**


Constrains are split into two large types
1)**Construct constrains**
 	 If a particular construct is allowed is checked on the construct level, like using fitler that block all unwanted constructs.
Wich implies that first all constructed are generated net efficient for large space with a limited number of constraints.
2)**Space** constraints
	The opposite approach overcome that unwanted constructs are generated. In this case, not all constructs need to be generated.
 This is still under development, but now only the general case with no constraints uses this function currently.

Both have different single types, and one compose type, they are explained below.

#### Construct constrains

##### Single constrain
A Single constrain is the lowest level of constraints that are allowed.
Currently, 3 single con constraints are defined:
1) Ordered constrains
2) Unordered constrains


##### Compse
