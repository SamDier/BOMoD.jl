@testset "Filter_test" begin

    mt_a = Mod("a")
    mt_b = Mod("b")
    mt_c = Mod("c")
    mt_d = Mod("d")
    mt_e = Mod("e")

    # some test constructs
    oc1 = OrderedConstruct([mt_a mt_d mt_b])
    oc2 = OrderedConstruct([mt_a mt_b mt_e])
    oc3 = OrderedConstruct([mt_e mt_d mt_c])
    oc4 = OrderedConstruct([mt_e mt_a mt_d])
    # constrains
    con1 = UnOrderedConstraint([Mod("a") , Mod("b")])
    con2 = OrderedConstraint([1 3],[Mod("a") Mod("b")])
    con3 = OrderedConstraint([1 3],[Mod("e") Mod("c")])
    con4 = con1 + con2 + con3

    @testset "UnCon" begin
        @test filterconstraint(oc1,con1) == true
        @test filterconstraint(oc2,con1) == true
        @test filterconstraint(oc3,con1) == false
    end

    @testset "OrCon" begin
        @test filterconstraint(oc1,con2) == true
        @test filterconstraint(oc2,con2) == false
        @test filterconstraint(oc3,con2) == false
    end

    @testset "compose" begin
        @test filterconstraint(oc1,con4) == true
        @test filterconstraint(oc2,con4) == true
        @test filterconstraint(oc3,con4) == true
        @test filterconstraint(oc4,con4) == false
    end
end
