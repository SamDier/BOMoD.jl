@testset "Samplers" begin

    mt_String_array = groupmod(["b", "a", "c","e","d"])
    rng = MersenneTwister()

    design1 =constructdesign(mt_String_array,3,order=true)
    test_space = getspace(design1)
    n_samples = rand(1:20)
    a_sample = sample(rng,test_space,n_samples, with_index = false)

    @testset "sample_with_index = false " begin
        @test length(a_sample) == n_samples
        @test_throws BoundsError size(a_sample)[2]
        #number of samples oke
        @test  length(a_sample) == n_samples
        # all unique
        @test  length(Set(a_sample)) == n_samples
        # collect works
    end

    a_sample_with_index = sample(rng,test_space,n_samples, with_index = true)

    @testset "sample_with_index = true " begin
        @test length(a_sample_with_index[1]) == n_samples
        @test length(a_sample_with_index) == 2
        #number of samples oke
        @test  isequal(test_space[a_sample_with_index[2][1]],a_sample_with_index[1][1]) == true
        # collect works
    end

    Unordered_con_c_e = UnOrderedConstraint([Mod("c") , Mod("e")])
    design2 = constructdesign(mt_String_array,3,Unordered_con_c_e,order=true)
    test_space2 = getspace(design2)
    n_samples2 = rand(1:10)
    a_sample2 = sample(rng,test_space2,n_samples2)

    @testset "sample_reject" begin
        # number of samples
        @test length(a_sample2[1]) == n_samples2
        # all unique elements
        @test a_sample2[1] |> unique |> length == n_samples2
        #contrain is used
        for i in a_sample2
            @test (Mod("c") in i && Mod("e") in i) == false
        end
        @test typeof(a_sample2[2]) == Vector{Int}
    end

    design3  = constructdesign(mt_String_array,[2,3],UnOrderedConstraint([Mod("c") , Mod("e")]),order=true)
    test_space3 = getspace(design3)
    n_samples3 = rand(1:10)
    a_sample3 = sample(rng,test_space3,n_samples3)


    @testset "multiframe" begin
        # number of samples
        @test length(a_sample3[1]) == n_samples3
        # all unique elements
        @test a_sample3[1] |> unique |> length == n_samples3
        #contrain is used
        for i in a_sample3
            @test (Mod("c") in i && Mod("e") in i) == false
        end
    end


end
