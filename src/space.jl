
abstract type AbstractSpaceType{T} end


"""
Frame to generated  random Construct form the design space. Constrains are taken into account. This are indexalbe object to obtain repoduceble resultes every run.
The full design space isn't constucted explisitly. No effiencent way is used to do this so form most functialitys a Comuted space object is generated and used.
"""
struct Frame_Space{T} <: AbstractSpaceType{T}
    space::T
end

"""
Frame to generated effienct random Construct form the design space. If possible the given constrains are taken into account.
This are indexalbe object to obtain repoduceble resultes every run.
The full design space isn't constucted explisitly. The Eff frame space suggest that a effient way is used to allow constrains in the space
"""

abstract type Eff_Space{T}  <: AbstractSpaceType{T} end

"""
Struct for ordered space without contrains to allow
"""
struct Full_Ordered_space{T}<: Eff_Space{T}
    space::T
end

"""
If the full design space is generated, Construct saved in AbstractArray
"""
struct Computed_Space{T} <: Eff_Space{T}
    space::T
end
