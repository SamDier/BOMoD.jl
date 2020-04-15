# Main functionalities of BOMoD package.
## Intro
The goal of the package is to facilitate optimisation for combinatorial design problems using Bayesian optimisation.

To solve these combinatorial optimastion problem
the package is split into 2 main sections
1) Combinatorial design : Construction
2) Bayesian optimisation Step.

## Combinatorial design : ellements

A Combinatorial **design** built up out of four elements:

1) **Modules:** A single element with no given features
2) **Constructs:**  Made from combinations of modules.
3) **Constrains:** A specific combination of elements that is not allowed in the constructs.
4) **Lenghts**: The allowed length of the constructs, indicates how  many moduels are allowed in the constructs

Based on these four elements a **design space** can be made. The design space are all the constructs can be made given the four conditions of a praticlar design


```@docs
group_mod(input::Array{T} where T)
```
