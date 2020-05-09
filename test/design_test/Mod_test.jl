@testset "Moduels" begin


    Symbol_array =[:sym, :sym2, :sym3]
    String_array = ["a", "b", "c"]

    mt_a = Mod("a")
    mt_b = Mod("b")
    mt_c = Mod("c")
    mt_d = Mod("d")
    mt_e = Mod("e")

    mt_symb = Mod(:sym)

    moduel_test_Symbol_array_non_unique =[:sym, :sym2, :sym3, :sym2]
    moduel_test_String_array_non_unique= ["a", "b", "c" ,"a"]

    @testset "SetMod_single"  begin
        @test mt_symb.m == :sym
        @test mt_a.m == "a"
        @test mt_symb |> length  == 1
        @test mt_a |> length == 1
    end

    Group_Mod_test = GroupMod([mt_a,mt_b,mt_c,mt_d,mt_e])
    Group_Mod_test_order = GroupMod([mt_b,mt_a,mt_c,mt_d,mt_e,mt_c])

    @testset "Group_mod" begin
        @test Group_Mod_test_order.m == Group_Mod_test.m
    end

    @testset "group_mod" begin
        @test groupmod(["b", "a", "c","c","e","d"]).m == GroupMod([mt_a,mt_b,mt_c,mt_d,mt_e]).m
        @test groupmod([:b, :a, :c,:c,:e,:d]).m == GroupMod([Mod(:a),Mod(:b),Mod(:c),Mod(:d),Mod(:e)]).m
    end

    mt_String_array = groupmod(["b", "a", "c","c","e","d"])
    @testset "length" begin
        @test length(mt_String_array) == 5
        @test length(Mod("a")) == 1
    end

    @testset "isless" begin
        @test isless(Mod(:b),Mod(:a)) == false
        @test isless(Mod(:c),Mod(:e)) == true
        @test isless(Mod("a"),Mod("begin")) == true
    end

    @testset "isless" begin
        @test isless(Mod(:b),Mod(:a)) == false
        @test isless(Mod(:c),Mod(:e)) == true
        @test isless(Mod("a"),Mod("begin")) == true
    end

    test_collect = collect(Group_Mod_test_order)
    @testset "collect" begin
        @test length(test_collect) == 5
        @test eltype(test_collect) == Mod{String}
    end


end
