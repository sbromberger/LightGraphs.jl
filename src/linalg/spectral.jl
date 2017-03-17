import Base: *

export adjacency_matrix,
laplacian_matrix,
incidence_matrix,
coo_sparse,
spectral_distance

"""
Returns a sparse boolean adjacency matrix for a graph, indexed by `[u, v]`
vertices. `true` values indicate an edge between `u` and `v`. Users may
specify a direction (`:in`, `:out`, or `:both` are currently supported; `:out`
is default for both directed and undirected graphs) and a data type for the
matrix (defaults to `Int`).

Note: This function is optimized for speed.
"""
function adjacency_matrix(g::AbstractGraph, dir::Symbol=:out, T::DataType=Int)
    n_v = nv(g)
    nz = ne(g) * (is_directed(g)? 1 : 2)
    colpt = ones(Int, n_v + 1)

    # see below - we iterate over columns. That's why we take the
    # "opposite" neighbor function. It's faster than taking the transpose
    # at the end.
    if dir == :out
        neighborfn = in_neighbors
    elseif dir == :in
        neighborfn = out_neighbors
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
    rowval = sizehint!(Vector{Int}(), nz)
    selfloops = Vector{Int}()
    for j in 1:n_v  # this is by column, not by row.
        if has_edge(g,j,j)
            push!(selfloops, j)
        end
        dsts = neighborfn(g, j)
        colpt[j+1] = colpt[j] + length(dsts)
        append!(rowval, sort!(dsts))
    end
    spmx = SparseMatrixCSC(n_v,n_v,colpt,rowval,ones(T,nz))

    # this is inefficient. There should be a better way of doing this.
    # the issue is that adjacency matrix entries for self-loops are 2,
    # not one(T).
    for i in selfloops
        if !(T <: Bool)
            spmx[i,i] += one(T)
        end
    end
    return spmx
end

adjacency_matrix(g::AbstractGraph, T::DataType) = adjacency_matrix(g, :out, T)

"""
Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix)
for a graph `g`, indexed by `[u, v]` vertices. For undirected graphs, `dir`
defaults to `:out`; for directed graphs, `dir` defaults to `:both`. `T`
defaults to `Int` for both graph types.
"""
function laplacian_matrix(g::AbstractGraph, dir::Symbol=:unspec, T::DataType=Int)
    if dir == :unspec
        dir = is_directed(g)? :both : :out
    end
    A = adjacency_matrix(g, dir, T)
    D = spdiagm(sum(A,2)[:])
    return D - A
end

doc"""Returns the eigenvalues of the Laplacian matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use
`eigs(laplacian_matrix(g);  kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`laplacian_matrix`.
"""
laplacian_spectrum(g::AbstractGraph, dir::Symbol=:unspec, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))

doc"""Returns the eigenvalues of the adjacency matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use
`eigs(adjacency_matrix(g);kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`adjacency_matrix`.
"""
function adjacency_spectrum(g::AbstractGraph, dir::Symbol=:unspec, T::DataType=Int)
    if dir == :unspec
        dir = is_directed(g)?  :both : :out
    end
    return eigvals(full(adjacency_matrix(g, dir, T)))
end

"""Returns a sparse node-arc incidence matrix for a graph, indexed by
`[v, i]`, where `i` is in `1:ne(g)`, indexing an edge `e`. For
directed graphs, a value of `-1` indicates that `src(e) == v`, while a
value of `1` indicates that `dst(e) == v`. Otherwise, the value is
`0`. For undirected graphs, if the optional keyword `oriented` is `false`,
both entries are `1`, otherwise, an arbitrary orientation is chosen.
"""
function incidence_matrix(g::AbstractGraph, T::DataType=Int; oriented=false)
    isdir = is_directed(g)
    n_v = nv(g)
    n_e = ne(g)
    nz = 2 * n_e

    # every col has the same 2 entries
    colpt = collect(1:2:(nz + 1))
    nzval = repmat([(isdir || oriented) ? -one(T) : one(T), one(T)], n_e)

    # iterate over edges for row indices
    rowval = zeros(Int, nz)
    i = 1
    for u in vertices(g)
        for v in out_neighbors(g, u)
            if isdir || u < v # add every edge only once
                rowval[2*i - 1] = u
                rowval[2*i] = v
                i += 1
            end
        end
    end

    spmx = SparseMatrixCSC(n_v,n_e,colpt,rowval,nzval)
    return spmx
end

"""
spectral_distance(G₁, G₂ [, k])
Compute the spectral distance between undirected n-vertex
graphs G₁ and G₂ using the top k ≤ n greatest eigenvalues.
If k is ommitted, uses full spectrum.

For further details, please refer to:

JOVANOVIC, I.; STANIC, Z., 2014. Spectral Distances of
Graphs Based on their Different Matrix Representations
"""
function spectral_distance end

@traitfn function spectral_distance{G<:AbstractGraph; !IsDirected{G}}(G₁::G, G₂::G, k::Integer)
    A₁ = adjacency_matrix(G₁)
    A₂ = adjacency_matrix(G₂)

    λ₁ = k < nv(G₁)-1 ? eigs(A₁, nev=k, which=:LR)[1] : eigvals(full(A₁))[end:-1:end-(k-1)]
    λ₂ = k < nv(G₂)-1 ? eigs(A₂, nev=k, which=:LR)[1] : eigvals(full(A₂))[end:-1:end-(k-1)]

    sumabs(λ₁ - λ₂)
end

@traitfn function spectral_distance{G<:AbstractGraph; !IsDirected{G}}(G₁::G, G₂::G)
    @assert nv(G₁) == nv(G₂) "spectral distance not defined for |G₁| != |G₂|"
    spectral_distance(G₁, G₂, nv(G₁))
end
