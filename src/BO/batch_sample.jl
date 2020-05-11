####
# Batch sampling methods
# function to sample b new data points
# optimise for  b << b_max with b_max all unseen test datapoints
###

"""
    thompson_sampling(f_pre::GPpredict,b; σ² = 10^-6)

Brute force Thompson sampling of all unseen data obtain b new samples.
Use GPpredict object,
which contains the GP_prediction model and the unseen design points

"""
function ts_sampler_stheno(f_pre::GPpredict,b)
    @assert length(f_pre.x_test) ≥ b
    # indices selected
    selected = Int[]
    f̂_matrix = rand(f_pre.f̂_pred,b)
    for j in eachcol(f̂_matrix)
        j[selected]  .= - Inf64
       i = argmax(j)
       push!(selected, i)
   end
   return f_pre.x_test[selected]
end

function ts_sampler_me(f_pre::GPpredict,b)
    # some checks
    @assert length(f_pre.x_test) ≥ b
    # index selected
    selected = Int[]
    #estimate distributions
    Ndist = marginals(f_pre.f̂_pred)
    #b randomsample form every distribution and set to matrix
    f̂_matrix = map(x->rand(x,b),Ndist) |> x-> hcat(x...)  |> permutedims
    # get max form every column
    # avoid retake, previous selected = -inf
    for n in eachcol(f̂_matrix)
        n[selected]  .= - Inf64
       i = argmax(n)
       push!(selected, i)
   end
   return f_pre.x_test[selected]
end

"""
    ei_sampler(f_pre::GPpredict,fmax,b;ϵ = 0)

Brute force Expected improvement (EI) to obtain b samples
from the non-evaluated
design space.
These means that for all unseen combination the  EI is calculated and the best b
constructs are returned
Uses a GPpredict object,
which contains the GP_prediction model and the unseen design points

ϵ is a paramters to balance between exploring and exploiting.
higher ϵ values will explore the search space more.
"""

function ei_sampler(f_pre::GPpredict,b,fmax;ϵ = 0)
    ei_values = ei(f_pre,fmax,;ϵ = 0) |> x -> sort( x,:EI,rev=true)
    return ei_values.x_test[1:b]
end

"""
    pi_sampler(f_pre::GPpredict,fmax,b;ϵ = 0)

Brute force Probability of improvement (PI) to obtain b samples
from the non-evaluated
design space.
The  PI is calculated for all unseen construct, and the b constructs
with the highest value are returned.
Uses a GPpredict object,
which contains the GP_prediction model and the unseen design points

ϵ is a paramters to balance between exploring and exploiting.
higher ϵ values will explore the search space more.
"""
function pi_sampler(f_pre::GPpredict,b,fmax;ϵ = 0)
    pi_values = pi(f_pre,fmax;ϵ = 0) |> x -> sort( x ,:PI,rev=true)
    return pi_values.x_test[1:b]
end

"""
    gpucb_sampler(f_pre::GPpredict,b,β)

Brute force calculation of the  Gaussian Process Upper Confidence Bound (GP-UCB)
to obtain b samples from the non-evaluated design space.
The  (GP-UCB) is calculated for all unseen construct,
and the b constructs with the highest value are returned.
Uses a GPpredict object,
which contains the GP_prediction model and the unseen design points

β is a paramters to balance between exploring and exploiting.
higher β values will explore the search space more.
"""
function gpucb_sampler(f_pre::GPpredict,b,β)
    gpubc_values = gp_ubc(f_pre::GPpredict,β) |> x -> sort( x ,:UCB,rev=true)
    return gpubc_values.x_test[1:b]
end

function ucb_sampler(f_pre::GPpredict,λ,b)
    ubc_values = ubc(f_pre::GPpredict,λ) |> x -> sort( x ,:UCB,rev=true)
    return ubc_values.x_test[1:b]
end

"""
    optimial_β(optimial_β(n,t;δ= 0.1)

  Optimal β for gp_ucb for sequential samler
  with n = number of training datapoints
  and t = iteration number
  δ ∈ [0,1]

  Gaussian Process Optimization in the Bandit Setting: No Regret and Experimental Design
  N. Srinivas, A. Krause, S.M. Kakade, M. Seeger.
  arXiv e-prints, pp. arXiv:0912.3995. 2009.
"""
optimial_β(n,t;δ = 0.2) = 2*log(n*t^2*π^2/(6δ))






######
# auxilary function for the acquisition function
# all formals can be found on
######

"""
    ei(f_pre::GPpredict,fmax,;ϵ = 0)
Return the expect impovent value for the give predicted GP model
ϵ is a paramters to balance between exploring and exploiting.
higher ϵ values will explore the search space more.
"""

function ei(f_pre::GPpredict,fmax;ϵ = 0)
    # estimate distribution
    Ndist = marginals(f_pre.f̂_pred)
    σ_t = std.(Ndist)
    μ_t = mean.(Ndist)
    # calculate z
    z =  (μ_t .- fmax.-ϵ) ./ σ_t
    EI = ((μ_t .- fmax .-ϵ) .*cdf.(Normal(),z)) .+ σ_t .* pdf.(Normal(),z)
    return DataFrame(EI = EI, x_test = f_pre.x_test)
end


"""
    pi(f_pre::GPpredict,fmax,;ϵ = 0)
Return the probability of improvent value for the give predicted GP model
ϵ is a paramters to balance between exploring and exploiting.
higher ϵ values will explore the search space more.
"""


function pi(f_pre,fmax;ϵ = 0)
    # estimate distribution
    Ndist = marginals(f_pre.f̂_pred)
    σ_t = std.(Ndist)
    μ_t = mean.(Ndist)
    # calculate z
    z =  (μ_t .- fmax.-ϵ) ./ σ_t
    PI = cdf.(Normal(),z)
    return  DataFrame(PI = PI, x_test = f_pre.x_test)
end


"""
    ubc(f_pre::GPpredict,λ)

Return the upper bound confience intravel for given prediction

"""

function ubc(f_pre::GPpredict,λ)
        Ndist = marginals(f_pre.f̂_pred)
        σ_t = std.(Ndist)
        μ_t = mean.(Ndist)
        UCB = μ_t .+ λ.*σ_t
        return DataFrame(UCB = UCB, x_test = f_pre.x_test)
end
"""
    gp_ubc(f_pre::GPpredict,λ)

Return the gp- upper bound confience intravel for given predictions.

"""
gp_ubc(f_pre::GPpredict,β) =  ubc(f_pre::GPpredict,sqrt(β))


#####
# need?
######



#FIXME: what is `initer`?
#FIXME: `save_thompson_sampling` => `safe_thompson_sampling`
"""
    save_thompson_sampling(f, x::AbstractVector,n_samples, σ²)

A brute force Thompson sampling algorithm that uses the initer undiscovered search space.
Save version that uses the eigenvalue decomposition of the posterior covariance matrix to assure that the covariance matrix is positive definite
"""
function save_thompson_sampling(f_post, constructs_test::AbstractVector,
                                            n_samples, σ²_opt)
    myeigen = (-(eigvals!(cov(f_post(constructs_test)))[1])) + σ²_opt
    if  myeigen > 0
        println("usetrick")
        sigma_add = myeigen+σ²_opt
        nextsample = thompson_sampling(f_post, constructs_test, n_samples,
                                            sigma_add)
    else
        nextsample = thompson_sampling(f_post, constructs_test, n_samples,
                                                σ²_opt)
    end
    return nextsample
end
