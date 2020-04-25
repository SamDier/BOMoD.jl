#Sampling methods
"""
    thompson_sampling(f, x::AbstractVector,n_samples, σ²)

Brute force thompson sampling over the inter undiscovered search space.
"""

function thompson_sampling(f, x::AbstractVector,
                n_samples::Integer, σ²::AbstractFloat)
    @assert length(x) ≥ n_samples
    @assert σ² > 0  #CHANGED: added check, if this should be <=
    # indices selected
    selected = Int[]
    all_test = copy(x)
    Ndist = f(all_test, σ²)
    while length(selected) < n_samples
        f̂ = rand(Ndist)
        f̂[selected] .= -Inf64 # CHANGED
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
    Ndist = f(all_test, σ²)
    f̂_matrix = rand(Ndist,n_samples)
    for n in eachcol(f̂_matrix)
        n[selected]  .= - Inf64 # CHANGED
       i = argmax(n)
       push!(selected, i)
   end
   return (x[selected],selected)
end
