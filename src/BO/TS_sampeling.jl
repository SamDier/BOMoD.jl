#Sampling methods
"""
thompson_sampling(f, x::AbstractVector,n_samples, σ²)
Brute force thompson sampling over the inter undiscovered search space.
"""

function thompson_sampling(f, x::AbstractVector,
                n_samples, σ²)
    @assert length(x) ≥ n_samples

    # indices selected
    selected = Int[]
    all_test = copy(x)
    Ndist = f(all_test, σ²)
    while length(selected) < n_samples
        f̂ = rand(Ndist)
        f̂[selected] .= - Inf
       i = argmax(f̂)
       push!(selected, i)
   end
   return (x[selected],selected)
end

"""
    save_thompson_sampling(f, x::AbstractVector,n_samples, σ²)
A brute force thompson sampling algorithm that uses the initer undiscovered search space.
Save version that uses the eigenvalue decomposition of the posterior covariance matrix to assure that the covariance matrix is positive definite
"""

function save_thompson_sampling(f_post, constructs_test::AbstractVector,n_samples,σ²_opt)
    myeigen = (-(eigvals!(cov(f_post(constructs_test)))[1])) + σ²_opt
    if  myeigen > 0
        println("usetrick")
        sigma_add = myeigen+σ²_opt
        nextsample = thompson_sampling(f_post,constructs_test,n_samples,sigma_add)
    else
        nextsample = thompson_sampling(f_post,constructs_test,n_samples,σ²_opt)
    end
    return nextsample
end
