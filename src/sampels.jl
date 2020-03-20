using Combi

function makedesingspace(allbloks)
    myiterobjects = []
    # length = 1
    push!(myiterobjects,[[i] for i in [allbloks...]])
    #length = 2
    for comb in with_replacement_combinations([allbloks...],2)
        if comb[1] == comb[2]
            push!(myiterobjects,[comb])
        else
            push!(myiterobjects,permutations(comb))
        end
    end
    #lenth = 3
    for comb in with_replacement_combinations([allbloks...],3)
        if comb[1] == comb[2] == comb[3]
            push!(myiterobjects,[comb])
        elseif comb[1] == comb[2]
            push!(myiterobjects,Perwithrepalce(reverse(comb,1,3)))
        elseif comb[1] == comb[3]
            push!(myiterobjects,Perwithrepalce(reverse(comb,1,2)))
        elseif  comb[2] == comb[3]
            push!(myiterobjects,Perwithrepalce(comb))
        else
        push!(myiterobjects,permutations(comb))
        end
    end
    return myiterobjects
end

test =combinations(["a,b,c,d"],2)
