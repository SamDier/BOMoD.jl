

####
# Moste complex code , can probebly be improved
####

abstract type AbstractDesign{T} end


""""
    SingleDesign{T} <: AbstractDesign{T}

A Single design is a structure that contains one special define type of construct.
They can be combined to form more complex design space.
"""
abstract type SingleDesign{T} <: AbstractDesign{T} end


"""
    OrderedDesign

Ordered space is where the possition in the construct has a functional role, the
construct [a,b,c] is different compeared to [c,b,a].
In the General case every module can be used infinite number of times.

Fields:
    - `mod::AbstractMod`: The used modules in this design
    - `len::Int` : The allowed length of the construct
    - `con::AbstractConstraints`: The constraints of the design space
    - `space::AbstractSpace`: Design space containing all constructs, if
                    possible, these constructs are not explicitly generated.
"""
struct OrderedDesign{Tm <: AbstractMod, Tcon <: AbstractConstraints,Tspace <: AbstractSpace{T} where T} <: SingleDesign{Tspace}
    mod::Tm
    len::Int
    con::Tcon
    space:: Tspace
end

#FIXME  makeorderedspace ? make_ordered_space
"""
    makeorderedspace(mod::GroupMod, len::Int)

The function generates all ordered constructs with given length and modules. The
modules can be infinity redrawn. The constructs are not explicitly generated.
With the use of the Kronecker product, every construct can be made on the fly
only on the moment when it is required.
"""
makeorderedspace(mod::GroupMod, len::Int) = reshape(mod.m, length(mod.m),1) |> y -> ⊗(y,len)
makesinglespace(mod::GroupMod) = reshape(mod.m, length(mod.m),1) |> y -> ⊗(y,ones(Int64,length(mod.m),1))

"""
    UnorderedDesign

Unordered space is where the position in the construct has a non-functional role,
the construct `[a,b,c]`` is seen as equal to [c,b,a], so only one of both will be
generated.

Al modules can only be used once.

Fields:
    - `mod::AbstractMod`: The used moduels in this design
    - `len::Int`: The allowed length of the constructs
    - `con::AbstractConstraints`: The constraints of the design space
    - `space::AbstractSpace`: Design space containing all constructs, if possible, these constructs are not explicitly generated.
"""
struct UnorderedDesign{Tm <: AbstractMod,Tcon <: AbstractConstraints,Tspace <: AbstractSpace{T} where T} <: SingleDesign{Tspace}
    mod::Tm
    len::Int
    con::Tcon
    space:: Tspace
end

"""
    makeunorderedspace(mod::GroupMod,len::Int)

The function generates all unordered constructs with given length and modules.
Every module can only be used one single time in a construct.
The constructs aren't explicitly generated.
With the use of the ``Combination`` structure, every construct can be made on
the fly only on the moment it is required.
"""
makeunorderedspace(mod::GroupMod, len::Int) = Combination(mod.m,len)



"""
    constructdesign(mod::GroupMod, len::Int; con::NoConstraint = NoConstraint(nothing) , order::Bool = false)

Returns a correct filled `UnorderedDesign` with given input modules and desired length.
If `order = true`, then an `OrderedDesign` is returned using the same input settings
See [`UnorderedDesign`](@ref) or [`OrderedDesign`](@ref)
"""
function constructdesign(mod::GroupMod, len::Int; order::Bool = false)
    if order == true
        if len == 1
            makesinglespace(mod) |> FullOrderedspace |> (y -> OrderedDesign(mod,len,NoConstraint(nothing),y))
        else
            makeorderedspace(mod,len) |> FullOrderedspace |> (y -> OrderedDesign(mod,len,NoConstraint(nothing),y))
        end
    else
        makeunorderedspace(mod,len) |> FullUnorderedspace |> (y -> UnorderedDesign(mod,len,NoConstraint(nothing),y))
    end
end

#FIXME: this function is too long for a one-liner
# precomuted full space all other field are ignored, currently not used , manby usefull in the future.
function constructdesign(Tspace::ComputedSpace ; mod = GroupMod(nothing),
     len = LenConstraint(nothing), con = NoConstraint(nothing), order= false)
     if order == true
         return  OrderedDesign(mod,len,con,Tspace)
     else
         return UnorderedDesign(mod,len,con,Tspace)
     end
end

"""
    constructdesign(mod::GroupMod, len::Int, con::ConstructConstraints; order = false)

Returns a correct filled `UnorderedDesign` with given input modules and desired
length. The constraints are attributed and evaluated if they are useful for the
given constructed type.

Ordered constraints are only helpful if  `order = true`, then an `OrderedDesign`
is returned.

See [`UnorderedDesign`](@ref) or [`OrderedDesign`](@ref)
"""
function constructdesign(mod::GroupMod, len::Int, con::ConstructConstraints{T} where T; order = false)
    if order == true
        makeorderedspace(mod,len) |> x -> FrameSpace(FullOrderedspace(x),con) |> (y -> OrderedDesign(mod,len,con,y))
    else
        if isa(con,UnOrderedConstraint) || promotetype(eltype(con),UnOrderedConstraint) == UnOrderedConstraint
            return makeunorderedspace(mod,len) |> x -> FrameSpace(FullUnorderedspace(x),con) |> (y -> UnorderedDesign(mod,len,con,y))
        else
            error("Ordered contrains can't be used in unorderd design set order to true or remove Constraints")
        end
    end
end



"""
    getspace(Design::SingleDesign; full = false)


If the input design has no Constraints, then an efficient space is generated
This space type allow most `Base` function that you would have on the explicit generated design space.
If constraints are added than no efficient space can be generated.
For most functionalities explicitly, generation is needed.
In some case one can continue using the whole design structure.
If `full = true` the whole space is generated explicitly, which isn't recommended for large designs.
Still for constrained problems is sometimes the best or only option.
"""

function getspace(Design::SingleDesign; full = false)
          if full== false
              if  isa(Design.space, FrameSpace)
                  @info "given space is the closed effienct space that can be made, not all Constraints are used"
              end
              return Design.space
          else
            return  createdspace(Design.space,Design.con)
        end
end

### Create space can be removed in the future because Base.iterate{Framespace} has same functionalities.
#was implented before and it works so kept for now.


"""
    createdspace(space::EffSpace)

Generated explicated all constructed for a space that can be handled efficiently
"""
function createdspace(space::EffSpace,::AbstractConstraints)
    newspace = [construct for construct in space]
    return ComputedSpace(newspace)
end

"""
    createdspace(space::Framespace,con::Constructcostrains)

It generated the space that has one or multiple constraints.
The constructed that aren't allowed base on given constraints are filtered out.
"""
function createdspace(space::FrameSpace,con::ConstructConstraints)
    new_space = eltype(space)[]
    for temp_construct in space.space
        #print(tempconstruct)
            if filterconstraint(temp_construct,con) == false
                 push!(newspace,tempconstruct)
            end
   end
    return ComputedSpace(new_space)
end



"""
    createdspace(space::Comuputedspace)

fall back if space was computed before.
"""
createdspace(space::ComputedSpace,::AbstractConstraints) = space.space



"""
    constraintcheck(lenconstruct::Int,Constraint)

quick check if the Constraint make sense given the length of the constructs.
"""
constraintcheck(len_construct::Int,constraint) = (len_construct >= length(constraint.combination)) && (len_construct >= maximum(constraint.pos))



""""
    filterconstraint(construct::OrderedConstruct, con::OrderedConstraint)

Evaluated if the `construct` is allowed given  `con`.  Returns `true` when the construct isn't allowed.
Because the constraint is ordered, the given modules are only tested on the given position. Only with an exact match, it returns true,if no match is found it returns `false`.
"""
function filterconstraint(construct::OrderedConstruct, con::OrderedConstraint)
    # check if Constraints makes sence to given construct
    if constraintcheck(length(construct),con) == false
        @warn "skiped constraint that didn't make sence"
        return false
    else
         for (pos,element) in  zip(con.pos,con.combination)
             if construct[pos] != element
                 return false
            end
        end
    end
    return true
end

""""
    filterconstraint(construct::AbstractConstruct, con::UnOrderedConstraint)

Evaluated if the `construct` is allowed given  `con`.  Returns `true` when the construct isn't allowed.  If no match is found it returns `false`
Because the constraint is unordered only all modules in the constraint need to be present in construct.
The position is not evaluated.
"""

function filterconstraint(construct::AbstractConstruct, con::UnOrderedConstraint)
    con_count = count_elements(con.combination)
    construct_count =  count_elements(construct.c)
    for (key,n) in con_count
        if haskey(construct_count,key)
            if construct_count[key] < n
                return false
           end
       else
           return false
       end
   end
   return true
end

function count_elements(a::Array)
     n = Dict(key => 0 for key in a)
     for element in a
         n[element] +=1
    end
    return n
end

""""
    filterconstraint(construct::AbstractConstruct, con::ComposeConstructConstraints)

A wrapper to evaluated multiple constraints regarding the same constructs.
The function terminates if one of the constraint matches to the given constructs and returns `true`.
"""

function filterconstraint(construct::AbstractConstruct, con::ComposeConstructConstraints)
    for temp_con in con.constructcon
        if filterconstraint(construct,temp_con)
            return true
        end
    end
    return false
end




"""
    MultiDesign{Tm <: SingleDesign{T} where T} <: AbstractDesign{T}

Designs that are constructed out of different `SingleDesign`.
The underlining Designs are stored  in a Vector.
Currently only used to allow multiple lengths of constructs for the same design rules ( modules and constraints ).
"""

struct MultiDesign{T} <: AbstractDesign{T}
    d::Vector{T}
end

"""
addition of differnt designs
"""
Base.eltype(::MultiDesign{T}) where T = T
Base.length(design::MultiDesign) = length(design.d)
Base.iterate(design::MultiDesign,state = 1) = length(design.d) >= state ? (design[state],state+1) : nothing
Base.getindex(design::MultiDesign,i) = design.d[i]
Base.size(design::MultiDesign) = (length(design), map((i -> length(i.space,nothing)),design) |> sum )



"""
    constructdesign(mod::GroupMod, min::Int, max::Int; order = false)

Returns MulitDesign contianing the design space for ever length between `min` and `max`.
If `order = true`, then an `OrderedDesign` is constructed.
"""

constructdesign(mod::GroupMod, min::Int, max::Int; order = false) = MultiDesign([constructdesign(mod,len,order = order) for len in min:max])



"""
    constructdesign(mod::GroupMod, min::Int, max::Int; order = false)

Returns MulitDesign contianing the design space for ever length in the `lens` array.
If `order = true`, then an `OrderedDesign` is constructed.
"""

constructdesign(mod::GroupMod, lens::Array{Int}; order = false) = MultiDesign([constructdesign(mod,len,order = order) for len in lens])

"""
    constructdesign(mod::GroupMod, min::Int, max::Int; order = false)

Returns MulitDesign contianing the design space for ever length in the `lens` array.
If `order = true`, then an `OrderedDesign` is constructed.
"""

constructdesign(mod::GroupMod, lens::Array{Int}, con::ConstructConstraints{T} where T; order = false) = MultiDesign([constructdesign(mod,len,con,order = order) for len in lens])



"""
    getspace(multipledesign::MultiDesign; full = false )

Simple wrapper to obtain all different space in the MultiDesign object using `getspace(Design::SingleDesign; full = false)` iteratively.
type determined on the space of the first design
"""

function getspace(design::MultiDesign; full = false )

    if full
        all_spaces = collect(design[1].space)
        for i in 2:length(design)
            append!(all_spaces,collect(design[i].space))
        end

        return ComputedSpace(all_spaces)

    else
        all_spaces = AbstractSpace[]
        for d in design
             push!(all_spaces,getspace(d))
        end
        return MultiSpace(all_spaces)
    end

end


# Combining of combinations if not all intermediate-length are desired.

Base.:+(des1::SingleDesign,des2::SingleDesign) where T = MultiDesign([des1,des2])
Base.:+(des1::MultiDesign{T} where T, des2::SingleDesign) = MultiDesign([des1.d...,des2])
Base.:+(des1::SingleDesign,des2::MultiDesign) = +(des2,des1)
Base.:+(des1::MultiDesign{T} where T, des2::MultiDesign{N} where N) = MultiDesign([des1.d...,des2.d...])
