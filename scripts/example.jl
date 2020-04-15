using BOMoD
using Random
using StatsBase
using LinearAlgebra
using Stheno
using Plots
using StatsPlots
#using Optim
#import Optim: minimizer
include("Binary_Quadratic.jl")
# random
rng = MersenneTwister(1)
# set up BOMoD use
# make binary moduels
Mod0 = Mod(Symbol(0))
Mod1 = Mod(Symbol(1))
lenght_c = 5
# no constrains model of lenght 10, not all constructs are generated
all_moduels =Group_Mod([Mod0,Mod1])
σ²_mean = 10^-6
# the design
design = construct_design(all_moduels,lenght_c,order = true)
# the space
a_space = getspace(design)

# settings of the toy datatsettings

λ = 0
Lc = 10
# setting up the toydata
const Q = compute_decay(rng,lenght_c,Lc)


# first sampling step

points = sample(rng,a_space,10,with_index = true )

#get y_train values
# zet up the generated data
y_train = map(x -> vec(unpackconstruct(x)) |> (x -> quad(x,Q,λ)),points[:,1])
constructs_train = points[:,1]
MyKernel = LevStehnoexp(1)
Model = gp_optimised(constructs_train,y_train,MyKernel)




# Needs improvement to prevent the explicit generation of all constructs.
all_constructs = map(x -> unpackconstruct(x),collect(space))
x_test = [con for (index,con) in enumerate(all_constructs) if index ∉ points[:,2]]
x_test_space = [con for (index,con) in enumerate(space) if index ∉ points[:,2]]
constructs_test = [construct for construct in space if sum([isequal(construct,train_con) for train_con in points[:,1]]) == 0 ]

new_predictions = thompson_sampling_fast(Model.GP_model,constructs_test,10,10^-6)
new_predictions[1]
#evaluate TS
##
m = marginals(Model.GP_model(y_train),10^-6)


m = marginals(Model.GP_model(constructs_test,10^-6))
save = Matrix{Float64}(undef,22,1000)

permutedims(hcat(rand.(m,5)...) )
for i in 1:1000
    save[:,i]= map(x-> rand(x),m)
end
save2 = rand(Model.GP_model(constructs_test,10^-6),1000)

gr()

plt  = plot(title = " y* - max(y)",legend = false);
for i in 1:10
    boxplot!(plt,[string("Stheno","$i")],save2[i,:],label = string("Stheno"))
    boxplot!(plt,[string("myrand","$i")],save[i,:],label = string("myrand"))
end

plot(plt)
