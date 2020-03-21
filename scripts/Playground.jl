
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
construct_ordered_design(mt_String_array,2,3,Compose_Constuct)
aconstruct[aconstrain.pos]
con.combination

filter_constrain(aconstruct2, aconstrain)
construct[con.pos] == con.combination
Ref([Ordered_con_a_b ,Ordered_con_a_b])[][1]

test_kronker = split(mt_String_array)
# test Kronecker
kron_test  = test_kronker ⊗ test_kronker


Full_Ordered_space(kron_test)


product([true false false])




#construct design space
mt_string_d = Mod("d")
mt_String_array = group_mod(["a", "b", "c"]);
push!(mt_String_array,mt_string_d)
Mod(["a"]) *  Mod(["B"])
mt_string_d * mt_string_d
# test split
test_kronker = split(mt_String_array)
# test Kronecker
kron_test  = test_kronker ⊗ test_kronker
kron_test_2  = test_kronker ⊗ test_kronker ⊗ test_kronker ⊗ test_kronker
kron_test_3 =  ⊗(test_kronker,3)
#test length
length(mt_Symbol_array)


# construct lenght constrain
# length between 2 and 4 are allowed
Len_2_4 = Len_Constrain(2,4);

# number of length taht are allowed can be found with length function
length(Len_2_4)

# iterate over every possible allowed length
[i for i in Len_2_4]

# length of only 3 is allowed
Len_3 = Len_Constrain(3);
[i for i in Len_3]

# make unorded design space with legth 3
unord_space_3 = unorded_spaces(mt_String_array,3)
unord_space_len_3= unorded_spaces(mt_String_array,Len_3)
# calculate length , number of construct that can be made
length(unord_space_3)
# calculate length , number of construct that can be made
length(unord_space_len_3)
# make unorded design space with length 2 3 and 4
unord_space_Len_2_4 = unorded_spaces(mt_String_array,Len_2_4)
unord_space_Len_2_4 = unorded_spaces(mt_String_array,2,4)
# calculate length , number of construct that can be made  (6 for length 2 , 4 lenght 3 and 1 length 4)
length(unord_space_Len_2_4)

# make orded design space with legth 3
ord_space_3 = ordered_spaces(mt_String_array,3)
ord_space_len_3= ordered_spaces(mt_String_array,Len_3)
# calculate length , number of construct that can be made
length(ord_space_3
)
# make norded design space with length 2 3 and 4
ord_space_Len_2_4 = ordered_spaces(mt_String_array,Len_2_4)
# calculate length , number of construct that can be made  (6 for length 2 , 4 lenght 3 and 1 length 4)
length(ord_space_Len_2_4)
# test length
let
        len = 0
    for i in ord_space_Len_2_4.space
        len += length(i)
    end
    println(length(ord_space_Len_2_4) == len)
end
# test eltype

#test itrator or orderd space
ord_space_Len_2_3 = ordered_spaces(mt_String_array,2,3)
ord_space_Len_2_3

for i in ord_space_Len_2_3
    @show(i)
end

#test getindgex
# Combinatorics.jl
real_comb = combinations(["1","2","3","4","5"],3)
real_length = length(real_comb)
#my implementaiton
mymod = Moduels(["1","2","3","4","5"]) |> split
my_comb = MyComb(mymod,3)
length(my_comb)
for i in real_comb
    show(i)
end

for i in my_comb
    show(i)
end

# test constrains

A = Possition_Constrain(2,["a","b"])
B = Possition_Constrain(3,["D","b"])
C = Possition_Constrain(4,["R","b"])
D = UnOrdered_Constrain(["A","B"])
E = UnOrdered_Constrain(["D","V"])
F = Ordered_Constrain([2,3],["A","B"])
G = Ordered_Constrain([2,3,4],["A","B","C"])

A + B
H = A + B
I = E + F + G
Q = D + I


P = Q + C

P + B
promote_type(typeof(Q),typeof(C))
J = F + G
K = A + B + C
L_1 = F + G
L2 = E + L_1
L = F + G


all = [A , B , C , D ,E , F, G]
A + B +
blabal = sum(all)
promote(G,F)
promote_type(typeof(K),typeof(E))
typeof(L_1)
[1 2 3]
x = (a = 1, b = 2.0, c = "hello world")
z = ( = blabal )
4 .^ [1 2 3]

("a", "b") + ("c","d")
