"""A type representing an undirected graph."""
type LightGraph <: Graph
    n::Int
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
end

######### BASE CONSTRUCTORS #########################
function LightGraph(n::Int)
    fadjlist = Vector{Vector{Int}}()
    sizehint!(fadjlist,n)
    for i = 1:n
        push!(fadjlist, Vector{Int}())
    end
    return LightGraph(n, Set{Edge}(), fadjlist)
end

LightGraph() = LightGraph(0)

function LightGraph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")
    issym(adjmx) || error("Adjacency / distance matrices must be symmetric")

    g = LightGraph(dima)
    for i in find(triu(adjmx))
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

function LightGraph(g::DiGraph)
    h = LightGraph(nv(g))

    for e in edges(g)
        if !has_edge(h, e)
            unsafe_add_edge!(h, e)
        end
    end
    return h
end
############################################

has_edge(g::LightGraph, e::Edge) = (e in edges(g)) || (reverse(e) in edges(g))
edges(g::LightGraph) = g.edges

nv(g::LightGraph) = g.n
ne(g::LightGraph) = length(edges(g))

function add_vertex!(g::LightGraph)
    g.n += 1
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end

function add_edge!(g::SimpleGraph, e::Edge)
    has_edge(g,e) && error("Edge $e already in graph")
    (has_vertex(g,src(e)) && has_vertex(g,dst(e))) || throw(BoundsError())
    unsafe_add_edge!(g,e)
end

function unsafe_add_edge!(g::Graph, e::Edge)
    push!(g.fadjlist[src(e)], dst(e))
    if src(e) != dst(e)
        push!(g.fadjlist[dst(e)], src(e))
    end
    push!(g.edges, e)
    return e
end

function rem_edge!(g::Graph, e::Edge)
    if !(e in edges(g))
        reve = reverse(e)
        (reve in edges(g)) || error("Edge $e is not in graph")
        e = reve
    end

    i = findfirst(g.fadjlist[src(e)], dst(e))
    _swapnpop!(g.fadjlist[src(e)], i)
    if src(e) != dst(e)     # not a self loop
        i = findfirst(g.fadjlist[dst(e)], src(e))
        _swapnpop!(g.fadjlist[dst(e)], i)
    end
    return pop!(g.edges, e)
end

function copy(g::LightGraph)
    return LightGraph(g.n,copy(g.edges),deepcopy(g.fadjlist))
end

fadj(g::LightGraph) = g.fadjlist
badj(g::LightGraph) = fadj(g)
