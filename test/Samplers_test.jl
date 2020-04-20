@testset "Samplers" begin

    mt_String_array = group_mod(["b", "a", "c","e","d"])

    first_design =construct_design(mt_String_array,3,order=true)
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

    Unordered_con_c_e = UnOrdered_Constrain([Mod("c") , Mod("e")])
    constrained_design = construct_design(mt_String_array,3,Unordered_con_c_e,order=true)
    test_space2 = constrained_design.space
    n_samples2 = rand(1:10)
    a_sample2 = sample(rng,test_space,n_samples2)

    @testset "sample_reject" begin
        # number of samples
        @test size(a_sample2)[1] == n_samples2
        # all unique elements
        @test a_sample2[:,1] |> unique |> length == n_samples2
        #contrain is used
        for i in a_sample
            @test (Mod("c") in a_sample && Mod("e") in a_sample) == false
        end
    end 

end
