const SimpleGraphEdge = SimpleEdge

"""
    SimpleGraph{T}

A type representing an undirected graph.
"""
mutable struct SimpleGraph{T<:Integer} <: AbstractSimpleGraph
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
end

eltype(x::SimpleGraph{T}) where T<:Integer = T

# Graph{UInt8}(6), Graph{Int16}(7), Graph{UInt8}()
function (::Type{SimpleGraph{T}})(n::Integer = 0) where T<:Integer
    fadjlist = [Vector{T}() for _ = one(T):n]
    return SimpleGraph{T}(0, fadjlist)
end

# Graph()
SimpleGraph() = SimpleGraph{Int}()

# Graph(6), Graph(0x5)
SimpleGraph(n::T) where T<:Integer = SimpleGraph{T}(n)

# SimpleGraph(UInt8)
SimpleGraph(::Type{T}) where T<:Integer = SimpleGraph{T}(zero(T))

# Graph{UInt8}(adjmx)
function (::Type{SimpleGraph{T}})(adjmx::AbstractMatrix) where T<:Integer
    dima, dimb = size(adjmx)
    isequal(dima, dimb) || error("Adjacency / distance matrices must be square")
    issymmetric(adjmx) || error("Adjacency / distance matrices must be symmetric")

    g = SimpleGraph(T(dima))
    for i in find(triu(adjmx))
        ind = ind2sub((dima, dimb), i)
        add_edge!(g, ind...)
    end
    return g
end

# converts Graph{Int} to Graph{Int32}
function (::Type{SimpleGraph{T}})(g::SimpleGraph) where T<:Integer
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    return SimpleGraph(ne(g), h_fadj)
end


# Graph(adjmx)
SimpleGraph(adjmx::AbstractMatrix) = SimpleGraph{Int}(adjmx)

# Graph(digraph)
function SimpleGraph(g::SimpleDiGraph)
    gnv = nv(g)
    edgect = 0
    newfadj = deepcopy(g.fadjlist)
    for i in vertices(g)
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

function add_edge!(g::SimpleGraph, e::SimpleGraphEdge)
    T = eltype(g)
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

function add_edges!(g::SimpleGraph, es)
    T = eltype(g)
    nvnew = nvold = nv(g)
    touched = falses(nvold)
    neold = ne(g)
    for e in es
        s, d = T.(Tuple(e))
        if s < 1 || d < 1
            error("Nonpositive vertex number")
        end
        for v in (s, d)
            if v > nvnew
                resize!(g.fadjlist, v)
                for i in nvnew+1:v
                    g.fadjlist[i] = Vector{T}()
                end
                nvnew = v
            elseif v <= nvold 
                touched[v] = true
            end
        end
        append!(g.fadjlist[s], d)
        s != d && append!(g.fadjlist[d], s)
    end
    k = 0
    for s in 1:nvold
        if touched[s]
            sort!(g.fadjlist[s])
            uniquesorted!(g.fadjlist[s])
        end
        k += length(g.fadjlist[s])
        if insorted(s, g.fadjlist[s])
            k += 1
        end
    end
    for s in nvold+1:nvnew
        sort!(g.fadjlist[s])
        uniquesorted!(g.fadjlist[s])
        k += length(g.fadjlist[s])
        if insorted(s, g.fadjlist[s])
            k += 1
        end
    end
    g.ne = k ÷ 2
    return g.ne > neold
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
function add_vertex!(g::SimpleGraph)
    T = eltype(g)
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.fadjlist, Vector{T}())
    return true
end
