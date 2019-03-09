import Base: size
"""
    non_backtracking_matrix(g)

Return a non-backtracking matrix `B` and an edgemap storing the oriented
edges' positions in `B`.

Given two arcs ``A_{i j}` and `A_{k l}` in `g`, the
non-backtracking matrix ``B`` is defined as

``B_{A_{i j}, A_{k l}} = δ_{j k} * (1 - δ_{i l})``
"""
function non_backtracking_matrix(g::AbstractGraph)
    # idedgemap = Dict{Int,Edge}()
    edgeidmap = Dict{Edge,Int}()
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

    for (e, u) in edgeidmap
        i, j = src(e), dst(e)
        for k in inneighbors(g, i)
            k == j && continue
            v = edgeidmap[Edge(k, i)]
            B[v, u] = 1
        end
    end

    return B, edgeidmap
end

"""
    Nonbacktracking{G}

A compact representation of the nonbacktracking operator.

The Nonbacktracking operator can be used for community detection.
This representation is compact in that it uses only ne(g) additional storage
and provides an implicit representation of the matrix B_g defined below.

Given two arcs ``A_{i j}` and `A_{k l}` in `g`, the
non-backtraking matrix ``B`` is defined as

``B_{A_{i j}, A_{k l}} = δ_{j k} * (1 - δ_{i l})``

This type is in the style of GraphMatrices.jl and supports the necessary operations
for computed eigenvectors and conducting linear solves.

Additionally the `contract!(vertexspace, nbt, edgespace)` method takes vectors
represented in the domain of ``B`` and represents them in the domain of the
adjacency matrix of `g`.
"""
struct Nonbacktracking{G <: AbstractGraph}
    g::G
    edgeidmap::Dict{Edge,Int}
    m::Int
end

function Nonbacktracking(g::AbstractGraph)
    edgeidmap = Dict{Edge,Int}()
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

size(nbt::Nonbacktracking) = (nbt.m, nbt.m)
size(nbt::Nonbacktracking, i::Number) = size(nbt)[i]
eltype(nbt::Nonbacktracking) = Float64
issymmetric(nbt::Nonbacktracking) = false

function *(nbt::Nonbacktracking, x::Vector{T}) where T <: Number
    length(x) == nbt.m || error("dimension mismatch")
    y = zeros(T, length(x))
    for (e, u) in nbt.edgeidmap
        i, j = src(e), dst(e)
        for k in inneighbors(nbt.g, i)
            k == j && continue
            v = nbt.edgeidmap[Edge(k, i)]
            y[v] += x[u]
        end
    end
    return y
end
function mul!(C, nbt::Nonbacktracking, B)
    # computs C = A * B
    for i in 1:size(B, 2)
        C[:, i] = nbt * B[:, i]
    end
    return C
end

function coo_sparse(nbt::Nonbacktracking)
    m = nbt.m
    #= I,J = zeros(Int, m), zeros(Int, m) =#
    I, J = zeros(Int, 0), zeros(Int, 0)
    for (e, u) in nbt.edgeidmap
        i, j = src(e), dst(e)
        for k in inneighbors(nbt.g, i)
            k == j && continue
            v = nbt.edgeidmap[Edge(k, i)]
            #= J[u] = v =#
            #= I[u] = u =#
            push!(I, v)
            push!(J, u)
        end
    end
    return I, J, 1.0
end

sparse(nbt::Nonbacktracking) = sparse(coo_sparse(nbt)..., nbt.m, nbt.m)

function *(nbt::Nonbacktracking, x::AbstractMatrix)
    y = zero(x)
    for i in 1:nbt.m
        y[:, i] = nbt * x[:, i]
    end
    return y
end

"""
    contract!(vertexspace, nbt, edgespace)

The mutating version of `contract(nbt, edgespace)`. Modifies `vertexspace`.
"""
function contract!(vertexspace::Vector, nbt::Nonbacktracking, edgespace::Vector)
    T = eltype(nbt.g)
    for i = one(T):nv(nbt.g), j in neighbors(nbt.g, i)
        u = nbt.edgeidmap[i > j ? Edge(j, i) : Edge(i, j)]
        vertexspace[i] += edgespace[u]
    end
end

#TODO: documentation needs work. sbromberger 20170326
"""
    contract(nbt, edgespace)

Integrate out the edges by summing over the edges incident to each vertex.
"""
function contract(nbt::Nonbacktracking, edgespace::Vector)
    y = zeros(eltype(edgespace), nv(nbt.g))
    contract!(y, nbt, edgespace)
    return y
end
