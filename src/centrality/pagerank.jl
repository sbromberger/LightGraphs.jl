# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

function pagerank(g::DiGraph, α=0.85, n=100, ϵ = 1.0e-6)
    M = adjacency_matrix(g)
    S = vec(sum(M,1))
    S = 1./S
    S[find(S .== Inf)]=0.0
    M = scale(S, M')
    N = nv(g)
    x = repmat([1.0/N], N)
    p = repmat([1.0/N], N)
    dangling_weights = p
    is_dangling = find(S .== 0)

    for _ in 1:n
        xlast = x
        x = α * (M.' * x + sum(x[is_dangling]) * dangling_weights) + (1 - α) * p
        err = sum(abs(x - xlast))
        if (err < N * ϵ)
            return x
        end
    end
    error("Pagerank did not converge after $n iterations.")
end
