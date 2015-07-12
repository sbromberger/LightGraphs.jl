# this function is optimized for speed.
function adjacency_matrix(g::SimpleGraph, T::DataType=Int; dir::Symbol=:out)
    n_v = nv(g)
    nz = ne(g) * (is_directed(g)? 1 : 2)
    colpt = ones(Int, n_v + 1)
    rowval = sizehint!(Int[], nz)
    if dir == :out
        neighborfn = out_neighbors
    elseif dir == :in
        neighborfn = in_neighbors
    elseif dir == :both
        neighborfn = neighbors
    else
        error("Not implemented")
    end
    for j in 1:n_v
        dsts = neighborfn(g, j)
        colpt[j+1] = colpt[j] + length(dsts)
        append!(rowval, sort!(dsts))
    end
    return SparseMatrixCSC(n_v,n_v,colpt,rowval,ones(T,nz))
end

function laplacian_matrix(g::Graph)
    A = adjacency_matrix(g)
    D = spdiagm(sum(A,2)[:])
    return D - A
end


laplacian_matrix(g::DiGraph; dir::Symbol=:out) = laplacian_matrix(g; dir=dir)


laplacian_spectrum(g::Graph) = eigvals(full(laplacian_matrix(g)))
laplacian_spectrum(g::DiGraph; dir::Symbol=:out) = eigvals(full(laplacian_matrix(g; dir=dir)))

adjacency_spectrum(g::SimpleGraph) = eigvals(full(adjacency_matrix(g)))
