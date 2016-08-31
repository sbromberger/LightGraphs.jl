"""Returns a sparse boolean adjacency matrix for a graph, indexed by `[u, v]`
vertices. `true` values indicate an edge between `u` and `v`. Users may
specify a direction (`:in`, `:out`, or `:both` are currently supported; `:out`
is default for both directed and undirected graphs) and a data type for the
matrix (defaults to `Int`).

Note: This function is optimized for speed.
"""
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
    rowval = sizehint!(Vector{Int}(), nz)
    selfloops = Vector{Int}()
    for j in 1:n_v
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


"""Returns a sparse [Laplacian matrix](https://en.wikipedia.org/wiki/Laplacian_matrix)
for a graph `g`, indexed by `[u, v]` vertices. For undirected graphs, `dir`
defaults to `:out`; for directed graphs, `dir` defaults to `:both`. `T`
defaults to `Int` for both graph types.
"""
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

doc"""Returns the eigenvalues of the Laplacian matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use
`eigs(laplacian_matrix(g);  kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`laplacian_matrix`.
"""
laplacian_spectrum(g::Graph, dir::Symbol=:out, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))
laplacian_spectrum(g::DiGraph, dir::Symbol=:both, T::DataType=Int) = eigvals(full(laplacian_matrix(g, dir, T)))

doc"""Returns the eigenvalues of the adjacency matrix for a graph `g`, indexed
by vertex. Warning: Converts the matrix to dense with $nv^2$ memory usage. Use
`eigs(adjacency_matrix(g);kwargs...)` to compute some of the
eigenvalues/eigenvectors. Default values for `dir` and `T` are the same as
`adjacency_matrix`.
"""
adjacency_spectrum(g::Graph, dir::Symbol=:out, T::DataType=Int) = eigvals(full(adjacency_matrix(g, dir, T)))
adjacency_spectrum(g::DiGraph, dir::Symbol=:both, T::DataType=Int) = eigvals(full(adjacency_matrix(g, dir, T)))


"""Returns a sparse node-arc incidence matrix for a graph, indexed by
`[v, i]`, where `i` is in `1:ne(g)`, indexing an edge `e`. For
directed graphs, a value of `-1` indicates that `src(e) == v`, while a
value of `1` indicates that `dst(e) == v`. Otherwise, the value is
`0`. For undirected graphs, both entries are `1`.
"""
function incidence_matrix(g::SimpleGraph, T::DataType=Int)
    isdir = is_directed(g)
    n_v = nv(g)
    n_e = ne(g)
    nz = 2 * n_e

    # every col has the same 2 entries
    colpt = collect(1:2:(nz + 1))
    nzval = repmat([isdir ? -one(T) : one(T), one(T)], n_e)

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
Given two oriented edges i->j and k->l in g, the
non-backtraking matrix B is defined as

B[i->j, k->l] = δ(j,k)* (1 - δ(i,l))

returns a matrix B, and an edgemap storing the oriented edges' positions in B
"""
function non_backtracking_matrix(g::SimpleGraph)
    # idedgemap = Dict{Int, Edge}()
    edgeidmap = Dict{Edge, Int}()
    m = 0
    for e in edges(g)
        m += 1
        edgeidmap[e] = m
    end

    if !is_directed(g)
        for e in edges(g)
            m += 1
            edgeidmap[reverse(e)] = m
        end
    end

    B = zeros(Float64, m, m)

    for (e,u) in edgeidmap
        i, j = src(e), dst(e)
        for k in in_neighbors(g,i)
            k == j && continue
            v = edgeidmap[Edge(k, i)]
            B[v, u] = 1
        end
    end

    return B, edgeidmap
end

"""Nonbacktracking: a compact representation of the nonbacktracking operator

    g: the underlying graph
    edgeidmap: the association between oriented edges and index into the NBT matrix

The Nonbacktracking operator can be used for community detection.
This representation is compact in that it uses only ne(g) additional storage
and provides an implicit representation of the matrix B_g defined below.

Given two oriented edges i->j and k->l in g, the
non-backtraking matrix B is defined as

B[i->j, k->l] = δ(j,k)* (1 - δ(i,l))

This type is in the style of GraphMatrices.jl and supports the necessary operations
for computed eigenvectors and conducting linear solves.

Additionally the contract!(vertexspace, nbt, edgespace) method takes vectors represented in
the domain of B and represents them in the domain of the adjacency matrix of g.
"""
type Nonbacktracking{G}
    g::G
    edgeidmap::Dict{Edge,Int}
    m::Int
end

function Nonbacktracking(g::SimpleGraph)
    edgeidmap = Dict{Edge, Int}()
    m = 0
    for e in edges(g)
        m += 1
        edgeidmap[e] = m
    end
    if !is_directed(g)
        for e in edges(g)
            m += 1
            edgeidmap[reverse(e)] = m
        end
    end
    return Nonbacktracking(g, edgeidmap, m)
end

size(nbt::Nonbacktracking) = (nbt.m,nbt.m)
eltype(nbt::Nonbacktracking) = Float64
issymmetric(nbt::Nonbacktracking) = false

function *{G, T<:Number}(nbt::Nonbacktracking{G}, x::Vector{T})
    length(x) == nbt.m || error("dimension mismatch")
    y = zeros(T, length(x))
    for (e,u) in nbt.edgeidmap
        i, j = src(e), dst(e)
        for k in in_neighbors(nbt.g,i)
            k == j && continue
            v = nbt.edgeidmap[Edge(k, i)]
            y[v] += x[u]
        end
    end
    return y
end

function coo_sparse(nbt::Nonbacktracking)
    m = nbt.m
    #= I,J = zeros(Int, m), zeros(Int, m) =#
    I,J = zeros(Int, 0), zeros(Int, 0)
    for (e,u) in nbt.edgeidmap
        i, j = src(e), dst(e)
        for k in in_neighbors(nbt.g,i)
            k == j && continue
            v = nbt.edgeidmap[Edge(k, i)]
            #= J[u] = v =#
            #= I[u] = u =#
            push!(I, v)
            push!(J, u)
        end
    end
    return I,J,1.0
end

sparse(nbt::Nonbacktracking) = sparse(coo_sparse(nbt)..., nbt.m,nbt.m)

function *{G, T<:Number}(nbt::Nonbacktracking{G}, x::AbstractMatrix{T})
    y = zeros(x)
    for i in 1:nbt.m
        y[:,i] = nbt * x[:,i]
    end
    return y
end

"""contract!(vertexspace, nbt, edgespace) in place version of
contract(nbt, edgespace). modifies first argument
"""
function contract!(vertexspace::Vector, nbt::Nonbacktracking, edgespace::Vector)
    for i=1:nv(nbt.g)
        for j in neighbors(nbt.g, i)
            u = nbt.edgeidmap[i > j ? Edge(j,i) : Edge(i,j)]
            vertexspace[i] += edgespace[u]
        end
    end
end

"""contract(nbt, edgespace)
Integrates out the edges by summing over the edges incident to each vertex.
"""
function contract(nbt::Nonbacktracking, edgespace::Vector)
    y = zeros(eltype(edgespace), nv(nbt.g))
    contract!(y,nbt,edgespace)
    return y
end
