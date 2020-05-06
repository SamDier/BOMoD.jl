# FIXME: typo in function name `design_maxtrix` => `design_matrix`
# make Toydata
"""
    design_maxtrix(subspace, moduels::Group_Mod)

Generates the design matrix for the given subspace of constructs.
The Designmatrix has (n x p) dimension where `n` is the number of constructs and
`p` the number of modules.
Depending on the application it needs to be transposed.
"""

function design_matrix(subspace,moduels::Group_Mod)
    # mod to index
    dict_mod = Dict(moduels.m .=> collect(1:length(moduels.m)))
    # setup design matrix
    dm = Array{Int,2}(undef,length(subspace),length(moduels))
    #make matrix
    for (row,construct) in enumerate(subspace)
        dm[row,:] = _design_vector(construct,dict_mod)
    end
    return dm
end

# REVIEW this docstring
