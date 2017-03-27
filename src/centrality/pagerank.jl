# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    pagerank(g, α=0.85, n=100, ϵ=1.0e-6)

Calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
directed graph `g` parameterized by damping factor `α`, number of
iterations `n`, and convergence threshold `ϵ`. Return a vector representing
the centrality calculated for each node in `g`, or an error if convergence
is not reached within `n` iterations.
"""
function pagerank end

@traitfn function pagerank(g::::IsDirected, α=0.85, n=100, ϵ=1.0e-6)
    A = adjacency_matrix(g,:in,Float64)
    S = vec(sum(A,1))
    S = 1./S
    S[find(S .== Inf)]=0.0
    M = A' # need a separate line due to bug #17456 in julia
    M = (Diagonal(S) * M)'
    N = Int(nv(g))
    x = fill(1.0/N, N)
    p = fill(1.0/N, N)
    dangling_weights = p
    is_dangling = find(S .== 0)

    for _ in 1:n
        xlast = x
        x = α * (M * x + sum(x[is_dangling]) * dangling_weights) + (1 - α) * p
        err = sum(abs, (x - xlast))
        if (err < N * ϵ)
            return x
        end
    end
    error("Pagerank did not converge after $n iterations.")
end
