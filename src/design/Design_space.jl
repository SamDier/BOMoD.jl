#FIXME: `Design_Space` etc => `Design Space`

####
# Moste complex code , can probebly be improved
####

abstract type AbstractDesign{T} end


""""
    Single_Design{T} <: AbstractDesign{T}

A Single design is a structure that contains one special define type of construct.
They can be combined to form more complex design space.
"""
abstract type Single_Design{T} <: AbstractDesign{T} end


"""
    Ordered_Design

Ordered space is where the possition in the construct has a functional role, the
construct [a,b,c] is different compeared to [c,b,a].
In the General case every module can be used infinite number of times.

Fields:
    - `mod::AbstractMod`: The used modules in this design
    - `len::Int` : The allowed length of the construct
    - `con::AbstractConstrains`: The constraints of the design space
    - `space::AbstractSpace`: Design space containing all constructs, if
                    possible, these constructs are not explicitly generated.
"""
struct Ordered_Design{Tm <: AbstractMod, Tcon <: AbstractConstrains,Tspace <: AbstractSpace{T} where T} <: Single_Design{Tspace}
    mod::Tm
    len::Int
    con::Tcon
    space:: Tspace
end

"""
    make_ordered_space(mod::Group_Mod, len::Int)

The function generates all ordered constructs with given length and modules. The
modules can be infinity redrawn. The constructs are not explicitly generated.
With the use of the Kronecker product, every construct can be made on the fly
only on the moment when it is required.
"""
make_ordered_space(mod::Group_Mod, len::Int) = reshape(mod.m, length(mod.m),1) |>
                            (y -> len > 1 ? ⊗(y,len) : mod )


"""
    Unordered_Design

Unordered space is where the position in the construct has a non-functional role,
the construct `[a,b,c]`` is seen as equal to [c,b,a], so only one of both will be
generated.

Al modules can only be used once.

Fields:
    - `mod::AbstractMod`: The used moduels in this design
    - `len::Int`: The allowed length of the constructs
    - `con::AbstractConstrains`: The constraints of the design space
    - `space::AbstractSpace`: Design space containing all constructs, if possible, these constructs are not explicitly generated.
"""
struct Unordered_Design{Tm <: AbstractMod,Tcon <: AbstractConstrains,Tspace <: AbstractSpace{T} where T} <: Single_Design{Tspace}
    mod::Tm
    len::Int
    con::Tcon
    space:: Tspace
end

"""
    make_unordered_space(mod::Group_Mod,len::Int)

The function generates all unordered constructs with given length and modules.
Every module can only be used one single time in a construct.
The constructs aren't explicitly generated.
With the use of the ``Combination`` structure, every construct can be made on
the fly only on the moment it is required.
"""
make_unordered_space(mod::Group_Mod, len::Int) =  len > 1 ? Combination(mod.m,len) : mod



"""
    construct_design(mod::Group_Mod, len::Int; con::No_Constrain = No_Constrain(nothing) , order::Bool = false)

Returns a correct filled `Unordered_Design` with given input modules and desired length.
If `order = true`, then an `Ordered_Design` is returned using the same input settings
See [`Unordered_Design`](@ref) or [`Ordered_Design`](@ref)
"""
function construct_design(mod::Group_Mod, len::Int; order::Bool = false)
    if order == true
        make_ordered_space(mod,len) |> Full_Ordered_space |> (y -> Ordered_Design(mod,len,No_Constrain(nothing),y))
    else
        make_unordered_space(mod,len) |> Full_Unordered_space |> (y -> Unordered_Design(mod,len,No_Constrain(nothing),y))
    end
end

#FIXME: this function is too long for a one-liner
# precomuted full space all other field are ignored, currently not used , manby usefull in the future.
construct_design(Tspace::Computed_Space ; mod = Group_Mod(nothing), len = Len_Constrain(nothing), con = No_Constrain(nothing), order= false) =  order == true ?  Ordered_Design(mod,len,con,Tspace) : Unordered_Design(mod,len,con,Tspace)

"""
    construct_design(mod::Group_Mod, len::Int, con::Construct_Constrains; order = false)

Returns a correct filled `Unordered_Design` with given input modules and desired
length. The constraints are attributed and evaluated if they are useful for the
given constructed type.

Ordered constraints are only helpful if  `order = true`, then an `Ordered_Design`
is returned.

See [`Unordered_Design`](@ref) or [`Ordered_Design`](@ref)
"""
function construct_design(mod::Group_Mod, len::Int, con::Construct_Constrains{T} where T; order = false)
    if order == true
        make_ordered_space(mod,len) |> x -> Frame_Space(Full_Ordered_space(x),con) |> (y -> Ordered_Design(mod,len,con,y))
    else
        if isa(con,UnOrdered_Constrain) || promote_type(eltype(con),UnOrdered_Constrain) == UnOrdered_Constrain
            return make_unordered_space(mod,len) |> x -> Frame_Space(Full_Unordered_space(x),con) |> (y -> Unordered_Design(mod,len,con,y))
        else
            error("Ordered contrains can't be used in unorderd design set order to true or remove constrains")
        end
    end
end



"""
    getspace(Design::Single_Design; full = false)


If the input design has no constrains, then an efficient space is generated This space type allow most `Base` function that you would have on the explicit generated design space.
If constraints are added than no efficient space can be generated. For most functionalities explicitly, generation is needed. In some case one can continue using the whole design structure.
If `full = true` the whole space is generated explicitly, which isn't recommended for large designs. Still for constrained problems is sometimes the best or only option.
"""

function getspace(Design::Single_Design; full = false)
          if full== false
              if  isa(Design.space, Frame_Space)
                  @warn "given space is the closed effienct space that can be made, not all constrains are used"
              end
              return Design.space
          else
            return  created_space(Design.space,Design.con)
        end
end

### Create space can be removed in the future because Base.iterate{Frame_space} has same functionalities.
#was implented before and it works so kept for now.


"""
    created_space(space::Eff_Space)

Generated explicated all constructed for a space that can be handled efficiently
"""
function created_space(space::Eff_Space,::AbstractConstrains)
    new_space = [construct for construct in space]
    return Computed_Space(new_space)
end

"""
    created_space(space::Frame_space,con::Construct_costrains)

It generated the space that has one or multiple constraints.
The constructed that aren't allowed base on given constraints are filtered out.
"""
function created_space(space::Frame_Space,con::Construct_Constrains)
    new_space = eltype(space)[]
    for temp_construct in space.space
        #print(temp_construct)
            if filter_constrain(temp_construct,con) == false
                 push!(new_space,temp_construct)
            end
   end
    return Computed_Space(new_space)
end



"""
    created_space(space::Comuputed_space)

fall back if space was computed before.
"""
created_space(space::Computed_Space,::AbstractConstrains) = space.space



"""
    constrain_check(len_construct::Int,constrain)

quick check if the constrain make sense given the length of the constructs.
"""
constrain_check(len_construct::Int,constrain) = (len_construct >= length(constrain.combination)) && (len_construct >= maximum(constrain.pos))



""""
    filter_constrain(construct::Ordered_Construct, con::Ordered_Constrain)

Evaluated if the `construct` is allowed given  `con`.  Returns `true` when the construct isn't allowed.
Because the constrain is ordered, the given modules are only tested on the given position. Only with an exact match, it returns true,if no match is found it returns `false`.
"""
function filter_constrain(construct::Ordered_Construct, con::Ordered_Constrain)
    # check if constrains makes sence to given construct
    if constrain_check(length(construct),con) == false
        @warn "skiped constrain that didn't make sence"
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
    filter_constrain(construct::AbstractConstruct, con::UnOrdered_Constrain)

Evaluated if the `construct` is allowed given  `con`.  Returns `true` when the construct isn't allowed.  If no match is found it returns `false`
Because the constrain is unordered only all modules in the constrain need to be present in construct.
The position is not evaluated.
"""

filter_constrain(construct::AbstractConstruct, con::UnOrdered_Constrain) = (Set(construct.c) ∩ Set(con.combination)) |> length |> (y -> y == length(con.combination))

""""
    filter_constrain(construct::AbstractConstruct, con::Compose_Construct_Constrains)

A wrapper to evaluated multiple constraints regarding the same constructs.
The function terminates if one of the constrain matches to the given constructs and returns `true`.
"""

function filter_constrain(construct::AbstractConstruct, con::Compose_Construct_Constrains)
    for temp_con in con.construct_con
        if filter_constrain(construct,temp_con)
            return true
        end
    end
    return false
end




"""
    Multi_Design{Tm <: Single_Design{T} where T} <: AbstractDesign{T}

Designs that are constructed out of different `Single_Design`.
The underlining Designs are stored  in a Vector.
Currently only used to allow multiple lengths of constructs for the same design rules ( modules and constraints ).
"""

struct Multi_Design{T} <: AbstractDesign{T}
    d::Vector{T}
end

"""
addition of differnt designs
"""
Base.eltype(::Multi_Design{T}) where T = T
Base.length(design::Multi_Design) = length(design.d)
Base.iterate(design::Multi_Design,state = 1) = length(design.d) >= state ? (design[state],state+1) : nothing
Base.getindex(design::Multi_Design,i) = design.d[i]
Base.size(design::Multi_Design) = (length(design), map((i -> length(i.space,nothing)),design) |> sum )



"""
    construct_design(mod::Group_Mod, min::Int, max::Int; order = false)

Returns Mulit_Design contianing the design space for ever length between `min` and `max`.
If `order = true`, then an `Ordered_Design` is constructed.
"""

construct_design(mod::Group_Mod, min::Int, max::Int; order = false) = Multi_Design([construct_design(mod,len,order = order) for len in min:max])



"""
    construct_design(mod::Group_Mod, min::Int, max::Int; order = false)

Returns Mulit_Design contianing the design space for ever length in the `lens` array.
If `order = true`, then an `Ordered_Design` is constructed.
"""

construct_design(mod::Group_Mod, lens::Array{Int}; order = false) = Multi_Design([construct_design(mod,len,order = order) for len in lens])

"""
    construct_design(mod::Group_Mod, min::Int, max::Int; order = false)

Returns Mulit_Design contianing the design space for ever length in the `lens` array.
If `order = true`, then an `Ordered_Design` is constructed.
"""

construct_design(mod::Group_Mod, lens::Array{Int}, con::Construct_Constrains{T} where T; order = false) = Multi_Design([construct_design(mod,len,con,order = order) for len in lens])



"""
    getspace(multiple_design::Multi_Design; full = false )

Simple wrapper to obtain all different space in the Multi_Design object using `getspace(Design::Single_Design; full = false)` iteratively.
type determined on the space of the first design
"""

function getspace(design::Multi_Design; full = false )

    if full
        all_spaces = collect(design[1].space)
        for i in 2:length(design)
            append!(all_spaces,collect(design[i].space))
        end

        return Computed_Space(all_spaces)

    else
        all_spaces = AbstractSpace[]
        for d in design
             push!(all_spaces,getspace(d))
        end
        return Multi_Space(all_spaces)
    end

end


# Combining of combinations if not all intermediate-length are desired.

Base.:+(des1::T,des2::T) where T = Multi_Design([des1,des2])
Base.:+(des1::Multi_Design{T} where T, des2::Single_Design) = Multi_Design([des1.design...,des2])
Base.:+(des1::Single_Design,des2::Multi_Design) = +(des2,des1)
Base.:+(des1::Multi_Design{T} where T, des2::Multi_Design{N} where N) = Multi_Design([des1.design...,des2.design...])
