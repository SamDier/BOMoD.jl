####
#String to vector
####


"""
   _word2vector(construct,dict_mod)

Returns the vector embedding of a give `construct` where the
length equals the number of modules in dict_mod. The occurrence of every model is counted.
Afterwards, these numbers are stored in a vector ad the correponding index index.
The corresponding index of every construct is stored in`dict_mod`.
"""
function _word2vec(construct,dict_mod)
    word2vec = zeros(Int,length(dict_mod))
    for mod in construct
        word2vec[dict_mod[mod]]+=1
    end
    return word2vec
end
"""
    _word2vec(construct,mod::GroupMod)

Returns the vector embedding of a give `construct` where the
length equals the number of modules in mod. The occurrence of every module is counted.
Afterwards, these numbers are stored in a vector and the correct index.
The corresponding index of every construct is stored in`dict_mod`.
"""
function _word2vec(construct,mod::GroupMod)
    dict_mod = Dict(mod.m .=> collect(1:length(mod.m)))
    _word2vec(construct,dict_mod)
end


####
#Q-gram distances
####
struct QgramKernel{T <: QGramDistance } <: Kernel
    d::T
end

ew(k::QgramKernel, x::AbstractVector) = [1-evaluate(k.d,xᵢ,xᵢ)) for xᵢ in x]
ew(k::QgramKernel, x::AbstractVector, x′::AbstractVector) = [1-evaluate(k.d,xᵢ,xⱼ)) for (xᵢ,xⱼ) in zip(x, x′)]

pw(k::QgramKernel, x::AbstractVector) = reshape([1-evaluate(k.d,xᵢ,xⱼ)) for xᵢ in x for xⱼ in x] ,(length(x),length(x)))
pw(k::QgramKernel, x::AbstractVector, x′::AbstractVector) = reshape([1-evaluate(k.d,xᵢ,xⱼ)) for xⱼ in x′ for xᵢ in x] ,(length(x),length(x′)))

###
#EditDistancesKernel
###
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

ew(k::EditDistancesKernel, x::AbstractVector) = [exp(-evaluate(k.d,xᵢ,xᵢ)) for xᵢ in x]

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

####
#Diffusion
####
"""
    Diffusion
allow to use a Diffion kernel on a graph.
The graph is constructed based on all combinations.
"""
abstract type KernelGraph{T} <:Kernel{T}
struct DiffusionKernel{T}  <: KernelGraph{T}
    β::T
 end
struct Prandomwalk{T}   <: KernelGraph
    p::Int
    a::{T}
 end

function setupgraph(S,k::KernelGraph,edgerule::EdgeRule)
    fullspace = collect(S)
    return  adjacency(fullspace, edgerule) |>  norm_laplacian
end


"""
     kernelgraph(l::AbstractArray,gk::Diffusion;β = 1)

Diffusion kernel on the normalized laplacian `l` wiht hyper parameter β

Smola A.J., Kondor R. (2003) Kernels and Regularization on Graphs.
In: Schölkopf B., Warmuth M.K. (eds) Learning Theory and Kernel Machines.
Lecture Notes in Computer Science, vol 2777. Springer, Berlin, Heidelberg
"""
kernelgraph(L,gk::DiffusionKernel,β) = exp(-β*L)

"""
     kernelgraph(l::AbstractArray,gk::Diffusion;β = 1)
p-random walk kernel on the normalized laplacian `l` wiht hyper parameter a

Smola A.J., Kondor R. (2003) Kernels and Regularization on Graphs.
In: Schölkopf B., Warmuth M.K. (eds) Learning Theory and Kernel Machines.
Lecture Notes in Computer Science, vol 2777. Springer, Berlin, Heidelberg
"""
function kernelgraph(L,gk::Prandomwalk,a,p)
    @assert a >= 2 "a has to be larger than 2"
    return (a*I - L)^(p)
end







@doc raw"""
    cossim(xᵢ,xⱼ)
Returns the cosine  similarity  between two strings.
The first the strings are transformed in a vector-embedding
and then between the obtained vectors the cosine similarity.

``cossim(x_i,x_j))= dot(x_i, x_j) / (norm(x_i) * norm(x_j))``

"""

function cossim(xᵢ,xⱼ)
    letter2index = Dict( letter => index for (index,letter) in enumerate(Set([xᵢ;xⱼ])))
    xi_v = _word2vec(xᵢ,letter2index)
    xj_v = _word2vec(xⱼ,letter2index)
    return dot(xi_v,xj_v)/(norm(xi_v) * norm(xj_v))
end


struct CosStheno <: Kernel end


ew(::CosStheno , x::AbstractVector{N} where N) = ones(length(x))
ew(::CosStheno , x::AbstractVector{N} where N, x′::AbstractVector{N} where N) = [cossim(xᵢ,xⱼ) for (xᵢ,xⱼ) in zip(x, x′)]


pw(k:: CosStheno , x::AbstractVector{N} where N) = reshape([cossim(xᵢ,xⱼ) for xᵢ in x for xⱼ in x] ,(length(x),length(x)))
pw(k:: CosStheno , x::AbstractVector{N} where N, x′::AbstractVector{N} where N) = reshape([cossim(xᵢ,xⱼ) for xⱼ in x′ for xᵢ in x] ,(length(x),length(x′)))
