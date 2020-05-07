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
 Set rev = true if the distance increase as two vectors are more similar
 e.g. Cosine  simularity
"""
function Compear_distance(Bᵢ,Bⱼ,d;rev=false)
    Dᵢ = pairwised(Bᵢ,d) |> (t -> sort(t,rev=rev))
    Dⱼ = pairwised(Bⱼ,d) |> (t -> sort(t,rev=rev))
    println(Dᵢ)for
    println(Dⱼ)
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
