@testset "Constraints" begin



   Unordered_con_c_e = UnOrderedConstraint([Mod("c") , Mod("e")])
   Ordered_con_a_b = OrderedConstraint([1 3],[Mod("a") Mod("b")])
   Ordered_con_c_b = OrderedConstraint([2 3],[Mod("c") Mod("b")])



   @testset "single addition" begin
      @test isa(Unordered_con_c_e,UnOrderedConstraint) == true
      @test isa(Ordered_con_a_b,OrderedConstraint) == true
      @test isa((Ordered_con_c_b +  Ordered_con_a_b),ComposeConstructConstraints) == true
      @test (Ordered_con_c_b +  Ordered_con_a_b).constructcon == [Ordered_con_c_b;Ordered_con_a_b]
      @test (Unordered_con_c_e +  Ordered_con_a_b).constructcon == [Unordered_con_c_e;Ordered_con_a_b]
   end

   @testset "mulitple_additions" begin
      @test  Set((Ordered_con_c_b +  Ordered_con_a_b + Unordered_con_c_e).constructcon) == Set([Ordered_con_c_b;Ordered_con_a_b;Unordered_con_c_e])
      @test  isa(sum([Ordered_con_c_b +  Ordered_con_a_b + Unordered_con_c_e]),ComposeConstructConstraints) == true
   end

end
