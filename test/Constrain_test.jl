@testset "Constrains" begin



Unordered_con_c_e = UnOrdered_Constrain([Mod("c") , Mod("e")])
Ordered_con_a_b = Ordered_Constrain([1 3],[Mod("a") Mod("b")])
Ordered_con_c_b = Ordered_Constrain([2 3],[Mod("c") Mod("b")])



@testset "single addition" begin
   @test isa(Unordered_con_c_e,UnOrdered_Constrain) == true
   @test isa(Ordered_con_a_b,Ordered_Constrain) == true
   @test isa(Ordered_con_c_b +  Ordered_con_a_b,Compose_Construct_Constrains) == true
   @test (Ordered_con_c_b +  Ordered_con_a_b).construct_con == [Ordered_con_c_b;Ordered_con_a_b]
   @test (Unordered_con_c_e +  Ordered_con_a_b).construct_con == [Unordered_con_c_e;Ordered_con_a_b]
end

@testset "mulitple_additions" begin
   @test  Set((Ordered_con_c_b +  Ordered_con_a_b + Unordered_con_c_e).construct_con) == Set([Ordered_con_c_b;Ordered_con_a_b;Unordered_con_c_e])
   @test  isa(sum([Ordered_con_c_b +  Ordered_con_a_b + Unordered_con_c_e]),Compose_Construct_Constrains) == true
end

end
