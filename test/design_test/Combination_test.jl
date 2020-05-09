@testset "Combinations" begin

    # length of the construct
    n_rand = rand(1:5)
    #input modules
    mt_String_array = groupmod(["1", "2", "3", "4","5","6","7","8","9"])
    test_com = Combination(mt_String_array.m,n_rand)
    @testset "setup" begin
        @test length(test_com) == binomial(length(mt_String_array),n_rand)
        @test size(test_com) == (binomial(length(mt_String_array),n_rand),1)
        @test length(collect(test_com)) == length(test_com)
        # all unique
        @test length(Set(collect(test_com))) == length(test_com)
    end

    # check if getindex equals the iterator
    # chekc if all combination have unique elements
    @testset "getindex" begin
        for (a,b) in zip(test_com,1:length(test_com))
            @test isequal(a,test_com[b])
            @test allunique(a) == true
        end
    end

    test_collect = collect(test_com)
    @testset "test_collect" begin
        @test length(test_collect) == binomial(9,n_rand)
        @test eltype(test_collect) == UnorderedConstruct{Mod{String}}
    end




end
