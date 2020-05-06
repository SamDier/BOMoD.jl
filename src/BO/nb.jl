

"""
d_neibourhood(construct::Ordered_Construct,mod::Group_Mod)
generates all constructs
"""
function neibourhood_1(construct::UnorderedConstruct,mod::Group_Mod)
    d_n = Vector{Ordered_Construct}(undef,length(mod))
    for i in 1:length(construct)
        if i > 1
            d_n[i] = construct[1:i-1].*mod.m.*construct[i+1:end]
        else
            d_n[i] = mod.m*construct[i+1:end]
        end
    end
    return d_n
end



function nd(construct::UnorderedConstruct,mod::GroupMod,n)
    new_mod = filter(x -> !(x in construct) , mod.m)
    @assert n < (length(construct)*length(new_mod)) "neighoorhood is to small to generated $n samples"
    d_n = Array{UnorderedConstruct}(undef,length(construct),length(new_mod))
    for i in 1:length(construct)
        for j in 1:length(new_mod)
            if i > 1
                d_n[i,j] = construct[1:i-1] + new_mod[j]  + construct[i+1:end]
            else
                d_n[i,j] = new_mod[j] + construct[2:end]
            end
        end
    end
    return rand(d_n,n)
end




    start = Dict(m.m => (length(new_mod),[]) for m in construct)
    neiberhood = Array{T}[undef,n]
    for i in 1:n
        rand(keys(start))
         new = sample(new_mod)
         #Neiberhood.jl
         """
         d_neibourhood(construct::Ordered_Construct,mod::Group_Mod)
         generates all constructs
         """
         function d_neibourhood(construct::Ordered_Construct,mod::Group_Mod)
             d_n = Vector{Ordered_Construct}{undef,size_d_n(length(mod),length(construct),d)}
             for i in length(construct)


         function d_neibourhood(construct::Unordered_Construct,mod::Group_Mod)

         size_d_n(n_mod,l_con,d) = l_con*d^(n_mod-1)

         """
         d_neibourhood(construct::Ordered_Construct,mod::Group_Mod)
         generates all constructs
         """
         function neibourhood_1(construct::Ordered_Construct,mod::Group_Mod)
             d_n = Vector{Ordered_Construct}(undef,length(mod))
             for i in 1:length(construct)
                 if i > 1
                     d_n[i] = construct[1:i-1].*mod.m.*construct[i+1:end]
                 else
                     d_n[i] = mod.m*construct[i+1:end]
                 end
             end
             return d_n
         end
