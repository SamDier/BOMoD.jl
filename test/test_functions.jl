##############
#auxiliary functions to run the testes
##############

function Grammatrix_levenstein(Xᵢ,Xⱼ)
    K = Array{Float64,2}(undef,4,4)
    for (i,si) in enumerate(Xᵢ)
        for (j,sj) in  enumerate(Xⱼ)
            K[i,j] = exp(-evaluate(Levenshtein(),si,sj))
        end
    end
    return K
end

function Grammatrix_cossine(Xᵢ,Xⱼ,all_mod)

     K= Array{Float64,2}(undef,4,4)
    for (i,si) in enumerate(Xᵢ)
        for (j,sj) in  enumerate(Xⱼ)
            v1 = _word2vec(si,all_mod)
            v2 = _word2vec(sj,all_mod)
            K[i,j] = 1-cosine_dist(v1,v2)
        end
    end
    return K
end
