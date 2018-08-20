# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

using Base.Threads

"""
    pagerank(g, α=0.85, n=100, ϵ=1.0e-6)
    parallel_pagerank(g, α=0.85, n=100, ϵ=1.0e-6)

Calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
graph `g` parameterized by damping factor `α`, number of iterations 
`n`, and convergence threshold `ϵ`. Return a vector representing the
centrality calculated for each node in `g`, or an error if convergence
is not reached within `n` iterations.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> pagerank(g)
5-element Array{Float64,1}:
 0.07733381437929017
 0.09573374222239664
 0.11137368088903715
 0.37057339939785167
 0.34498536311142447
```
"""
function pagerank(
    g::AbstractGraph{U}, 
    α=0.85, 
    n=100::Integer, 
    ϵ=1.0e-6
    ) where U <: Integer
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
        for edge in edges(g)
            u, v = src(edge), dst(edge)
            xlast[v] += α * x[u] / outdegree(g, u)
            if !is_directed(g)
                xlast[u] += α * x[v] / outdegree(g, v)
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

function parallel_pagerank(
    g::AbstractGraph{U}, 
    α=0.85, 
    n=100::Integer, 
    ϵ=1.0e-6
    ) where U <: Integer
    
    # indegree(g, v) is estimated run-time to iterate over inneighbors(g, v)
    partitions = optimal_contiguous_partition(indegree(g), nthreads(), nv(g))

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
