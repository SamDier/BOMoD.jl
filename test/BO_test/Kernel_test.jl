
#test _word2vector
mod = sort(["a","b","c","d"])
dict_mod = Dict( j => i for (i,j) in enumerate(mod))
@testset "_word2vector" begin
    @test _word2vec(["a","b","c","d"],dict_mod) == [1,1,1,1]
    @test _word2vec(["b","b","c","d"],dict_mod) == [0,2,1,1]
    @test _word2vec(["b","b","c","c"],dict_mod) == [0,2,2,0]
    @test _word2vec(["a","c","c","d"],dict_mod) == [1,0,2,1]
end

# Kernels
s1 = ["a","b","c","d"]
s2 = ["b","b","c","d"]
s3 = ["b","b","c","c"]
s4 = ["a","c","c","d"]
x1 = [s1,s2,s3,s4]

s5=  ["a","b","d","d"]
s6 = ["b","b","b","d"]
s7 = ["a","a","c","c"]
s8 = ["d","c","c","d"]
x2 = [s5,s6,s7,s8]


testkernel = EditDistancesKernel(Levenshtein())
#expexted output for custum ew
ew_test = exp.([-evaluate(Levenshtein(),s1,s5),-evaluate(Levenshtein(),s2,s6),
    -evaluate(Levenshtein(),s3,s7),
    -evaluate(Levenshtein(),s4,s8)])

@testset "Editdistance" begin
    @test map(x -> exp(-evaluate(Levenshtein(),x,x)),x1) == ew(testkernel,x1)
    @test ew_test == ew(testkernel,x1,x2)
    @test  Grammatrix_levenstein(x1,x1)== pw(testkernel,x1)
    @test  Grammatrix_levenstein(x1,x2) == pw(testkernel,x1,x2)
end

#test cossim
testkernel2 = QgramKernel(StringDistances.Cosine(1))
v1 = [[1,1,1,1],[0,2,1,1],[0,2,2,0],[1,0,2,1]]
v2 = [_word2vec(i,dict_mod) for i in x2]
@testset "Qnorm" begin
    @test map(x -> (1-cosine_dist(x,x)) ,v1) ≈ ew(testkernel2,x1)
    @test [(1-cosine_dist(i,j)) for (i,j) in zip(v1,v2)] ≈ ew(testkernel2,x1,x2)
    @test  Grammatrix_cossine(x1,x1,dict_mod) ≈ pw(testkernel2,x1)
    @test  Grammatrix_cossine(x1,x2,dict_mod) ≈ pw(testkernel2,x1,x2)
end
