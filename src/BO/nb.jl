"""
    nd(construct::Ordered_Construct,mod::Group_Mod,n::Int)

Retruns n random sample from neighourhood of the given construct.
The neighourhood is obtain by replacing
one module of the construct with an other module of the alphabet `mod`.
This procedure is repeat or every possition and the alphabet `mod`.
Afterwards random sample of the neighourhood is pickt

"""
function nd(construct::OrderedConstruct,mod::GroupMod,n::Int)
    @assert n < (length(construct)*length(mod)) "neighoorhood is to small to generated $n samples"
    d_n = Array{OrderedConstruct}(undef,length(construct),length(mod)-1)
    for i in 1:length(construct)
        # avoid make the same construct
        temp_mod = filter(x -> (x != mod[1]) , mod.m)
        for j in 1:length(mod)-1
            if i > 1
                d_n[i,j] = construct[1:i-1] *  temp_mod[j]  * construct[i+1:end]
            else
                d_n[i,j] = temp_mod[j] * construct[2:end]
            end
        end
    end
    return rand(d_n,n)
end

"""
    nd(construct::UnorderedConstruct,mod::Group_Mod,n::Int)

Retruns n random sample from neighourhood of the given construct.
The neighourhood is obtain by replacing
one module of the construct with an other module of the alphabet `mod`.
This procedure is repeat or every possition and the alphabet `mod`.
Afterwards random sample of the neighourhood is pickt

"""
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
