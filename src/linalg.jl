function adjacency_matrix(g::AbstractGraph)
    n_v = nv(g)
    mx = spzeros(Bool, n_v, n_v)
    for e in edges(g)
        mx[src(e), dst(e)] = true
        if typeof(g) == Graph
            mx[dst(e), src(e)] = true
        end
    end
    return mx
end

function laplacian_matrix(g::Graph)
    n_v = nv(g)
    A = adjacency_matrix(g)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

laplacian_spectrum(g::Graph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractGraph) = eigvals(full(adjacency_matrix(g)))
