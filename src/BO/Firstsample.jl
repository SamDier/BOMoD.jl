"""
    pairwised(X,d)
Returns the pairwise distances `d` between every vector stored in X.
"""

function pairwised(X,d)
    m = length(X)
    return [evaluate(d,X[i],X[j]) for i in (1:m-1) for j in (i+1):m]
end

"""
    Compear_distance(Bᵢ,Bⱼ,d;rev=false)

 Returns the most spacefilling subset given Bᵢ of Bⱼ.
 The distance `d` is used to evaluate the pairwise distance in every set.
 The `rev` arguments allow to adapt the function to different distances.
 Set rev = false if the distance decreases as two vectors are more similar.
 e.g. Levenshtein distance.
 Set rev = true if a simularity is used, which increase as two vectors are more similar
 e.g. Cosine simularity
"""
function Compear_distance(Bᵢ,Bⱼ,d;rev=false)
    Dᵢ = pairwised(Bᵢ,d) |> (t -> sort(t,rev=rev))
    Dⱼ = pairwised(Bⱼ,d) |> (t -> sort(t,rev=rev))
    for (di,dj) in zip(Dᵢ,Dⱼ)
        if di < dj
            return Bⱼ
        elseif di > dj
            return Bᵢ
        end
    end
    @info "equaly spaced and first set is returned"
    return Bᵢ
end

"""
    greedy_local_search(d,S,B,b,)

"""

function greedy_local_search(d,S,B,b,)
    while length(B) < b
        j = argmin([sᵢ ∈ B ? -Inf64:d_max(d,S,push!(copy(B),sᵢ)) for sᵢ in S])
        push!(B, S[i])
    end
return S
end


min_dist(d,sᵢ, B ) = minimum(evaluate(d,sᵢ,xᵢ) for xᵢ in B)
d_max(d,S,B) = maximum(min_dist(d,sᵢ,B) for sᵢ in S)
