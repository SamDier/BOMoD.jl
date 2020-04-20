# get optimised hyperparameter
"""
     nlml_stheno(parm, x_train,y_train, K::Kernel; ϵ=1e-6)

Calculates the negative log marginal likelihood for given parameters and kernel.
Adds a small offset `ϵ` for numerical purposes.
"""
function nlml_stheno(parm, x_train, y_train, K::Kernel; ϵ=1e-6)
        @assert length(parm) == 2
        α,σ²= exp.(parm) .+ ϵ
        f = α*GP(K, GPC())
        return -logpdf(f(x_train, σ²), y_train)
end

#FIXME: `Kernel` is a type or an oject (e.g., `Kernel()`), I think this should be
# in with a small cap => `kernel`
"""
    GP_optimised(parm, constructs_train, activity_train, Mykernel::Kernel)

Optimises the hyperparameters of the GP with the given kernel.
Then calculated the posterior distribution given this optimised hyperparameters
and data.

Returns a Stheno object.
"""
function gp_optimised(constructs_train,activity_train,Mykernel::Kernel; θ₀= zeros(2))
        results = Optim.optimize(parm -> nlml_stheno(parm,constructs_train,activity_train,Mykernel), θ₀, NelderMead())
        #get optimal hyperparameters
        α_opt, σ²_opt = exp.(Optim.minimizer(results)) .+ 10^-6
        #set Gaussian procces in Stheno framework
        fGP = α_opt * GP(Mykernel, GPC())
        #calculate f_postirior based on training data and the prior f
        return  GP_optimised(fGP | (fGP(constructs_train,σ²_opt) ← activity_train), α_opt, σ²_opt)
end

struct GP_optimised{T}
        GP_model::T
        α_opt::Float64
        σ²_opt::Float64
end
