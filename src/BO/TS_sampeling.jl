#Sampling methods
"""
    thompson_sampling(f_pre::GPpredict,b; σ² = 10^-6)

Brute force Thompson sampling  to sample b samples form the unseen design space.
Use GP_predict ,which contains the Gp model and the unseen design points
"""
function thompson_sampling(f_pre::GPpredict,b; σ² = 10^-6)
    @assert length(f_pre.x_test) ≥ b
    @assert σ² > 0  #
    # indices selected
    selected = Int[]
    f̂_matrix = rand(f_pre.f̂,b)
    for j in eachcol(f̂_matrix)
        j[selected]  .= - Inf64
       i = argmax(j)
       push!(selected, i)
   end
   return (f_pre.x_test[selected],selected)
end


























"""
    thompson_sampling(f, x::AbstractVector,n_samples, σ²)

Brute force thompson sampling over the inter undiscovered search space.
"""

function thompson_sampling(f, x::AbstractVector,
                n_samples::Integer, σ²::AbstractFloat)
    @assert length(x) ≥ n_samples
    @assert σ² => 0  #CHANGED: added check, if this should be <=
    # indices selected
    selected = Int[]
    all_test = copy(x)
    Ndist = f(all_test, σ²)
    while length(selected) < n_samples
        f̂ = rand(Ndist)
        f̂[selected] .= -Inf64
        i = argmax(f̂)
        push!(selected, i)
    end
    return (x[selected],selected)
end





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

#FIXME: what is `initer`?
#Sampling methods
"""
    thompson_sampling(f, x::AbstractVector,n_samples, σ²)

Brute force Thompson sampling over the inter undiscovered search space.
"""
function thompson_sampling_fast(f, x::AbstractVector,
                n_samples, σ²)
    @assert length(x) ≥ n_samples
    @assert σ² > 0  #CHANGED: added check, if this should be <=
    # indices selected
    selected = Int[]
    all_test = copy(x)
    Ndist = predict_GP()
    f̂_matrix = rand(Ndist,n_samples)
    for n in eachcol(f̂_matrix)
        n[selected]  .= - Inf64 # CHANGED
       i = argmax(n)
       push!(selected, i)
   end
   return (x[selected],selected)
end

"""
    expect_imp(µ,sigma,fmax,sigma_min;ϵ = 0)

expected improvement for a 1-D gaussianprocces.
"""

function expect_imp(µ,sigma,fmax,sigma_min;ϵ = 0)
        Z = z(µ,sigma,fmax,ϵ)
        EX_I = ((μ .- fmax) .*cdf.(Normal(),Z)) .+ sigma.* pdf.(Normal(),Z)
        return EX_I
end

z(μ,sigma,fmax,ϵ) =  (μ .- fmax.-ϵ) ./ sigma
