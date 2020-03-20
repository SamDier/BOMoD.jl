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

struct Mulit_len_Design{Tm <: Single_Design{T} where T} <: Multi_Design{Tm}
    design::AbstractArray{Tm}
end

"""
addition of differnt designs
"""

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
struct Ordered_Design{Tm <: AbstractMod,Tcon <: AbstractConstrains,Tspace <: AbstractSpaceType{T} where T} <: Single_Design{Tspace}
    mod::Tm
    len::Int
    con::Tcon
    space:: Tspace
end
"""
genaral space generator
"""
make_space(mod::Group_Mod,len::Int) =  reshape(mod.m,length(mod.m),1) |> (y -> len > 1 ? ⊗(y,len) : mod )



"""
construct_order_design. Makes an ordered spaces based on the given input
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
construct_ordered_design(mod::Group_Mod, min::Int, max::Int,con::Element_Constrains) = Mulit_len_Design([construct_ordered_design(mod,len,con) for len in min:max])

# constuct space white one lenght and given group of constrains
construct_ordered_design(mod::Group_Mod, con ::Len_Constrain) = construct_ordered_design(mod,con.len,con.el_con)

# constuct space white one lenght and given group of constrains but different input
construct_ordered_design(mod::Group_Mod, len::Int,con::Multipe_constrain ) = construct_ordered_design(mod,len,con.space_con) |> filter_design(space,con)

# if only space constrains are used , still under construction
construct_ordered_design(mod::Group_Mod, len::Int, con::Space_Constrains) = 5

# if only construct constrains are used evaluated the every construct to given constrains. not effiecent for large data set.
construct_ordered_design(mod::Group_Mod, len::Int, con::Construct_Constrains) = construct_ordered_design(mod,len) |> (y -> filter_design(y,con,full_space = true))

# filters a given design for the input constrains , used for construct constrains
function filter_design(input_design::Ordered_Design,con::Construct_Constrains ; full_space=false)
    #new_con = input_design.con + con
    new_con = con
    if full_space
        @warn "Full space will be explisited calculate for full construction,with isn't efficent in many cases"
         filtered_space = created_space(input_design.space,con)
         return Ordered_Design(input_design.mod , input_design.len , new_con ,filtered_space)
    else
        return Ordered_Design(input_design.mod ,input_design.len, new_con, Frame_Space(input_design.space.space))
    end
end

# filter for space constrains , not yet finished
function filter_design(input_design::Ordered_Design, con::Space_Constrains ; full_space = false)
    @warn "under construction, not ready to used."
end


# To genenerated t

"""
makes all constructions and filters the not allowed constrains
"""
function created_space(space::AbstractSpaceType,con::Construct_Constrains)
    new_space = Ordered_Construct[]
    for temp_construct in space
        #print(temp_construct)
            if filter_constrain(temp_construct,con) == false
                 push!(new_space,temp_construct)
            end
   end
    return Computed_Space(new_space)
end

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
             if construct[pos] == element
                 return false
            end
        end
    end
    return true
end

filter_constrain(construct::Ordered_Construct, con::UnOrdered_Constrain) = (construct.c ∩ con.combination) |> length |> (y -> y == 0)

function filter_constrain(construct::Ordered_Construct, con::Compose_Construct_Constrains)
    for temp_con in con.construct_con
        if filter_constrain(construct,temp_con)
            return true
        end
    end
    return false
end

constrain_check(len_construct,constrain) = (len_construct >= length(constrain.combination)) && (len_construct >= maximum(constrain.pos))



Base.eltype(::Eff_Space) = Ordered_Construct{T} where T

function Base.iterate(space::Eff_Space, state = 1 )
    if  state <= length(space)
        construct = space.space[state]
        state += 1
        return (construct,state)
    else
        return
    end
end


Base.iterate(Design::Ordered_Design, state...) =  Base.iterate(Design.space)


Base.length(space::Eff_Space) = length(space.space)
Base.length(space::Frame_Space) = lenght(space.space) |> (y -> @warn " $y is the maximual length (no constrains) , no effienct length calculation, generated construct for full length")
Base.length(Design::Ordered_Design) = length(Design.space)
