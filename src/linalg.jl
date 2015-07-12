# this function is optimized for speed.
function adjacency_matrix(g::SimpleGraph, dir::Symbol=:out, T::DataType=Int)
    n_v = nv(g)
    nz = ne(g) * (is_directed(g)? 1 : 2)
    colpt = ones(Int, n_v + 1)

    if dir == :out
        neighborfn = out_neighbors
    elseif dir == :in
        neighborfn = in_neighbors
    elseif dir == :both
        if is_directed(g)
            neighborfn = all_neighbors
            nz *= 2
        else
            neighborfn = out_neighbors
        end
    else
        error("Not implemented")
    end
    rowval = sizehint!(@compat(Vector{Int}()), nz)
    for j in 1:n_v
        dsts = neighborfn(g, j)
        colpt[j+1] = colpt[j] + length(dsts)
        append!(rowval, sort!(dsts))
    end
    return SparseMatrixCSC(n_v,n_v,colpt,rowval,ones(T,nz))
end

function laplacian_matrix(g::Graph, dir::Symbol=:out, T::DataType=Int)
    A = adjacency_matrix(g, dir, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

function laplacian_matrix(g::DiGraph, dir::Symbol=:both, T::DataType=Int)
    A = adjacency_matrix(g, dir, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end


laplacian_spectrum(g::Graph, dir::Symbol=:out, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))
laplacian_spectrum(g::DiGraph, dir::Symbol=:both, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))

adjacency_spectrum(g::Graph, dir::Symbol=:out, T::DataType=Int) = eigvals(full(adjacency_matrix(g, dir, T)))
adjacency_spectrum(g::DiGraph, dir::Symbol=:both, T::DataType=Int) = eigvals(full(adjacency_matrix(g, dir, T)))
