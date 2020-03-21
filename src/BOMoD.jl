module BOMoD

export Mod, Group_Mod , group_mod
export construct_ordered_design
export No_Constrain, Ordered_Constrain, UnOrdered_Constrain, Possition_Constrain
export Ordered_Construct, Unordered_Construct
export Frame_Space,Computed_Space,Full_Ordered_space
export func


using Kronecker
import Base: +, *, getindex,length, eltype

include("Mod.jl")
include("Constrains.jl")
include("space.jl")
include("Construct.jl")
include("Design_space.jl")

end # module
