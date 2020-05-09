@testset "Constructs_test" begin

    mt_a = Mod("a")
    mt_b = Mod("b")
    mt_c = Mod("c")
    mt_d = Mod("d")
    mt_e = Mod("e")
    # some test constructs
    oc1 = OrderedConstruct([mt_a,mt_d,mt_b])
    oc2 = OrderedConstruct([mt_a,mt_b,mt_e,mt_d])
    unoc1 = UnorderedConstruct([mt_e,mt_d,mt_c])
    unoc2 = UnorderedConstruct([mt_e,mt_a,mt_d,mt_e])
     @testset "Base" begin
        @test length(oc1) == 3
        @test length(oc2) == 4
        @test length(unoc1) == 3
        @test length(unoc2) == 4

        @test oc1[2] == mt_d
        @test oc2[3] == mt_e

        @test isequal(oc1[1:2],OrderedConstruct([mt_a,mt_d])) == true
        @test isequal(oc1[1:2],OrderedConstruct([mt_a,mt_d])) == true
        @test length(collect(oc1)) == length(oc1)
        @test length(collect(unoc1)) == length(unoc1)
        @test eltype(collect(oc1)) == typeof(mt_a)
    end

    @testset "*_ordered" begin
        @test isequal(mt_a*mt_b,OrderedConstruct([mt_a,mt_b])) == true
        @test isequal(OrderedConstruct([mt_a,mt_b])*mt_c,OrderedConstruct([mt_a,mt_b,mt_c])) == true
        @test isequal(mt_c*OrderedConstruct([mt_a,mt_b]),OrderedConstruct([mt_c,mt_a,mt_b])) == true
        @test isequal((OrderedConstruct([mt_a,mt_b])*OrderedConstruct([mt_d,mt_e])),OrderedConstruct([mt_a,mt_b,mt_d,mt_e])) == true
    end

    @testset "+_unordered" begin
        @test isequal((mt_a+mt_b),UnorderedConstruct([mt_a,mt_b])) == true
        @test isequal(UnorderedConstruct([mt_a,mt_b])+mt_c,UnorderedConstruct([mt_a,mt_b,mt_c])) == true
        @test isequal(mt_c+UnorderedConstruct([mt_a,mt_b]),UnorderedConstruct([mt_c,mt_a,mt_b])) == true
        @test isequal((UnorderedConstruct([mt_a,mt_b])+UnorderedConstruct([mt_d,mt_e])),UnorderedConstruct([mt_a,mt_b,mt_d,mt_e])) == true
    end

end
