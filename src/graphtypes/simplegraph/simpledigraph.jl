const SimpleDiGraphEdge = SimpleEdge

"""A type representing a directed graph."""
mutable struct SimpleDiGraph{T<:Integer} <: AbstractSimpleGraph
    vertices::UnitRange{T}
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{T}} # [dst]: (src, src, src)
end

eltype{T<:Integer}(x::SimpleDiGraph{T}) = T


# DiGraph{UInt8}(6), DiGraph{Int16}(7), DiGraph{Int8}()
function (::Type{SimpleDiGraph{T}}){T<:Integer}(n::Integer = 0)
    fadjlist = Vector{Vector{T}}()
    badjlist = Vector{Vector{T}}()
    for _ = one(T):n
        push!(badjlist, Vector{T}())
        push!(fadjlist, Vector{T}())
    end
    vertices = one(T):T(n)
    return SimpleDiGraph(vertices, 0, fadjlist, badjlist)
end

# DiGraph()
SimpleDiGraph() = SimpleDiGraph{Int}()

# DiGraph(6), DiGraph(0x5)
SimpleDiGraph{T<:Integer}(n::T) = SimpleDiGraph{T}(n)

# SimpleDiGraph(UInt8)
SimpleDiGraph{T<:Integer}(::Type{T}) = SimpleDiGraph{T}(zero(T))

# sparse adjacency matrix constructor: DiGraph(adjmx)
function (::Type{SimpleDiGraph{T}}){T<:Integer, U}(adjmx::SparseMatrixCSC{U})
    dima, dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = SimpleDiGraph(T(dima))
    maxc = length(adjmx.colptr)
    for c = 1:(maxc-1)
        for rind = adjmx.colptr[c]:adjmx.colptr[c+1]-1
            isnz = (adjmx.nzval[rind] != zero(U))
            if isnz
                r = adjmx.rowval[rind]
                add_edge!(g,r,c)
            end
        end
    end
    return g
end

# dense adjacency matrix constructor: DiGraph{UInt8}(adjmx)
function (::Type{SimpleDiGraph{T}}){T<:Integer}(adjmx::AbstractMatrix)
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = SimpleDiGraph(T(dima))
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

# DiGraph(adjmx)
SimpleDiGraph(adjmx::AbstractMatrix) = SimpleDiGraph{Int}(adjmx)

# converts DiGraph{Int} to DiGraph{Int32}
function (::Type{SimpleDiGraph{T}}){T<:Integer}(g::SimpleDiGraph)
    h_vertices = one(T):T(nv(g))
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    h_badj = [Vector{T}(x) for x in badj(g)]
    return SimpleDiGraph(h_vertices, ne(g), h_fadj, h_badj)
end


# constructor from abstract graph: DiGraph(graph)
function SimpleDiGraph(g::AbstractSimpleGraph)
    h = SimpleDiGraph(nv(g))
    h.ne = ne(g) * 2 - num_self_loops(g)
    h.fadjlist = deepcopy(fadj(g))
    h.badjlist = deepcopy(badj(g))
    return h
end

edgetype{T<:Integer}(::SimpleDiGraph{T}) = SimpleGraphEdge{T}


badj(g::SimpleDiGraph) = g.badjlist
badj(g::SimpleDiGraph, v::Integer) = badj(g)[v]


copy{T<:Integer}(g::SimpleDiGraph{T}) =
SimpleDiGraph{T}(g.vertices, g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))


==(g::SimpleDiGraph, h::SimpleDiGraph) =
vertices(g) == vertices(h) &&
ne(g) == ne(h) &&
fadj(g) == fadj(h) &&
badj(g) == badj(h)

is_directed(g::SimpleDiGraph) = true
is_directed(::Type{SimpleDiGraph}) = true
is_directed{T}(::Type{SimpleDiGraph{T}}) = true

function add_edge!(g::SimpleDiGraph, e::SimpleDiGraphEdge)
    T = eltype(g)
    s, d = T.(Tuple(e))
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    return inserted && _insert_and_dedup!(g.badjlist[d], s)
end


function rem_edge!(g::SimpleDiGraph, e::SimpleDiGraphEdge)
    has_edge(g,e) || return false
    i = searchsorted(g.fadjlist[src(e)], dst(e))[1]
    deleteat!(g.fadjlist[src(e)], i)
    i = searchsorted(g.badjlist[dst(e)], src(e))[1]
    deleteat!(g.badjlist[dst(e)], i)
    g.ne -= 1
    return true
end


function add_vertex!{T<:Integer}(g::SimpleDiGraph{T})
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    g.vertices = 1:nv(g)+1
    push!(g.badjlist, Vector{T}())
    push!(g.fadjlist, Vector{T}())

    return true
end


function has_edge(g::SimpleDiGraph, e::SimpleDiGraphEdge)
    u, v = Tuple(e)
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) < degree(g,v)
        return length(searchsorted(fadj(g,u), v)) > 0
    else
        return length(searchsorted(badj(g,v), u)) > 0
    end
end

empty{T<:Integer}(g::SimpleDiGraph{T}) = SimpleDiGraph{T}()
