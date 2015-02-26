# This function is not very efficient due to assignment within sparse matrices.
# Deprecated in favor of the function below.
# function adjacency_matrix(g::AbstractGraph; T::DataType=Int)
#     n_v = nv(g)
#     mx = spzeros(T, n_v, n_v)
#     # sizehint!(mx, ne(g))
#     for e in edges(g)
#         mx[src(e), dst(e)] = one(T)
#         if !is_directed(g)
#             mx[dst(e), src(e)] = one(T)
#         end
#     end
#     return mx
# end

# this function is optimized for speed.
function adjacency_matrix(g::AbstractGraph, T::DataType=Int)
    n = nv(g)                           # dimension of matrix
    ## number of nonzeros in the result is 2*ne(g) for Graph, ne(g) for DiGraph
    nz = ne(g) * (isa(g,LightGraphs.Graph) + 1)
    colpt = ones(T,n + 1)
    rowval = sizehint!(T[],nz)
    for j in 1:n
        ev = [dst(e) for e in g.finclist[j]]
        colpt[j+1] = colpt[j] + length(ev)
        append!(rowval,sort!(ev))
    end
    return SparseMatrixCSC(n,n,colpt,rowval,ones(T,nz))
end

function laplacian_matrix(g::Graph)
    A = int(adjacency_matrix(g))
    D = spdiagm(sum(A,2)[:])
    return D - A
end

laplacian_spectrum(g::Graph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractGraph) = eigvals(full(int(adjacency_matrix(g))))
