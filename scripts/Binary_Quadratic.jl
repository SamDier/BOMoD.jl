# ref https://github.com/baptistar/BOCS/blob/master/test_problems/Quadratic/quad_mat.m
function compute_decay(n_vars, Lc)
	K = (s,t) -> exp(-1*(s-t)^2/Lc)
	decay = Array{Float64,2}(undef,n_vars,n_vars)

	for i=1:n_vars
		for j=1:n_vars
			decay[i,j] = K(i,j);
		end
	end

	#Generate random quadratic model
	#and apply exponential decay to Q
	Q = randn(n_vars, n_vars);
	Qa = Q.*decay;
end

quad(x,Q,λ) = transpose(x)*Q*x - λ*norm(x,1)
