function pairwised(X,d)
    m = length(X)
    return [evaluted(d,xi,xj) for xi in (1:m-1) for j in (i+1):m]
end


function Compear_distance(Bᵢ,Bⱼ,d)
    Dᵢ = pairwised(Bᵢ,d) |> sort
    Dⱼ = pairwised(Bⱼ,d) |> sort
    for (di,dj) in zip(Dᵢ,Dⱼ)
        if di < dj
            return Bⱼ
        elseif di > dj
            return Bᵢ
        end
    end
    return Bᵢ
end
