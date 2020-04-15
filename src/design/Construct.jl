abstract type AbstractConstruct{T} end

# Define some base function on AbstractConstruct
Base.eltype(::AbstractConstruct{T}) where {T} = T
Base.getindex(Construct::AbstractConstruct,i::Int) = Construct.c[i]
Base.getindex(Construct::AbstractConstruct,i::UnitRange) = Ordered_Construct(Construct.c[i])
Base.length(Construct::AbstractConstruct) = length(Construct.c)
Base.lastindex(Construct::AbstractConstruct) =  last(eachindex(IndexLinear(), Construct.c))
Base.size(Construct::AbstractConstruct) = (1,length(Construct.c))
Base.isequal(c1::AbstractConstruct,c2::AbstractConstruct) = isequal(c1.c,c2.c)


function Base.iterate(Construct::AbstractConstruct,state=1)
    if  state <= length(Construct)
        mod = Construct[state]
        state += 1
        return (mod,state)
    else
        return
    end
end


struct Ordered_Construct{T}  <: AbstractConstruct{T}
    c::Array{T}
end


*(m1::Mod,m2::Mod) = Ordered_Construct([m1,m2])
*(c::Ordered_Construct ,m::Mod) = push!(c.c,m) |> Ordered_Construct
*(m::Mod,  c::Ordered_Construct) = pushfirst!(c.c,m) |> Ordered_Construct
*(c1::Ordered_Construct ,c2::Ordered_Construct) = vcat(c1.c,c2.c)


struct Unordered_Construct{T} <: AbstractConstruct{T}
    c::Array{T}
end


+(m1::Mod,m2::Mod) = Unordered_Construct([m1,m2])
+(c::Unordered_Construct ,m::Mod) = push!(c.c,m) |> Unordered_Construct
+(m::Mod, c::Unordered_Construct) = pushfirst!(c.c,m) |> Unordered_Construct
+(c1::Unordered_Construct,c2::Unordered_Construct) = vcat(c1,c2)
