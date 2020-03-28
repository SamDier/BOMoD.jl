@testset "Space" begin

    # make space
    mt_String_array = group_mod(["b", "a", "c","c","e","d"])

    first_design =construct_ordered_design(mt_String_array,3)
    test_space = first_design.space
    index = rand(1:125)
    @testset "Full orderd space" begin
        #length works
        @test length(test_space) == 125
        # collect works
        @test length(collect(test_space)) == 125
        # all unique
        @test length(Set(collect(test_space))) == 125
        #check get index
        @test (test_space[index][1] == collect(test_space)[index][1]) && (test_space[index][2] == collect(test_space)[index][2]) && (test_space[index][3] == collect(test_space)[index][3]) == true
        #chekc type
        @test eltype(test_space) == Ordered_Construct
    end

    first_design =construct_ordered_design(mt_String_array,3)
    test_space = first_design.space
    rng = MersenneTwister()
    n_samples = rand(1:20)
    a_sample = sample(rng,test_space,n_samples, with_index = false)

    @testset "sample_with_index = false " begin
        @test size(a_sample)[1] == n_samples
        @test_throws BoundsError size(a_sample)[2]
        #number of samples oke
        @test  length(a_sample) == n_samples
        # all unique
        @test  length(Set(a_sample)) == n_samples
        # collect works
    end

    a_sample_with_index = sample(rng,test_space,n_samples, with_index = true)

    @testset "sample_with_index = true " begin
        @test size(a_sample_with_index)[1] == n_samples
        @test size(a_sample_with_index)[2] == 2
        #number of samples oke
        @test  isequal(test_space[a_sample_with_index[1,2]],a_sample_with_index[1,1]) == true
        # collect works
    end

end
