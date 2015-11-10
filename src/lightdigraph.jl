"""A type representing a directed graph."""
type LightDiGraph <: DiGraph
    n::Int
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

######### BASE CONSTRUCTORS #########################
function LightDiGraph(n::Int)
    fadjlist = Vector{Vector{Int}}()
    badjlist = Vector{Vector{Int}}()
    for i = 1:n
        push!(badjlist, Vector{Int}())
        push!(fadjlist, Vector{Int}())
    end
    return LightDiGraph(n, Set{Edge}(), badjlist, fadjlist)
end

LightDiGraph() = LightDiGraph(0)

function LightDiGraph{T<:Real}(adjmx::SparseMatrixCSC{T})
    dima, dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = LightDiGraph(dima)
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

function LightDiGraph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = LightDiGraph(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

function LightDiGraph(g::Graph)
    h = DiGraph(nv(g))
    for e in edges(g)
        push!(h.edges,e)
        push!(h.edges,reverse(e))
    end
    h.fadjlist = copy(fadj(g))
    h.badjlist = copy(badj(g))
    return h
end

##################################################

edges(g::LightDiGraph) = g.edges

has_edge(g::LightDiGraph, e::Edge) = e in edges(g)

nv(g::LightDiGraph) = g.n
ne(g::LightDiGraph) = length(edges(g))

function add_vertex!(g::LightDiGraph)
    g.n = nv(g) + 1
    push!(g.badjlist, Vector{Int}())
    push!(g.fadjlist, Vector{Int}())

    return g.n
end

function add_edge!(g::LightDiGraph, e::Edge)
    has_edge(g,e) && error("Edge $e already in graph")
    (has_vertex(g,src(e)) && has_vertex(g,dst(e))) || throw(BoundsError())
    unsafe_add_edge!(g,e)
end

function unsafe_add_edge!(g::LightDiGraph, e::Edge)
    push!(g.fadjlist[src(e)], dst(e))
    push!(g.badjlist[dst(e)], src(e))
    push!(g.edges, e)
    return e
end

function rem_edge!(g::LightDiGraph, e::Edge)
    reve = reverse(e)
    has_edge(g,e) || error("Edge $e is not in graph")

    i = findfirst(g.fadjlist[src(e)], dst(e))
    deleteat!(g.fadjlist[src(e)], i)
    i = findfirst(g.badjlist[dst(e)], src(e))
    deleteat!(g.badjlist[dst(e)], i)
    return pop!(g.edges, e)
end

function copy(g::LightDiGraph)
    return LightDiGraph(g.n,copy(g.edges),deepcopy(g.fadjlist),deepcopy(g.badjlist))
end

fadj(g::LightDiGraph) = g.fadjlist
badj(g::LightDiGraph) = g.badjlist
