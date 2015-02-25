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
function adjacency_matrix(g::AbstractGraph, as::DataType=Int)
    n_v = nv(g)
    mx = spzeros(as,0,0)
    mx.n = n_v
    mx.m = n_v
    colindex = 1
    for r in g.finclist
        colvals = Int[]
        for e in r

            push!(colvals, dst(e))
            push!(mx.nzval, one(as))
            colindex += 1
        end
        sort!(colvals)
        append!(mx.rowval, colvals)
        push!(mx.colptr, colindex)
    end

    return mx
end

function laplacian_matrix(g::Graph)
    A = adjacency_matrix(g)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

laplacian_spectrum(g::Graph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractGraph) = eigvals(full(adjacency_matrix(g)))
