const SimpleGraphEdge = SimpleEdge

"""
    SimpleGraph{T}

A type representing an undirected graph.
"""
mutable struct SimpleGraph{T<:Integer} <: AbstractSimpleGraph{T}
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
end

eltype(x::SimpleGraph{T}) where T = T

# Graph{UInt8}(6), Graph{Int16}(7), Graph{UInt8}()
function SimpleGraph{T}(n::Integer = 0) where T<:Integer
    fadjlist = [Vector{T}() for _ = one(T):n]
    return SimpleGraph{T}(0, fadjlist)
end

# SimpleGraph()
SimpleGraph() = SimpleGraph{Int}()

# SimpleGraph(6), SimpleGraph(0x5)
SimpleGraph(n::T) where T<:Integer = SimpleGraph{T}(n)

# SimpleGraph(UInt8)
SimpleGraph(::Type{T}) where T<:Integer = SimpleGraph{T}(zero(T))

# Graph{UInt8}(adjmx)
function SimpleGraph{T}(adjmx::AbstractMatrix) where T<:Integer
    dima, dimb = size(adjmx)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))
    issymmetric(adjmx) || throw(ArgumentError("Adjacency / distance matrices must be symmetric"))

    g = SimpleGraph(T(dima))
    @inbounds for i in findall(triu(adjmx).!=0)
        add_edge!(g, i[1], i[2])
    end
    return g
end

# converts Graph{Int} to Graph{Int32}
function SimpleGraph{T}(g::SimpleGraph) where T<:Integer
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    return SimpleGraph(ne(g), h_fadj)
end


# SimpleGraph(adjmx)
SimpleGraph(adjmx::AbstractMatrix) = SimpleGraph{Int}(adjmx)

# SimpleGraph(digraph)
function SimpleGraph(g::SimpleDiGraph)
    gnv = nv(g)
    edgect = 0
    newfadj = deepcopy(g.fadjlist)
    @inbounds for i in vertices(g)
        for j in badj(g, i)
            if (_insert_and_dedup!(newfadj[i], j))
                edgect += 2     # this is a new edge only in badjlist
            else
                edgect += 1     # this is an existing edge - we already have it
                if i == j
                    edgect += 1 # need to count self loops
                end
            end
        end
    end
    iseven(edgect) || throw(AssertionError("invalid edgect in graph creation - please file bug report"))
    return SimpleGraph(edgect ÷ 2, newfadj)
end

edgetype(::SimpleGraph{T}) where T<:Integer = SimpleGraphEdge{T}

"""
    badj(g::SimpleGraph[, v::Integer])

Return the backwards adjacency list of a graph. If `v` is specified,
return only the adjacency list for that vertex.

###Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
badj(g::SimpleGraph) = fadj(g)
badj(g::SimpleGraph, v::Integer) = fadj(g, v)


"""
    adj(g[, v])

Return the adjacency list of a graph. If `v` is specified, return only the
adjacency list for that vertex.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
adj(g::SimpleGraph) = fadj(g)
adj(g::SimpleGraph, v::Integer) = fadj(g, v)

copy(g::SimpleGraph) =  SimpleGraph(g.ne, deepcopy(g.fadjlist))

==(g::SimpleGraph, h::SimpleGraph) =
vertices(g) == vertices(h) &&
ne(g) == ne(h) &&
fadj(g) == fadj(h)


"""
    is_directed(g)

Return `true` if `g` is a directed graph.
"""
is_directed(::Type{SimpleGraph}) = false
is_directed(::Type{SimpleGraph{T}}) where T = false
is_directed(g::SimpleGraph) = false

function has_edge(g::SimpleGraph, e::SimpleGraphEdge)
    u, v = Tuple(e)
    (u > nv(g) || v > nv(g)) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return insorted(v, fadj(g, u))
end

function add_edge!(g::SimpleGraph{T}, e::SimpleGraphEdge{T}) where T
    s, d = T.(Tuple(e))
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    if s != d
        inserted = _insert_and_dedup!(g.fadjlist[d], s)
    end
    return inserted
end

function rem_edge!(g::SimpleGraph, e::SimpleGraphEdge)
    i = searchsorted(g.fadjlist[src(e)], dst(e))
    isempty(i) && return false   # edge not in graph
    j = first(i)
    deleteat!(g.fadjlist[src(e)], j)
    if src(e) != dst(e)     # not a self loop
        j = searchsortedfirst(g.fadjlist[dst(e)], src(e))
        deleteat!(g.fadjlist[dst(e)], j)
    end
    g.ne -= 1
    return true # edge successfully removed
end


"""
    add_vertex!(g)

Add a new vertex to the graph `g`. Return `true` if addition was successful.
"""
function add_vertex!(g::SimpleGraph{T}) where T
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.fadjlist, Vector{T}())
    return true
end
