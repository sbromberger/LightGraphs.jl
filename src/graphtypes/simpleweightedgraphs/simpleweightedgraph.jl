const SimpleWeightedGraphEdge = SimpleWeightedEdge

"""
    SimpleWeightedGraph{T, U}

A type representing an undirected graph with weights of type `U`.
"""
mutable struct SimpleWeightedGraph{T<:Integer, U<:Real} <: AbstractSimpleWeightedGraph
    weights::SparseMatrixCSC{U, T} # indexed by [dst, src]
end

eltype(x::AbstractSimpleWeightedGraph) = eltype(rowvals(x.weights))
weighttype(x::AbstractSimpleWeightedGraph) = eltype(x.weights)
ne(g::SimpleWeightedGraph) = nnz(g.weights) ÷ 2

# Graph{UInt8}(6), Graph{Int16}(7), Graph{UInt8}()
function (::Type{SimpleWeightedGraph{T, U}})(n::Integer = 0) where T<:Integer where U<:Real
    weights = spzeros(U, T, T(n), T(n))
    return SimpleWeightedGraph{T, U}(weights)
end

# Graph()
SimpleWeightedGraph() = SimpleWeightedGraph{Int, Float64}()

# Graph(6), Graph(0x5)
SimpleWeightedGraph(n::T) where T<:Integer = SimpleWeightedGraph{T, Float64}(n)

# Graph(UInt8)
SimpleWeightedGraph(::Type{T}) where T<:Integer = SimpleWeightedGraph{T, Float64}(zero(T))

# Graph(UInt8, Float32)
SimpleWeightedGraph(::Type{T}, ::Type{U}) where T<:Integer where U<:Real = SimpleWeightedGraph{U, T}(zero(T))


# Graph{UInt8}(adjmx)
# function (::Type{SimpleWeightedGraph{T, U}})(adjmx::AbstractMatrix) where T<:Integer where U <: Real
#     dima,dimb = size(adjmx)
#     isequal(dima,dimb) || error("Adjacency / distance matrices must be square")
#     issymmetric(adjmx) || error("Adjacency / distance matrices must be symmetric")
#     g = SimpleWeightedGraph(U.(spones(adjmx)))
# end

# converts Graph{Int} to Graph{Int32}
# function (::Type{SimpleWeightedGraph{T, U}})(g::SimpleWeightedGraph) where T<:Integer where U<:Real
#     h_fadj = [Vector{T}(x) for x in fadj(g)]
#     return SimpleGraph(ne(g), h_fadj)
# end


# Graph(adjmx)
SimpleWeightedGraph(adjmx::AbstractMatrix) = SimpleWeightedGraph{Int, eltype(adjmx)}(adjmx)

# Graph(digraph). Weights will be added.
# TODO: uncomment this.
# SimpleWeightedGraph(g::SimpleWeightedDiGraph) = SimpleWeightedGraph(g.weights .+ g.weights')

edgetype(::SimpleWeightedGraph{T, U}) where T<:Integer where U<:Real= SimpleWeightedGraphEdge{T,U}

edges(g::SimpleWeightedGraph) = (SimpleWeightedEdge(x[1], x[2], x[3]) for x in zip(findnz(triu(g.weights))...))

"""
    badj(g::SimpleWeightedGraph[, v::Integer])

Return the backwards adjacency list of a graph. If `v` is specified,
return only the adjacency list for that vertex.

###Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
badj(g::SimpleWeightedGraph) = fadj(g)
badj(g::SimpleWeightedGraph, v::Integer) = fadj(g, v)


"""
    adj(g[, v])

Return the adjacency list of a graph. If `v` is specified, return only the
adjacency list for that vertex.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
adj(g::SimpleWeightedGraph) = fadj(g)
adj(g::SimpleWeightedGraph, v::Integer) = fadj(g, v)

copy(g::SimpleWeightedGraph) =  SimpleWeightedGraph(copy(g.weights))

==(g::SimpleWeightedGraph, h::SimpleWeightedGraph) = g.weights == h.weights


"""
    is_directed(g)

Return `true` if `g` is a directed graph.
"""
is_directed(::Type{SimpleWeightedGraph}) = false
is_directed(::Type{SimpleWeightedGraph{T, U}}) where T where U = false
is_directed(g::SimpleWeightedGraph) = false



# add_edge! will overwrite weights.
function add_edge!(g::SimpleWeightedGraph, e::SimpleWeightedGraphEdge)
    T = eltype(g)
    U = weighttype(g)
    s_, d_, w = Tuple(e)
    s = T(s_)
    d = T(d_)
    (s in vertices(g) && d in vertices(g)) || return false
    g.weights[d, s] = w
    g.weights[s, d] = w
    return true
end

function rem_edge!(g::SimpleWeightedGraph, e::SimpleWeightedGraphEdge)
    U = weighttype(g)
    g.weights[dst(e), src(e)] = zero(U)
    g.weights[src(e), dst(e)] = zero(U)
    return true
end
