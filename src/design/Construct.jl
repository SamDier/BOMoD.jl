#import Base: *,+,getindex

abstract type AbstractConstruct{T} end


struct Ordered_Construct{T}  <: AbstractConstruct{T}
    c::Array{T}
end

struct Unordered_Construct{T}  <: AbstractConstruct{T}
    c::Set{T}
end
# make costruct form moduels
#*(m1::Moduels{<:T} where T,m2::Moduels{<:T} where T) = [m1 , m2]
#*(m1::AbstractArray{N} where N <: Moduels{<:T} where T,m2::Moduels{<:T} where T) = [m1... , m2]
#*(m2::Moduels{<:T} where T  ,m1::AbstractArray{N} where N <: Moduels{<:T} where T) = [m1... , m2]

# Moduels * Moduels
*(m1::Mod,m2::Mod) = Ordered_Construct([m1  m2])

# Moduels * multi_construct
*(m1::Ordered_Construct ,m2::Mod) = Ordered_Construct([m1.c...  m2])
*(m2::Mod,  m1::Ordered_Construct) = Ordered_Construct([m1.c...  m2])
Base.eltype(::Ordered_Construct{T}) where T = T
Base.getindex(Construct::Ordered_Construct,i) = Construct.c[i]
Base.length(Construct::AbstractConstruct) = length(Construct.c)


function Base.iterate(Construct::Ordered_Construct,state=1)
    if  state <= length(Construct)
        mod = Construct[state]
        state += 1
        return (mod,state)
    else
        return
    end
end

Base.isequal(c1::AbstractConstruct,c2::AbstractConstruct) = c1.c == c2.c
