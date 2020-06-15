# BOMoD.jl
*A userfriendly package to solve combinatorial modular design optimisation problems within a Bayesian optimisation framework.*

[![Build Status](https://travis-ci.com/SamDier/BOMoD.jl.svg?branch=master)](https://travis-ci.com/SamDier/BOMoD.jl)
[![Codecov](https://codecov.io/gh/SamDier/BOMoD.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SamDier/BOMoD.jl)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://SamDier.github.io/BOMoD.jl/stable)


## Installation
The package is not registered, to install this package use:
`] add https://github.com/SamDier/BOMoD.jl.git`

**Warning**
The package is currently under development, only a first experimental version is made.

## A modular design
To understand the concept of modular design, we introduce two crucial terms.
1) **A module**: A single element without extra features.
It is a building block that can be connected or grouped with other modules; in this way, different combinations of modules can then be made.
2) **A construct**: A specific combination of different modules is called a construct.
Every construct can be evaluated. This result in a certain "activity" value.

**The goal**: Find the construct with the highest "activity", given a group of modules, which is an optimisation process.

## Bayesian optimisation in BOMoD.
This package uses a Bayesian optimisation framework to find the best combination.
The surrogate model used in the package is a Gaussian process calculated with the
[Stheno.jl](https://github.com/willtebbutt/Stheno.jl) package.

The BOMoD package difference form classic BO package is two critical points.

1) Custom kernels are made to evaluate the string distance between the input construct.
2) Batch sampling algorithms are given to propose multiple datapoints in every iteration

 if found in the documentation, a quickstart example is given:

 ## Theoretical background
 More information on Bayesian optimisation a Gaussian Prosses can be found in:

[Agnihotri & Batra, "Exploring Bayesian Optimization", Distill, 2020](https://distill.pub/2020/bayesian-optimization/)

[Görtler, et al., "A Visual Exploration of Gaussian Processes", Distill, 2019.](https://distill.pub/2019/visual-exploration-gaussian-processes/)


## Quickstart With the BOMoD package

This quick start section focuses on the aspects that need to be known to use the package. The figure below shows an overview of the BOMoD pipeline, blue are functions, and green are types.


![Manual picture](Manual_picture_6.jpg)
a more elaborate explanation can be found in the other help pages.
To illustrated the package, a trivial example is made using scoops of icecream:
The goal is to find the best flavour combination with two scoops,
using the different flavours  Vanilla, Chocolate, Strawberry, without the need to test all possible combinations.

The package is build up in two stages:
Step 1) Make the design space.
Step 2) Use The BOMoD Bayesian optimisation pipeline.

## Stage 1) Make the design space

**Goal of step 1**
Creating all ice creams with two scoops, using the different flavours  Vanilla, Chocolate and Strawberry


The first two inputs can be set:
1) The different flavours are the modules of the project.
    They are converted in the proper format using the `groupmod` function
2) The number of scopes allowed is the length of the construct and is set to two.

````julia
using BOMoD
using DataFrames
# Input modules u
Ice_flavours = groupmod([:Vanilla, :Chocolate,:Strawberry]);
n_scopes = 2;
````

One more import input is needed, which will determine what sort of variant are allowed.
Option 1: Using a cone of ice cream: In this case, there is a relative position between the different flavours, up or below.
e.g. a variant with first Vanilla and then Chocolate is different than ice cream with first Chocolate and then Vanilla.
Addionlay every flavour can be set on every position, so a combination with Vanilla-Vanilla is allowed.
This option is called "order" in the BOMoD ecosystem.

One simple function of `construct design` is used to generate all possibilities.
The `order = true` indicated that order option is desired.
The `getspace` function retrieves than all desired combination.

````julia
Cone_of_ice_ordered = constructdesign(Ice_flavours,2,order = true );
Cone_space = getspace(Cone_of_ice_ordered);
````


````
spacetype| BOMoD.FullOrderedspace{BOMoD.Mod{Symbol}}
 generted constructs| BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}}
 n_consturcts| 9
````




The returned space can be used; it is a vector containing all combination.
1) number of different combination

````julia
length(Cone_space);
````


2) Indexing at a certain position
````julia
construct = Cone_space[2]
````

````
[:Chocolate, :Strawberry]
````




3)Taking n random samples

````julia
using Random
using StatsBase
rng = MersenneTwister();
a_sample = sample(rng,Cone_space,3)
````


````
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 [:Chocolate, :Chocolate]
 [:Strawberry, :Vanilla]
 [:Vanilla, :Vanilla]
````




4) Iteration over all combinations
````julia
for cone in Cone_space
    @show cone
end
````


````
cone = [:Chocolate, :Chocolate]
cone = [:Chocolate, :Strawberry]
cone = [:Chocolate, :Vanilla]
cone = [:Strawberry, :Chocolate]
cone = [:Strawberry, :Strawberry]
cone = [:Strawberry, :Vanilla]
cone = [:Vanilla, :Chocolate]
cone = [:Vanilla, :Strawberry]
cone = [:Vanilla, :Vanilla]
````





5) Collect as a vector
````julia
collect(Cone_space)
````


````
9-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 [:Chocolate, :Chocolate]
 [:Chocolate, :Strawberry]
 [:Chocolate, :Vanilla]
 [:Strawberry, :Chocolate]
 [:Strawberry, :Strawberry]
 [:Strawberry, :Vanilla]
 [:Vanilla, :Chocolate]
 [:Vanilla, :Strawberry]
 [:Vanilla, :Vanilla]
````





Option 2: Making a jar of ice cream instead of a cone of ice cream, which as opposite properties as option one.
Now there is no difference between first adding Vanilla or Chocolate and every flavour can only be used ones.


The intire setup of the problem remains the same, only the order factor is set to true.
````julia
jar_of_ice_unorderd = constructdesign(Ice_flavours,2,order = false );
jar_space = getspace(jar_of_ice_unorderd);
````


````
spacetype | BOMoD.FullUnorderedspace{BOMoD.Mod{Symbol}}
 generted constructs| BOMoD.UnorderedConstruct{BOMoD.Mod{Symbol}}
 n_consturcts | 3
````





All the above functionalities can be used in this space.
The significant difference is the construct that is produced aren't array but sets of modules.

````julia
for jar in jar_space
    @show jar
end
````


````
jar = {:Strawberry, :Chocolate}
jar = {:Vanilla, :Chocolate}
jar = {:Vanilla, :Strawberry}
````





In the remaining of this example, the first option is chosen, we continue with the  `Cone_design` and `Cone_space` object.

## Stage 2) Bayesain optimisation

First, a method is needed to evaluate a given flavour combination.
This is something that needs the be done and set up in the lab. In this example, this step is mimicked by a "go2lab" function
which attributes a random value. The function is indicated where BOMoD algorithm needs data input form the lab.

````julia
function go2lab(ice)
    return randn(length(ice))
end
````


````
go2lab (generic function with 1 method)
````






### Step 2a) Sample first data points


The first two flavour combinations are obtained using the `sample` function.
````julia
first_icecreams = sample(Cone_space,2)
````


````
2-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 [:Chocolate, :Strawberry]
 [:Strawberry, :Strawberry]
````




Afterwards these combintions are evaluate and the data is stored in a Dataframe.
````julia
lab_value = go2lab(first_icecreams)
df = DataFrame(flavour_combinations = first_icecreams , lab_value = lab_value)
````


````
2×2 DataFrame
│ Row │ flavour_combinations       │ lab_value │
│     │ BOMoD.OrderedConstruct…    │ Float64   │
├─────┼────────────────────────────┼───────────┤
│ 1   │ [:Chocolate, :Strawberry]  │ 1.52066   │
│ 2   │ [:Strawberry, :Strawberry] │ 0.137378  │
````



### Step 2B) Fit Surrogate model

In the second step, the sample flavour combinations and their lab values are fitted in a Gaussian Prosses using the `fit_gp` function.
This model requires a Kernel; different kernels are implemented in BOMoD and can be found in the help page.
In this example, a linear Kernel is used.

````julia
x_train = df.flavour_combinations
y_train = df.lab_value
k = Linear()
linear_model = fit_gp(x_train,y_train,k,Ice_flavours)
````

Base on this model prediction can be made for all unseen flavour combinations using the `predict_gp`` function.

````julia
S = collect(Cone_space)
predictions = predict_gp(S,x_train,linear_model,Ice_flavours);
````


### Step 2C)

The final step in to obtain a new batch of b datapoints using a batch sampling algorithm.
In this example b = 2.
# Batch sampling step
````julia
new_icecreams = ts_sampler(predictions,2)
````


````
2-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 [:Chocolate, :Chocolate]
 [:Vanilla, :Chocolate]
````



## Repeat 2B & 2C

The given combination can then be evaluated and added to the current data frame.

````julia
new_lab_values =  go2lab(new_icecreams )
df_new = DataFrame(flavour_combinations = new_icecreams, lab_value = new_lab_values)
append!(df,df_new)
````


````
4×2 DataFrame
│ Row │ flavour_combinations       │ lab_value │
│     │ BOMoD.OrderedConstruct…    │ Float64   │
├─────┼────────────────────────────┼───────────┤
│ 1   │ [:Chocolate, :Strawberry]  │ 1.52066   │
│ 2   │ [:Strawberry, :Strawberry] │ 0.137378  │
│ 3   │ [:Chocolate, :Chocolate]   │ 0.91964   │
│ 4   │ [:Vanilla, :Chocolate]     │ -0.650099 │
````



This data can then be fed to the model, improved predictions can be made, and new data points can be sampled.
This cycle can be repeated multiple times until the entire budget is used.
