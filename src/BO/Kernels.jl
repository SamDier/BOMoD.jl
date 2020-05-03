@doc raw"""
    LevStehnoexp{T} <: Kernel

The kernel for of the levenshteindistance
`` k(x, x^\prime) = \exp(-levensthein(x_i,x_j))``
"""
struct LevStehnoexp{T} <: Kernel
    s::T
end


"""
    levensthein(xᵢ,xⱼ)

Dynamic calculations of the Levenshtein distance between two vectors of modules.
"""
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
ew(k::LevStehnoexp, x::AbstractVector{N} where N) = exp.(-k.s .*zeros(length(x)))
ew(k::LevStehnoexp, x::AbstractVector{N} where N, x′::AbstractVector{N} where N) = [exp(-k.s*levenshtein(xᵢ,xⱼ)) for (xᵢ,xⱼ) in zip(x, x′)]

pw(k::LevStehnoexp, x::AbstractVector{N} where N) = reshape([exp(-k.s*levenshtein(xᵢ,xⱼ)) for xᵢ in x for xⱼ in x] ,(length(x),length(x)))
pw(k::LevStehnoexp, x::AbstractVector{N} where N, x′::AbstractVector{N} where N) = reshape([exp(-k.s*levenshtein(xᵢ,xⱼ)) for xⱼ in x′ for xᵢ in x] ,(length(x),length(x′)))

####
#Cosine kernel
####

####
#make vectors first
####

function myword2vec(word,letter2index)
    word2vec = letter2index  |> t -> length(t) |> l-> zeros(l)
    for letter in word
        word2vec[letter2index[letter]] += 1
    end
    return word2vec
end

#TODO: documentation?
function cossim(xi,xj)
    letter2index = Dict( letter => index for (index,letter) in enumerate(Set([xi...,xj...])))
    xi_v = myword2vec(xi,letter2index)
    xj_v = myword2vec(xj,letter2index)
    return dot(xi_v,xj_v)/(norm(xi_v) * norm(xj_v))
end


struct CosStehno <: Kernel end


ew(::CosStehno, x::AbstractVector{N} where N) = ones(length(x))
ew(::CosStehno, x::AbstractVector{N} where N, x′::AbstractVector{N} where N) = [cossim(xᵢ,xⱼ) for (xᵢ,xⱼ) in zip(x, x′)]


pw(k:: CosStehno, x::AbstractVector{N} where N) = reshape([cossim(xᵢ,xⱼ) for xᵢ in x for xⱼ in x] ,(length(x),length(x)))
pw(k:: CosStehno, x::AbstractVector{N} where N, x′::AbstractVector{N} where N) = reshape([cossim(xᵢ,xⱼ) for xⱼ in x′ for xᵢ in x] ,(length(x),length(x′)))

##
@doc raw"""
    EditDistancesKernel{T} <: Kernel

The kernel for the edit distances diffiend in the [StringDistances.jl]@ref(https://github.com/matthieugomez/StringDistances.jl) package.
`` k(x, x^\prime) = \exp(-distance(x_i,x_j))``
"""
struct EditDistancesKernel{T <: SemiMetric } <: Kernel
    d::T
end


"""
    ew(k::EditDistancesKernel, x::AbstractVector)

Internal function to fit the `EditDistancesKernel` into the Stheno framework.
More information can be found on [Stheno]@ref(https://github.com/willtebbutt/Stheno.jl)
"""

ew(k::EditDistancesKernel, x::AbstractVector) = exp.(-ones(lenght(x)))

"""
    ew(k::EditDistancesKernel, x::AbstractVector, x′::AbstractVector)

Internal function to fit the `EditDistancesKernel` into the Stheno framework.
More information can be found on [Stheno]@ref(https://github.com/willtebbutt/Stheno.jl)
"""

ew(k::EditDistancesKernel, x::AbstractVector, x′::AbstractVector) = [exp(-evaluate(k.d,xᵢ,xⱼ)) for (xᵢ,xⱼ) in zip(x, x′)]

"""
    ew(k::EditDistancesKernel, x::AbstractVector)

Internal function to fit the `EditDistancesKernel` into the Stheno framework.
More information can be found on [Stheno]@ref(https://github.com/willtebbutt/Stheno.jl)
"""

pw(k::EditDistancesKernel, x::AbstractVector) = reshape([exp(-evaluate(k.d,xᵢ,xⱼ)) for xᵢ in x for xⱼ in x] ,(length(x),length(x)))
"""
    ew(k::EditDistancesKernel, x::AbstractVector)

Internal function to fit the `EditDistancesKernel` into the Stheno framework.
More information can be found on [Stheno]@ref(https://github.com/willtebbutt/Stheno.jl)
"""

pw(k::EditDistancesKernel, x::AbstractVector, x′::AbstractVector) = reshape([exp(-evaluate(k.d,xᵢ,xⱼ)) for xⱼ in x′ for xᵢ in x] ,(length(x),length(x′)))
