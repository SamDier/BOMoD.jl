s1 = ["a","b","c","d"]
s2 = ["b","b","c","d"]
s3 = ["b","b","c","c"]
s4 = ["a","c","c","d"]
m = groupmod( ["a","b","c","d"])
x1_test = [s1,s2,s3,s4]
x1 = [OrderedConstruct([Mod(m) for m in s]) for s in [s1,s2,s3,s4]]
y_train = randn(4)
## _creatGP
k2 = EditDistancesKernel(Levenshtein())
@testset "GP" begin
    typeof(_creatGP(k2,[1])[1]) == Stheno.CompositeGP
    typeof(_creatGP(k2,[1])[1]) == Stheno.CompositeGP
    _creatGP(k2,[1])[1].args[3].k == k2
end

k1 = QGramKernel(StringDistance.Cosine(1))
@testset "GP" begin
    typeof(_creatGP(k1,[1])[1]) == Stheno.CompositeGP
    typeof(_creatGP(k1,[1])[1]) == Stheno.CompositeGP
    _creatGP(k1,[1])[1].args[3].k == k1
end

## fit_gp



@testset "fit_gp" begin
    typeof(fit_gp(x_train,y_train,k2,m,optimse=false)) == GPModel
    typeof(fit_gp(x_train,y_train,k2,m,optimse=false).f̂) == Stheno.CompositeGP
end
