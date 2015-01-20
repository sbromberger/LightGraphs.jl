function adjacency_matrix(g::AbstractFastGraph)
    n_v = nv(g)
    mx = spzeros(n_v, n_v)
    for e in edges(g)
        mx[src(e), dst(e)] = dist(e)
        if typeof(g) == FastGraph
            mx[dst(e), src(e)] = dist(e)
        end
    end
    return mx
end

function laplacian_matrix(g::FastGraph)
    n_v = nv(g)
    A = adjacency_matrix(g)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

laplacian_spectrum(g::FastGraph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractFastGraph) = eigvals(full(adjacency_matrix(g)))
