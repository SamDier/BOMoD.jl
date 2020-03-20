import Base: *,+,getindex

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
*(m1::Mod{<:T} where T,m2::Mod{<:T} where T) = Ordered_Construct([m1  m2])

# Moduels * multi_construct
*(m1::Ordered_Construct{N} where N <: AbstractArray{<:T} where T ,m2::Mod{<:T} where T) = Ordered_Construct([m1.c...  m2])
*(m2::Mod{<:T} where T ,  m1::Ordered_Construct{N} where N <: AbstractArray{<:T} where T) = Ordered_Construct([m1.c...  m2])

Base.getindex(Construct::Ordered_Construct,i) = Construct.c[i]
Base.length(Construct::AbstractConstruct) = length(Construct.c)
