##########################
#Wrapper Stheno GP modeles
##########################
####
#output structs
####
#=
struct Hyperparmeter{T} <: AbstractVector{T}
        parm::Vector{T}
end

Base.length(p::Hyperparmeter) = length(p.parm)
Base.size(p::Hyperparmeter) = (length(p.parm),1)
Base.getindex(p::Hyperparmeter,i) = p.parm[i]
=#
"""
        GPModel{T <: Any}

Struct to store fitted model with given Kernel K and hyperparmeters θ
"""

struct GPModel{Tf <: Any, Ts <: Any}
        f̂::Tf
        K::Kernel
        θ::Dict{String,Ts}
end

"""
        GPModel{T <: Any}

Struct to store precitions of the model en used input points
"""
struct GPpredict{Tf <: Any,Tx<: Any}
        f̂_pred::Tf
        x_test::Tx
end


#####
#Fit and Predict
#####

"""
   fit_gp(x_train,y_train,k::Kernel,mod::GroupMod,θ;σ²_n = 10^-6,optimise = false)

  Fit a Gaussian process with kernel `k` to the given training data `x_train`,`y_train`.
  Respectively the input constructs a corresponding activity values.
  Theta is the vector containing the hyperparameters of the model.
  If only one hyperparameter is needed, it still should be in a vector.
  Two kwarg are given:
  `σ²_n::`  which is the variance on the data points, default =``10^-6`` .
  `optimise::` Set to true if hyperparameters need to be optimised based
   on maximum likelihood estimation, default = false.

"""


function fit_gp(x_train,y_train,k::Kernel,mod::GroupMod,θ;σ²_n = 10^-6,optimise = false)
        v_train = transform_data(x_train,mod::GroupMod,k)
        #set Gaussian procces in Stheno framework
        if optimise
                θ = gp_optimised(v_train,y_train,k,σ²_n)
        end
        # one
        fGP,θ_save = _creatGP(k,θ)
        push!(θ_save, "σ²_n" => σ²_n)
        f_posterior = fGP | Obs( fGP(v_train,σ²_n), y_train)
        #calculate f_postirior based on training data and the prior f
        return GPModel(f_posterior,k,θ_save)
end



"""
    fit_gp(x_train,y_train::Vector,k::Kernel,parm)

  Fit a Gaussian process using a kernel on a graph.

  A weighted graph is build up using the full design space ,`S`, as nodes.
  The edge rule determines the weight on the edges.

  Base on the graph, the whole kernel is precomputed.
  As a result, the model requires the **indexes** of the training data in vector x_train,
  and not the construct.
  The y_train vector contains the activity values for the training data.
  Theta is the vector containing the hyperparameters of the model.
  If only one hyperparameter is needed, it still should be in a vector.
  Two kwarg are given:
  σ²_n::  which is the variance on the data points, default =``10^-6`` .
  optimise:: Set to true if hyperparameters
  need to be optimised based on maximum likelihood estimation, default = false.

  eturns a GPModel with the posterior of the gp, the kernel, used hyperparameters
"""


function fit_gp(S,x_train,y_train,k::KernelGraph,edgerule::EdgeRule,θ;σ²_n = 10^-6,optimise = false)
        @assert isa(eltype(x_train),Integer) "for kernel on a graph the index of the given combinations are required as input"
        n_laplace = setupgraph(S,k,edgerule)
        #set Gaussian procces in Stheno framework
        if optimise
                θ = gp_optimised(n_laplace,index_train,y_train,k,σ²_n)
        end
        fGP,θ_save = _creatGP(n_laplace,k,θ)
        push!(θ_save, "σ²_n" => σ²_n)
        f_posterior = fGP | Obs( fGP(x_train,σ²_n), y_train)
        #calculate f_postirior based on training data and the prior f
        return GPModel(f_posterior,k,θ_save)
end




"""
        predict(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
predicts the value from the unseen datapoints

"""
function predict_GP(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
         v_test = transform_data(x_test,mod::GroupMod,model.K)
         return  GPpredict(model.f̂(v_test,σ²_test),x_test)
end

"""
        predict(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
Fitlers first all seen data point out S and than predict values for the unseen datapoints

"""
function predict_GP(S,x_train,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
         x_test = filter(x-> !(x in x_train) ,S)
        return predict_GP(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
end


######
#auxilary fit
######
"""
        _creatGP(k::Kernel, α)
Retuns an Stheno GP  model wiht a given kernel which is scaled with the parameter `α`.
"""

function _creatGP(k::Kernel, θ)
        @assert length(θ) == 1 " Kernel has only one hyperparamter, α"
        fGP = θ[1]* GP(k, GPC())
        return (fGP,Dict{String,Any}("α"=>θ[1]))
end

"""
        _creatGP(k::Kernel, α)
Retuns an Stheno GP  model wiht a given kernel which is scaled with the parameter `α`.
"""

function _creatGP(k::Kernel)
        @assert length(α) == 1 " Kernel has only one hyperparamter, α"
        fGP =  θ[1]* GP(k, GPC())
        return (fGP,Dict{String,Any}("α"=>α,"β"=>β))
end

"""
        _creatGP(k::Kernel, θ)
Retuns an Stheno GP  model with a diffusion kernel and hyperparameters θ.
"""

function _creatGP(n_laplace,gk::DiffusionKernel,θ)
        α = θ[1]
        β = θ[2]
        k = Precomputed(kernelgraph(n_laplace,gk,β))
        fGP = α* GP(k, GPC())
        return (fGP,Dict{String,Any}("α"=>α,"β"=>β))
end


"""
        _creatGP(k::Kernel, α)
Retuns an Stheno GP  model with a p-randomwalk kernel and hyperparameters θ.
"""
function _creatGP(graph_l,gk::Prandomwalk,θ)
        α = θ[1]
        a = θ[2]
        k = Precomputed(kernelgraph(n_laplace,gk,a))
        fGP = α * GP(k, GPC())
        return (fGP,Dict{String,Any}("α"=>α,"a"=>a,"p" => gk.p))
end

###############
# Hyperparmeter optimisation
# all optimisation is done with the Optim package
# https://github.com/JuliaNLSolvers/Optim.jl
###############



"""
     nlml_stheno(parm, x_train, y_train, k::Kernel, σ²_n = 1e-6)

 Calculates the negative log marginal likelihood for GP model, with given Kernel `k` and hyperparatmeters θ
 The model is trained with the given datapoints x_train and corresponding values y_train
 Adds a small offset ,`σ²_n`, is the variance added to the model.
"""

function nlml_stheno(θ_temp, x_train, y_train, k::Kernel, σ²_n)
    θ_exp = exp.(θ_temp) .+ 1e-6
    f,_ = _creatGP(k,θ_exp)
    return -logpdf(f(x_train,σ²_n), y_train)
end


"""
     nlml_stheno(parm, x_train, y_train, k::Kernel, σ²_n = 1e-6)

 Calculates the negative log marginal likelihood for GP model, with given Kernel `k` and hyperparatmeters θ
 The model is trained with the given datapoints x_train and corresponding values y_train
 Adds a small offset ,`σ²_n`, is the variance added to the model.
"""

function nlml_stheno(θ_temp,n_laplace,x_train, y_train, k::KernelGraph, σ²_n)
    θ_exp = exp.(θ_temp) .+ 1e-6
    f,_ = _creatGP(n_laplace,k,θ_exp)
    return -logpdf(f(x_train,σ²_n), y_train)
end


######
# gp_optimised 1 hyperparameter
#
######
"""
     gp_optimised(x_train,y_train,k::Kernel,σ²_n;min = -0.01, max = 100.0)

 Returns optimise a gp_model with a single hyperparameter
 with given input argument x_train,y_train,k,σ²_n
 The parameters are obtained by maximum-likelihood estimation.
 The model uses the Goldensection algorithm  from Optim.jl,
 min and max are respectively the lower and upper
 initial boundary of the algorithm

"""

function gp_optimised(x_train,y_train,k::Kernel,σ²_n;min = -0.01, max = 100.0)
#do perform optimisation base on gradient
results = Optim.optimize(θ_temp->nlml_stheno(θ_temp,x_train,y_train,k,σ²_n),min,max,
              GoldenSection())
#get optimal hyperparameters
        α_opt = exp.(Optim.minimizer(results)) .+ 10^-6
        return α_opt
end

"""
     gp_optimised(n_laplace,x_train,y_train,k::Kernel,σ²_n;θ₀=[0.0,0.0])

 Returns optimise a gp_model for a kernel on a graph with two hyperparameters
 with given input argument n_laplace, x_train, y_train, k, σ²_n
 The parameters are obtained by maximum-likelihood estimation.
 The model uses the NelderMead() algorithm  from Optim.jl,
 θ₀ is the initial starting point of the algoritme

"""
function gp_optimised(n_laplace,x_train,y_train,k::KernelGraph,σ²_n,θ₀=[0.0,0.0])
        results = Optim.optimize(θ_temp->nlml_stheno(θ_temp,n_laplace,x_train,y_train,k,σ²_n),θ₀,
                      NelderMead())
        #get optimal hyperparameters
                  θ_opt = exp.(Optim.minimizer(results)) .+ 10^-6
                return  θ_opt
end

####
#linear
# think gradient is litte over the top....
####

#=

"""
     gp_optimised(x_train,y_train::Vector,k::Linear,σ²_n; θ₀= [0])

 Returns the optimal hyperparameter for al linear kernel
"""

function gp_optimised(x_train,y_train,k::Linear,σ²_n; θ₀=[1.0])
        results = Optim.optimize(θ_temp->nlml_stheno(θ_temp,x_train,y_train,k,σ²_n),
                θ_temp->gradient(t -> nlml_stheno(t,x_train,y_train,k,σ²_n),θ_temp)[1],θ₀,
                BFGS(); inplace=false)
#get optimal hyperparameters
        α_opt = exp.(Optim.minimizer(results)) .+ 10^-6
        return α_opt
end
=#

######
# transform_data
######

"""
        transform_data(x_in,mod::GroupMod,::Linear)
 Current implementation opt Stheno linear model requires spacial data input.
 Function transforms the vector of constructs into the vector embedding
 and then transforms the data into `ColVecs` type to fit linear model
"""

function transform_data(x_in,mod::GroupMod,::Linear)
        # get vector embedding
        v_out = map(x -> _word2vec(x,mod),x_in)
        #transform to ColVecs
        return hcat(v_out...) |> ColVecs
end


"""
        transform_data(x_train)
"""

transform_data(x_in,mod::GroupMod,::Kernel) = x_in
