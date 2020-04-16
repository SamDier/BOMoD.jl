@testset "Samplers"

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
    constrained_design =construct_design(mt_String_array,3,Unordered_con_c_e,order=true)
    test_space2 = constrained_desig.space
    n_samples2 = rand(1:10)
    a_sample = sample_reject(rng,test_space,n_samples2)

    @testset "sample_reject " begin
        @test size(a_sample_with_index)[1] == n_samples2
        @test size(a_sample_with_index)[2] == 2
        #number of samples oke
        @test 
        @test  isequal(test_space[a_sample_with_index[1,2]],a_sample_with_index[1,1]) == true
        # collect works
    end
