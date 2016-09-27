export non_backtracking_matrix,
        Nonbacktracking,
        contract!,
        contract

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
