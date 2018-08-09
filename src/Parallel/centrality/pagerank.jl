function pagerank(
    g::AbstractGraph{U}, 
    α=0.85, 
    n=100::Integer, 
    ϵ=1.0e-6
    ) where U <: Integer
    
    # indegree(g, v) is estimated run-time to iterate over inneighbors(g, v)
    partitions = LightGraphs.optimal_contiguous_partition(indegree(g), nthreads(), nv(g))

    # collect dangling nodes
    dangling_nodes = [v for v in vertices(g) if outdegree(g, v) == 0]
    N = Int(nv(g))
    # solution vector and temporary vector
    x = fill(1.0 / N, N)
    xlast = copy(x)
    # personalization vector
    p = fill(1.0 / N, N)
    # adjustment for leaf nodes in digraph
    dangling_weights = p
    for _ in 1:n
        dangling_sum = 0.0
        for v in dangling_nodes
            dangling_sum += x[v]
        end
        # flow from teleprotation
        for v in vertices(g)
            xlast[v] = (1 - α + α * dangling_sum) * p[v]
        end
        # flow from edges
        @threads for v_set in partitions
            for v in v_set
                for u in inneighbors(g, v)
                    xlast[v] += α * x[u] / outdegree(g, u)
                end
            end
        end

        # l1 change in solution convergence criterion
        err = 0.0
        for v in vertices(g)
            err += abs(xlast[v] - x[v])
            x[v] = xlast[v]
        end
        if (err < N * ϵ)
            return x
        end
    end
    error("Pagerank did not converge after $n iterations.") # TODO 0.7: change to InexactError with appropriate msg.
end
