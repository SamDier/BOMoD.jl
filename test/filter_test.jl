using Test
@testset "filter_test" begin

#moduels
mt_a = Mod("a")
mt_b = Mod("b")
mt_c = Mod("c")
mt_d = Mod("d")
mt_e = Mod("e")
# a full design
Group_Mod_test = Group_Mod([mt_a,mt_b,mt_c,mt_d,mt_e])
first_design =construct_ordered_design(mt_String_array,3)
# some test constructs
oc1 = Ordered_Construct([mt_a ,mt_d,mt_b])
oc2 = Ordered_Construct([mt_a ,mt_b,mt_e])
oc3 = Ordered_Construct([mt_e,mt_d,mt_c])
oc4 = Ordered_Construct([mt_e,mt_a,mt_d])
# constrains
con1 = UnOrdered_Constrain([Mod("a") , Mod("b")])
con2 = Ordered_Constrain([1 3],[Mod("a") Mod("b")])
con3 = Ordered_Constrain([1 3],[Mod("e") Mod("c")])
con4 = con1 + con2 + con3

@testset "UnCon" begin
    @test filter_constrain(oc1,con1) == true
    @test filter_constrain(oc2,con1) == true
    @test filter_constrain(oc3,con1) == false
end

@testset "OrCon" begin
    @test filter_constrain(oc1,con2) == true
    @test filter_constrain(oc2,con2) == false
    @test filter_constrain(oc3,con2) == false
end

@testset "compose" begin
    @test filter_constrain(oc1,con4) == true
    @test filter_constrain(oc2,con4) == true
    @test filter_constrain(oc3,con4) == true
    @test filter_constrain(oc4,con4) == false
end
