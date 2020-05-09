@testset "Space" begin
        # make space
    mt_String_array = groupmod(["b", "a", "c","c","e","d"]);

    first_design =constructdesign(mt_String_array,3,order = true);
    test_space = getspace(first_design);
    index = rand(1:125);

    @testset "Full_orderd_space" begin
        #length works
        @test length(test_space) == 125
        # collect works
        @test length(collect(test_space)) == 125
        # all unique
        @test length(Set(collect(test_space))) == 125
        for (i,j) in zip(collect(test_space),collect(getspace(first_design,full=true)))
            @test isequal(i,j)
        end
        #check get index
        @test (test_space[index][1] == collect(test_space)[index][1]) && (test_space[index][2] == collect(test_space)[index][2]) && (test_space[index][3] == collect(test_space)[index][3]) == true
    end

    first_design2 = constructdesign(mt_String_array,3);
    test_space_2 =  getspace(first_design2);
    index = rand(1:10)

    @testset "Full_unorderd_space" begin
        #length works
        @test length(test_space_2) == 10
        # collect works
        @test length(collect(test_space_2)) == 10
        # all unique
        @test length(Set(collect(test_space_2))) == 10
        #check get index
        @test Set(test_space_2[index]) == Set(collect(test_space_2)[index])
    end

    con = UnOrderedConstraint([Mod("c") , Mod("e")])
    first_design_3 = constructdesign(mt_String_array,3,con)
    test_space_3 =  getspace(first_design_3)

    @testset "Frame_space" begin
        #length works
        @test length(test_space_3) == 7
        # collect works
        @test length(collect(test_space_3)) == 7
        # all unique
        @test length(Set(collect(test_space_3))) == 7
        #check get index
    end
end
