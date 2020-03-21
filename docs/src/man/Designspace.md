
## Step 1) Generated Design space

### Some Key concepts
Start of Combinatorial problem terms need to be clarified
1) **A module:** A single element with no given features
2) **A Construct:**  Made from combinations of modules.
3) **A constrain:** A specific combination of elements that isn't allowed in the constructs.
4) **A Space:**: A container that contains all constructs that can be made form the given modules. Generally, a Space explicitly calculated and all allow constructs are made. In special case generation of all construct isn't required.

## Set up the design space:

### Single moduels

A single module can is introduced as. Currentely modules are type String or type Symbol
```julia
    md_Symbol = Mod(:sym4)
    md_String = Mod("a")
```
### Group modules

Multiple modules are needed to make a constructs and can be grouped. T
Modules can be a group in different ways, all result should be equal.

1) Group modules of an array of
    ```julia
    md_group = Group_Mod([Mod("a"),Mod("b"),Mod("c"),Mod("d"),Mod("e")])
    ```
2) sum different modules
    ```julia
    md_group2 = Mod("a") + Mod("b") + Mod("c") + Mod("d") + Mod("e")
    ```
3) group module function: Array{T} where T is an Symbol or String

    ```julia
    md_group3 = group_mod(["a", "b", "c", "d","e"])
    ```
Addionally the grouped modules are ordered to have reproducible results and Duplicated modules are removed. As example:

```julia
md_group4 = group_mod(["b", "c", "a", "d","e","e"])
```
All the above code will result in the same Groupstructurde

```@repl
    md_group4 = group_mod(["b", "c", "a", "d","e","e"])
    md_group = group_mod(["a", "b", "c", "d","e"])
```
