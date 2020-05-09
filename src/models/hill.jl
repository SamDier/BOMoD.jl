
p = exp(-(f_proposal - f_current)/T)
stepsize(start,iteration,x) = start - x.iteration
stepsize(c::Int) = c


function hillclimbing(f,stepsize,x;max_iterate = 1000)
     i = 0
     while  f(x) > f((x+stepsize)) && i <= max_iterate
         x +=stepsize
         i+=1
    end
    return x
end
