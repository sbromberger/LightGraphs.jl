# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    pagerank(g, α=0.85, n=100, ϵ=1.0e-6)

Calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
graph `g` parameterized by damping factor `α`, number of iterations 
`n`, and convergence threshold `ϵ`. Return a vector representing the
centrality calculated for each node in `g`, or an error if convergence
is not reached within `n` iterations.
"""
function pagerank(g::AbstractGraph, α=0.85, n=100::Integer, ϵ=1.0e-6)
    # collect dangling nodes
    dangling_nodes = [v for v in vertices(g) if out_degree(g, v) == 0]
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
            xlast[v] += α * x[u] / out_degree(g, u)
            if !is_directed(g)
                xlast[u] += α * x[v] / out_degree(g, v)
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
