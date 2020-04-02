using BOMoD
using Random
using StatsBase
using LinearAlgebra
#using Optim
#import Optim: minimizer
include("Binary_Quadratic.jl")
# random
rng = MersenneTwister(1)
# set up BOMoD use
# make binary moduels
mod0 = Mod(Symbol(0))
mod1 = Mod(Symbol(1))
lenght_c = 10
# no constrains model of lenght 10, not all constructs are generated
all_moduels =Group_Mod([mod0,mod1])
σ²_mean = 10^-6
# the design
design = construct_ordered_design(all_moduels,lenght_c)
# the space
a_space = BOMoD.getspace(design)

# settings of the toy datatsettings

lenght_c = 10
λ = 0
Lc = 10
# setting up the toydata
const Q = compute_decay(rng,lenght_c,Lc)


# first sampling step

points = sample(rng,a_space,20,with_index = true )

#get y_train values
# zet up the generated data
y_train = map(x -> unpackconstruct(x) |> (x -> quad(x,Q,λ)),points[:,1])
constructs_train = points[:,1]
MyKernel = LevStehnoexp(1)
Model = gp_optimised(constructs_train,y_train,MyKernel)

# Needs improvement to prevent the explicit generation of all constructs.
all_constructs = map(x -> unpackconstruct(x),collect(space))
x_test = [con for (index,con) in enumerate(all_constructs) if index ∉ points[:,2]]
x_test_space = [con for (index,con) in enumerate(space) if index ∉ points[:,2]]
constructs_test = [construct for construct in space if sum([isequal(construct,train_con) for train_con in points[:,1]]) == 0 ]




in points[:,1])), space.space)
new_predictions = save_thompson_sampling(Model.GP_model,x_test_space,10,10^-6)

a_space[138] in points[:,1]

myfilter(x::Ordered_Construct) = sum([isequal(i,x) for i in points[:,1]]) == 0 ? x : nothing
