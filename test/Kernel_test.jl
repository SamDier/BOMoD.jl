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
testkernel = EditDistancesKernel(Levenshtein)
#expexted output for custum ew
ew_test = exp.[-evaluate(Levenshtein(),s1,s5),-evaluate(Levenshtein(),s2,s6),-evaluate(Levenshtein(),s3,s7),-evaluate(Levenshtein(),s1,s8)]

pw_test1 = Array{Float64,2}(undef,4,4)
for i,si in enumerate(x1)
    for j,sj in  enumerate(x2)
        pw_test1[i,j] = -evaluate(Levenshtein(),si,sj)
    end
end

pw_test2= Array{Float64,2}(undef,4,4)
for i,si in enumerate(x1)
    for j,sj in  enumerate(x1)
        pw_test2[i,j] = -evaluate(Levenshtein(),si,sj)
    end
end

for i in 1:length(x1)
@testset "Editdistance" begin
    @test map(x -> exp.(-evaluate(Levenshtein(),x,x),x1)) == ew(testkernel,x1)
    @test ew_test == ew(testkernel,x1,x2)
    @test pw_test1 == pw(testkernel,x1)
    @test pw_test2 = pw(testkernel,x1,x2)
end
