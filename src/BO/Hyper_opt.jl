##########################
#Wrapper Stheno GP modeles
##########################

struct Hyperparmeter{T} <: AbstractVector{T}
        parm::Vector{T}
end

Base.length(p::Hyperparmeter) = length(p.parm)
Base.size(p::Hyperparmeter) = (length(p.parm),1)
Base.getindex(p::Hyperparmeter,i) = p.parm[i]

struct GPModel{T <: Any}
        f̂::T
        K::Kernel
        θ::Dict{String,Float64}
end

######
#Kernel specific funtions
######

"""
        _creatGP(k::Linear,α::Hyperparm)
 Retuns an Stheno GP model wiht a linear kernel and is scaled with the parameter `α`.
"""
function _creatGP(k::Linear, α)
        @assert length(α) == 1 "Linear Kernel has only one hyperparamter, α"
        fGP = α[1]* GP(k, GPC())
        return (fGP,Dict{String,Float64}("α"=>α[1]))
end

"""
        _transform_data(x_train)
 Current implementation opt Stheno linear model requires spacial data input.
 Function transforms the vector of constructs into the vector embedding
 and then transforms the data into `ColVecs` type to fit linear model
"""

function transform_data(x_in,mod::GroupMod)
        # get vector embedding
        v_out = map(x -> _word2vec(x,mod),x_in)
        #transform to ColVecs
        return hcat(v_out...) |> ColVecs
end

"""
     gp_optimised(x_train,y_train::Vector,k::Linear,σ²_n; θ₀= [0])

 Returns the optimal hyperparameter for al linear kernel
"""

function gp_optimised(x_train,y_train,k::Linear,σ²_n; θ₀=[0.0])
        results = Optim.optimize(θ_temp->nlml_stheno(θ_temp,x_train,y_train,k),
                θ_temp->gradient(t -> nlml_stheno(t,x_train,y_train,k),θ_temp)[1],θ₀,
                BFGS(); inplace=false)
#get optimal hyperparameters
        α_opt = exp.(Optim.minimizer(results)) .+ 10^-6
        return α_opt
end
#####
#General GP fit functions
#####

"""
    fit_gp(x_train,y_train::Vector,k::Kernel,parm)

Fit a Gaussian procces to the given training data `x_train`,
which is a `AbstractVector{T where T::AbstractConstruct}` and
 y_train constains the correspoding functions values

Returns a Stheno object.
"""


function fit_gp(x_train,y_train,k::Kernel,mod::GroupMod,θ;σ²_n = 10^-6,optimise = false)
        v_train = transform_data(x_train,mod::GroupMod)
        #set Gaussian procces in Stheno framework
        if optimise
                θ = gp_optimised(v_train,y_train,k,σ²_n )
        end
        fGP,θ_save = _creatGP(k,θ)
        push!(θ_save, "σ²_n" => σ²_n)
        f_posterior = fGP | Obs( fGP(v_train,σ²_n), y_train)
        #calculate f_postirior based on training data and the prior f
        return GPModel(f_posterior,k,θ_save)
end


"""
     nlml_stheno(parm, x_train, y_train, k::Kernel, σ²_n = 1e-6)

 Calculates the negative log marginal likelihood for GP model, with given Kernel `k` and hyperparatmeters θ
 The model is trained with the given datapoints x_train and corresponding values y_train
 Adds a small offset ,`σ²_n`, is the variance added to the model.
"""

function nlml_stheno(θ_temp, x_train, y_train, k::Linear; σ²_n = 1e-6)
    θ_exp = exp.(θ_temp) .+ 1e-6
    f,_ = _creatGP(k,θ_exp)
    return -logpdf(f(x_train,σ²_n), y_train)
end

"""
        predict(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
predicts the value from the unseen datapoints

"""
function predict_GP(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
         v_test = transform_data(x_test,mod::GroupMod)
         println
         return model.f̂(v_test,σ²_test)
end
"""
        predict(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
Fitlers first all seen data point out S and than predict values for the unseen datapoints

"""
function predict_GP(S,x_train,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
         x_test = filter(x-> !(x in x_train) ,S)
         predict_GP(x_test,model::GPModel,mod::GroupMod; σ²_test = 1e-6)
end









# get optimised hyperparameter
"""
     nlml_stheno(parm, x_train,y_train, K::Kernel; ϵ=1e-6)

Calculates the negative log marginal likelihood for given parameters and kernel.
Adds a small offset `ϵ` for numerical purposes.
"""
function nlml_stheno(parm, x_train, y_train, k::Kernel; ϵ=1e-6)
        @assert length(parm) == 2
        α,σ²= exp.(parm) .+ ϵ
        f = α*GP(k, GPC())
        return -logpdf(f(x_train, σ²), y_train)
end

#FIXME: `Kernel` is a type or an oject (e.g., `Kernel()`), I think this should be
# in with a small cap => `kernel`
"""
    GP_optimised(parm, constructs_train, activity_train, Mykernel::Kernel)

Optimises the hyperparameters of the GP with the given kernel.
Then calculated the posterior distribution given this optimised hyperparameters
and data.

Returns a Stheno object.
"""
function gp_optimised(constructs_train,activity_train,Mykernel::Kernel; θ₀= zeros(2))
        results = Optim.optimize(parm -> nlml_stheno(parm,constructs_train,activity_train,Mykernel), θ₀, NelderMead())
        #get optimal hyperparameters
        α_opt, σ²_opt = exp.(Optim.minimizer(results)) .+ 10^-6
        #set Gaussian procces in Stheno framework
        fGP = α_opt * GP(Mykernel, GPC())
        #calculate f_postirior based on training data and the prior f
        return  GP_optimised(fGP | (fGP(constructs_train,σ²_opt) ← activity_train), α_opt, σ²_opt)
end

struct GP_optimised{T}
        GP_model::T
        α_opt::Float64
        σ²_opt::Float64
end
