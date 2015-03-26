# this function is optimized for speed.
function adjacency_matrix(g::AbstractGraph, T::DataType=Int)
    n_v = nv(g)                           # dimension of matrix
    ## number of nonzeros in the result is 2*ne(g) for Graph, ne(g) for DiGraph
    nz = ne(g) * (is_directed(g)? 1 : 2)
    colpt = ones(Int,n_v + 1)
    rowval = sizehint!(Int[],nz)
    storage = Array(Int, Δout(g))
    for j in 1:n_v
        dsts = outneighbors!(storage, g, j)
        colpt[j+1] = colpt[j] + length(dsts)
        append!(rowval,sort!(dsts))
    end
    return SparseMatrixCSC(n_v,n_v,colpt,rowval,ones(T,nz))
end

function laplacian_matrix(g::Graph)
    A = adjacency_matrix(g)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

function outneighbors!(outneighborhood, g, j)
    edgecollection = out_edges(g, j)
    degj = outdegree(g, j)
    for i =1:degj
        outneighborhood[i] = edgecollection[i].dst
    end
    return sub(outneighborhood, 1:degj)
end

laplacian_spectrum(g::Graph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractGraph) = eigvals(full(adjacency_matrix(g)))
