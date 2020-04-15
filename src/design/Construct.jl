abstract type AbstractConstruct{T}

#Base.IndexStyle(::Type{<AbstractConstruct}) = IndexCartesian()
Base.eltype(::AbstractConstruct{T}) where T = eltype(T)
Base.getindex(Construct::AbstractConstruct,i,j) = Construct.c[i,j]
Base.length(Construct::AbstractConstruct) = length(Construct.c)
Base.size(Construct::AbstractConstruct) = (1,length(Construct.c))
Base.isequal(c1::AbstractConstruct,c2::AbstractConstruct) = c1.c == c2.c


struct Ordered_Construct{T}  <: AbstractConstruct{T}
    c::Array{T}
end


# make costruct form moduels
#*(m1::Moduels{<:T} where T,m2::Moduels{<:T} where T) = [m1 , m2]
#*(m1::AbstractArray{N} where N <: Moduels{<:T} where T,m2::Moduels{<:T} where T) = [m1... , m2]
#*(m2::Moduels{<:T} where T  ,m1::AbstractArray{N} where N <: Moduels{<:T} where T) = [m1... , m2]

# Moduels * Moduels
*(m1::Mod,m2::Mod) = Ordered_Construct([m1 m2])

# Moduels * multi_construct
*(m1::Ordered_Construct ,m2::Mod) = Ordered_Construct([m1.c...  m2])
*(m2::Mod,  m1::Ordered_Construct) = Ordered_Construct([m1.c...  m2])

#Base.eltype(::Ordered_Construct{T}) where T = T
#Base.getindex(Construct::Ordered_Construct,i) = Construct.c[i]
#Base.length(Construct::AbstractConstruct) = length(Construct.c)


function Base.iterate(Construct::Ordered_Construct,state=1)
    if  state <= length(Construct)
        mod = Construct[state]
        state += 1
        return (mod,state)
    else
        return
    end
end




struct Unordered_Construct{T} <: AbstractConstruct{T}
    c::Array{T}
end

+(m1::Mod,m2::Mod) = Unordered_Construct([m1 m2])
+(m1::Unordered_Construct ,m2::Mod) = Unordered_Construct([m1.c... m2])
+(m2::Mod,  m1::Unordered_Construct) = Unordered_Construct([m1.c... m2])
