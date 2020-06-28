# Illustrations BOMoD.jl


## A) Construct Design space


### Input Settings
````julia
using BOMoD
using DataFrames
using Plots

# Input modules u
ice_flavours = groupmod([:Vanilla, :Chocolate, :Strawberry, :Banana, :Pistachio, :Stracciatella, :Almond, :Blackberry, :Coffee, :Lemon]);
n_scopes = 2
cone = true; # cone = orderd ice_cream
````


### Constraints
````julia
using BOMoD: Mod
No_Vanilla_Chocolate = UnOrderedConstraint([Mod(:Vanilla), Mod(:Chocolate)])

No_Vanilla_Chocolate_order = OrderedConstraint([1,2],[Mod(:Vanilla), Mod(:Chocolate)]);
````


````
BOMoD.OrderedConstraint{BOMoD.Mod{Symbol}}([1, 2], BOMoD.Mod{Symbol}[BOMoD.
Mod{Symbol}(:Vanilla), BOMoD.Mod{Symbol}(:Chocolate)])
````





### Constructing Design
````julia
design = constructdesign(ice_flavours,n_scopes,order = cone);
````


````
Used modules : {GroupMod}{:Almond, :Banana, :Blackberry, :Chocolate, :Coffe
e, :Lemon, :Pistachio, :Stracciatella, :Strawberry, :Vanilla}
allowed length : 2
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{Symbol}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}}
 n_consturcts | 100
````





###  The Space object
````julia
space = getspace(design);
#index
space[5]
#length
length(space)
#collect
S = collect(space)
````


````
100-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 {OrderedConstruct}[:Almond, :Almond]
 {OrderedConstruct}[:Almond, :Banana]
 {OrderedConstruct}[:Almond, :Blackberry]
 {OrderedConstruct}[:Almond, :Chocolate]
 {OrderedConstruct}[:Almond, :Coffee]
 {OrderedConstruct}[:Almond, :Lemon]
 {OrderedConstruct}[:Almond, :Pistachio]
 {OrderedConstruct}[:Almond, :Stracciatella]
 {OrderedConstruct}[:Almond, :Strawberry]
 {OrderedConstruct}[:Almond, :Vanilla]
 ⋮
 {OrderedConstruct}[:Vanilla, :Banana]
 {OrderedConstruct}[:Vanilla, :Blackberry]
 {OrderedConstruct}[:Vanilla, :Chocolate]
 {OrderedConstruct}[:Vanilla, :Coffee]
 {OrderedConstruct}[:Vanilla, :Lemon]
 {OrderedConstruct}[:Vanilla, :Pistachio]
 {OrderedConstruct}[:Vanilla, :Stracciatella]
 {OrderedConstruct}[:Vanilla, :Strawberry]
 {OrderedConstruct}[:Vanilla, :Vanilla]
````


## B Bayesian Optimisation


## (Simulated activities)
````julia
using Random
using Distributions
rng  = MersenneTwister(12);
activities = rand(rng,Uniform(0,10),length(ice_flavours));
toy_data = Dict(ice_flavours .=> activities);
ground_truth(construct,toy_data) = [sum([toy_data[m] for m in c]) for c in construct]
````


### Frist sampling step

````julia
n_first = 3;
ice_combinations = sample(rng,space,n_first)
````


````
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 {OrderedConstruct}[:Almond, :Banana]
 {OrderedConstruct}[:Vanilla, :Blackberry]
 {OrderedConstruct}[:Almond, :Pistachio]
````





### Evaluted new data

````julia
lab_μ = ground_truth(ice_combinations,toy_data)
df = DataFrame(ice_combinations = ice_combinations, μ = lab_μ);
maximums = [maximum(df.μ)]
````


### Surrogate model


````julia
##############
# All inputs
#############

# arg
x_train = df.ice_combinations
y_train = df.μ
k = Linear()
# ice_flavours = the modules defined above

# kwarg
optim = true

###################
# Fit the GP model
##################

linear_model = fit_gp(x_train,y_train,k,ice_flavours;optimise = optim)

###############
# Predictions
##############

S = collect(space)
predictions = predict_gp(S,x_train,linear_model,ice_flavours)
````




## Batch sampling step
````julia
new_comb = ts_sampler(predictions,3)
````


````
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{Symbol}},1}:
 {OrderedConstruct}[:Vanilla, :Almond]
 {OrderedConstruct}[:Chocolate, :Vanilla]
 {OrderedConstruct}[:Almond, :Almond]
````





## Iteration 1
````julia
# evaluation
lab_μ = ground_truth(new_comb,toy_data)
# update training data
df_new = DataFrame(ice_combinations = new_comb, μ = lab_μ);
df = append!(df_new,df)
# find maxium value
push!(maximums,maximum(df.μ))
#  visual
plot(xaxis = "Number of iterations",yaxis = "Highest activity ");
plot!([0:length(maximums)-1],maximums,label = "")
scatter!(([0:length(maximums)-1],maximums),label = "")
````


![](figures/BOMoD_tutorial_10_1.png)



## Iteration 2...
````julia
# setup the model
x_train = df.ice_combinations
y_train = df.μ
# fit model
linear_model = fit_gp(x_train,y_train,k,ice_flavours;optimise = optim)
# predict
predictions = predict_gp(S,x_train,linear_model,ice_flavours)
# sample
new_comb = ts_sampler(predictions,3)
#  update training data
lab_μ = ground_truth(new_comb,toy_data)
df_new = DataFrame(ice_combinations = new_comb, μ = lab_μ);
df = append!(df_new,df)
# visual
push!(maximums,maximum(df.μ))
plot(xaxis = "Number of iterations",yaxis = "Highest activity ");
plot!([0:length(maximums)-1],maximums,label = "")
scatter!(([0:length(maximums)-1],maximums),label = "")
````


![](figures/BOMoD_tutorial_11_1.png)
## Iteration 3
![](figures/BOMoD_tutorial_12_1.png)
## Iteration 4
![](figures/BOMoD_tutorial_13_1.png)
