using BOMoD
using Random
using StatsBase
using LinearAlgebra
using CSV
include("Binary_Quadratic.jl")
###################
#Set Design and make space
##################

# random
rng = MersenneTwister(1)
# set up BOMoD use
# make binary moduels
mod0 = Mod(Symbol(0))
mod1 = Mod(Symbol(1))

# no constrains model of lenght 10, not all constructs are generated
all_moduels = Group_Mod([mod0,mod1])
lenght_c = 10
σ²_mean = 10^-6
# the design
design = construct_design(all_moduels,lenght_c,order = true)
# the space
space = getspace(design)



####################
#settings evaluation
###################
# evaluad differet BO
# number of new Q
n_Q = 1
# number of simimulations
const n_iter = 10
const n_cycles = 20
# number of BO cycles
####################
#toy_data settings
###################
const λ = 0
const Lc = 10

##################
#BO-fixed settings
const Test_kernel = LevStehnoexp(1) # Kernel
n_samples = 10 # number of sampels in batch
##################
# setting up the toydata
const Q = compute_decay(rng,lenght_c,Lc)
# xstar, optimal construct

#Mykernel = SumKernel(CosStehno(),LevStehnoexp(1),1)
Mykernel = LevStehnoexp(1)
# matrix to save diff  x* and the max predicted construct.
# row represents independet cycels
# collumes represent the number of the BO prosses is repeated

max_random = Matrix{Float64}(undef, n_iter, n_cycles)
max_model = Matrix{Float64}(undef, n_iter, n_cycles)

for i in 1:n_iter
    println("n =$i")
    #choose random n points, x are index of the row in dataframe to link proper y
    points = sample(rng,space,n_samples,with_index = true )
    # liste to save the BO outcome an compare to radom
    #modelpoints = Array{Float64}(undef,n_samples)
    #radompoints = Array{Float64}(undef,n_samples)
    # set starting point
    #index_train_BO = points[:,2]
    #index_train_random = points[:,2]
    construct_train_BO = points[:,1]
    construct_train_random = points[:,1]


    # do the BO in n_cycles
    for j in 1:n_cycles
        # sample random
        # filter sample constructs
        x_test_random = [construct for construct in space if sum([isequal(construct,train_con) for train_con in construct_train_random]) == 0 ]
        myrandompoints = sample(rng,x_test_random,n_samples)


        # construct generated y-values
        y_train = map(x -> vec(unpackconstruct(x)) |> (x -> quad(x,Q,λ)),construct_train_BO)
        # use BO
        x_test_BO = [construct for construct in space if sum([isequal(construct,train_con) for train_con in construct_train_BO]) == 0 ]
        Model = gp_optimised(construct_train_BO,y_train,Test_kernel)
        new_predictions = thompson_sampling_fast(Model.GP_model,x_test_BO,10,10^-6)

        #save new constructs
        construct_train_random = [construct_train_BO;myrandompoints[:,1]]
        construct_train_BO = [construct_train_BO;new_predictions[1]]

        #max values
        max_random[i,j] =  maximum(map(x -> vec(unpackconstruct(x) )|> (x -> quad(x,Q,λ)),construct_train_random))
        max_model[i,j] = maximum(map(x -> vec(unpackconstruct(x))|> (x -> quad(x,Q,λ)),construct_train_BO ))

    end
end


writedlm("C:\\Users\\samdi\\.julia\\dev\\BOMoD\\scripts\\model_max.txt",max_model)
writedlm("C:\\Users\\samdi\\.julia\\dev\\BOMoD\\scripts\\random_max.txt",max_random)
gr()
plt = plot(xaxis ="x",yaxis = "maxf(x)");
plot1 = makeplot(max_random,"random",plt,:red);
plot2 = makeplot(max_model,"BO",plt,:blue);

plot(plt)
function makeplot(Data_matrix,name,plt,c= :blue)
    μ = [mean(Data_matrix[:,i]) for i in 1:size(Data_matrix)[2]]
    sigma = [std(Data_matrix[:,i]) for i in 1:size(Data_matrix)[2]]
    x_plot = collect(1:size(Data_matrix)[2])
    return plot!(plt,x_plot,μ,ribbon = sigma,label=name,color = c,lw=1.5,fillalpha = 0.3)
end
