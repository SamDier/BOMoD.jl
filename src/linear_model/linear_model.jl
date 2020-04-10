# make Toydata
"""
design_maxtrix(subspace,moduels::Group_Mod)

Generates the design matrix for the given subspace of constructs.
The Designmatrix has n x p dimension where n is the number of constructs and p the number of modules.
Depending on the application it needs to be transposed.
"""

function design_maxtrix(subspace,moduels::Group_Mod)
    # mod to index
    dict_mod = Dict(moduels.m .=> collect(1:length(moduels.m)))
    # setup design matrix
    dm = Array{Int,2}(undef,length(subspace),length(moduels))
    #make matrix
    for (row,construct) in enumerate(subspace)
        dm[row,:] = _design_vector(construct,dict_mod)
    end
    return dm
end
"""
_design_vector(construct,dict_mod)
internal function to genareted the design space
generates the degign vector one construct.
"""
function _design_vector(construct,dict_mod)
    word2vec = zeros(length(dict_mod))
    index = [dict_mod[mod] for mod in construct]
    word2vec[index] .+=1
    return word2vec
end

"""
go2lab(rng,subspace,Toy_data ; repeat = 3 ,sigma = 1)

Simulated the evaluation of constructs in the lab using the given Toy data set.
This function wraps the evaluation of multiple constructs. The mean and standard deviation are returned:

[`_eval_con`](@ref)
"""

function go2lab(rng,subspace,Toy_data ; repeat = 3 ,sigma = 1)
    μ = Vector{Float64}(undef,length(subspace))
    σ = Vector{Float64}(undef,length(subspace))
    for (i,construct) in enumerate(subspace)
         results =  _eval_con(rng,construct,Toy_data,sigma,repeat)
         μ[i] = Statistics.mean(results)
         σ[i] = Statistics.std(results)
    end
    return μ,σ
end
"""
ground_truth(construct,Toy_data)

Calculates the true value of a construct given the Toy Data set.
"""

ground_truth(construct,Toy_data) = sum([Toy_data[mod] for mod in construct])

"""
_eval_con(rng,construct,Toy_data,sigma,repeat)

Internal function to evaluated a single constructed.
Sigma sets the standard deviation of the normal distribution that sets that generates the activities.
Repeats is the number of time the same constructed is evaluated.

[`_eval_con`](@ref)
"""
function _eval_con(rng,construct,Toy_data,sigma,repeat)
  mean = ground_truth(construct,Toy_data)
  distr = Normal(mean,sigma)
  return  [rand(rng,distr) for rep in 1:repeat]
end

@doc raw"""

BO_Lin_wrapper(constructs,activities,sigma,moduels)
Wrapper fit a Bayesian linear regression model using the given constructs.

```math
β ∼ \mathcal{N}(0,1)
```
"""
function BO_Lin_wrapper(constructs,activities,sigma,moduels)
    #fall back to set prior
    n_moduels = length(moduels) |> Int
    mw, Λw = zeros(n_moduels), Diagonal(ones(n_moduels))
    Σ_noise = Diagonal(sigma)
    return BO_Lin_wrapper(constructs,activities,moduels,mw,Λw,Σ_noise)
end

"""
BO_Lin_wrapper(constructs,activities,moduels,mw,Λw,Σ_noise)
Wrapper fit a Bayesian linear regression model using the given constructs.
Custom prior can be used in this case, if n = number of modules.
Than mw = vector of mean values with length n
Λw is the precision matrix nxn
"""

function BO_Lin_wrapper(constructs,activities,moduels,mw,Λw,Σ_noise)
    #setup of the prior
    f = BayesianLinearRegressor(mw, Λw)
    #make design Matrix
    X_design = transpose(design_maxtrix(constructs,moduels))
    # setup the model with design matrix off set if requierd
    fX = f(X_design, Σ_noise)
    # posterior
    f_post = posterior(fX,activities)
    return f_post
end

"""
BO_Lin_wrapper(constructs,activities,moduels,mw,Λw,Σ_noise)
Wrapper fit a Bayesian linear regression model using the given constructs.
Allow the model to update the prior base on the posterior of the previous model.
"""

function BO_Lin_wrapper(f_post,constructs,activities,sigma,moduels)
    #fall back to set prior
    n_moduels = length(moduels) |> Int
    mw, Λw = f_post.mw, f_post.Λw
    Σ_noise = Diagonal(sigma)
    return BO_Lin_wrapper(constructs,activities,moduels,mw,Λw,Σ_noise)
end
"""
make_predictions(Unseen_space, mod)

Wrapper function to make predictions using the model

"""
make_predictions(Model_output,Unseen_space, mod) = mean.(marginals(Model_output(transpose(design_maxtrix(Unseen_space ,mod)),eps())))

"""
Linear_TS_sampling(f,moduels,constructs,n_samples,σ² = 10^-6)
Thomson sampler for linear models. Internally a design matrix is constructed.
For more information see documentation or [`thompson_sampling`](@ref)

"""

function Linear_TS_sampling(f,moduels,constructs,
                n_samples,σ² = 10^-6)
    @assert length(constructs) ≥ n_samples
    dm = transpose(design_maxtrix(constructs,moduels))
    # indices selected
    selected = Int[]
    all_test = copy(dm)
    Ndist = f(all_test, σ²)
    while length(selected) < n_samples
        f̂ = rand(Ndist)
        f̂[selected] .= - Inf
       i = argmax(f̂)
       push!(selected, i)
   end
   return constructs[selected]
end



"""
model_linear(design,n_first,n_samples,Toy_data,n_cycles)

Wrapper to execute multiple cycles of the Optimisation process efficiently.
A demonstration function only useful to multiple evaluated steps.
Function you probably don't need.

"""

function model_linear(design,n_first,n_samples,Toy_data,n_cycles)
    rng = MersenneTwister()
    # to save the output
    max_model = Vector{Float64}(undef,n_cycles)
    #first steps
    space = getspace(design)
    new_constructs = StatsBase.sample(rng,space,n_first)
    lab_μ,lab_σ = go2lab(rng,new_constructs,Toy_data)
    df = DataFrame(constructs = new_constructs,μ = lab_μ, σ = lab_σ);
    #get the full space explicitly
    Unseen_space = getspace(design,full = true).space
    for i in 1:n_cycles
        # make model
        Model_output = BO_Lin_wrapper(df.constructs,df.μ,df.σ,design.mod)
        # filter space
        Unseen_space = filter(x-> !(x in new_constructs) , Unseen_space)
        #sample with TS
        new_constructs = Linear_TS_sampling(Model_output,design.mod,Unseen_space,n_samples)
        #evaluated new points
        lab_μ,lab_σ = go2lab(rng,new_constructs,Toy_data);
        new_df = DataFrame(constructs = new_constructs, μ = lab_μ, σ = lab_σ)
        append!(df,new_df)
        max_model[i] = maximum(df.μ)
    end
    return max_model
end


"""
model_random(design,n_first,n_samples,Toy_data,n_cycles)
Simple random model to use as a baseline to compear with other models.
"""
function model_random(design,n_first,n_samples,Toy_data,n_cycles)
    rng = MersenneTwister()
    max_random = Vector{Float64}(undef,n_cycles)
    #first steps
    space = getspace(design)
    new_constructs = StatsBase.sample(rng,space,n_first)
    lab_μ,lab_σ = go2lab(rng,new_constructs,Toy_data)
    df = DataFrame(constructs = new_constructs,μ = lab_μ, σ = lab_σ);
    #get the full space explicitly
    Unseen_space = getspace(design,full = true).space
    for i in 1:n_cycles
        Unseen_space = filter(x-> !(x in new_constructs) , Unseen_space)
        new_constructs = StatsBase.sample(rng,Unseen_space,n_samples)
        lab_μ,lab_σ = go2lab(rng,new_constructs,Toy_data);
        new_df = DataFrame(constructs = new_constructs, μ = lab_μ, σ = lab_σ)
        append!(df,new_df)
        max_random[i] = maximum(df.μ)
    end
    return max_random
end


"""
update_prior_model_linear(design,n_first,n_samples,Toy_data,n_cycles)
Linear model that updates the posterior in every cycle
"""
function update_prior_model_linear(design,n_first,n_samples,Toy_data,n_cycles)
    rng = MersenneTwister()    # to save the output
    max_model = Vector{Float64}(undef,n_cycles)
    #first steps
    space = getspace(design)
    #save usemodel and new constructs for previous round (model = 1, new_df = 2)
    model_vector = Array{BayesianLinearRegressor}(undef,1)
    df_new_vector = Array{DataFrame}(undef,1)
    #start
    new_constructs = StatsBase.sample(rng,space,n_first)
    lab_μ,lab_σ = go2lab(rng,new_constructs,Toy_data)
    df = DataFrame(constructs = new_constructs,μ = lab_μ, σ = lab_σ);
    #get the full space explicitly
    Unseen_space = getspace(design,full = true).space
    for i in 1:n_cycles
        # make model, update prior and only use new data points
        if i == 1
            model_vector[1] = BO_Lin_wrapper(df.constructs,df.μ,df.σ,design.mod)
        else
            model_vector[1] = BO_Lin_wrapper(model_vector[1],df_new_vector[1].constructs,df_new_vector[1].μ,df_new_vector[1].σ,design.mod)
        end
        # filter space
        Unseen_space = filter(x-> !(x in new_constructs) , Unseen_space)
        #sample with TS
        new_constructs = Linear_TS_sampling(model_vector[1],design.mod,Unseen_space,n_samples)
        #evaluated new points
        lab_μ,lab_σ = go2lab(rng,new_constructs,Toy_data);
        df_new_vector[1] = DataFrame(constructs = new_constructs, μ = lab_μ, σ = lab_σ)
        append!(df,df_new_vector[1])
        max_model[i] = maximum(df.μ)
    end
    return max_model
end

"""
make_plot(plt,max_values::Matrix; label="label",color = :blue)

Generates the plots to compear different models.
"""
function make_plot(plt,max_values::Matrix; label="label",color = :blue)
    mean_m = [mean(i) for i in eachcol(max_values)]
    sigma_m = [std(i) for i in eachcol(max_values)]
    return plot!(plt,collect(1:size(max_values)[2]),mean_m,ribbon = 2*sigma_m./sqrt(size(max_values)[1]), label=label, color = color ,lw=1.5,fillalpha = 0.3)
end
