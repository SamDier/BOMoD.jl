
function levenshtein(xᵢ, xⱼ)
    n, m = length(xᵢ), length(xⱼ)
    lev = zeros(Int, n+1, m+1)
    lev[:,1] = 0:n
    lev[1,:] = 0:m
    for j in 1:m
        for i in 1:n
            lev[i+1, j+1] = min(
                lev[i, j+1] + 1,
                lev[i+1, j] + 1,
                xᵢ[i]==xⱼ[j] ? lev[i, j] : lev[i, j] + 1
            )
        end
    end
    return last(lev)
end
