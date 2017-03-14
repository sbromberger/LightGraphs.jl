typealias SimpleDiGraphEdge SimpleEdge

"""A type representing a directed graph."""
type SimpleDiGraph <: AbstractSimpleGraph
    vertices::UnitRange{Int}
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

edgetype(::SimpleDiGraph) = SimpleDiGraphEdge

function SimpleDiGraph(n::Int)
    fadjlist = Vector{Vector{Int}}()
    badjlist = Vector{Vector{Int}}()
    for i = 1:n
        push!(badjlist, Vector{Int}())
        push!(fadjlist, Vector{Int}())
    end
    return SimpleDiGraph(1:n, 0, badjlist, fadjlist)
end

SimpleDiGraph() = SimpleDiGraph(0)

function SimpleDiGraph{T<:Real}(adjmx::SparseMatrixCSC{T})
    dima, dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = SimpleDiGraph(dima)
    maxc = length(adjmx.colptr)
    for c = 1:(maxc-1)
        for rind = adjmx.colptr[c]:adjmx.colptr[c+1]-1
            isnz = (adjmx.nzval[rind] != zero(T))
            if isnz
                r = adjmx.rowval[rind]
                add_edge!(g,r,c)
            end
        end
    end
    return g
end

function SimpleDiGraph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = SimpleDiGraph(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

function SimpleDiGraph(g::AbstractSimpleGraph)
    h = SimpleDiGraph(nv(g))
    h.ne = ne(g) * 2 - num_self_loops(g)
    h.fadjlist = deepcopy(fadj(g))
    h.badjlist = deepcopy(badj(g))
    return h
end

badj(g::SimpleDiGraph) = g.badjlist
badj(g::SimpleDiGraph, v::Int) = badj(g)[v]


function copy(g::SimpleDiGraph)
    return SimpleDiGraph(g.vertices, g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))
end

==(g::SimpleDiGraph, h::SimpleDiGraph) =
    vertices(g) == vertices(h) &&
    ne(g) == ne(h) &&
    fadj(g) == fadj(h) &&
    badj(g) == badj(h)

is_directed(g::SimpleDiGraph) = true
is_directed(::Type{SimpleDiGraph}) = true

function add_edge!(g::SimpleDiGraph, e::SimpleDiGraphEdge)
    s, d = Tuple(e)
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


function add_vertex!(g::SimpleDiGraph)
    g.vertices = 1:nv(g)+1
    push!(g.badjlist, Vector{Int}())
    push!(g.fadjlist, Vector{Int}())

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
