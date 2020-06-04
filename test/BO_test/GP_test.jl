
    s2 = ["b","b","c","d"];
    s3 = ["b","b","c","c"];
    s4 = ["a","c","c","d"];
    m = groupmod(["a","b","c","d"])
    x1_test = [s1,s2,s3,s4]
    x1 = [OrderedConstruct([Mod(m) for m in s]) for s in [s1,s2,s3,s4]]
    y_train = randn(4)
    typeof(_creatGP(k2,[1])[1])

    ## _creatGP
    k2 = EditDistancesKernel(Levenshtein())
    @testset "GP2" begin
        isa(_creatGP(k2,[1])[1],Stheno.CompositeGP) == true
        _creatGP(k2,[1])[1].args[3].k == k2
    end

    k1 = QGramKernel(Cosine(1))
    @testset "GP3" begin
        isa(_creatGP(k1,[1])[1],Stheno.CompositeGP) == true
        _creatGP(k1,[1])[1].args[3].k == k1
    end

    ## fit_gp


    @testset "fit_gp" begin
        isa(fit_gp(x1,y_train,k1,m),GPModel) == true
        isa(fit_gp(x1_test ,y_train,k2,m).f̂, Stheno.CompositeGP) == true
    end
