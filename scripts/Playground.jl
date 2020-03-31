using BOMoD
using Random
#include("Combinatroics.jl")

# construct moduels

mt_Symbol = Mod(:sym4)
mt_a = Mod("a")
mt_b = Mod("b")
mt_c = Mod("c")
mt_d = Mod("d")

Group_Mod([Mod("a"),Mod("b"),Mod("c"),Mod("d")])

mt_Symbol_array = group_mod([:sym, :sym1, :sym3])
mt_String_array = group_mod(["a", "b", "c", "d","e"])

# set constrains
#single constrains
pos_con = Possition_Constrain(1,[Mod("a")])
Unordered_con_c_e = UnOrdered_Constrain([Mod("c") , Mod("e")])
Ordered_con_a_b = Ordered_Constrain([1 3],[Mod("a") Mod("b")])
Ordered_con_c_b = Ordered_Constrain([2 3],[Mod("c") Mod("b")])
#combine different constrains
Compose_Ordered =   Ordered_con_c_b +  Ordered_con_a_b
Compose_Constuct =   Ordered_con_c_b +  Ordered_con_a_b + Unordered_con_c_e
Compose_Construct_backup = Compose_Ordered + Unordered_con_c_e
Compose_multi = pos_con + Ordered_con_c_b + Ordered_con_a_b + Unordered_con_c_e
Compose_multi_backup = pos_con + Compose_Constuct
#easy combine
Compose_Constuct_easy = sum([Unordered_con_c_e, Ordered_con_a_b, Ordered_con_c_b ])
Compose_multi_easy = sum([Unordered_con_c_e, Ordered_con_a_b, Ordered_con_c_b, pos_con])




#test_design construction
#1 lenght no constrain
first_design =construct_ordered_design(mt_String_array,3)

#2 multiple length no constrain
construct_ordered_design(mt_String_array,2,4)
# test iteror over space
for i in first_design.space
    @show i
end
#take a constronct
aconstruct = first_design.space.space[2]
aconstruct2=Ordered_Construct([Mod("a") Mod("c") Mod("b")])
aconstrain = Ordered_Constrain([1 3],[Mod("a") Mod("b")])
#3 one lenght and construct contrain
construct_ordered_design(mt_String_array,3,Compose_Constuct)
construct_ordered_design(mt_String_array,2,3,Compose_Constuct)


rng = MersenneTwister()
sp = Random.Sampler(rng, 1:20)
