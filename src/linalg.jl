function adjacency_matrix(g::AbstractSimpleGraph)
    n_v = nv(g)
    mx = spzeros(Bool, n_v, n_v)
    for e in edges(g)
        mx[src(e), dst(e)] = true
        if typeof(g) == SimpleGraph
            mx[dst(e), src(e)] = true
        end
    end
    return mx
end

function laplacian_matrix(g::SimpleGraph)
    n_v = nv(g)
    A = adjacency_matrix(g)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

laplacian_spectrum(g::SimpleGraph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractSimpleGraph) = eigvals(full(adjacency_matrix(g)))
