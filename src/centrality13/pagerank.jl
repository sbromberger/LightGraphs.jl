# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

using Base.Threads

"""
    pagerank(g, α=0.85, n=100, ϵ=1.0e-6)

Calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
graph `g` parameterized by damping factor `α`, number of iterations
`n`, and convergence threshold `ϵ`. Return a vector representing the
centrality calculated for each node in `g`, or an error if convergence
is not reached within `n` iterations.
"""
function pagerank(
    g::AbstractGraph{U},
    α=0.85,
    n::Integer=100,
    ϵ=1.0e-6
    ) where U <: Integer
    α_div_outdegree = Vector{Float64}(undef,nv(g))
    dangling_nodes = Vector{U}()
    for v in vertices(g)
        if outdegree(g, v) == 0
            push!(dangling_nodes, v)
        end
        α_div_outdegree[v] = (α/outdegree(g, v))
    end
    N = Int(nv(g))
    # solution vector and temporary vector
    x = fill(1.0 / N, N)
    xlast = copy(x)
    for _ in 1:n
        dangling_sum = 0.0
        for v in dangling_nodes
            dangling_sum += x[v]
        end
        # flow from teleprotation
        for v in vertices(g)
            xlast[v] = (1 - α + α * dangling_sum) * (1.0 / N)
        end
        # flow from edges

        for v in vertices(g)
            for u in inneighbors(g, v)
                xlast[v] += (x[u] * α_div_outdegree[u])
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
