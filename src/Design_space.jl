
""""
differenct design types
"""

abstract type AbstractDesign{T} end


""""
Multi_Design combinens different independent designs
"""
abstract type Multi_Design{T}  <: AbstractDesign{T} end
""""
A single design
"""
abstract type Single_Design{T} <: AbstractDesign{T} end


"""
group multiple designs
"""

struct Multi_or_Design{Tm <: Single_Design{T} where T} <: Multi_Design{Tm}
    design::AbstractArray{Tm}
end

"""
addition of differnt designs
"""
Base.length(design::Multi_or_Design) = length(design.design)
Base.iterate(design::Multi_or_Design,state = 1) = length(design.design) >= state ? (design[state],state+1) : nothing
Base.getindex(design::Multi_or_Design,i) = design.design[i]
Base.eltype(::Multi_or_Design) = Single_Design{T} where T
Base.size(design::Multi_or_Design) = (length(design), map((i -> length(i.space,nothing)),design) |> sum )



Base.:+(des1::Single_Design,des2::Single_Design) = Multi_Design([des1,des2])
Base.:+(des1::Multi_Design{T} where T, des2::Single_Design) = Multi_Design([des1.design...,des2])
Base.:+(des1::Single_Design,des2::Multi_Design) = +(des2,des1)
Base.:+(des1::Multi_Design{T} where T, des2::Multi_Design{N} where N) = Multi_Design([des1.design...,des2.design...])



"""
ordered space is where the possition in the construct has a functional role, the construct [a,b,c] is different compeared to [c,b,a].
In the General case all every module can be used infinted times.
Arguments:
mod =  moduels of type Mod
len = length of the constructs, type Int
con = The constrainsn, of type  AbstractConstrains see Constrains for more infromation
space = design space
"""
struct Ordered_Design{Tm <: AbstractMod,Tcon <: AbstractConstrains,Tspace <: AbstractSpace{T} where T} <: Single_Design{Tspace}
    mod::Tm
    len::Int
    con::Tcon
    space:: Tspace
end
"""
Generates all permutions with infinity retake for given moduels and lenght
"""
make_space(mod::Group_Mod,len::Int) =  reshape(mod.m,length(mod.m),1) |> (y -> len > 1 ? ⊗(y,len) : mod )

"""
construct_ordered_design(mod,len)

construct design for single length and moduel group
"""
#Design space isn't constructed explisitly
#only one lenght
construct_ordered_design(mod::Group_Mod, len::Int ; con = No_Constrain(nothing)) = make_space(mod,len) |> Full_Ordered_space |> (y -> Ordered_Design(mod,len,con,y))

# case with no constrains only but for multiple lenghtes
construct_ordered_design(mod::Group_Mod, min::Int, max::Int) = Mulit_len_Design([construct_ordered_design(mod,len) for len in min:max])

# precomuted full space, modluels, length and constrains aren't obligatory anymore
construct_ordered_design(Tspace::Computed_Space ; mod = Group_Mod(nothing), len = Len_Constrain(nothing), con = No_Constrain(nothing)) =  Ordered_Design(mod,len,con,Tspace)

#Moste general case constuct space for differnt lenght with for every length specific constrains,
construct_ordered_design(mod::Group_Mod, con ::Group_Len_Constrain) = [construct_ordered_design(mod,icon) for icon in con]

#general case constuct space for different lenght but constrains are equal for every lenght space
construct_ordered_design(mod::Group_Mod, min::Int, max::Int,con::Element_Constrains) = Multi_or_Design([construct_ordered_design(mod,len,con) for len in min:max])

# constuct space white one lenght and given group of constrains
construct_ordered_design(mod::Group_Mod, con ::Len_Constrain) = construct_ordered_design(mod,con.len,con.el_con)

# if only construct constrains are used evaluated the every construct to given constrains. not effiecent for large data set.
construct_ordered_design(mod::Group_Mod, len::Int, con::Construct_Constrains) = make_space(mod,len) |> (y -> Ordered_Design(mod ,len, con, Frame_Space(y)))


#construction Site#
# constuct space white one lenght and given group of constrains but different input
#construct_ordered_design(mod::Group_Mod, len::Int,con::Multipe_constrain ) = construct_ordered_design(mod,len,con.space_con) |> filter_design(space,con)

# if only space constrains are used , still under construction
#construct_ordered_design(mod::Group_Mod, len::Int, con::Space_Constrains) =

# filter for space constrains , not yet finished, for extra feature
function filter_design(input_design::Ordered_Design, con::Space_Constrains ; full_space = false)
    @warn "under construction, not ready to used."
end
# end construction site#


"""
getspace(Design::Order_Design; kwarg)
function to get access to the spaces.
Expliced calculation of the space is possible but not recommended
"""

function getspace(multiple_design::Multi_or_Design; full = false )
        all_spaces = AbstractSpace[]
         for design in multiple_design
             push!(all_spaces,getspace(design, full = full))
        end
        return Multi_Space(all_spaces)
end
"""
getspace(Design::Order_Design; kwarg)
function to get access to the spaces.
Expliced calculation of the space is possible but not recommended
"""

function getspace(Design::Ordered_Design; full = false)
          if full== false
              if  isa(Design.space, Frame_Space)
                  @warn "given space is the closed effienct space that can be made, not all constrains are used"
              end
              return Design.space
          else
            return  created_space(Design.space,Design.con)
        end
end

"""
created_space(space::Frame_space,con::Construct_costrains)
Generated the space for unfilter space where Construct constrains where added
"""
function created_space(space::Frame_Space,con::Construct_Constrains)
    new_space = Ordered_Construct[]
    for temp_construct in space.space
        #print(temp_construct)
            if filter_constrain(temp_construct,con) == false
                 push!(new_space,temp_construct)
            end
   end
    return Computed_Space(new_space)
end


"""
created_space(space::Eff_Space)
Generated expliceted spaced for efficient calculated spaces
"""
function created_space(space::Eff_Space,::AbstractConstrains)
    new_space = [construct for construct in space]
    return Computed_Space(new_space)
end

"""
created_space(space::Comuputed_space)
fall back if space was computed before
"""
created_space(space::Computed_Space,::AbstractConstrains) = space.space


""""
fitler constrains, gives actions for every specific constrains type. Act on a single construct
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

filter_constrain(construct::Ordered_Construct, con::UnOrdered_Constrain) = (construct.c ∩ con.combination) |> length |> (y -> y == length(con.combination))

function filter_constrain(construct::Ordered_Construct, con::Compose_Construct_Constrains)
    for temp_con in con.construct_con
        if filter_constrain(construct,temp_con)
            return true
        end
    end
    return false
end

constrain_check(len_construct,constrain) = (len_construct >= length(constrain.combination)) && (len_construct >= maximum(constrain.pos))


Base.iterate(Design::Ordered_Design, state...) =  Base.iterate(Design.space)
Base.length(Design::Ordered_Design) = length(Design.space)

function sample_reject(rng::AbstractRNG,space,n::Int,con; with_index::Bool = true)
    sample_reject!(rng,Full_Ordered_space(space.space),n,con,Array{Int}(undef, 0, 1),  Array{Any}(undef, 0, 2))
end



function sample_reject!(rng::AbstractRNG,space::Frame_Space,n::Int,con,save_index::Array,check_constructs::Array ;
    with_index::Bool = true, replace::Bool=false, ordered::Bool=false)

            n_start = size(check_constructs)[1]
            #make new samples
            new_sample = sample(rng,space,n,with_index = true)
            #check if draw before
            new_sample = filter_sample!(new_sample,save_index)
            #updated check indexes
            save_index = [save_index;new_sample[:,2]]
            #check constrain
            new_sample = filter_sample!(new_sample,con)
            #updata approved constructs
            check_constructs = [check_constructs;new_sample]
            n_stop = size(check_constructs)[1]

            if  n_stop-n_start == n
                return (check_constructs)

            else
                delta = n - (n_stop - n_start)
                sample_reject!(space,delta,con,save_index,check_constructs)
            end
end


filter_sample!(new_sample,con::Construct_Constrains) = map(y -> !filter_constrain(y,con),new_sample[:,1]) |> (y -> new_sample[y,:])
filter_sample!(new_sample,saved_index::Array) = map((y -> y ∉ saved_index),new_sample[:,2]) |> (y -> new_sample[y,:])
