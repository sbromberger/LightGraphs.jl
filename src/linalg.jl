# this function is optimized for speed.
function adjacency_matrix(g::AbstractGraph, T::DataType=Int)
    n_v = nv(g)
    nz = ne(g) * (is_directed(g)? 1 : 2)
    colpt = ones(Int, n_v + 1)
    rowval = sizehint!(Int[], nz)
    for j in 1:n_v
        dsts = out_neighbors(g, j)
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


laplacian_spectrum(g::Graph) = eigvals(full(laplacian_matrix(g)))

adjacency_spectrum(g::AbstractGraph) = eigvals(full(adjacency_matrix(g)))

# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

function pagerank(g::DiGraph, α=0.85, n=100, ϵ = 1.0e-6)
    M = adjacency_matrix(g)
    S = vec(sum(M,1))
    S = 1./S; S[find(S .== Inf)]=0.0
    Q = spdiagm(S)
    M = Q * M'
    N = nv(g)
    x = repmat([1.0/N], N)
    p = repmat([1.0/N], N)
    dangling_weights = p
    is_dangling = find(S .== 0)

    for _ in 1:n
        xlast = x
        x = α * (x * M + sum(x[is_dangling]) * dangling_weights) + (1 - α) * p
        err = sum(abs(x - xlast))
        if (err < N * ϵ)
            return x
        end
    end
    error("Pagerank did not converge after $n iterations.")
end
