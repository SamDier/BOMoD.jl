abstract type AbstractConstruct{T} end
import Base: *
struct Construct{Tcon <: AbstractArray{T} where T <: Mod} <:AbstractConstruct{T}
    con::Tcon
end

# make costruct form moduels
*(m1::Moduels{<:T} where T,m2::Moduels{<:T} where T) = [m1 , m2]





*(m1::Constuct{T},m2::Moduels{T} where T <:Number) = Constuct(push!(m1.con


*(m1::Moduels{T} where T <:Number,m2::Moduels{T} where T <:Number)
