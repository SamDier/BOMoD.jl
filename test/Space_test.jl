@testset "Space" begin
        # make space
    mt_String_array = group_mod(["b", "a", "c","c","e","d"])

    first_design =construct_design(mt_String_array,3,order = true)
    test_space = first_design.space
    index = rand(1:125)

    @testset "Full_orderd_space" begin
        #length works
        @test length(test_space) == 125
        # collect works
        @test length(collect(test_space)) == 125
        # all unique
        @test length(Set(collect(test_space))) == 125
        #check get index
        @test (test_space[index][1] == collect(test_space)[index][1]) && (test_space[index][2] == collect(test_space)[index][2]) && (test_space[index][3] == collect(test_space)[index][3]) == true
    end

    first_design =construct_design(mt_String_array,3)
    test_space_2 = first_design.space
    index = rand(1:10)

    @testset "Full_orderd_space" begin
        #length works
        @test length(test_space2) == 10
        # collect works
        @test length(collect(test_space2)) == 10
        # all unique
        @test length(Set(collect(test_space2))) ==
        #check get index
        @test Set(test_space[index]) == Set(collect(test_space)[index])
    end
end
