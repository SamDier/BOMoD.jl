
"""
    go2lab(rng, subspace, Toy_data ; repeat = 3 ,sigma = 1)

Simulated the evaluation of constructs in the lab using the given Toy data set.
This function wraps the evaluation of multiple constructs. The mean and standard deviation are returned:

[`_eval_con`](@ref)
"""

function go2lab(rng, subspace, Toy_data; repeat=3 ,sigma=1)
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
    ground_truth(construct, Toy_data)

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
