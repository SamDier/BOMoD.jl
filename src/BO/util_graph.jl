#######
#additional functions to compute a kernel on a graph.
#####

#####
#Define the edge rules, resulting in the weight on the graph between edges
#####
"""
    EdgeRule

Determines the value for the edge.
"""
abstract type EdgeRule end

# define the type of the edge, default is Boolean
Base.eltype(::EdgeRule) = Float64


"""
    NCommon(n::Int)
Edgerule,evaluteds if there are at least n tiles are in common.

"""

struct NCommon <: EdgeRule
    n::Int
end

OneCommon() = NCommon(1)
TwoCommon() = NCommon(2)


"""
    edgevalue(rule::NCommon, sᵢ::Set, sⱼ::Set)

Return 1 if the two sets; sᵢ, sⱼ, have minimum `n` equal modules, 0 if not.
`n` obtained form `Ncommon` struct
"""
edgevalue(rule::NCommon, sᵢ::Set, sⱼ::Set) = length(sᵢ ∩ sⱼ) ≥ rule.n |> Int

"""
    edgevalue(rule::NCommon, xᵢ, xⱼ)

Return 1 if the two vectors; xᵢ, xⱼ,  have minimum `n` equal modules, 0 if not.
`n` obtained form `Ncommon` struct
"""

edgevalue(rule::NCommon, xᵢ, xⱼ) = edgevalue(rule, Set(xᵢ), Set(xⱼ))

"""
    LevRule
Edgerule, base on the Levenshtein distance between strings
"""
struct LevRule <: EdgeRule end

"""
    edgevalue(rule::LevRule, xᵢ, xⱼ)

Returns ``1-\\dfrac{d_\\text{lev}(x_i,x_j)}{\\text{max}}``.
Where ``d_\\text{lev}(x_i,x_j)`` is levenstein distance between xᵢ, xⱼ.
and max is the maximum levenstein distance between xᵢ, xⱼ possible.
"""

function edgevalue(rule::LevRule, xᵢ, xⱼ)
    max = maximum([length(xᵢ),length(xⱼ)])
    return (1 - evaluate(Levenshtein, xᵢ, xⱼ)/max)
end

"""
    CosRule(q::Int)
Edgerule, base on the Cosine distance between strings

"""
struct CosRule <: EdgeRule  end

"""
    edgevalue(rule::CosRule, xᵢ, xⱼ)
Returns the Cosine similarity between xᵢ, xⱼ.
Calulation base on the Cosine function of
[StringDistances.jl](https://github.com/matthieugomez/StringDistances.jl)
current implementation, q = 1 if fixed.
Extention to use the full capacity of this function can be made
"""

edgevalue(rule::CosRule, xᵢ, xⱼ) = (1 - evaluate(StringDistances.Cosine(1), xᵢ, xⱼ))

#######
#Function of the graph
#######
"""
    Base.exp(E::Eigen)
Efficient exponential of a matrix based on the Eigenvalue decomposition
"""
Base.exp(E::Eigen) = eigvecs(E) * Diagonal(exp.(eigvals(E))) * eigvecs(E)'
Base.:*(a::Real, E::Eigen) = Eigen(a * eigvals(E), eigvecs(E))

"""
    degree(A::AbstractMatrix)
Returns a vector with the degree of the graph
"""

degree(A::AbstractMatrix) = Diagonal(sum(A, dims=1)[:])

"""
laplacian(A::AbstractMatrix)
Constructs a Laplacian based on the adjacency matrix `A`.
"""
laplacian(A::AbstractMatrix) = degree(A) - A


"""
    diffusion(L::AbstractMatrix, β::Real=1.0)

Compute the diffusion kernel directly on the Laplacian.
"""
diffusion(L::AbstractMatrix, β::Real=1.0) = exp(β * L)

"""
    diffusion(E::Eigen, β::Real=1.0)

Compute the diffusion kernel based on the Eigenvalue decomposition
of the Laplacian.
"""
diffusion(E::Eigen, β::Real=1.0) = exp(β * E)

"""
    norm_laplacian(L)

Normalizes a Laplacian matrix such that the diagonal values equal -1.
"""
norm_laplacian(A) = I - (degree(A)^(-0.5))*A*(degree(A)^(-0.5))

"""
adjacency(x::AbstractVector, edgerule::EdgeRule)

Constructs an adjacency matrix of the graph based on a list of nodes `x` and and the `edgerule`.
The Diagnal is set to zero, no self-loops allowed in the graph
"""


function adjacency(X::AbstractVector, d::EdgeRule)
    n = length(X)
    A = Matrix{Float64}(undef, n, n)
    for (i, xᵢ) in enumerate(X)
        for (j, xⱼ) in enumerate(X)
            A[i,j] = i==j ?  0 : edgevalue(d,xᵢ, xⱼ)
        end
    end
    return A
end
